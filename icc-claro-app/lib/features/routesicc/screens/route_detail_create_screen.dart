// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icc_claro_app/core/widgets/custom_autocomplete.dart';
import 'package:icc_claro_app/core/widgets/custom_text_field.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/dropdown_data_loader.dart';
import 'package:icc_claro_app/features/routesicc/models/route_model.dart';
import 'package:icc_claro_app/features/routesicc/repository/route_state.dart';
import 'package:provider/provider.dart';

class RouteDetailCreateScreen extends StatefulWidget {
  final RouteModel? route;

  const RouteDetailCreateScreen({super.key, this.route});

  @override
  _RouteDetailScreenToEditState createState() =>
      _RouteDetailScreenToEditState();
}

class _RouteDetailScreenToEditState extends State<RouteDetailCreateScreen> {
  bool _isLoadingLocation = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dropdownDataLoader =
          Provider.of<DropdownDataLoader>(context, listen: false);

      final routeStateHandler =
          Provider.of<RouteStateHandler>(context, listen: false);

      await dropdownDataLoader.loadDropdownData(context);

      routeStateHandler.resetForm(context);

      if (widget.route == null) {
      } else {
        routeStateHandler.posDescriptions = dropdownDataLoader.posDescriptions;
        routeStateHandler.initControllers(widget.route!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          "Crear nuevo Punto de Venta",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(children: [
        Container(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          color: Colors.black.withOpacity(1),
          child: Consumer<RouteStateHandler>(
            builder: (context, routeState, child) {
              return Consumer<DropdownDataLoader>(
                builder: (context, dropdownData, child) {
                  if (dropdownData.isLoading) {
                    return const SizedBox.shrink();
                  }
                  if (dropdownData.errorMessage.isNotEmpty) {
                    return Center(child: Text(dropdownData.errorMessage));
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _spacing(),
                        CustomTextField(
                          controller: routeState.nombreController,
                          label: 'Nombre',
                          icon: Icons.person_add,
                          inputFormatters: [CapitalizeTextInputFormatter()],
                        ),
                        _buildDropdown(
                          label: 'Descripción de Ubicación',
                          value: routeState.selectedPosDesc,
                          items:
                              dropdownData.posDescriptions.map((description) {
                            return DropdownMenuItem<String>(
                              value: description['lovId'].toString(),
                              child: Text(description['lovDescription']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            routeState.updatePosDesc(value);
                          },
                        ),
                        _buildDropdown(
                          label: 'Tipo',
                          value: routeState.selectedPosType,
                          items: dropdownData.posTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['lovId'].toString(),
                              child: Text(type['lovDescription']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            routeState.updatePosType(value);
                          },
                        ),
                        _buildDropdown(
                          label: 'Operador',
                          value: routeState.selectedOperator,
                          items: dropdownData.operadores.map((operator) {
                            return DropdownMenuItem<String>(
                              value: operator['lovId'].toString(),
                              child: Text(operator['lovDescription']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            routeState.updateOperator(value);
                          },
                        ),
                        _buildDropdown(
                          label: 'Canal',
                          value: routeState.selectedPosChannel,
                          items: dropdownData.posChannel.map((channel) {
                            return DropdownMenuItem<String>(
                              value: channel['lovId'].toString(),
                              child: Text(channel['lovDescription']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            routeState.updatePosChannel(value);
                          },
                        ),
                        CustomTextField(
                          controller: routeState.addressController,
                          label: 'Dirección',
                          icon: Icons.add_home,
                          inputFormatters: [CapitalizeTextInputFormatter()],
                        ),
                        _buildDropdown(
                          label: 'Pueblo',
                          value: routeState.selectedPosTowns,
                          items: dropdownData.posTowns.map((town) {
                            return DropdownMenuItem<String>(
                              value: town['zoneTown'],
                              child: Text(town['zoneTown']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              routeState.selectedPosTowns = value;
                              final selectedTown =
                                  dropdownData.posTowns.firstWhere(
                                (town) => town['zoneTown'] == value,
                              );
                              routeState.selectedPosZones =
                                  selectedTown['zone'];
                              routeState.selectedPosZoneDesc =
                                  selectedTown['zoneDesc'];
                              routeState.fetchTownDemographic(value!);
                            });
                          },
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                              text: routeState.selectedPosZoneDesc ?? ''),
                          label: 'Zona',
                          icon: Icons.location_city,
                          isNumber: false,
                          readOnly: true,
                        ),
                        CustomTextField(
                          controller: routeState.townDemographicController,
                          label: 'Demográficos',
                          icon: Icons.numbers,
                          readOnly: true,
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_isLoadingLocation) return;

                              setState(() {
                                _isLoadingLocation = true;
                              });

                              await _getCurrentLocation(routeState);

                              setState(() {
                                _isLoadingLocation = false;
                              });
                            },
                            icon: const Icon(Icons.my_location),
                            label: const Text("Detectar mi ubicación"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFFb60000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                          ),
                        ),
                        _buildLatLonFields(routeState),
                        CustomTextField(
                          controller: routeState.marketShareController,
                          label: 'Puntuación',
                          icon: Icons.percent,
                          readOnly: true,
                        ),
                        CustomAutocomplete(
                          label: 'Gerente',
                          icon: Icons.person,
                          controller: routeState.allUsersController,
                          options: routeState.filteredAllUsers
                              .where(
                                  (user) => user != routeState.selectedGerente)
                              .toList(),
                          onOptionSelected: (String value) {
                            routeState.updateSelectedGerente(value);
                          },
                          onTextChanged: routeState.fetchAllUsers,
                        ),
                        CustomAutocomplete(
                          label: 'Asistente',
                          icon: Icons.person,
                          controller: routeState.allUsersController,
                          options: routeState.filteredAllUsers
                              .where((user) =>
                                  user != routeState.selectedAsistente)
                              .toList(),
                          onOptionSelected: (String value) {
                            routeState.updateSelectedAsistente(value);
                          },
                          onTextChanged: routeState.fetchAllUsers,
                        ),
                        CustomAutocomplete(
                          label: 'Código de Agente',
                          icon: Icons.qr_code,
                          controller: routeState.agentCodeController,
                          options: routeState.filteredAgentCodes,
                          onOptionSelected: (String value) {
                            routeState.selectedAgentCode = value;
                          },
                          onTextChanged: routeState.fetchAgentCodes,
                        ),
                        CustomAutocomplete(
                          label: 'Código de Localidad',
                          icon: Icons.qr_code,
                          controller: routeState.locationCodeController,
                          options: routeState.filteredLocationCodes,
                          onOptionSelected: (String value) {
                            routeState.selectedPosRmsLocations = value;
                          },
                          onTextChanged: routeState.fetchLocationCodes,
                        ),
                        const SizedBox(height: 200),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Consumer<DropdownDataLoader>(
          builder: (context, dropdownData, child) {
            if (dropdownData.isLoading) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(child: LoadingProgress()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Consumer<RouteStateHandler>(
          builder: (context, routeStateHandler, _) {
            if (routeStateHandler.isSubmitting) {
              return Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(child: LoadingProgress()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final routeStateHandler =
              Provider.of<RouteStateHandler>(context, listen: false);
          if (routeStateHandler.validateForm()) {
            routeStateHandler.submitForm(context, route: widget.route);
          } else {
            routeStateHandler.showErrorDialog(
              context,
              "Por favor, completa todos los campos antes de enviar",
            );
          }
        },
        backgroundColor: const Color(0xFFb60000),
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  Future<void> _getCurrentLocation(RouteStateHandler routeState) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    routeState.latController.text = position.latitude.toString();
    routeState.lonController.text = position.longitude.toString();
  }

  Widget _spacing() {
    return const SizedBox(height: 10);
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    double height = 30.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: SizedBox(
            height: height,
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF005954).withOpacity(0.9),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              hint: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class CapitalizeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word.toUpperCase();
      }
      return word;
    }).join(' ');

    return newValue.copyWith(
      text: capitalizedWords,
      selection: newValue.selection,
    );
  }
}

Widget _buildLatLonFields(RouteStateHandler routeState) {
  return Row(
    children: [
      Expanded(
        child: CustomTextField(
          controller: routeState.latController,
          label: 'Lat',
          icon: Icons.location_on,
          inputAction: TextInputAction.next,
          enableInteractiveSelection: true,
          onChanged: (value) {
            final parts = value.split(',');
            if (parts.length == 2) {
              routeState.latController.text = parts[0].trim();
              routeState.lonController.text = parts[1].trim();
            }
          },
        ),
      ),
      const SizedBox(width: 3),
      Expanded(
        child: CustomTextField(
          controller: routeState.lonController,
          label: 'Lon',
          icon: Icons.location_on,
          inputAction: TextInputAction.done,
          enableInteractiveSelection: true,
        ),
      ),
    ],
  );
}

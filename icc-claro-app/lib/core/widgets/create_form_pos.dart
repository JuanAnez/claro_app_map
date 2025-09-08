// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, invalid_use_of_visible_for_testing_member,, use_super_parameters
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/custom_autocomplete.dart';
import 'package:icc_claro_app/core/widgets/custom_text_field.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/dropdown_data_loader.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/form_state.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class CreateFormPos extends StatefulWidget {
  const CreateFormPos({super.key});

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateFormPos> {
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropdownDataLoader =
          Provider.of<DropdownDataLoader>(context, listen: false);
      dropdownDataLoader.loadDropdownData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Crear Punto de Venta',
          style: TextStyle(color: Colors.white),
        ),
        // Image.asset(
        //   'assets/images/icc_claro_appbar.png',
        //   height: 30,
        // ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey.shade500),
      ),
      body: Stack(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
            color: Colors.black.withOpacity(1),
            child: Consumer<FormStateHandler>(
              builder: (context, formState, child) {
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
                          CustomTextField(
                            controller: formState.nombreController,
                            label: 'Nombre',
                            icon: Icons.person_add,
                            inputFormatters: [CapitalizeTextInputFormatter()],
                          ),
                          CustomTextField(
                            controller: formState.desciptionController,
                            label: 'Descripción de Localidad',
                            icon: Icons.description,
                            inputFormatters: [CapitalizeTextInputFormatter()],
                          ),
                          _buildDropdown(
                            label: 'Descripción de Ubicación',
                            value: formState.selectedPosDesc,
                            items:
                                dropdownData.posDescriptions.map((description) {
                              return DropdownMenuItem<String>(
                                value: description['lovId'].toString(),
                                child: Text(description['lovDescription']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formState.updatePosDesc(value);
                            },
                          ),
                          _buildDropdown(
                            label: 'Tipo',
                            value: formState.selectedPosType,
                            items: dropdownData.posTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['lovId'].toString(),
                                child: Text(type['lovDescription']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formState.updatePosType(value);
                            },
                          ),
                          _buildDropdown(
                            label: 'Operador',
                            value: formState.selectedOperator,
                            items: dropdownData.operadores.map((operator) {
                              return DropdownMenuItem<String>(
                                value: operator['lovId'].toString(),
                                child: Text(operator['lovDescription']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formState.updateOperator(value);
                            },
                          ),
                          CustomTextField(
                            controller: formState.marketShareController,
                            label: 'Puntuación',
                            icon: Icons.percent,
                            readOnly: true,
                          ),
                          _buildDropdown(
                            label: 'Canal',
                            value: formState.selectedPosChannel,
                            items: dropdownData.posChannel.map((channel) {
                              return DropdownMenuItem<String>(
                                value: channel['lovId'].toString(),
                                child: Text(channel['lovDescription']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formState.updatePosChannel(value);
                            },
                          ),
                          CustomTextField(
                            controller: formState.addressController,
                            label: 'Dirección',
                            icon: Icons.add_home,
                            inputFormatters: [CapitalizeTextInputFormatter()],
                          ),
                          _buildDropdown(
                            label: 'Pueblo',
                            value: formState.selectedPosTowns,
                            items: dropdownData.posTowns.map((town) {
                              return DropdownMenuItem<String>(
                                value: town['zoneTown'],
                                child: Text(town['zoneTown']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                formState.selectedPosTowns = value;
                                final selectedTown =
                                    dropdownData.posTowns.firstWhere(
                                  (town) => town['zoneTown'] == value,
                                );
                                formState.selectedPosZones =
                                    selectedTown['zone'];
                                formState.selectedPosZoneDesc =
                                    selectedTown['zoneDesc'];
                                formState.fetchTownDemographic(value!);
                              });
                            },
                          ),
                          CustomTextField(
                            controller: formState.townDemographicController,
                            label: 'Demográficos',
                            icon: Icons.numbers,
                            readOnly: true,
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                                text: formState.selectedPosZoneDesc ?? ''),
                            label: 'Zona',
                            icon: Icons.location_city,
                            isNumber: false,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_isLoadingLocation) return;

                                setState(() {
                                  _isLoadingLocation = true;
                                });

                                await _getCurrentLocation(formState);

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
                          _buildLatLonFields(formState),
                          const SizedBox(height: 16),
                          CustomAutocomplete(
                            label: 'Gerente',
                            icon: Icons.person,
                            controller: formState.allUsersController,
                            options: formState.filteredAllUsers
                                .where((user) =>
                                    user != formState.selectedAsistente)
                                .toList(),
                            onOptionSelected: (String value) {
                              formState.updateSelectedGerente(value);
                            },
                            onTextChanged: formState.fetchAllUsers,
                          ),
                          CustomAutocomplete(
                            label: 'Asistente',
                            icon: Icons.person,
                            controller: formState.allUsersController,
                            options: formState.filteredAllUsers
                                .where(
                                    (user) => user != formState.selectedGerente)
                                .toList(),
                            onOptionSelected: (String value) {
                              formState.updateSelectedAsistente(value);
                            },
                            onTextChanged: formState.fetchAllUsers,
                          ),
                          CustomAutocomplete(
                            label: 'Código de Agente',
                            icon: Icons.qr_code,
                            controller: formState.agentCodeController,
                            options: formState.filteredAgentCodes,
                            onOptionSelected: (String value) {
                              formState.selectedAgentCode = value;
                            },
                            onTextChanged: formState.fetchAgentCodes,
                          ),
                          CustomAutocomplete(
                            label: 'Código de Agente (Fijo)',
                            icon: Icons.qr_code,
                            controller: formState.fixedAgentCodesController,
                            options: formState.filteredFixedAgentCodes,
                            onOptionSelected: (String value) {
                              formState.selectedFixedAgentCodes = value;
                            },
                            onTextChanged: formState.fetchFixedAgentCodes,
                          ),
                          CustomAutocomplete(
                            label: 'Código de Localidad',
                            icon: Icons.qr_code,
                            controller: formState.locationCodeController,
                            options: formState.filteredLocationCodes,
                            onOptionSelected: (String value) {
                              formState.selectedPosRmsLocations = value;
                            },
                            onTextChanged: formState.fetchLocationCodes,
                          ),
                          _buildEditableDropdown(
                            label: 'Estatus de Localidad',
                            controller: formState.locStatusController,
                            options: formState.locStatus,
                            icon: Icons.qr_code,
                            onOptionSelected: (String value) {
                              formState.selectedStatus = value;
                            },
                            onTextChanged: (value) {
                              formState.loadLocStatus(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Consumer<FormStateHandler>(
                              builder: (context, formState, child) {
                                return ElevatedButton(
                                  onPressed: () {
                                    if (formState.validateForm()) {
                                      formState.submitForm(context);
                                    } else {
                                      formState.showErrorDialog(context,
                                          "Por favor, completa todos los campos antes de enviar");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFFb60000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                  ),
                                  child: const Text(
                                    'Añadir Punto de Venta',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<FormStateHandler>(
            builder: (context, formState, child) {
              if (formState.isSubmitting) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildEditableDropdown({
    required String label,
    required TextEditingController controller,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String> onOptionSelected,
    required ValueChanged<String> onTextChanged,
    double height = 35.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          border: const OutlineInputBorder(),
        ),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onTextChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ),
              IconButton(
                icon: Icon(icon, color: const Color(0xFFb60000)),
                onPressed: () async {
                  final selected = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        backgroundColor:
                            const Color(0xFF005954).withOpacity(0.9),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options.map((option) {
                              return ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onTap: () {
                                  Navigator.pop(context, option);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );

                  if (selected != null) {
                    controller.text = selected;
                    onOptionSelected(selected);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatLonFields(FormStateHandler formState) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: formState.lonController,
            label: 'Lon',
            icon: Icons.location_on,
            inputType: const TextInputType.numberWithOptions(decimal: true),
            inputAction: TextInputAction.next,
            enableInteractiveSelection: true,
          ),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: CustomTextField(
            controller: formState.latController,
            label: 'Lat',
            icon: Icons.location_on,
            inputType: const TextInputType.numberWithOptions(decimal: true),
            inputAction: TextInputAction.done,
            enableInteractiveSelection: true,
          ),
        ),
      ],
    );
  }
}

Future<void> _getCurrentLocation(FormStateHandler formState) async {
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
  formState.latController.text = position.latitude.toString();
  formState.lonController.text = position.longitude.toString();
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

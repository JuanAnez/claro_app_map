// ignore_for_file: unused_local_variable
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icc_maps/data/form/form_state.dart';
import 'package:icc_maps/data/services/dropdown_data_loader.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class CreateFormMall extends StatefulWidget {
  const CreateFormMall({Key? key}) : super(key: key);

  @override
  State<CreateFormMall> createState() => _CreateFormMallState();
}

class _CreateFormMallState extends State<CreateFormMall> {
  bool _isLoadingLocation = false;
  List<PlatformFile>? selectedFiles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropdownDataLoader =
          Provider.of<DropdownDataLoader>(context, listen: false);
      dropdownDataLoader.loadDropdownData();
      dropdownDataLoader.fetchAllTowns();
    });
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles!.addAll(result.files);
      });
    } else {
      print("Selección cancelada");
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      selectedFiles!.remove(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: Image.asset(
            'assets/images/icc_claro_appbar.png',
            height: 30,
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.blueGrey.shade500),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Consumer<FormStateHandler>(
                builder: (context, formState, child) {
                  return Consumer<DropdownDataLoader>(
                    builder: (context, dropdownData, child) {
                      if (dropdownData.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                                                
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
                              controller: formState.descripcionController,
                              label: 'Descripción',
                              icon: Icons.add_box,
                              inputFormatters: [CapitalizeTextInputFormatter()],
                            ),
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
                            _buildDropdown(
                              label: 'Pueblo',
                              value: dropdownData.selectedPosTown,
                              items: dropdownData.allTowns.map((town) {
                                return DropdownMenuItem<String>(
                                  value: town['townName'],
                                  child: Text(town['townName']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  dropdownData.selectedPosTown = value;
                                  dropdownData.fetchAllLocations(value!);
                                });
                              },
                            ),
                            _buildMultiSelectField(dropdownData),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _selectFile,
                                icon: const Icon(Icons.attach_file),
                                label: const Text("Seleccionar archivo o foto"),
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
                            const SizedBox(height: 10),
                            if (selectedFiles!.isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: selectedFiles!.map((file) {
                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.white,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildFileThumbnail(file),
                                            Text(
                                              file.name,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () => _removeFile(file),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Text(
                                                  'X',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            Center(
                              child: Consumer<FormStateHandler>(
                                builder: (context, formState, child) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      if (!formState.isSubmittingMall) {
                                        formState.submitFormMall(
                                          context,
                                          dropdownData.selectedPosLocations,
                                          dropdownData.allTowns
                                              .firstWhere((town) =>
                                                  town['townName'] ==
                                                  dropdownData
                                                      .selectedPosTown)[
                                                  'townId']
                                              .toString(),
                                          selectedFiles ?? [],
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFFb60000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                    ),
                                    child: const Text(
                                      'Añadir Centro Comercial',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 25),
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
                if (formState.isSubmittingMall) {
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
        ));
  }

  Widget _buildMultiSelectField(DropdownDataLoader dropdownData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MultiSelectDialogField(
        checkColor: Colors.white,
        items: dropdownData.filteredLocations.map((location) {
          return MultiSelectItem<int>(
            location['posLocationId'],
            '${location['posLocationId']} - ${location['posLocationName']}',
          );
        }).toList(),
        initialValue: dropdownData.selectedPosLocations,
        title: const Text("Localidades"),
        selectedColor: const Color(0xFFb60000),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Colors.white38,
            width: 1,
          ),
        ),
        buttonIcon: const Icon(Icons.location_city, color: Color(0xFFb60000)),
        buttonText: const Text(
          "Selecciona Localidades",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 20,
          ),
        ),
        onConfirm: (results) {
          dropdownData.updateSelectedLocations(List<int>.from(results));
        },
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

  Widget _buildFileThumbnail(PlatformFile file) {
    if (file.extension == 'jpg' ||
        file.extension == 'jpeg' ||
        file.extension == 'pdf' ||
        file.extension == 'png') {
      return FutureBuilder<Uint8List?>(
        future: File(file.path!).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Image.memory(
              snapshot.data!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else if (file.extension == 'pdf') {
      return const Icon(
        Icons.picture_as_pdf,
        size: 50,
        color: Colors.red,
      );
    } else {
      return const Icon(
        Icons.file_present,
        size: 50,
        color: Colors.grey,
      );
    }
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

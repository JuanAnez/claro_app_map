// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/webtest/mocktest_repository.dart';
import 'package:icc_maps/data/services/dropdown_data_loader.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/clases/pos_location.dart';
import 'package:provider/provider.dart';
import 'package:turf/turf.dart';

class FormStateHandler extends ChangeNotifier {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController marketShareController = TextEditingController();
  final TextEditingController townDemographicController =
      TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController locationCodeController = TextEditingController();
  final TextEditingController allUsersController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  FeatureCollection? puertoRicoFeatureCollection;

  FormStateHandler() {
    _loadGeoJson();
  }

  bool _isSubmitting = false;
  bool isSubmittingMall = false;

  bool get isSubmitting => _isSubmitting;

  void setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  String? selectedOperator;
  String? selectedPosDesc;
  String? selectedPosType;
  String? selectedPosChannel;
  String? selectedPosTowns;
  String? selectedPosZones;
  String? selectedPosZoneDesc;
  String? selectedPosRmsLocations;
  String? selectedGerente;
  String? selectedAsistente;
  String? selectedAgentCode;
  String? marketShareValue;
  String? townDemographicValue;

  List<String> posDescriptions = [];
  List<Map<String, dynamic>> posTypes = [];
  List<Map<String, dynamic>> operadores = [];
  List<String> posChannel = [];
  List<String> posTowns = [];
  List<String> posZones = [];
  List<String> posRmsLocations = [];
  List<String> users = [];
  List<String> filteredAgentCodes = [];
  List<String> filteredLocationCodes = [];
  List<String> filteredAllUsers = [];

  Future<void> _loadGeoJson() async {
    try {
      String geoJsonString =
          await rootBundle.loadString('assets/geojson/puerto_rico.geojson');
      final geoJsonData = jsonDecode(geoJsonString);
      // print('Loaded GeoJSON: $geoJsonData');
      puertoRicoFeatureCollection = FeatureCollection.fromJson(geoJsonData);
    } catch (e) {
      print('Error loading GeoJSON: $e');
    }
  }

  bool validateCoordinates() {
    double? lat = double.tryParse(latController.text);
    double? lon = double.tryParse(lonController.text);

    if (lat != null && lon != null) {
      // print('Latitud: $lat, Longitud: $lon');
      bool isValid = isPointInPuertoRico(lat, lon);
      // print('¿Está dentro de Puerto Rico?: $isValid');
      return isValid;
    }
    return false;
  }

  bool isPointInPuertoRico(double lat, double lon) {
    if (puertoRicoFeatureCollection != null) {
      // print(
      //     "Características GeoJSON: ${puertoRicoFeatureCollection!.features}");
      final point = Position(lon, lat);

      for (var feature in puertoRicoFeatureCollection!.features) {
        if (feature.geometry is Polygon) {
          final polygon = feature.geometry as Polygon;
          // print('Verificando polígono: ${polygon.coordinates}');
          if (booleanPointInPolygon(point, polygon)) {
            return true;
          }
        } else if (feature.geometry is MultiPolygon) {
          final multiPolygon = feature.geometry as MultiPolygon;
          for (var polygonCoordinates in multiPolygon.coordinates) {
            final polygon = Polygon(coordinates: polygonCoordinates);
            // print('Verificando multi-polígono: ${polygonCoordinates}');
            if (booleanPointInPolygon(point, polygon)) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void updatePosDesc(String? newPosDesc) {
    selectedPosDesc = newPosDesc;
    notifyListeners();
  }

  void updatePosType(String? newPosType) {
    selectedPosType = newPosType;
    notifyListeners();
    if (selectedPosType != null && selectedOperator != null) {
      fetchMarketShareValue(
        int.parse(selectedPosType!),
        int.parse(selectedOperator!),
      );
    }
  }

  void updateOperator(String? newOperator) {
    selectedOperator = newOperator;
    notifyListeners();
    if (selectedPosType != null && selectedOperator != null) {
      fetchMarketShareValue(
        int.parse(selectedPosType!),
        int.parse(selectedOperator!),
      );
    }
  }

  void updatePosChannel(String? newChannel) {
    selectedPosChannel = newChannel;
    notifyListeners();
  }

  void updateSelectedGerente(String? value) {
    selectedGerente = value?.split(' - ')[0];
    if (selectedGerente == selectedAsistente) {
      selectedAsistente = null;
    }
    notifyListeners();
  }

  void updateSelectedAsistente(String? value) {
    selectedAsistente = value?.split(' - ')[0];
    if (selectedGerente == selectedAsistente) {
      selectedGerente = null;
    }
    notifyListeners();
  }

  void resetForm(BuildContext context) {
    nombreController.clear();
    descripcionController.clear();
    addressController.clear();
    marketShareController.clear();
    townDemographicController.clear();
    agentCodeController.clear();
    latController.clear();
    lonController.clear();
    posTowns.clear();

    selectedOperator = null;
    selectedPosDesc = null;
    selectedPosType = null;
    selectedPosChannel = null;
    selectedPosTowns = null;
    selectedPosZoneDesc = null;
    selectedPosRmsLocations = null;
    selectedGerente = null;
    selectedAsistente = null;
    selectedAgentCode = null;
    marketShareValue = null;
    townDemographicValue = null;

    final dropdownDataLoader =
        Provider.of<DropdownDataLoader>(context, listen: false);
    dropdownDataLoader.clearAllTownsAndLocations();
  }

  Future<void> fetchMarketShareValue(
      int selectedType, int selectedOperator) async {
    try {
      MocktestClient client = MocktestClient();
      MessageResponse response =
          await client.getMarketShareValue(selectedType, selectedOperator);

      if (response.ok) {
        double? marketShareDouble =
            double.tryParse(response.content.toString());

        if (marketShareDouble != null) {
          marketShareValue = marketShareDouble.toStringAsFixed(2);
          marketShareController.text = marketShareValue ?? '';
        } else {
          marketShareValue = '';
          marketShareController.text = marketShareValue!;
        }

        notifyListeners();
      } else {
        print('Error fetching market share value: ${response.message}');
      }
    } catch (e) {
      print('Exception fetching market share value: $e');
    }
  }

  Future<void> fetchTownDemographic(String selectedTown) async {
    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getTownDemographic(selectedTown);
      if (response.ok) {
        townDemographicValue = response.content.toString();
        townDemographicController.text = townDemographicValue ?? '';
        notifyListeners();
      } else {
        print('Error fetching town demographic value: ${response.message}');
      }
    } catch (e) {
      print('Exception fetching town demographic value: $e');
    }
  }

  Future<void> fetchAgentCodes(String searchTerm) async {
    List<String> combinedAgentCodes = [];

    try {
      MocktestClient client = MocktestClient();

      MessageResponse response1 = await client.getAgentCode(searchTerm);
      if (response1.ok) {
        List<String> agentCodes1 = (response1.content as List).map((agent) {
          final dealerCode =
              agent['dealer'] != null ? agent['dealer'].toString() : '';
          final dealerName =
              agent['dlrName'] != null ? agent['dlrName'].toString() : '';
          return '$dealerCode - $dealerName';
        }).toList();
        combinedAgentCodes.addAll(agentCodes1);
      } else {
        print('Error fetching agent code: ${response1.message}');
      }
      MessageResponse response2 = await client.getFixedAgentCode(searchTerm);
      if (response2.ok) {
        List<String> agentCodes2 = (response2.content as List).map((agent) {
          final dealerCode =
              agent['dealer'] != null ? agent['dealer'].toString() : '';
          final dealerName =
              agent['dlrName'] != null ? agent['dlrName'].toString() : '';
          return '$dealerCode - $dealerName';
        }).toList();
        combinedAgentCodes.addAll(agentCodes2);
      } else {
        print('Error fetching fixed agent code: ${response2.message}');
      }

      filteredAgentCodes = combinedAgentCodes;
      notifyListeners();
    } catch (e) {
      print('Exception fetching agent codes: $e');
    }
  }

  Future<void> fetchLocationCodes(String searchTerm) async {
    List<String> combinedLocationCodes = [];

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getPosLocDropdownInputs();
      if (response.ok) {
        List<String> locationCodes =
            (response.content['allPosRmsLocations'] as List)
                .map<String>((location) {
          final rmsLocationId = location['rmsLocationId'] as String;
          final locationName = location['locationName'] as String;
          return '$rmsLocationId - $locationName';
        }).toList();
        combinedLocationCodes.addAll(locationCodes);
      } else {
        print('Error fetching location code: ${response.message}');
      }
      filteredLocationCodes = combinedLocationCodes;
      notifyListeners();
    } catch (e) {
      print('Exception fetching location codes: $e');
    }
  }

  Future<void> fetchAllUsers(String searchTerm) async {
    List<String> combinedAllUsers = [];

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getPosLocDropdownInputs();
      if (response.ok) {
        List<String> allUsers =
            (response.content['allUsers'] as List).map<String>((user) {
          final name = user['name'] != null ? user['name'] as String : '';
          final lastName =
              user['last_NAME'] != null ? user['last_NAME'] as String : '';
          final userName =
              user['username'] != null ? user['username'] as String : '';
          return '$name $lastName - $userName';
        }).toList();
        combinedAllUsers.addAll(allUsers);
      } else {
        print('Error fetching users: ${response.message}');
      }
      filteredAllUsers = combinedAllUsers;
      notifyListeners();
    } catch (e) {
      print('Exception fetching users: $e');
    }
  }

  Future<void> postPOSToServer(
      BuildContext context, Map<String, dynamic> jsonData) async {
    final uri =
        Uri.parse('https://webtest/icc/api/uploadPosLocationToDb'
            // 'http://192.168.1.5:8082/uploadPosLocationToDb'
            );

    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(jsonData));

      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Datos enviados correctamente: $responseBody');
        resetForm(context);
      } else if (response.statusCode == 400) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Error 400 al enviar los datos: $responseBody');
        showErrorDialog(context, 'Error al enviar datos: $responseBody');
      } else {
        print('Error al enviar datos: ${response.statusCode}');
        showErrorDialog(context, 'Error inesperado al enviar los datos');
      }
    } catch (e) {
      print('Excepción: $e');
      showErrorDialog(context, 'Ocurrió un error durante la conexión');
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    addressController.dispose();
    marketShareController.dispose();
    townDemographicController.dispose();
    agentCodeController.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFb60000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'El punto de venta se ha añadido correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _refreshPage(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFb60000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshPage(BuildContext context) {
    final formState = Provider.of<FormStateHandler>(context, listen: false);
    formState.resetForm(context);
    final dropdownDataLoader =
        Provider.of<DropdownDataLoader>(context, listen: false);
    dropdownDataLoader.loadDropdownData();
    formState.notifyListeners();
  }

  bool validateForm() {
    if (nombreController.text.isEmpty ||
        selectedPosDesc == null ||
        selectedPosType == null ||
        selectedOperator == null ||
        selectedPosChannel == null ||
        addressController.text.isEmpty ||
        selectedPosTowns == null ||
        selectedPosZoneDesc == null ||
        latController.text.isEmpty ||
        lonController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void submitForm(BuildContext context) async {
    if (!validateForm()) {
      showErrorDialog(
          context, "Por favor, completa todos los campos antes de enviar.");
      return;
    }

    if (!validateCoordinates()) {
      showErrorDialog(
          context, "Las coordenadas están fuera del perímetro de Puerto Rico.");
      return;
    }

    setSubmitting(true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.getUser()?.username ?? "DEFAULT_USERNAME";

      final newPosLocation = PosLocation(
        posLocName: nombreController.text,
        posLocDesc: selectedPosDesc ?? '',
        posLocType: int.tryParse(selectedPosType ?? '0') ?? 0,
        posLocOperator: int.tryParse(selectedOperator ?? '0') ?? 0,
        posLocChannel: int.tryParse(selectedPosChannel ?? '0') ?? 0,
        posLocAddress: addressController.text,
        posLocTown: selectedPosTowns ?? '',
        posLocZone: int.tryParse(selectedPosZones ?? '0') ?? 0,
        posLocZoneDesc: selectedPosZoneDesc ?? '',
        posLocDemo: int.tryParse(townDemographicController.text) ?? 0,
        posLocShareMktValue: double.parse(marketShareValue ?? '0.00'),
        posLocLat: latController.text,
        posLocLon: lonController.text,
        posLocManager:
            selectedGerente?.isNotEmpty == true ? selectedGerente : "",
        posLocAssistant:
            selectedAsistente?.isNotEmpty == true ? selectedAsistente : "",
        posDealer:
            selectedAgentCode?.isNotEmpty == true ? selectedAgentCode : "",
        posLocationCode: selectedPosRmsLocations?.isNotEmpty == true
            ? selectedPosRmsLocations
            : "",
        userName: username,
      );
      final jsonData = newPosLocation.toJson();
      print('JSON enviado: $jsonData');
      await postPOSToServer(context, jsonData);
      setSubmitting(false);

      await showSuccessDialog(context);
    } catch (error) {
      print('Error durante el envío: $error');
      showErrorDialog(context, 'Error durante el envío de los datos.');
      setSubmitting(false);
    }
  }

  bool validateFormMall() {
    if (nombreController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        lonController.text.isEmpty ||
        latController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> showErrorDialogMall(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFb60000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitFormMall(
    BuildContext context,
    List<int> selectedLocationIds,
    String selectedTownId,
    List<PlatformFile>? selectedFiles, // Cambiado a lista
  ) async {
    if (!validateFormMall()) {
      showErrorDialogMall(
          context, "Por favor, completa todos los campos antes de enviar.");
      return;
    }

    if (!validateCoordinates()) {
      showErrorDialog(
          context, "Las coordenadas están fuera del perímetro de Puerto Rico.");
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.getUser()?.username ?? "DEFAULT_USERNAME";
    final Map<String, dynamic> formData = {
      "groupName": nombreController.text,
      "groupDescription": descripcionController.text,
      "locationSelected":
          selectedLocationIds.map((id) => id.toString()).join(','),
      "latitude": latController.text,
      "longitude": lonController.text,
      "town": selectedTownId,
      "userName": username,
    };

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      List<Map<String, dynamic>> fileUploads = [];

      for (var selectedFile in selectedFiles) {
        String base64File = base64Encode(selectedFile.bytes!);
        fileUploads.add({
          "fileName": selectedFile.name,
          "fileSize": selectedFile.size,
          "fileContent": base64File,
        });
      }

      formData["fileUpload"] = fileUploads;
    }

    final url = Uri.parse('http://192.168.1.5:8082/uploadPosGroupToDb');

    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final request = await client.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(formData));

      final response = await request.close();
      isSubmittingMall = true;
      notifyListeners();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formulario enviado con éxito!')),
        );
      } else {
        showErrorDialogMall(
            context, 'Error en el envío: ${response.statusCode}');
      }
      await showSuccessDialogMall(context);
    } catch (e) {
      showErrorDialogMall(context, 'Error de red: $e');
    } finally {
      isSubmittingMall = false;
      notifyListeners();
    }
  }

  Future<void> showSuccessDialogMall(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'El Centro Comercial se ha añadido correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _refreshPage(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFb60000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  detectCurrentLocation() {}
}

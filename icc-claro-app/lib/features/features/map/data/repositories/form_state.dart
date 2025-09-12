// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, use_build_context_synchronously, unused_local_variable, deprecated_export_use

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icc_claro_app/core/utils/classes/pos_location.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/dropdown_data_loader.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'package:turf/turf.dart';
// import 'package:mime/mime.dart';

class FormStateHandler extends ChangeNotifier {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController desciptionController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController marketShareController = TextEditingController();
  final TextEditingController townDemographicController =
      TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController fixedAgentCodesController =
      TextEditingController();

  final TextEditingController locationCodeController = TextEditingController();
  final TextEditingController allUsersController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();
  final TextEditingController locStatusController = TextEditingController();

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
  String? selectedFixedAgentCodes;
  String? marketShareValue;
  String? townDemographicValue;
  String? selectedStatus;

  List<String> posDescriptions = [];
  List<Map<String, dynamic>> posTypes = [];
  List<Map<String, dynamic>> operadores = [];
  List<String> posChannel = [];
  List<String> posTowns = [];
  List<String> posZones = [];
  List<String> posRmsLocations = [];
  List<String> users = [];
  List<String> locStatus = [];
  List<String> filteredAgentCodes = [];
  List<String> filteredLocationCodes = [];
  List<String> filteredAllUsers = [];
  List<String> filteredFixedAgentCodes = [];

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
      bool isValid = isPointInPuertoRico(lat, lon);
      return isValid;
    }
    return false;
  }

  bool isPointInPuertoRico(double lat, double lon) {
    if (puertoRicoFeatureCollection != null) {
      final point = Position(lon, lat);

      for (var feature in puertoRicoFeatureCollection!.features) {
        if (feature.geometry is Polygon) {
          final polygon = feature.geometry as Polygon;
          if (booleanPointInPolygon(point, polygon)) {
            return true;
          }
        } else if (feature.geometry is MultiPolygon) {
          final multiPolygon = feature.geometry as MultiPolygon;
          for (var polygonCoordinates in multiPolygon.coordinates) {
            final polygon = Polygon(coordinates: polygonCoordinates);
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

  void updatePosType(String? newPosType, [BuildContext? context]) {
    selectedPosType = newPosType;
    notifyListeners();
    if (selectedPosType != null && selectedOperator != null) {
      fetchMarketShareValue(
        int.parse(selectedPosType!),
        int.parse(selectedOperator!),
        context,
      );
    }
  }

  void updateOperator(String? newOperator, [BuildContext? context]) {
    selectedOperator = newOperator;
    notifyListeners();
    if (selectedPosType != null && selectedOperator != null) {
      fetchMarketShareValue(
        int.parse(selectedPosType!),
        int.parse(selectedOperator!),
        context,
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
    desciptionController.clear();
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
    posTowns.clear();
    selectedPosZoneDesc = null;
    selectedPosRmsLocations = null;
    selectedGerente = null;
    selectedAsistente = null;
    selectedAgentCode = null;
    marketShareValue = null;
    townDemographicValue = null;

    selectedPosTowns = null;
    posTowns.clear();
    selectedPosRmsLocations = null;
    clearSelectedFiles();

    final dropdownDataLoader =
        Provider.of<DropdownDataLoader>(context, listen: false);
    dropdownDataLoader.clearAllTownsAndLocations();
  }

  void clearSelectedFiles() {
    notifyListeners();
  }

  Future<void> fetchMarketShareValue(
      int selectedType, int selectedOperator, [BuildContext? context]) async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response =
          await client.getMarketShareValue(selectedType, selectedOperator, context);

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

   Future<void> fetchTownDemographic(String selectedTown, [BuildContext? context]) async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getTownDemographic(selectedTown, context);
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

  Future<void> fetchAgentCodes(String searchTerm, [BuildContext? context]) async {
    try {
      MapsRepository client = MapsRepository();

      MessageResponse response = await client.getAgentCode(searchTerm, context);
      if (response.ok) {
        List<String> agentCodes = (response.content as List).map((agent) {
          final dealerCode =
              agent['dealer'] != null ? agent['dealer'].toString() : '';
          final dealerName =
              agent['dlrName'] != null ? agent['dlrName'].toString() : '';
          return '$dealerCode - $dealerName';
        }).toList();
        filteredAgentCodes = agentCodes;
      } else {
        print('Error fetching agent code: ${response.message}');
      }
      notifyListeners();
    } catch (e) {
      print('Exception fetching agent codes: $e');
    }
  }

  Future<void> fetchFixedAgentCodes(String searchTerm) async {
    try {
      MapsRepository client = MapsRepository();

      MessageResponse response = await client.getFixedAgentCode(searchTerm);
      if (response.ok) {
        List<String> fixedAgentCodes = (response.content as List).map((agent) {
          final dealerCode =
              agent['dealer'] != null ? agent['dealer'].toString() : '';
          final dealerName =
              agent['dlrName'] != null ? agent['dlrName'].toString() : '';
          return '$dealerCode - $dealerName';
        }).toList();
        filteredFixedAgentCodes = fixedAgentCodes;
      } else {
        print('Error fetching fixed agent code: ${response.message}');
      }
      notifyListeners();
    } catch (e) {
      print('Exception fetching fixed agent codes: $e');
    }
  }

  Future<void> fetchLocationCodes(String searchTerm) async {
    List<String> combinedLocationCodes = [];

    try {
      MapsRepository client = MapsRepository();
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
      MapsRepository client = MapsRepository();
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

  Future<void> loadLocStatus(String selectedStatus) async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_LOC_STATUS');

      if (response.ok) {
        locStatus = (response.content as List)
            .map<String>((status) {
              final lovGroup = status['lovGroup'] ?? '';
              final lovDescription = status['lovDescription'] ?? '';
              if (lovGroup == 'Alta') {
                return '$lovGroup - $lovDescription';
              }
              return '';
            })
            .where((status) => status.isNotEmpty)
            .toList();

        notifyListeners();
      } else {
        print('Error loading location types: ${response.message}');
      }
    } catch (e) {
      print('Exception loading location types: $e');
    }
  }

  Future<void> postPOSToServer(
      BuildContext context, Map<String, dynamic> jsonData) async {
    final uri =
        Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.uploadPosLocationToDb));

    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set('accept-charset', 'UTF-8');
      request.write(jsonEncode(jsonData));

      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Datos enviados correctamente: ${responseBody}');
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

  bool validateForm() {
    if (nombreController.text.isEmpty ||
        selectedPosDesc == null ||
        selectedPosType == null ||
        selectedOperator == null ||
        selectedPosChannel == null ||
        addressController.text.isEmpty ||
        selectedPosTowns == null ||
        selectedPosZoneDesc == null ||
        selectedStatus == null ||
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
        description: desciptionController.text,
        posLocDesc: selectedPosDesc ?? '',
        posLocType: int.tryParse(selectedPosType ?? '0') ?? 0,
        posLocOperator: int.tryParse(selectedOperator ?? '0') ?? 0,
        posLocChannel: int.tryParse(selectedPosChannel ?? '0') ?? 0,
        posLocAddress: addressController.text,
        posLocTown: selectedPosTowns ?? '',
        posLocZone: int.tryParse(selectedPosZones ?? '0') ?? 0,
        posLocZoneDesc: selectedPosZoneDesc ?? '',
        posLocDemo: int.tryParse(townDemographicController.text) ?? 0,
        posLocShareMktValue: (double.tryParse(marketShareValue ?? '0.0') ?? 0.0)
            .toStringAsFixed(2),
        posLocLat: latController.text,
        posLocLon: lonController.text,
        posLocManager:
            selectedGerente?.isNotEmpty == true ? selectedGerente : "",
        posLocAssistant:
            selectedAsistente?.isNotEmpty == true ? selectedAsistente : "",
        posDealer: selectedAgentCode?.split(' - ')[0] ?? "",
        posDealerFixed: selectedFixedAgentCodes?.split(' - ')[0] ?? "",
        posLocationCode: selectedPosRmsLocations?.split(' - ')[0] ?? "",
        userName: username,
        posLocStatus: selectedStatus ?? '',
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
    List<PlatformFile>? selectedFiles,
  ) async {
    if (!validateFormMall()) {
      showErrorDialogMall(context, "Por favor, completa todos los campos.");
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.getUser()?.username ?? "DEFAULT_USERNAME";

    final payload = {
      "groupName": nombreController.text,
      "groupDescription": descripcionController.text,
      "locationSelected": selectedLocationIds.join(','),
      "latitude": latController.text,
      "longitude": lonController.text,
      "town": selectedTownId,
      "userName": username,
    };

    final url =
        Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.uploadPosGroupToDb));
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final boundary =
        '----dartFormBoundary${DateTime.now().millisecondsSinceEpoch}';

    try {
      final request = await client.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary');

      final multipartBody = BytesBuilder();
      multipartBody.add(utf8.encode('--$boundary\r\n'));
      multipartBody.add(
          utf8.encode('Content-Disposition: form-data; name="payload"\r\n'));
      multipartBody.add(utf8.encode('Content-Type: application/json\r\n\r\n'));
      multipartBody.add(utf8.encode(jsonEncode(payload)));
      multipartBody.add(utf8.encode('\r\n--$boundary--\r\n'));

      request.add(multipartBody.toBytes());

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseBody);

      final decodedResponse = jsonDecode(responseBody);

      print('📥 Respuesta del servidor: $decodedResponse');

      final groupId = decoded["groupId"];
      if (decoded["result"] == "SUCCESS" &&
          groupId != null &&
          selectedFiles != null &&
          selectedFiles.isNotEmpty) {
        // print('🚀 Enviando mall con archivos: ${selectedFiles?.length ?? 0}');
        for (final f in selectedFiles) {
          print('   Archivo: ${f.name}, size: ${f.size}');
        }

        await uploadBlueprintFiles(groupId, selectedFiles, username);
      }

      showSuccessDialogMall(context);
    } catch (e) {
      showErrorDialogMall(context, 'Error: $e');
    }
  }

  Future<void> uploadBlueprintFiles(
    int groupId,
    List<PlatformFile> files,
    String username,
  ) async {
    final url =
        Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.uploadBlueprintToDb));
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final boundary =
        '----dartFormBoundary${DateTime.now().millisecondsSinceEpoch}';

    final request = await client.postUrl(url);
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    final body = BytesBuilder();

    void writeField(String name, String value) {
      body.add(utf8.encode('--$boundary\r\n'));
      body.add(
          utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'));
      body.add(utf8.encode(value));
      body.add(utf8.encode('\r\n'));
    }

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file.name;
      final filePath = file.path!;
      final extension = file.extension ?? 'png';
      final mimeType =
          extension == 'pdf' ? 'application/pdf' : 'image/$extension';
      final fileBytes = await File(filePath).readAsBytes();

      print('📤 Subiendo archivo: $fileName (${fileBytes.length} bytes)');

      body.add(utf8.encode('--$boundary\r\n'));
      body.add(utf8.encode(
          'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n'));
      body.add(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
      body.add(fileBytes);
      body.add(utf8.encode('\r\n'));

      writeField("fileDescription", "Archivo ${i + 1}");
      writeField("fileGroupId", groupId.toString());
    }

    writeField("userName", username);

    body.add(utf8.encode('--$boundary--\r\n'));

    request.add(body.toBytes());

    try {
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      print("📤 Respuesta subida de documentos: $responseText");

      if (responseText.toLowerCase() == 'true') {
        print("✅ Documentos subidos exitosamente");
      } else {
        print("❌ Error en la subida de documentos");
      }
    } catch (e) {
      print("❌ Excepción subiendo documentos: $e");
    }
  }

  void _refreshPage(BuildContext context) {
    final formState = Provider.of<FormStateHandler>(context, listen: false);
    formState.resetForm(context);
    final dropdownDataLoader =
        Provider.of<DropdownDataLoader>(context, listen: false);
          dropdownDataLoader.loadDropdownData(context);
    formState.notifyListeners();
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
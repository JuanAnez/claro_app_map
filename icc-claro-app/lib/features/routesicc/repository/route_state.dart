// ignore_for_file: unused_field, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icc_claro_app/core/utils/classes/pos_location_route.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
// import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/dropdown_data_loader.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
import 'package:icc_claro_app/features/routesicc/models/route_model.dart';
import 'package:provider/provider.dart';
import 'package:turf/turf.dart';

class RouteStateHandler extends ChangeNotifier {
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  final TextEditingController posLocationRouteIDController =
      TextEditingController();
  final TextEditingController posLocationIDController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
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

  List<Map<String, dynamic>> posDescriptions = [];
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
  List<String> filteredFixedAgentCodes = [];

  bool validateForm() {
    if (nombreController.text.isEmpty ||
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

  void initControllers(RouteModel route) {
    posLocationRouteIDController.text = route.posLocationRouteID.toString();
    posLocationIDController.text = route.posLocationID.toString();
    nombreController.text = route.posLocationName;
    desciptionController.text = route.description ?? '';
    selectedPosDesc = getDescriptionIdFromName(route.locDescription);
    selectedPosType = route.locTypeId.toString();
    selectedOperator = route.posOperatorId.toString();
    selectedPosChannel = route.channelId.toString();
    addressController.text = route.posAddress;
    selectedPosTowns = route.posTown;
    selectedPosZones = route.posZone;
    selectedPosZoneDesc = route.posZoneDescription;
    townDemographicController.text = route.posDemographics;
    marketShareController.text = route.posShareMktValue;
    statusController.text = route.status;
    latController.text = route.latitude.toString();
    lonController.text = route.longitude.toString();
    selectedGerente = route.routeManagerName;
    selectedAsistente = route.routeAssistantName;
    agentCodeController.text = route.posDealer ?? '';
    locationCodeController.text = route.posLocationCode ?? '';
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

  void resetForm(BuildContext context) {
    posLocationRouteIDController.clear();
    posLocationIDController.clear();
    statusController.clear();
    fixedAgentCodesController.clear();
    locationCodeController.clear();
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

  Future<void> _loadGeoJson() async {
    try {
      String geoJsonString =
          await rootBundle.loadString('assets/geojson/puerto_rico.geojson');
      final geoJsonData = jsonDecode(geoJsonString);
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

  FeatureCollection? puertoRicoFeatureCollection;

  RouteStateHandler() {
    _loadGeoJson();
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

  void setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void updatePosDesc(String? newPosDesc) {
    selectedPosDesc = newPosDesc;
    notifyListeners();
  }

  String? getDescriptionIdFromName(String descriptionName) {
    try {
      final match = posDescriptions.firstWhere(
        (item) => item['lovDescription'] == descriptionName,
      );
      return match['lovId'].toString();
    } catch (e) {
      return null;
    }
  }

  String? getDescriptionFromId(String? id) {
    try {
      final match = posDescriptions.firstWhere(
        (item) => item['lovId'].toString() == id,
      );
      return match['lovDescription'].toString();
    } catch (e) {
      return null;
    }
  }

  String? getTypeDescriptionFromId(String id) {
    try {
      final item =
          posTypes.firstWhere((element) => element['lovId'].toString() == id);
      return item['lovDescription'];
    } catch (e) {
      return null;
    }
  }

  String? getOperatorDescriptionFromId(String id) {
    try {
      final item =
          operadores.firstWhere((element) => element['lovId'].toString() == id);
      return item['lovDescription'];
    } catch (e) {
      return null;
    }
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

  Future<void> fetchMarketShareValue(
      int selectedType, int selectedOperator) async {
    try {
      MapsRepository client = MapsRepository();
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

  Future<void> fetchAgentCodes(String searchTerm) async {
    try {
      MapsRepository client = MapsRepository();

      MessageResponse response = await client.getAgentCode(searchTerm);
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

  Future<void> fetchTownDemographic(String selectedTown) async {
    try {
      MapsRepository client = MapsRepository();
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

  void submitForm(BuildContext context,
      {RouteModel? route, VoidCallback? onReload}) async {
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
      final userName = userProvider.getUser()?.username ?? "DEFAULT_USERNAME";

      final dropdownDataLoader =
          Provider.of<DropdownDataLoader>(context, listen: false);
      posDescriptions = dropdownDataLoader.posDescriptions;

      final newPosLocation = PosLocationRoute(
        posLocName: nombreController.text,
        posLocDesc: getDescriptionFromId(selectedPosDesc) ?? '',
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
        posLocationCode: selectedPosRmsLocations?.split(' - ')[0] ?? "",
        userName: userName,
        routeManagerId: route?.routeManagerId ?? 0,
        routeAssistantId: route?.routeAssistantId ?? 0,
        routeAssignedId: route?.routeAssignedId ?? 0,
        posLocationRouteId: null,
        posLocationId: null,
      );

      print(
          "Ruta seleccionada: ${route?.routeManagerId}, ${route?.routeAssistantId}, ${route?.routeAssignedId}");

      final jsonData = newPosLocation.toJson();
      print('JSON enviado: $jsonData');
      await postInsertPosRoute(context, jsonData, onReload);
      // resetForm(context);
      setSubmitting(false);

      // await showSuccessDialog(
      //   context,
      //   message: 'El punto de venta se ha añadido correctamente',
      // );

      showSuccessSnackBar(
        context,
        message: 'El punto de venta se ha añadido correctamente',
        onReload: onReload,
      );
    } catch (error) {
      print('Error durante el envío: $error');
      showErrorDialog(context, 'Error durante el envío de los datos.');
      setSubmitting(false);
    }
  }

  Future<void> postInsertPosRoute(BuildContext context,
      Map<String, dynamic> jsonData, VoidCallback? onReload) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        '/insertPosRoute',
        body: jsonData,
        context: context,
      );

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = response.body;
        print('Datos enviados correctamente: $responseBody');

        try {
          final jsonResponse = json.decode(responseBody);
          final result = jsonResponse['result'];
          final message = jsonResponse['message'];

          if (result == 'SUCCESS') {
            showSuccessSnackBar(context, message: message, onReload: onReload);
          } else {
            showErrorDialog(context, 'Error: $message');
          }
        } catch (e) {
          // fallback
          showSuccessSnackBar(context,
              message: 'El punto de venta se añadió.', onReload: onReload);
        }

        resetForm(context);
      } else {
        print('Error al enviar datos: ${response.statusCode}');
        showErrorDialog(context, 'Error al enviar datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción: $e');
      showErrorDialog(context, 'Ocurrió un error durante la conexión');
    }
  }

  void submitFormToEdit(
    BuildContext context, {
    RouteModel? route,
    VoidCallback? onReload,
    String? routeType,
    List<String>? roles,
    Map<String, dynamic>? location,
  }) async {
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
      final userName = userProvider.getUser()?.username ?? "DEFAULT_USERNAME";

      route!.posLocationName = nombreController.text;
      route.locDescription = getDescriptionFromId(selectedPosDesc) ?? '';
      route.locType = selectedPosType ?? '';
      route.posOperator = selectedOperator ?? '';
      route.posAddress = addressController.text;
      route.posTown = selectedPosTowns ?? '';
      route.posZone = selectedPosZones ?? '';
      route.channelId = int.tryParse(selectedPosChannel ?? '0') ?? 0;
      route.posZoneDescription = selectedPosZoneDesc ?? '';
      route.posDemographics =
          (int.tryParse(townDemographicController.text) ?? 0).toString();
      route.posShareMktValue =
          (double.tryParse(marketShareController.text) ?? 0.0)
              .toStringAsFixed(2);
      route.updatedBy = userName;
      route.latitude = double.tryParse(latController.text) ?? 0.0;
      route.longitude = double.tryParse(lonController.text) ?? 0.0;
      route.routeManagerId = route.routeManagerId;
      route.routeAssistantId = route.routeAssistantId;
      route.posDealer = selectedAgentCode?.split(' - ')[0] ?? '';
      route.posLocationCode = selectedPosRmsLocations?.split(' - ')[0] ?? '';

      final jsonData = route.toJsonForUpdateRouteV2();
      print('JSON enviado: $jsonData');

      await postUpdatePosRoute(context, jsonData);

      setSubmitting(false);

      showSuccessSnackBar(
        context,
        message: 'El punto de venta se ha editado correctamente',
        onReload: onReload,
      );
    } catch (error) {
      print('Error durante el envío: $error');
      showErrorDialog(context, 'Error durante el envío de los datos.');
      setSubmitting(false);
    }
  }

  Future<void> postUpdatePosRoute(
      BuildContext context, Map<String, dynamic> jsonData) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        '/updateRouteV2',
        body: jsonData,
        context: context,
      );

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = response.body;
        print('Datos enviados correctamente: $responseBody');
        resetForm(context);
      } else if (response.statusCode == 400) {
        print('Error 400 al enviar los datos: ${response.body}');
        showErrorDialog(context, 'Error al enviar datos: ${response.body}');
      } else {
        print('Error al enviar datos: ${response.statusCode}');
        showErrorDialog(context, 'Error inesperado al enviar los datos');
      }
    } catch (e) {
      print('Excepción: $e');
      showErrorDialog(context, 'Ocurrió un error durante la conexión');
    }
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

  Future<void> showSuccessDialog(BuildContext context,
      {required String message}) async {
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
                        Navigator.of(context).pop(true);
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

  void showSuccessSnackBar(BuildContext context,
      {required String message, VoidCallback? onReload}) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );

      if (onReload != null) {
        onReload();
      }

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop(true);
      });
    }
  }
}

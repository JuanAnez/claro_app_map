// ignore_for_file: unused_field, unused_element, deprecated_member_use, use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, empty_constructor_bodies, non_constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/webtest/mocktest_repository.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/type/custom_polygon.dart';
import 'package:icc_maps/ui/pages/map/type/map_display_types.dart';
import 'package:icc_maps/domain/use_cases/map_use_case.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/clases/custom_marker.dart';
import 'package:latlong2/latlong.dart';

class PointsOfSaleProvider extends ChangeNotifier {
  late final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  PointsOfSaleProvider() {}

  static const double _zoomValue = 0.5;
  final MapUseCase mapUseCase = MapUseCase();

  bool _isLoadingData = false;
  bool get isLoadingData => _isLoadingData;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  MapDisplayTypes _mapType = MapDisplayTypes.streets;
  MapDisplayTypes get mapType => _mapType;

  final Set<Enum> _selectedButtons = <Enum>{};
  Set<Enum> get selectedButtons => _selectedButtons;

  final Map<String, List<CustomPolygon>> _mapMunicipalities = {};
  final Map<String, List<Marker>> _mapSalesCache = {};
  final Map<String, List<Marker>> _mapSales = {};
  final Map<String, List<Marker>> _mapMalls = {};

  Marker? _userMarker;
  Marker? get userMarker => _userMarker;

  static final LatLngBounds bounds = LatLngBounds(
    const LatLng(17.729101, -67.546335),
    const LatLng(18.759204, -65.112048),
  );

  void addUserMarker(Marker marker) {
    _userMarker = marker;
    notifyListeners();
  }

  List<Marker> get mapSales {
    final allMarkers = _mapSales.values.expand((a) => a).toList();
    if (_userMarker != null) {
      allMarkers.add(_userMarker!);
    }
    return allMarkers;
  }

  List<Marker> get mapMalls {
    final allMarkers = _mapMalls.values.expand((a) => a).toList();
    if (_userMarker != null) {
      allMarkers.add(_userMarker!);
    }
    return allMarkers;
  }

  List<CustomPolygon> get mapMunicipalities =>
      _mapMunicipalities.values.expand((c) => c).toList();

  LatLng? _lastCenter;
  double? _lastZoom;
  MapDisplayTypes? _lastMapType;

  void _storeMapState() {
    try {
      _lastCenter = _mapController.center;
      _lastZoom = _mapController.zoom;
      _lastMapType = _mapType;
    } catch (e) {
      print('Error in _storeMapState: $e');
    }
  }

  void _reloadMap() {
    notifyListeners();
  }

  void _restoreMapState() {
    if (_lastCenter != null && _lastZoom != null) {
      !_mapController.move(_lastCenter!, _lastZoom!);
    }
  }

  void _putSalesOnMap(String key, List<Marker> markers) {
    _mapSales[key] = markers;
    notifyListeners();
  }

  void handleButtonAction(ButtonsActionType action) async {
    if (!_isLoadingData) {
      _isLoadingData = true;
      notifyListeners();

      if (action is CollapseButtons) {
        await _collapseButtons();
      } else if (action is ZoomMap) {
        await _zoomMap(action.zoomIn);
      } else if (action is ChangeMapDisplay) {
        await _changeMapDisplay();
      }

      _isLoadingData = false;
      notifyListeners();
    }
  }

  String getMapTemplateURL() {
    return 'https://api.mapbox.com/styles/v1/mapbox/${_mapType.name}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}';
  }

  Map<String, String> getMapAccessToken() => {
        "accessToken":
            "pk.eyJ1IjoiaXN5OTk4MDEiLCJhIjoiY20wbWpyOTE0MDM1YjJqcHIxODNuZDc1cCJ9.-G1o8fZuKwIPe__J1BWoqg"
      };

  Future<void> _collapseButtons() async {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  Future<void> _zoomMap(bool zoomIn) async {
    _mapController.move(
      _mapController.center,
      _mapController.zoom + (zoomIn ? _zoomValue : -_zoomValue),
    );
    _storeMapState();
    notifyListeners();
  }

  Future<void> _changeMapDisplay() async {
    int index = MapDisplayTypes.values.indexOf(_mapType);
    bool reachTheLastIndex = index >= MapDisplayTypes.values.length - 1;

    if (reachTheLastIndex) {
      _mapType = MapDisplayTypes.values[0];
    } else {
      _mapType = MapDisplayTypes.values[index + 1];
    }
    _storeMapState();
    notifyListeners();
  }

  Future<void> loadMarkers() async {
    _isLoadingData = true;
    _storeMapState();

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.findSales(0);
      if (response.ok) {
        _mapSales['sales'] = response.content.cast<Marker>();
        _restoreMapState();
      } else {
        print("Error loading markers: ${response.message}");
      }
    } catch (e) {
      print("Exception loading markers: $e");
    }

    _restoreMapState();
    notifyListeners();
  }

  Future<void> searchSales({
    required String posLocationId,
    required String posLocationName,
    required String posManager,
    required String posAddress,
    required String centro,
    required String posZoneDescription,
    required String locType,
    required String operador,
    required String posTown,
    required bool centrosComerciales,
    required String locDescription,
  }) async {
    _isLoadingData = true;
    _storeMapState();
    notifyListeners();

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.filterSale(
        posLocationId: posLocationId.isNotEmpty ? int.parse(posLocationId) : -1,
        posLocationName: posLocationName,
        posManager: posManager,
        posAddress: posAddress,
        centro: centro,
        locType: locType,
        operador: operador,
        posTown: posTown,
        centrosComerciales: centrosComerciales,
        locDescription: locDescription,
        posZoneDescription: posZoneDescription,
        onReload: _reloadMap,
      );
      print(response);
      if (response.ok) {
        _mapSales['sales'] = response.content.cast<Marker>();
      } else {
        print("Error loading markers: ${response.message}");
      }
    } catch (e) {
      print("Exception loading markers: $e");
    } finally {
      _isLoadingData = false;
      // notifyListeners();
    }
  }

  Future<void> loadMalls(int? groupId) async {
    _isLoadingData = true;
    notifyListeners();

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.findMalls();

      if (response.ok) {
        if (groupId != null) {
          final filteredMalls = response.content.where((marker) {
            if (marker is CustomMarker) {
              return marker.groupId == groupId;
            }
            return false;
          }).toList();

          if (filteredMalls.isEmpty) {
            print("No malls found for groupId: $groupId");
            _mapMalls['malls'] = [];
          } else {
            _mapMalls['malls'] = filteredMalls;
          }
        } else {
          _mapMalls['malls'] = response.content.cast<Marker>();
        }
      } else {
        print("Error loading markers: ${response.message}");
      }
    } catch (e) {
      print("Exception loading markers: $e");
    }

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> loadMunicipalities() async {
    if (_isLoadingData || _mapMunicipalities.isNotEmpty) return;

    _isLoadingData = true;
    notifyListeners();

    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.findMunicipalities();
      if (response.ok) {
        _mapMunicipalities['municipalities'] =
            response.content.cast<CustomPolygon>();

        for (var polygon in _mapMunicipalities['municipalities']!) {
          await _applyMarketShareColorToPolygon(polygon);
        }
      } else {
        print("Error loading municipalities: ${response.message}");
      }
    } catch (e) {
      print("Exception loading municipalities: $e");
    }

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> _applyMarketShareColorToPolygon(CustomPolygon polygon) async {
    try {
      MocktestClient client = MocktestClient();
      MessageResponse response =
          await client.getMarketShareForTown(polygon.label);

      if (response.ok) {
        final marketShare = response.content;
        double maxParticipacion = 0.0;
        double secondMaxParticipacion = 0.0;
        String? localidadConMayorParticipacion;
        bool empateMax = false;
        Map<String, double> localidadParticipaciones = {};

        for (var detail in marketShare['marketShareDetails']) {
          double participacion = double.tryParse(
                  detail['porcientoParticipacion'].replaceAll('%', '')) ??
              0.0;
          localidadParticipaciones[detail['localidad']] = participacion;

          if (participacion > maxParticipacion) {
            secondMaxParticipacion = maxParticipacion;
            maxParticipacion = participacion;
            localidadConMayorParticipacion = detail['localidad'];
            empateMax = false;
          } else if (participacion == maxParticipacion) {
            empateMax = true;
          }
        }

        Color newColor = Colors.white;
        if (maxParticipacion == 0.0) {
          newColor = Colors.white;
        } else if (empateMax &&
            secondMaxParticipacion > 0 &&
            maxParticipacion > secondMaxParticipacion) {
          newColor =
              localidadColors[localidadConMayorParticipacion] ?? Colors.white;
        } else if (!empateMax) {
          newColor =
              localidadColors[localidadConMayorParticipacion] ?? Colors.white;
        }

        final updatedPolygon = CustomPolygon(
          points: polygon.points,
          borderColor: polygon.borderColor,
          borderStrokeWidth: polygon.borderStrokeWidth,
          color: newColor,
          label: polygon.label,
        );

        int index = _mapMunicipalities['municipalities']!
            .indexWhere((p) => p.label == polygon.label);

        if (index != -1) {
          _mapMunicipalities['municipalities']![index] = updatedPolygon;
        }

        notifyListeners();
      } else {
        print(
            "Error loading market share for ${polygon.label}: ${response.message}");
      }
    } catch (e) {
      print(
          "Exception applying market share color to polygon ${polygon.label}: $e");
    }
  }

  Future<void> showMarketShareDialog(BuildContext context, String town) async {
    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getMarketShareForTown(town);
      if (response.ok) {
        final marketShare = response.content;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 300,
                      padding: const EdgeInsets.only(
                          right: 30, left: 30, top: 30, bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              town.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Participación de Mercado",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildMarketShareRow(
                              "Fijo: ",
                              marketShare['posTownMarketValue']['somFijo'] ??
                                  '0.00%',
                              Colors.white,
                              Colors.red),
                          _buildMarketShareRow(
                              "Móvil: ",
                              marketShare['posTownMarketValue']['somMovil'] ??
                                  '0.00%',
                              Colors.white,
                              Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            "Presencia Física",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...marketShare['marketShareDetails']
                              .map<Widget>((detail) {
                            final marketShareMap =
                                parseCustomJSON(detail['marketShareJSON']);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMarketShareRow(
                                    "${detail['localidad']}: ",
                                    detail['porcientoParticipacion'],
                                    localidadColors[detail['localidad']] ??
                                        Colors.white,
                                    localidadColors[detail['localidad']] ??
                                        Colors.white),
                                ...marketShareMap.entries.map((entry) {
                                  return Text(
                                    "• ${entry.key}: ${entry.value}",
                                    style: const TextStyle(color: Colors.white),
                                  );
                                }).toList(),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          Center(
                            child: ElevatedButton(
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
                                    vertical: 3.0, horizontal: 3.0),
                              ),
                              child: const Text('Cerrar'),
                            ),
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
      } else {
        print("Error loading market share: ${response.message}");
        showErrorDialog(
            context, "Error loading market share: ${response.message}");
      }
    } catch (e) {
      print("Exception loading market share: $e");
      showErrorDialog(context, "Exception loading market share: $e");
    }
  }

  final Map<String, Color> localidadColors = {
    'CLARO': const Color(0xFFFF0000),
    'BOOST': const Color(0xFFFF651D),
    'TMOBILE': const Color(0xFFE10974),
    'LIBERTY': const Color(0xFF4F8DC3),
    'Multimarca': const Color(0xFFFFFF00),
    'METRO BY T-MOBILE': const Color(0xFF8012ed),
    'Prueba': const Color.fromARGB(255, 8, 175, 63),
  };

  Map<String, dynamic> parseCustomJSON(String customJSON) {
    final result = <String, dynamic>{};
    final sanitizedString = customJSON.replaceAll("{", "").replaceAll("}", "");
    final pairs = sanitizedString.split(",");

    for (var pair in pairs) {
      if (pair.isNotEmpty) {
        final keyValue = pair.split(":");
        if (keyValue.length == 2) {
          result[keyValue[0]] = keyValue[1];
        }
      }
    }

    return result;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarketShareRow(
      String label, String value, Color color1, Color color2) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: color1),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: color2),
          ),
        ],
      ),
    );
  }

  void checkBounds(MapController controller, MapPosition position) {
    final LatLng center = position.center!;
    if (!bounds.contains(center)) {
      final double newLat = center.latitude
          .clamp(bounds.southWest.latitude, bounds.northEast.latitude);
      final double newLng = center.longitude
          .clamp(bounds.southWest.longitude, bounds.northEast.longitude);
      controller.move(LatLng(newLat, newLng), position.zoom!);
    }
  }
}

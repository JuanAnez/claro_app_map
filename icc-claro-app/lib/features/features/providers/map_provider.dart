// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/utils/classes/custom_polygon.dart';
import 'package:icc_claro_app/core/utils/classes/disable_pos_location.dart';
import 'package:icc_claro_app/core/widgets/show_pos_suggestions_dialog.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapProvider with ChangeNotifier {
  final GetMarkersUseCase _getMarkersUseCase;
  final MapsRepository _mapsRepository;
  bool isExpanded = false;

  final Map<String, List<CustomPolygon>> _mapMunicipalities = {};
  List<CustomPolygon> get mapMunicipalities =>
      _mapMunicipalities.values.expand((c) => c).toList();

  bool isLoadingData = false;
  final Map<String, List<Marker>> _mapMalls = {};
  Map<String, List<Marker>> get mapMalls => _mapMalls;

  Set<Marker> markers = {};
  MapType mapType = MapType.normal;
  GoogleMapController? _mapController;

  MapProvider(this._getMarkersUseCase, this._mapsRepository);

  void updateMarkers() {
    markers = _mapMalls.values.expand((malls) => malls).toSet();
    notifyListeners();
  }

  bool _isMounted = true;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isMounted = false;
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  static final LatLngBounds _bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  Future<void> loadMarkers(BuildContext context) async {
    try {
      isLoadingData = true;
      notifyListeners();

      Future.delayed(const Duration(seconds: 5), () {
        isLoadingData = false;
        notifyListeners();
      });

      final locations = await _mapsRepository.fetchPosLocations();

      final newMarkers =
          await _getMarkersUseCase.createMarkers(locations, context);
      markers.addAll(newMarkers);

      isLoadingData = false;
      notifyListeners();
    } catch (e) {
      isLoadingData = false;
      notifyListeners();
      print("Error al cargar los marcadores: ${e.toString()}");
    }
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
    required BuildContext context,
  }) async {
    isLoadingData = true;
    notifyListeners();

    try {
      final response = await _mapsRepository.filterSale(
        posLocationId: int.tryParse(posLocationId) ?? -1,
        posLocationName: posLocationName,
        posManager: posManager,
        posAddress: posAddress,
        centro: centro,
        posZoneDescription: posZoneDescription,
        locType: locType,
        operador: operador,
        posTown: posTown,
        centrosComerciales: centrosComerciales,
        locDescription: locDescription,
        onReload: () {
          loadMarkers(context);
        },
        context: context,
      );

      if (response != null && response.ok) {
        markers = response.content.toSet();
      } else {
        print("Error al buscar puntos de venta: ${response?.message}");
      }
    } catch (e) {
      print("Error durante la búsqueda: $e");
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> loadMalls(BuildContext context, int? groupId) async {
    try {
      isLoadingData = true;
      if (context.mounted) {
        notifyListeners();
      }

      MapsRepository client = MapsRepository();
      MessageResponse response = await client.findMalls(context);

      if (response.ok) {
        List<Marker> markers = response.content.cast<Marker>();

        if (groupId != null) {
          final filteredMalls = markers.where((marker) {
            return marker.markerId.value == groupId.toString();
          }).toList();

          _mapMalls['malls'] = filteredMalls;
        } else {
          _mapMalls['malls'] = markers;
        }

        updateMarkers();
      } else {
        print("❌ Error loading malls: ${response.message}");
      }
    } catch (e) {
      print("❌ Exception loading malls: $e");
    } finally {
      isLoadingData = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  static void showMallDialog(BuildContext context, int groupId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.getUser();
    final userAuthorities = user?.authorities;

    if (userAuthorities == null ||
        !userAuthorities.contains('TRAIN_POS_ADMIN')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFb60000),
          content: Text(
            'No tienes permiso para inhabilitar este centro comercial.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Estás seguro de que quieres Inhabilitar este Centro Comercial?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AlertButton(
                          text: 'Cancelar',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: const Color(0xFFb60000),
                        ),
                        AlertButton(
                          text: 'Confirmar',
                          onPressed: () {
                            disablePosGroup(context, groupId);
                            Navigator.of(context).pop();
                          },
                          color: const Color(0xFF449D44),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void toggleExpand() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void toggleMapType() {
    final List<MapType> mapTypes = [
      MapType.normal,
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
    ];

    int currentIndex = mapTypes.indexOf(mapType);
    int nextIndex = (currentIndex + 1) % mapTypes.length;

    mapType = mapTypes[nextIndex];
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> goToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng userLocation = LatLng(position.latitude, position.longitude);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLocation, 14),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    notifyListeners();
  }

  void checkBounds(LatLng position) {
    if (!_bounds.contains(position)) {
      final double newLat = position.latitude
          .clamp(_bounds.southwest.latitude, _bounds.northeast.latitude);
      final double newLng = position.longitude
          .clamp(_bounds.southwest.longitude, _bounds.northeast.longitude);
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(LatLng(newLat, newLng)),
      );
    }
  }

  Future<void> loadMunicipalities(BuildContext context) async {
    if (isLoadingData || _mapMunicipalities.isNotEmpty) return;

    isLoadingData = true;
    if (_isMounted) {
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    String? cachedMunicipalities = prefs.getString('cachedMunicipalities');

    if (cachedMunicipalities != null) {
      try {
        _mapMunicipalities['municipalities'] =
            (jsonDecode(cachedMunicipalities) as List)
                .map((e) => CustomPolygon.fromJson(e))
                .toList();

        // Aplicar colores a los municipios cacheados
        for (var polygon in _mapMunicipalities['municipalities']!) {
          await _applyMarketShareColorToPolygon(polygon, context);
        }

        isLoadingData = false;
        if (_isMounted) {
          notifyListeners();
        }
        return;
      } catch (e) {
        print("Error decoding cached municipalities: $e");
      }
    }

    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.findMunicipalities();
      if (response.ok) {
        _mapMunicipalities['municipalities'] =
            response.content.cast<CustomPolygon>();

        for (var polygon in _mapMunicipalities['municipalities']!) {
          await _applyMarketShareColorToPolygon(polygon, context);
        }

        await prefs.setString(
          'cachedMunicipalities',
          jsonEncode(
            _mapMunicipalities['municipalities']
                ?.map((e) => e.toJson())
                .toList(),
          ),
        );
      } else {
        print("Error loading municipalities: ${response.message}");
      }
    } catch (e) {
      print("Exception loading municipalities: $e");
    }

    isLoadingData = false;
    if (_isMounted) {
      notifyListeners();
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

  Future<void> _applyMarketShareColorToPolygon(CustomPolygon polygon, BuildContext context) async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response =
          await client.getMarketShareForTown(polygon.label, context);

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
          newColor = Colors.grey; // Color gris para municipios sin datos
        } else if (empateMax && secondMaxParticipacion > 0) {
          // En caso de empate, usar el color de la localidad con mayor participación
          newColor = localidadColors[localidadConMayorParticipacion] ?? Colors.grey;
        } else if (!empateMax && localidadConMayorParticipacion != null) {
          // Sin empate, usar el color de la localidad dominante
          newColor = localidadColors[localidadConMayorParticipacion] ?? Colors.grey;
        } else {
          // Fallback: usar gris si no se puede determinar
          newColor = Colors.grey;
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
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getMarketShareForTown(town, context);
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
                                }),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    fetchAndShowSuggestions(context, town);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                  ),
                                  child: const Text('Sugerencia de POS'),
                                ),
                              ],
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
        _showErrorDialog(
            context, "Error loading market share: ${response.message}");
      }
    } catch (e) {
      print("Exception loading market share: $e");
      _showErrorDialog(context, "Exception loading market share: $e");
    }
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

  void _showErrorDialog(BuildContext context, String message) {
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

  void _showNoSuggestionsDialog(BuildContext context, String town) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.only(
                top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Información",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "No hay sugerencias de POS para $town",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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
        );
      },
    );
  }

  void showMarkerDetails(BuildContext context, Marker marker) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Marker Details'),
        content: Text('Details for marker: ${marker.markerId}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAndShowSuggestions(
      BuildContext context, String town) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosTypePredictions,
        context: context,
        useCache: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final townData = data.firstWhere(
          (item) => item['town'].toString().toUpperCase() == town.toUpperCase(),
          orElse: () => null,
        );

        if (townData == null) {
          _showNoSuggestionsDialog(context, town);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PosSuggestionsScreen(
              town: townData['town'],
              currentLeader: townData['currentLeader'],
              pointsToLeader: townData['pointsToLeader'].toString(),
              posTypePredictions: townData['posTypePredictions'],
            ),
          ),
        );
      } else {
        _showErrorDialog(
            context, 'Error al consultar API: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error: $e');
    }
  }
}

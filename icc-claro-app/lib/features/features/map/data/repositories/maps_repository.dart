// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/classes/custom_polygon.dart';
import 'package:icc_claro_app/core/utils/classes/customer_marker.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';

class MapsRepository {
  MapsRepository();

  // URLs base - ahora usando endpoints centralizados

  Future<MessageResponse?> filterSale({
    required int posLocationId,
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
    required VoidCallback onReload,
    required BuildContext context,
  }) async {
    try {
      final List<dynamic> jsonApi = await _fetchPosLocations(context);
      if (jsonApi.isEmpty) {
        return MessageResponse(ok: false, message: "No se encontraron datos.");
      }

      final GetMarkersUseCase markersUseCase = GetMarkersUseCase(this);
      final filteredMarkers = await _filterMarkers(
        jsonApi,
        posLocationId,
        posLocationName,
        posManager,
        posAddress,
        centro,
        posZoneDescription,
        locType,
        operador,
        posTown,
        centrosComerciales,
        locDescription,
        markersUseCase.svgToBitmapDescriptor,
        context,
        () {
          print("🔄 UI actualizada sin recargar marcadores");
        },
      );

      return MessageResponse(
        ok: true,
        content: filteredMarkers,
        additionalContent: jsonApi,
      );
    } catch (e) {
      print("❌ Excepción en filterSale: $e");
      return MessageResponse(
        ok: false,
        message: "Error de conexión al servidor: $e",
      );
    }
  }

  Future<List<dynamic>> _fetchPosLocations(BuildContext context) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosLocationsInfo,
        context: context,
        useCache: true, // Usar caché para optimizar
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonApi = jsonDecode(response.body);
        return jsonApi;
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error en _fetchPosLocations: $e");
      rethrow;
    }
  }

  Future<List<Marker>> _filterMarkers(
    List<dynamic> jsonApi,
    int posLocationId,
    String posLocationName,
    String posManager,
    String posAddress,
    String centro,
    String posZoneDescription,
    String locType,
    String operador,
    String posTown,
    bool centrosComerciales,
    String locDescription,
    Future<BitmapDescriptor> Function(String, String) svgToBitmapDescriptor,
    BuildContext context,
    VoidCallback onReload,
  ) async {
    final filteredData = jsonApi.where((feature) {
      bool matches = feature['posLocationName']
              .toString()
              .toLowerCase()
              .contains(posLocationName.toLowerCase()) &&
          feature['manager']
              .toString()
              .toLowerCase()
              .contains(posManager.toLowerCase()) &&
          feature['posAddress']
              .toString()
              .toLowerCase()
              .contains(posAddress.toLowerCase()) &&
          feature['locType']
              .toString()
              .toLowerCase()
              .contains(locType.toLowerCase()) &&
          feature['posZoneDescription']
              .toString()
              .toLowerCase()
              .contains(posZoneDescription.toLowerCase()) &&
          feature['posOperator']
              .toString()
              .toLowerCase()
              .contains(operador.toLowerCase()) &&
          feature['posTown']
              .toString()
              .toLowerCase()
              .contains(posTown.toLowerCase()) &&
          feature['locDescription']
              .toString()
              .toLowerCase()
              .contains(locDescription.toLowerCase());

      if (posLocationId != -1) {
        return matches &&
            feature['posLocationId'].toString() == posLocationId.toString();
      }
      return matches;
    }).toList();

    return _convertToMarkers(
        filteredData, svgToBitmapDescriptor, context, onReload);
  }

  Future<List<Marker>> _convertToMarkers(
    List<dynamic> filteredData,
    Future<BitmapDescriptor> Function(String, String) svgToBitmapDescriptor,
    BuildContext context,
    VoidCallback onReload,
  ) async {
    List<Marker> markers = [];

    for (var feature in filteredData) {
      try {
        final latitude =
            double.tryParse(feature['latitude']?.toString() ?? '') ?? 0.0;
        final longitude =
            double.tryParse(feature['longitude']?.toString() ?? '') ?? 0.0;

        if (latitude == 0.0 || longitude == 0.0) continue;

        BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
        final posIcon = feature['posIcon'];
        final String svgString = posIcon?['iconSource'] ?? '';
        final String fillColor = posIcon?['iconFillColor'] ?? '#FF0000';

        if (svgString.isNotEmpty) {
          icon = await svgToBitmapDescriptor(svgString, fillColor);
        }

        markers.add(
          Marker(
            markerId: MarkerId(feature['posLocationId'].toString()),
            position: LatLng(latitude, longitude),
            icon: icon,
            onTap: () {
              showMarkerDetails(context, feature, onReload);
              // print("📍 Marcador seleccionado: ${feature['posLocationName']}");
            },
          ),
        );
      } catch (e) {
        print("⚠️ Error al procesar marcador: $e");
      }
    }

    onReload();
    return markers;
  }

  Future<List<dynamic>> fetchPosLocations() async {
    // Este método se mantiene por compatibilidad pero requiere contexto
    // Los llamadores deben usar _fetchPosLocations con contexto
    throw UnimplementedError('Este método requiere BuildContext. Use _fetchPosLocations con contexto.');
  }

  Future<MessageResponse> findMunicipalities() async {
    final uri = Uri.parse(ApiEndpoints.municipalitiesGeoJson);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };

    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw HttpException(
            "API error. Status code: ${apiResponse.statusCode}");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);

      final List<CustomPolygon> polygons =
          (jsonApi['features'] as List).map((feature) {
        final geometry = feature['geometry'];
        final coordinates = geometry['coordinates'][0] as List;

        if (geometry['type'] != 'Polygon' || coordinates.isEmpty) {
          throw const FormatException("Invalid coordinates");
        }

        final List<LatLng> points = coordinates.map<LatLng>((coord) {
          final lng = coord[0] as double;
          final lat = coord[1] as double;
          return LatLng(lat, lng);
        }).toList();

        return CustomPolygon(
          points: points,
          borderColor: Colors.black,
          borderStrokeWidth: 1.0,
          color: Colors.lightBlue.withOpacity(0.3), // Color base más visible
          label: feature['properties']['NAME'] ?? '',
        );
      }).toList();

      return MessageResponse(
        ok: true,
        content: polygons,
        additionalContent: jsonApi,
      );
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> findMalls(BuildContext context) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.findPosGroupsWithLocRef,
        context: context,
        useCache: true, // Usar caché para centros comerciales
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonApi = jsonDecode(response.body);

        // Restaurando toda la lógica para mantener íconos y detalles
        final List<Marker> markers =
            await Future.wait(jsonApi.map<Future<Marker>>((mall) async {
          if (mall is! Map<String, dynamic> || mall['group_ID'] == null) {
            throw Exception("Invalid mall data: $mall");
          }

          final Map<String, dynamic>? groupIcon = mall['groupIcon'];
          String svgIcon = "";
          String fillColorHex = "#FF0000";

          if (groupIcon != null) {
            svgIcon = groupIcon['iconSource'] ?? "";
            fillColorHex = groupIcon['iconFillColor'] ?? "#FF0000";
          }

          final List<Map<String, String>> locations =
              (mall['posLocationList'] as List?)
                      ?.map<Map<String, String>>((location) => {
                            'location_NAME': location['location_NAME'] ?? '',
                            'location_ADDRESS':
                                location['location_ADDRESS'] ?? '',
                          })
                      .toList() ??
                  [];

          final List<Map<String, String>> marketShareDetailList =
              (mall['marketShareDetailList'] as List?)
                      ?.map<Map<String, String>>((detail) => {
                            'localidad': detail['localidad'] ?? '',
                            'porcientoParticipacion':
                                detail['porcientoParticipacion'] ?? '',
                          })
                      .toList() ??
                  [];

          return await MarkerEntity.toMall(
            context: context,
            groupId: mall['group_ID'],
            groupName: mall['group_NAME'] ?? '',
            groupDescription: mall['group_DESCRIPTION'] ?? '',
            town: mall['town'] ?? '',
            locations: locations,
            marketShareDetailList: marketShareDetailList,
            latitude: mall['latitude'] != null && mall['latitude'].isNotEmpty
                ? double.parse(mall['latitude'])
                : 0.0,
            longitude: mall['longitude'] != null && mall['longitude'].isNotEmpty
                ? double.parse(mall['longitude'])
                : 0.0,
            svgString: svgIcon,
            iconFillColor: fillColorHex,
          );
        }).toList());

        return MessageResponse(
          ok: true,
          content: markers,
          additionalContent: jsonApi,
        );
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }

  Future<MessageResponse> getMarketShareForTown(String town, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getMarketShareForTown,
        queryParameters: {'town': town},
        context: context,
        useCache: true, // Usar caché para datos de market share
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getPosLovByType(String lovType, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosLovByType,
        queryParameters: {'lovType': lovType},
        context: context,
        useCache: true, // Usar caché para LOVs
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> findSales(int posLocationId) {
    throw UnimplementedError();
  }

  Future<MessageResponse> getPosLocDropdownInputs([BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosLocDropdownInputs,
        context: context,
        useCache: true, // Usar caché para dropdowns
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getAgentCode(String searchTerm, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getAllMatchPosDealers,
        queryParameters: {'searchTerm': searchTerm},
        context: context,
        useCache: false, // No usar caché para búsquedas
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getFixedAgentCode(String searchTerm, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getAllMatchPosFixedDealers,
        queryParameters: {'searchTerm': searchTerm},
        context: context,
        useCache: false, // No usar caché para búsquedas
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getTownDemographic(String selectedTown, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getTownDemographic,
        queryParameters: {'selectedTown': selectedTown},
        context: context,
        useCache: true, // Usar caché para datos demográficos
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getMarketShareValue(
      int selectedType, int selectedOperator, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getMarketShareValue,
        queryParameters: {
          'selectedType': selectedType.toString(),
          'selectedOperator': selectedOperator.toString(),
        },
        context: context,
        useCache: true, // Usar caché para valores de market share
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getTowns([BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getTowns,
        context: context,
        useCache: true, // Usar caché para lista de pueblos
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  Future<MessageResponse> getAllLocations(String selectedTown, [BuildContext? context]) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosLocationsReferencesByTown,
        queryParameters: {'town': selectedTown},
        context: context,
        useCache: true, // Usar caché para ubicaciones por pueblo
      );

      if (response.statusCode == 200) {
        final jsonApi = jsonDecode(response.body);
        return MessageResponse(ok: true, content: jsonApi);
      } else {
        throw Exception("Error en API: Código ${response.statusCode}");
      }
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }
}

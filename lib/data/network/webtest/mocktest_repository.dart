// ignore_for_file: override_on_non_overriding_member, unnecessary_type_check

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/entities/marker_entity.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/sale_repository.dart';
import 'package:icc_maps/ui/pages/map/type/custom_polygon.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

class MocktestClient extends SaleRepository {
  static const _saleURL =
      "https://webtest/icc/api/getPosLocationsInfo";
  // "http://192.168.1.5:8082/getPosLocationsInfo";
  // "http://192.168.1.5:8080/api/pos-location/getPosLocationsInfo";
  static const _municipalitiesURL =
      "https://webtest/geojson/municipalities.geojson?d=2";
  // "http://192.168.1.5:8082/municipalities";
  static const _marketShareURL =
      "https://webtest/icc/api/getMarketShareForTown?town=";
  // "http://192.168.1.5:8082/getMarketShareForTown?town=";
  static const _posLovByTypeURL =
      "https://webtest/icc/api/getPosLovByType?lovType=";
  // "http://192.168.1.5:8082/getPosLovByType?lovType=";
  static const _getPosLocDropdownInputsURL =
      "https://webtest/icc/api/getPosLocDropdownInputs";
  // "http://192.168.1.5:8082/getPosLovByType?lovType=";
  static const _mallURL =
      "https://webtest/icc/api/findPosGroupsWithLocRef";
  // "http://192.168.1.5:8082/findPosGroupsWithLocRef";

  @override
  Future<MessageResponse> filterSale({
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
  }) async {
    final uri = Uri.parse(_saleURL);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException("API error: Polygon not found");
      }
      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);

      final filterJson = (jsonApi as List).where((feature) {
        var containsString = (feature['posLocationName']
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
                .contains(locDescription.toLowerCase()));

        if (feature['closeDate'] != null) {
          return false;
        }

        if (posLocationId != -1) {
          var containsId = feature['posLocationId']
              .toString()
              .contains(posLocationId.toString());
          if (!centrosComerciales) {
            return containsString && containsId;
          } else {
            return containsString &&
                containsId &&
                feature['centrosComerciales'] == centrosComerciales;
          }
        }
        if (!centrosComerciales) {
          return containsString;
        } else {
          return containsString &&
              feature['centrosComerciales'] == centrosComerciales;
        }
      });

      final jsonData = _convertToGeoJson(filterJson.toList());
      final baseCoordinates = json.decode(jsonData);
      final features = (baseCoordinates["features"] as List);

      final List<Marker> markers = features.map((feature) {
        final coordinates = feature['geometry']['coordinates'];
        final properties = feature['properties'];

        if (coordinates == null || coordinates.length < 2) {
          throw const FormatException("Invalid coordinates");
        }

        return MarkerEntity.toSale(
          posLocationId: properties['posLocationId'],
          latitude: coordinates[1],
          longitude: coordinates[0],
          iconSource: properties['posIcon']['iconSource'],
          posLocationName: properties['posLocationName'],
          locType: properties['locType'],
          locDescription: properties['locDescription'],
          posLocationCode: properties['posLocationCode'] ?? "N/A",
          posOperator: properties['posOperator'],
          posDemographics: properties['posDemographics'],
          posTown: properties['posTown'],
          posAddress: properties['locDescription'],
          posZone: properties['posZone'],
          posZoneDescription: properties['posZoneDescription'],
          posManager: properties['manager'] ?? "N/A",
          posAssistant: properties['assistant'] ?? "N/A",
          channel: properties['channel'],
          posShareMktValue: properties['posShareMktValue'],
          posDealer: properties['posDealer'] ?? "N/A",
          iconFillColor: properties['posIcon']['iconFillColor'],
          iconStrokeColor: properties['posIcon']['iconStrokeColor'],
          iconViewBox: properties['posIcon']['iconViewBox'],
          onReload: onReload,
        );
      }).toList();
      onReload();
      return MessageResponse(
          ok: true, content: markers, additionalContent: jsonApi);
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }

  String _convertToGeoJson(List<dynamic> items) {
    Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "features": items
          .map((item) => {
                "type": "Feature",
                "geometry": {
                  "type": "Point",
                  "coordinates": [
                    double.parse(item['longitude']),
                    double.parse(item['latitude'])
                  ]
                },
                "properties": item
              })
          .toList()
    };
    return jsonEncode(geoJson);
  }

  @override
  Future<MessageResponse> findMalls() async {
    final uri = Uri.parse(_mallURL);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException(
            "API error in findMalls. StatusCode (${apiResponse.statusCode})");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);
      final List<Marker> markers = (jsonApi as List).expand<Marker>((mall) {
        if (mall['group_ID'] == null) {
          throw Exception("group_ID is null for mall: ${mall['group_NAME']}");
        }
        final List<Map<String, String>> locations =
            (mall['posLocationList'] != null)
                ? (mall['posLocationList'] as List)
                    .map<Map<String, String>>((location) {
                    return {
                      'location_NAME': location['location_NAME'] ?? '',
                      'location_ADDRESS': location['location_ADDRESS'] ?? '',
                    };
                  }).toList()
                : [];
        final List<Map<String, String>> marketShareDetailList =
            (mall['marketShareDetailList'] != null)
                ? (mall['marketShareDetailList'] as List)
                    .map<Map<String, String>>((detail) {
                    return {
                      'localidad': detail['localidad'] ?? '',
                      'porcientoParticipacion':
                          detail['porcientoParticipacion'] ?? '',
                    };
                  }).toList()
                : [];

        return [
          MarkerEntity.toMall(
            groupId: mall['group_ID'],
            groupName: mall['group_NAME'],
            groupDescription: mall['group_DESCRIPTION'],
            town: mall['town'],
            locations: locations,
            latitude: mall['latitude'] != null && mall['latitude'].isNotEmpty
                ? double.parse(mall['latitude'])
                : 0.0,
            longitude: mall['longitude'] != null && mall['longitude'].isNotEmpty
                ? double.parse(mall['longitude'])
                : 0.0,
            marketShareDetailList: marketShareDetailList,
          )
        ];
      }).toList();

      return MessageResponse(
        ok: true,
        content: markers,
        additionalContent: jsonApi,
      );
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findMunicipalities() async {
    final uri = Uri.parse(_municipalitiesURL);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);

      final List<CustomPolygon> polygons =
          (jsonApi['features'] as List).map((feature) {
        final geometry = feature['geometry'];
        final coordinates = geometry['coordinates'][0] as List;

        if (geometry['type'] != 'Polygon' ||
            coordinates is! List ||
            coordinates.isEmpty) {
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
          borderStrokeWidth: 1,
          color: const Color(0xFF5D5D5D).withOpacity(0.3),
          label: feature['properties']['NAME'] ?? '',
        );
      }).toList();

      return MessageResponse(
          ok: true, content: polygons, additionalContent: jsonApi);
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }
  
  @override
  Future<MessageResponse> getMarketShareForTown(String town) async {
    final uri = Uri.parse("$_marketShareURL$town");
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();
      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();

      final jsonApi = jsonDecode(apiData);

      return MessageResponse(ok: true, content: jsonApi);
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  @override
  Future<MessageResponse> getPosLovByType(String lovType) async {
    final uri = Uri.parse("$_posLovByTypeURL$lovType");
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);

      return MessageResponse(ok: true, content: jsonApi);
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findSales(int posLocationId) {
    throw UnimplementedError();
  }

  Future<MessageResponse> getPosLocDropdownInputs() async {
    final uri = Uri.parse(_getPosLocDropdownInputsURL);
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getAgentCode(String searchTerm) async {
    final uri = Uri.parse(
        "https://webtest/icc/api/getAllMatchPosDealers?searchTerm=$searchTerm");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getFixedAgentCode(String searchTerm) async {
    final uri = Uri.parse(
        "https://webtest/icc/api/getAllMatchPosFixedDealers?searchTerm=$searchTerm");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getTownDemographic(String selectedTown) async {
    final uri = Uri.parse(
        "https://webtest/icc/api/getTownDemographic?selectedTown=$selectedTown");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getMarketShareValue(
      int selectedType, int selectedOperator) async {
    final uri = Uri.parse(
        "https://webtest/icc/api/getMarketShareValue?selectedType=$selectedType&selectedOperator=$selectedOperator");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getTowns() async {
    final uri = Uri.parse("https://webtest/icc/api/getTowns");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> getAllLocations(String selectedTown) async {
    final uri = Uri.parse(
        "https://webtest/icc/api/getPosLocationsReferencesByTown?town=$selectedTown");
    return await _fetchFromApi(uri);
  }

  Future<MessageResponse> _fetchFromApi(Uri uri) async {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");
      }

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);

      return MessageResponse(ok: true, content: jsonApi);
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
    }
  }
}



/*Future<MessageResponse> findSales(int posLocationId,
      {required VoidCallback onReload}) async {
    final uri = Uri.parse(_saleURL);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok) {
        throw ClientException("API error: Polygon not found");
      }
      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);
      final jsonData = _convertToGeoJson(jsonApi);
      final baseCoordinates = json.decode(jsonData);
      final features = baseCoordinates["features"] as List;

      final List<Marker> markers = features.map((feature) {
        final coordinates = feature['geometry']['coordinates'];
        final properties = feature['properties'];

        if (coordinates == null || coordinates.length < 2) {
          throw const FormatException("Invalid coordinates");
        }
        return MarkerEntity.toSale(
          posLocationId: properties['posLocationId'],
          latitude: coordinates[1],
          longitude: coordinates[0],
          iconSource: properties['posIcon']['iconSource'],
          posLocationName: properties['posLocationName'],
          locType: properties['locType'],
          locDescription: properties['locDescription'],
          posLocationCode: properties['posLocationCode'],
          posOperator: properties['posOperator'],
          posDemographics: properties['posDemographics'],
          posTown: properties['posTown'],
          posAddress: properties['locDescription'],
          posZone: properties['posZone'],
          posZoneDescription: properties['posZoneDescription'],
          posManager: properties['posManager'],
          posAssistant: properties['posAssistant'],
          channel: properties['channel'],
          posShareMktValue: properties['posShareMktValue'],
          posDealer: properties['posDealer'],
          iconFillColor: properties['posIcon']['iconFillColor'],
          iconStrokeColor: properties['posIcon']['iconStrokeColor'],
          iconViewBox: properties['posIcon']['iconViewBox'],
          onReload: () {},
        );
      }).toList();
      return MessageResponse(
          ok: true, content: markers, additionalContent: jsonApi);
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }*/
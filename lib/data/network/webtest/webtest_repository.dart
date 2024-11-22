// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/entities/marker_entity.dart';
import 'package:icc_maps/data/entities/polygon_entity.dart';
import 'package:icc_maps/data/network/api_repository.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/utils/hex_color.dart';
import 'package:http/http.dart';

class WebtestClient extends ApiRepository {
  static const _prefix = "https://webtest.prt.local/icc/api";
  // static const _prefix = "http://192.168.1.5:8082";

  static const _antennasURL = "$_prefix/getBaseCoords?polygonTypeID=";
  static const _coverageURL = "$_prefix/getPolygonTypes";

  @override
  Future<MessageResponse> findAntennas(int polygonTypeId) async {
    final uri = Uri.parse(_antennasURL + polygonTypeId.toString());
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // print("BAD CERTIFICATE -> host=$host | port=$port | cert=$cert");
        return true;
      };
    // print(client);

    try {
      final apiRequest = await client.getUrl(uri);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok)
        throw ClientException("API error: Polygon not found");

      final String apiData = await apiResponse.transform(utf8.decoder).join();
      final jsonApi = jsonDecode(apiData);
      final jsonData = _convertToGeoJson(jsonApi);
      final baseCoordinates = json.decode(jsonData);
      final features = baseCoordinates["features"] as List;

      final List<Marker> markers = features.map((feature) {
        final coordinates = feature['geometry']['coordinates'];
        final properties = feature['properties'];

        return MarkerEntity.toMarker(
            polygonTypeId: polygonTypeId,
            lat: coordinates[1],
            lon: coordinates[0],
            siteName: properties['site_NAME'],
            siteId: properties['site_ID']);
      }).toList();
      return MessageResponse(
          ok: true, content: markers, additionalContent: jsonApi);
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findCoverages(int id) async {
    final url = Uri.parse(_coverageURL);
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // print("BAD CERTIFICATE -> host=$host | port=$port | cert=$cert");
        return true;
      };

    try {
      final apiRequest = await client.getUrl(url);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok)
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");

      final apiData = await utf8.decodeStream(apiResponse);
      final List<dynamic> polygonTypesList = jsonDecode(apiData);

      final polygonType = polygonTypesList
          .firstWhere(orElse: () => <String, dynamic>{}, (polygon) {
        if (polygon is Map)
          return polygon["polygon_TYPE_ID"] == id;
        else
          return false;
      });

      if (polygonType.isEmpty)
        throw ClientException("API error: Polygon not found");

      final polygonURL = Uri.parse(polygonType["polygon_URL"]);
      final polygonColor = HexColor(polygonType["polygon_COLOR"]);

      final MessageResponse polygonsResponse = await findGeoJson(
          url: polygonURL, color: polygonColor, client: client);
      if (!polygonsResponse.ok) throw ClientException(polygonsResponse.message);

      return MessageResponse(
          ok: true,
          content: polygonsResponse.content,
          additionalContent: polygonType);
    } catch (e) {
      return MessageResponse(message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findGeoJson(
      {required Uri url, required Color color, HttpClient? client}) async {
    client ??= HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // print("BAD CERTIFICATE -> host=$host | port=$port | cert=$cert");
        return true;
      };

    try {
      final apiRequest = await client.getUrl(url);
      final apiResponse = await apiRequest.close();

      if (apiResponse.statusCode != HttpStatus.ok)
        throw ClientException(
            "API error. StatusCode (${apiResponse.statusCode})");

      final gzipData =
          await apiResponse.expand((List<int> chunk) => chunk).toList();
      final polygons = PolygonEntity.toPolygons(gzipData, color);
      return MessageResponse(ok: true, content: polygons);
    } catch (e) {
      return MessageResponse(ok: false, message: e.toString());
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
                    double.parse(item['coord_LON']),
                    double.parse(item['coord_LAT'])
                  ]
                },
                "properties": item
              })
          .toList()
    };
    return jsonEncode(geoJson);
  }
}

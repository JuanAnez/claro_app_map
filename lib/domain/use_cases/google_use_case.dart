import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_maps/data/entities/polygon_entity.dart';
import 'package:icc_maps/data/network/webtest/google_client.dart';

class GoogleUseCase {
  final GoogleClient _client = GoogleClient();

  Future<List<Polygon>> getPolygonsById(int polygonTypeId) async {
    final polygonTypes = await _client.fetchPolygonTypes();
    final selectedPolygon = polygonTypes.firstWhere(
      (polygon) => polygon["polygon_TYPE_ID"] == polygonTypeId,
      orElse: () => throw Exception("Polygon not found."),
    );

    if (selectedPolygon["polygon_URL"] == null) {
      throw Exception("Polygon URL is missing.");
    }

    final geoJson = await _client.fetchGeoJsonGzip(Uri.parse(selectedPolygon["polygon_URL"]));
    final color = _hexToColor(selectedPolygon["polygon_COLOR"]);

    return PolygonEntity.fromGeoJson(geoJson, color);
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

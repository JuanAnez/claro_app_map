import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class PolygonGoogleEntity {
  static List<Polygon> toPolygons(List<int> gzipData, Color polygonColor) {
    final gzipDecode = GZipCodec().decode(gzipData);
    final String gzipString = utf8.decode(gzipDecode);
    final geoJsonObject = jsonDecode(gzipString);

    final List<Polygon> polygons = [];

    if (geoJsonObject["features"] != null) {
      for (var feature in geoJsonObject["features"]) {
        if (feature["geometry"] != null) {
          String geometryType = feature["geometry"]["type"];
          List<dynamic> coordinates = feature["geometry"]["coordinates"];

          if (geometryType == "Polygon") {
            List<LatLng> polygonPoints = _parsePolygonCoordinates(coordinates);
            polygons.add(
              Polygon(
                polygonId: PolygonId(feature["properties"]["name"] ??
                    feature["id"] ??
                    'defaultId'),
                points: polygonPoints,
                strokeWidth: 2,
                strokeColor: polygonColor,
                fillColor: polygonColor.withOpacity(0.4),
              ),
            );
          } else if (geometryType == "MultiPolygon") {
            for (var polygon in coordinates) {
              List<LatLng> polygonPoints = _parsePolygonCoordinates(polygon);
              polygons.add(
                Polygon(
                  polygonId: PolygonId(feature["properties"]["name"] ??
                      feature["id"] ??
                      'defaultId'),
                  points: polygonPoints,
                  strokeWidth: 1,
                  strokeColor: polygonColor,
                  fillColor: polygonColor.withOpacity(0.4),
                ),
              );
            }
          }
        }
      }
    }

    // print("Generated Polygons: $polygons");
    return polygons;
  }

  static List<LatLng> _parsePolygonCoordinates(List<dynamic> coordinates) {
    List<LatLng> polygonPoints = [];
    for (var ring in coordinates) {
      for (var coordinate in ring) {
        double lat = _convertToDouble(coordinate[1]);
        double lon = _convertToDouble(coordinate[0]);
        polygonPoints.add(LatLng(lat, lon));
      }
    }
    return polygonPoints;
  }

  static double _convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw Exception('Valor no soportado para conversión a double: $value');
    }
  }
}

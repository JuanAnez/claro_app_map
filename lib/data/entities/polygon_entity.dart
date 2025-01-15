// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_geojson/flutter_map_geojson.dart';

// class PolygonEntity {
//   static List<Polygon> toPolygons(List<int> gzipData, Color polygonColor) {
//     final gzipDecode = GZipCodec().decode(gzipData);
//     final String gzipString = utf8.decode(gzipDecode);
//     final geoJsonObject = jsonDecode(gzipString);

//     final modifiedGeoJsonObject = _convertIntsToDoubles(geoJsonObject);
//     final modifiedGeoJsonString = jsonEncode(modifiedGeoJsonObject);

//     final GeoJsonParser geoJsonParser = GeoJsonParser(
//         defaultPolygonBorderColor: polygonColor,
//         defaultPolygonFillColor: polygonColor.withOpacity(0.1),
//         defaultCircleMarkerColor: Colors.blue.withOpacity(0.1));
//     geoJsonParser.parseGeoJsonAsString(modifiedGeoJsonString);
//     return geoJsonParser.polygons;
//   }

//   static dynamic _convertIntsToDoubles(dynamic item) {
//     if (item is Map) {
//       item.forEach((key, value) {
//         item[key] = _convertIntsToDoubles(value);
//       });
//     } else if (item is List) {
//       return item.map((value) => _convertIntsToDoubles(value)).toList();
//     } else if (item is int) {
//       return item.toDouble();
//     }
//     return item;
//   }
// }
import 'dart:convert';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonEntity {
  static List<Polygon> fromGeoJson(String geoJson, Color color) {
    final Map<String, dynamic> data = jsonDecode(geoJson);
    final List<dynamic> features = data["features"];

    List<Polygon> polygons = [];

    for (var feature in features) {
      final geometry = feature["geometry"];
      final coordinates = geometry["coordinates"];

      if (geometry["type"] == "MultiPolygon") {
        for (var polygon in coordinates) {
          polygons.add(_createPolygon(polygon, feature, color));
        }
      } else if (geometry["type"] == "Polygon") {
        polygons.add(_createPolygon(coordinates, feature, color));
      }
    }

    return polygons;
  }

  static Polygon _createPolygon(
  List<dynamic> coordinates,
  Map<String, dynamic> feature,
  Color color,
) {
  final points = coordinates[0]
      .map<LatLng>((coord) => LatLng(
            _toDouble(coord[1]),
            _toDouble(coord[0]),
          ))
      .toList();

  return Polygon(
    polygonId: PolygonId(feature["id"] ?? "default"),
    points: points,
    strokeWidth: 1,
    strokeColor: color,
    fillColor: color.withOpacity(0.3),
  );
}

static double _toDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else {
    throw Exception("Unexpected coordinate value: $value");
  }
}


  static toPolygons(List<int> gzipData, Color color) {}
}

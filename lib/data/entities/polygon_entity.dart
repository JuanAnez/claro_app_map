import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

class PolygonEntity {
  static List<Polygon> toPolygons(List<int> gzipData, Color polygonColor) {
    final gzipDecode = GZipCodec().decode(gzipData);
    final String gzipString = utf8.decode(gzipDecode);
    final geoJsonObject = jsonDecode(gzipString);

    final modifiedGeoJsonObject = _convertIntsToDoubles(geoJsonObject);
    final modifiedGeoJsonString = jsonEncode(modifiedGeoJsonObject);

    final GeoJsonParser geoJsonParser = GeoJsonParser(
        defaultPolygonBorderColor: polygonColor,
        defaultPolygonFillColor: polygonColor.withOpacity(0.1),
        defaultCircleMarkerColor: Colors.blue.withOpacity(0.1));
    geoJsonParser.parseGeoJsonAsString(modifiedGeoJsonString);
    return geoJsonParser.polygons;
  }

  static dynamic _convertIntsToDoubles(dynamic item) {
    if (item is Map) {
      item.forEach((key, value) {
        item[key] = _convertIntsToDoubles(value);
      });
    } else if (item is List) {
      return item.map((value) => _convertIntsToDoubles(value)).toList();
    } else if (item is int) {
      return item.toDouble();
    }
    return item;
  }
}

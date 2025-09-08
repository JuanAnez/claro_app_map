import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/config/memory_config.dart';

class PolygonEntity {
  final String id;
  final List<LatLng> points;
  final Color color;

  PolygonEntity({
    required this.id,
    required this.points,
    required this.color,
  });

  // Constantes para optimización de memoria
  static const double _coordinatePrecision = MemoryConfig.coordinatePrecision;
  static const int _maxPointsPerPolygon = MemoryConfig.maxPointsPerPolygon;

  static List<PolygonEntity> fromGzipToEntities(
      List<int> gzipData, Color polygonColor) {
    final gzipDecode = GZipCodec().decode(gzipData);
    final String geoJsonString = utf8.decode(gzipDecode);
    final geoJson = jsonDecode(geoJsonString);

    print("GeoJSON Descomprimido: $geoJsonString");
    print("GeoJSON Parseado: $geoJson");

    if (!geoJson.containsKey('features') || geoJson['features'].isEmpty) {
      throw Exception("GeoJSON no contiene features.");
    }

    final List<PolygonEntity> polygons = [];
    for (var feature in geoJson['features']) {
      final id =
          feature['properties']?['id']?.toString() ?? UniqueKey().toString();
      final geometryType = feature['geometry']['type'];
      final coordinates = feature['geometry']['coordinates'];

      if (geometryType == 'MultiPolygon') {
        for (var polygon in coordinates) {
          final points = _simplifyCoordinates(polygon[0]);
          if (points.isNotEmpty) {
            polygons.add(
              PolygonEntity(
                id: id,
                points: points,
                color: polygonColor,
              ),
            );
          }
        }
      } else if (geometryType == 'Polygon') {
        final points = _simplifyCoordinates(coordinates[0]);
        if (points.isNotEmpty) {
          polygons.add(
            PolygonEntity(
              id: id,
              points: points,
              color: polygonColor,
            ),
          );
        }
      } else {
        print("Geometría no soportada: $geometryType");
      }
    }

    return polygons;
  }

  static List<Polygon> toGoogleMapPolygons(List<PolygonEntity> entities) {
    return entities.map((entity) {
      return Polygon(
        polygonId: PolygonId(entity.id),
        points: entity.points,
        strokeColor: entity.color,
        fillColor: entity.color.withOpacity(0.3),
        strokeWidth: 2,
      );
    }).toList();
  }

  static List<Polygon> fromGeoJson(String geoJson, Color color) {
    final Map<String, dynamic> data = jsonDecode(geoJson);
    final List<dynamic> features = data["features"];

    List<Polygon> polygons = [];

    for (var feature in features) {
      final geometry = feature["geometry"];
      final coordinates = geometry["coordinates"];

      if (geometry["type"] == "MultiPolygon") {
        for (var polygon in coordinates) {
          final points = _simplifyCoordinates(polygon[0]);
          if (points.isNotEmpty) {
            polygons.add(_createPolygon(points, feature, color));
          }
        }
      } else if (geometry["type"] == "Polygon") {
        final points = _simplifyCoordinates(coordinates[0]);
        if (points.isNotEmpty) {
          polygons.add(_createPolygon(points, feature, color));
        }
      }
    }

    return polygons;
  }

  // Método para simplificar coordenadas y reducir memoria
  static List<LatLng> _simplifyCoordinates(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return [];
    
    List<LatLng> points = [];
    List<LatLng> simplifiedPoints = [];
    
    // Convertir a LatLng
    for (var coord in coordinates) {
      if (coord.length >= 2) {
        final lat = _toDouble(coord[1]);
        final lng = _toDouble(coord[0]);
        points.add(LatLng(lat, lng));
      }
    }
    
    if (points.isEmpty) return [];
    
    // Aplicar algoritmo de simplificación Douglas-Peucker
    simplifiedPoints = _douglasPeucker(points, _coordinatePrecision);
    
    // Limitar puntos si es necesario
    if (simplifiedPoints.length > _maxPointsPerPolygon) {
      simplifiedPoints = _limitPoints(simplifiedPoints, _maxPointsPerPolygon);
    }
    
    return simplifiedPoints;
  }

  // Algoritmo de simplificación Douglas-Peucker
  static List<LatLng> _douglasPeucker(List<LatLng> points, double epsilon) {
    if (points.length <= 2) return points;
    
    double maxDistance = 0;
    int index = 0;
    
    for (int i = 1; i < points.length - 1; i++) {
      double distance = _perpendicularDistance(points[i], points.first, points.last);
      if (distance > maxDistance) {
        maxDistance = distance;
        index = i;
      }
    }
    
    if (maxDistance > epsilon) {
      List<LatLng> result1 = _douglasPeucker(points.sublist(0, index + 1), epsilon);
      List<LatLng> result2 = _douglasPeucker(points.sublist(index), epsilon);
      return [...result1.sublist(0, result1.length - 1), ...result2];
    } else {
      return [points.first, points.last];
    }
  }

  // Calcular distancia perpendicular de un punto a una línea
  static double _perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
    if (lineStart.latitude == lineEnd.latitude && lineStart.longitude == lineEnd.longitude) {
      return _calculateDistance(point, lineStart);
    }
    
    double A = point.latitude - lineStart.latitude;
    double B = point.longitude - lineStart.longitude;
    double C = lineEnd.latitude - lineStart.latitude;
    double D = lineEnd.longitude - lineStart.longitude;
    
    double dot = A * C + B * D;
    double lenSq = C * C + D * D;
    double param = dot / lenSq;
    
    double xx, yy;
    if (param < 0) {
      xx = lineStart.latitude;
      yy = lineStart.longitude;
    } else if (param > 1) {
      xx = lineEnd.latitude;
      yy = lineEnd.longitude;
    } else {
      xx = lineStart.latitude + param * C;
      yy = lineStart.longitude + param * D;
    }
    
    return _calculateDistance(point, LatLng(xx, yy));
  }

  // Calcular distancia entre dos puntos
  static double _calculateDistance(LatLng p1, LatLng p2) {
    double lat1 = p1.latitude * pi / 180;
    double lat2 = p2.latitude * pi / 180;
    double deltaLat = (p2.latitude - p1.latitude) * pi / 180;
    double deltaLng = (p2.longitude - p1.longitude) * pi / 180;
    
    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return 6371000 * c; // Radio de la Tierra en metros
  }

  // Limitar número de puntos usando muestreo uniforme
  static List<LatLng> _limitPoints(List<LatLng> points, int maxPoints) {
    if (points.length <= maxPoints) return points;
    
    List<LatLng> limited = [];
    double step = (points.length - 1) / (maxPoints - 1);
    
    for (int i = 0; i < maxPoints; i++) {
      int index = (i * step).round();
      if (index >= points.length) index = points.length - 1;
      limited.add(points[index]);
    }
    
    return limited;
  }

  static Polygon _createPolygon(
      List<LatLng> coordinates,
      Map<String, dynamic> feature,
      Color color,
  ) {
    return Polygon(
      polygonId: PolygonId(feature["id"] ?? "default"),
      points: coordinates,
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
}

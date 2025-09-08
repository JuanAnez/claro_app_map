import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomPolygon {
  final List<LatLng> points;
  final Color borderColor;
  final double borderStrokeWidth;
  final Color color;
  final String label;

  CustomPolygon({
    required this.points,
    required this.borderColor,
    required this.borderStrokeWidth,
    required this.color,
    required this.label,
  });

  bool contains(LatLng point) {
    int intersectCount = 0;
    for (int j = 0; j < points.length - 1; j++) {
      if (rayCastIntersect(point, points[j], points[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1);
  }

  bool rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    final double aY = vertA.latitude;
    final double bY = vertB.latitude;
    final double aX = vertA.longitude;
    final double bX = vertB.longitude;
    final double pY = point.latitude;
    final double pX = point.longitude;

    if ((pY > aY && pY > bY) || (pY < aY && pY < bY) || (pX > aX && pX > bX)) {
      return false;
    }
    if (pX < aX && pX < bX) {
      return true;
    }

    final double m = (aY - bY) / (aX - bX);
    final double bee = -aX * m + aY;
    final double x = (pY - bee) / m;

    return x > pX;
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList(),
      'borderColor': borderColor.value,
      'borderStrokeWidth': borderStrokeWidth,
      'color': color.value,
      'label': label,
    };
  }

  factory CustomPolygon.fromJson(Map<String, dynamic> json) {
    return CustomPolygon(
      points: (json['points'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
      borderColor: Color(json['borderColor']),
      borderStrokeWidth: json['borderStrokeWidth'],
      color: Color(json['color']),
      label: json['label'],
    );
  }
}

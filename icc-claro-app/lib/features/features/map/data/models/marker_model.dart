import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerModel {
  final int id;
  final String name;
  final LatLng position;

  MarkerModel({
    required this.id,
    required this.name,
    required this.position,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      id: json['posLocationId'],
      name: json['posLocationName'] ?? 'Sin nombre',
      position: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
    );
  }
}

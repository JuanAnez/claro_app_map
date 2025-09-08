// ignore_for_file: prefer_collection_literals

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:provider/provider.dart';

class MallsMap extends StatefulWidget {
  const MallsMap({super.key});

  static const defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 9.5;

  @override
  State<MallsMap> createState() => _MallsMapState();
}

class _MallsMapState extends State<MallsMap> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapProvider>();

    return GoogleMap(
      onMapCreated: (controller) => provider.setMapController(controller),
      initialCameraPosition: const CameraPosition(
        target: LatLng(18.238384, -66.475422),
        zoom: 9,
      ),
      mapType: provider.mapType,
      markers: provider.markers,
      zoomControlsEnabled: false,
      onCameraMove: (CameraPosition position) {
        provider.checkBounds(position.target);
      },
    );
  }
}
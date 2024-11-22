// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/custom_map_tile_layer.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CustomMap extends StatelessWidget {
  const CustomMap({super.key});

  static const defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 8;
  static const double minZoom = 6;
  static const double maxZoom = 18;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();

    return Stack(children: [
      FlutterMap(
        mapController: mapProvider.mapController,
        options: MapOptions(
            initialCenter: defaultPosition,
            initialZoom: defaultZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
            onTap: (tapPosition, point) {
              _handleMapTap(context, point);
            },
            bounds: MapProvider.bounds,
            keepAlive: true,
            interactiveFlags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom,
            onPositionChanged: (MapPosition position, bool hasGesture) {
              mapProvider.checkBounds(mapProvider.mapController, position);
            }),
        children: [
          const CustomMapTileLayer(),
          PolygonLayer(polygons: mapProvider.mapCoverages),
          MarkerLayer(markers: mapProvider.mapAntennas),
          PolylineLayer(polylines: mapProvider.polyLines),
          CircleLayer(circles: mapProvider.circles),
        ],
      ),
      if (mapProvider.isInitialLoading) const SkeletonMap()
    ]);
  }

  void _handleMapTap(BuildContext context, LatLng point) {
    final mapProvider = context.read<MapProvider>();
    final coverages = mapProvider.getCoveragesContainingPoint(point);

    mapProvider.updateMarker(point);

    if (coverages.isNotEmpty && mapProvider.selectedButtons.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Coverages'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: coverages.map((coverage) => Text(coverage)).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:provider/provider.dart';

class CustomMap extends StatelessWidget {
  const CustomMap({super.key});

  static const LatLng defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 8.0;
  static const double minZoom = 6.0;
  static const double maxZoom = 18.0;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    if (mapProvider.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: defaultPosition,
          zoom: defaultZoom,
        ),
        markers: mapProvider.markers,
        polygons: mapProvider.polygons,
        polylines: mapProvider.polyLines,
        circles: mapProvider.circles,
        onTap: (LatLng point) {
          _handleMapTap(context, point);
        },
        onMapCreated: (GoogleMapController controller) {
          mapProvider.setMapController(controller);
        },
      );
    }
  }

  void _handleMapTap(BuildContext context, LatLng point) {
    final mapProvider = context.read<MapProvider>();
    final coverages = mapProvider.getCoveragesContainingPoint(point);

    mapProvider.updateMarker(point);

    if (coverages.isNotEmpty && mapProvider.selectedButtons.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Coverages'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: coverages.map((coverage) => Text(coverage)).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
*/
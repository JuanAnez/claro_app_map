// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/points_of_sale_map_layer.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class PointsOfSaleMap extends StatelessWidget {
  const PointsOfSaleMap({super.key});

  static const defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 8;
  static const double minZoom = 8;
  static const double maxZoom = 18;

  @override
  Widget build(BuildContext context) {
    final pointsOfSaleProvider = context.watch<PointsOfSaleProvider>();

    return Stack(children: [
      FlutterMap(
        mapController: pointsOfSaleProvider.mapController,
        options: MapOptions(
            initialCenter: defaultPosition,
            initialZoom: defaultZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
            bounds: PointsOfSaleProvider.bounds,
            keepAlive: true,
            interactiveFlags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom,
            onPositionChanged: (MapPosition position, bool hasGesture) {
              pointsOfSaleProvider.checkBounds(
                  pointsOfSaleProvider.mapController, position);
            }),
        children: [
          const PointsOfSaleMapLayer(),
          MarkerLayer(markers: pointsOfSaleProvider.mapSales),
        ],
      ),
      if (pointsOfSaleProvider.isLoadingData) const SkeletonMap()
    ]);
  }
}

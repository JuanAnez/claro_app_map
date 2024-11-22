// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:icc_maps/ui/pages/map/type/map_display_types.dart';
// import 'package:icc_maps/ui/pages/map/widgets/map/custom_map.dart';
// import 'package:icc_maps/ui/pages/map/widgets/map/custom_map_tile_layer.dart';

class SkeletonMap extends StatelessWidget {
  const SkeletonMap({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator.adaptive(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      );

  // const FlutterMap(
  //         options: MapOptions(
  //             initialCenter: CustomMap.defaultPosition,
  //             initialZoom: CustomMap.defaultZoom,
  //             minZoom: CustomMap.minZoom,
  //             maxZoom: CustomMap.maxZoom),
  //         children: [
  //           CustomMapTileLayer(),
  //           Center(child: CircularProgressIndicator(color: Colors.transparent))
  //         ]);
}

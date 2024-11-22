// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:icc_maps/ui/pages/map/type/map_display_types.dart';
// import 'package:icc_maps/ui/pages/map/widgets/map/points_of_sale_map.dart';
// import 'package:icc_maps/ui/pages/map/widgets/map/points_of_sale_map_layer.dart';

class SkeletonSale extends StatelessWidget {
  const SkeletonSale({super.key});

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
  //  const FlutterMap(
  //         options: MapOptions(
  //             initialCenter: PointsOfSaleMap.defaultPosition,
  //             initialZoom: PointsOfSaleMap.defaultZoom,
  //             minZoom: PointsOfSaleMap.minZoom,
  //             maxZoom: PointsOfSaleMap.maxZoom),
  //         children: [
  //           PointsOfSaleMapLayer(),
  //           Center(child: CircularProgressIndicator(color: Colors.transparent))
  //         ]
  //         );
}

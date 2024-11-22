import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:provider/provider.dart';

class PointsOfSaleMapLayer extends StatelessWidget {
  const PointsOfSaleMapLayer({super.key});

  @override
  Widget build(BuildContext context) {
    String urlTemplate =
        context.watch<PointsOfSaleProvider>().getMapTemplateURL();
    Map<String, String> accessToken =
        context.watch<PointsOfSaleProvider>().getMapAccessToken();

    return TileLayer(
      urlTemplate: urlTemplate,
      additionalOptions: accessToken,
      tileProvider: NetworkTileProvider(),
    );
  }
}

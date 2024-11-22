import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:provider/provider.dart';

class CustomMapTileLayer extends StatelessWidget {
  const CustomMapTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    String urlTemplate = context.watch<MapProvider>().getMapTemplateURL();
    Map<String, String> accessToken =
        context.watch<MapProvider>().getMapAccessToken();

    return TileLayer(
      urlTemplate: urlTemplate,
      additionalOptions: accessToken,
      tileProvider: NetworkTileProvider(),
    );
  }
}

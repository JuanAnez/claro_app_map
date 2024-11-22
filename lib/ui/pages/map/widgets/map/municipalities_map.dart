// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_sale.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MunicipalitiesMap extends StatefulWidget {
  const MunicipalitiesMap({super.key});

  static const defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 8;
  static const double minZoom = 8;
  static const double maxZoom = 18;

  @override
  _MunicipalitiesMapState createState() => _MunicipalitiesMapState();
}

class _MunicipalitiesMapState extends State<MunicipalitiesMap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pointsOfSaleProvider = context.read<PointsOfSaleProvider>();
      if (pointsOfSaleProvider.mapMunicipalities.isEmpty) {
        pointsOfSaleProvider.loadMunicipalities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pointsOfSaleProvider = context.watch<PointsOfSaleProvider>();

    return Stack(children: [
      FlutterMap(
        mapController: pointsOfSaleProvider.mapController,
        options: MapOptions(
            center: MunicipalitiesMap.defaultPosition,
            zoom: MunicipalitiesMap.defaultZoom,
            minZoom: MunicipalitiesMap.minZoom,
            maxZoom: MunicipalitiesMap.maxZoom,
            onTap: (_, LatLng latlng) {
              for (var polygon in pointsOfSaleProvider.mapMunicipalities) {
                if (polygon.contains(latlng)) {
                  pointsOfSaleProvider.showMarketShareDialog(
                      context, polygon.label);
                  break;
                }
              }
            },
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
          TileLayer(
            urlTemplate: pointsOfSaleProvider.getMapTemplateURL(),
            additionalOptions: pointsOfSaleProvider.getMapAccessToken(),
          ),
          PolygonLayer(
            polygons: pointsOfSaleProvider.mapMunicipalities.map((polygon) {
              return Polygon(
                points: polygon.points,
                borderColor: polygon.borderColor,
                borderStrokeWidth: polygon.borderStrokeWidth,
                color: polygon.color,
                isFilled: true,
              );
            }).toList(),
          ),
          MarkerLayer(
            markers: pointsOfSaleProvider.mapMunicipalities.map((polygon) {
              final center = _getPolygonCenter(polygon.points);
              return Marker(
                width: 70,
                point: center,
                child: Text(
                  polygon.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.transparent,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          MarkerLayer(
            markers: pointsOfSaleProvider.mapSales +
                (pointsOfSaleProvider.userMarker != null
                    ? [pointsOfSaleProvider.userMarker!]
                    : []),
          )
        ],
      ),
      if (pointsOfSaleProvider.isLoadingData) const SkeletonSale()
    ]);
  }

  LatLng _getPolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;

    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return LatLng(latSum / points.length, lngSum / points.length);
  }
}

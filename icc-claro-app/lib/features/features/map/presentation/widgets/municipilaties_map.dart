// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/classes/custom_polygon.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:provider/provider.dart';

class MunicipalitiesMap extends StatefulWidget {
  const MunicipalitiesMap({super.key});

  static const defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 9.5;

  @override
  _MunicipalitiesMapState createState() => _MunicipalitiesMapState();
}

class _MunicipalitiesMapState extends State<MunicipalitiesMap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadMunicipalities(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MapProvider, bool>(
      selector: (_, provider) => provider.isLoadingData,
      builder: (context, isLoadingData, child) {
        if (isLoadingData) {
          return const Center(child: LoadingProgress());
        }

        return Consumer<MapProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                GoogleMap(
                  mapType: provider.mapType,
                  initialCameraPosition: const CameraPosition(
                    target: MunicipalitiesMap.defaultPosition,
                    zoom: MunicipalitiesMap.defaultZoom,
                  ),
                  polygons: _buildPolygons(provider.mapMunicipalities),
                  markers: provider.markers,
                  onMapCreated: (controller) {
                    provider.setMapController(controller);
                  },
                  onTap: (LatLng point) {
                    for (var polygon in provider.mapMunicipalities) {
                      if (_isPointInsidePolygon(point, polygon.points)) {
                        provider.showMarketShareDialog(context, polygon.label);
                        break;
                      }
                    }
                  },
                  zoomControlsEnabled: false,
                  onCameraMove: (CameraPosition position) {
                    provider.checkBounds(position.target);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Set<Polygon> _buildPolygons(List<CustomPolygon> polygons) {
    return polygons.map((polygon) {
      return Polygon(
        polygonId: PolygonId(polygon.label),
        points: polygon.points,
        strokeColor: polygon.borderColor,
        strokeWidth: polygon.borderStrokeWidth.toInt(),
        fillColor: polygon.color.withOpacity(1),
      );
    }).toSet();
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    if (aX == bX) {
      return aX > pX;
    }

    double m = (bY - aY) / (bX - aX);
    double bee = aY - m * aX;
    double x = (pY - bee) / m;

    return x > pX;
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/config/map_config.dart';
import 'package:icc_claro_app/features/features/providers/coverage_provider.dart';
import 'package:provider/provider.dart';

class CoverageMap extends StatefulWidget {
  const CoverageMap({super.key});

  static const LatLng defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = MapConfig.defaultZoom;

  @override
  State<CoverageMap> createState() => _CoverageMapState();
}

class _CoverageMapState extends State<CoverageMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGoogleMap(context),
          _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    final coverageProvider = context.watch<CoverageProvider>();

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: CoverageMap.defaultPosition,
        zoom: CoverageMap.defaultZoom,
      ),
      mapType: coverageProvider.mapType,
      markers: coverageProvider.mapMarkers,
      polygons: coverageProvider.visiblePolygons,
      polylines: coverageProvider.polyLines,
      onMapCreated: (GoogleMapController controller) {
        coverageProvider.setMapController(controller);
      },
      onTap: (LatLng point) {
        coverageProvider.updateMarker(point);
      },
      zoomControlsEnabled: false,
      onCameraMove: (CameraPosition position) {
        coverageProvider.checkBounds(position.target);
      },
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Builder(
      builder: (context) {
        final coverageProvider = context.watch<CoverageProvider>();
        print("⚠️ AnimatedOpacity: ${coverageProvider.isLoadingData}");
        return AnimatedOpacity(
          opacity: coverageProvider.isLoadingData ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: coverageProvider.isLoadingData
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: LoadingProgress()),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

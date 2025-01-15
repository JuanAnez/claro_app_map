import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_maps/ui/pages/map/provider/google_map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_google_buttons.dart';
import 'package:provider/provider.dart';

class GoogleMapPage extends StatelessWidget {
  const GoogleMapPage({super.key});

  static const LatLng defaultPosition = LatLng(18.192150, -66.340428);
  static const double defaultZoom = 8;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoogleMapProvider>();

    return Scaffold(
      // appBar: AppBar(title: const Text("Polygon Manager")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: defaultPosition,
              zoom: defaultZoom,
            ),
            mapType: provider.mapType,
            polygons: Set<Polygon>.from(provider.visiblePolygons),
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              provider.setMapController(controller);
            },
          ),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: MenuGoogleButtons(),
    );
  }
}

    
     
     
      /*floatingActionButton: FloatingActionButton(
        onPressed: () => _showPolygonMenu(context),
        child: const Icon(Icons.layers),
      ),*/
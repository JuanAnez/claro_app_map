import 'dart:typed_data';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
// import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:provider/provider.dart';

class GetMarkersUseCase {
  GetMarkersUseCase(MapsRepository mapsRepository);

  // final MapsRepository repository;
  // GetMarkersUseCase(this.repository);

  Future<Set<Marker>> createMarkers(
      List<dynamic> locations, BuildContext context) async {
    Set<Marker> markers = {};

    for (var location in locations) {
      try {
        final latitude =
            double.tryParse(location['latitude']?.toString() ?? '') ?? 0.0;
        final longitude =
            double.tryParse(location['longitude']?.toString() ?? '') ?? 0.0;

        if (latitude == 0.0 || longitude == 0.0) continue;

        BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
        final posIcon = location['posIcon'];
        final String svgString = posIcon?['iconSource'] ?? '';
        final String fillColor = posIcon?['iconFillColor'] ?? '#FF0000';

        if (svgString.isNotEmpty) {
          icon = await svgToBitmapDescriptor(svgString, fillColor);
        }

        markers.add(
          Marker(
            markerId: MarkerId(location['posLocationId'].toString()),
            position: LatLng(latitude, longitude),
            icon: icon,
            onTap: () {
              showMarkerDetails(context, location, () {
                context.read<MapProvider>().loadMarkers(context);
              });
            },
          ),
        );
      } catch (e) {
        print("Error al crear marcador: $e");
      }
    }

    return markers;
  }

  static Future<BitmapDescriptor> generateBitmapDescriptor(
      String svgSource, String fillColor) async {
    try {
      if (!svgSource.trim().startsWith('<svg')) {
        svgSource = '''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18">
      <path d="$svgSource" fill="$fillColor" />
    </svg>
    ''';
      }

      final DrawableRoot svgRoot =
          await svg.fromSvgString(svgSource, svgSource);
      final picture = svgRoot.toPicture(size: const Size(40, 40));
      final image = await picture.toImage(40, 40);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("❌ Error al generar BitmapDescriptor desde SVG: ${e.toString()}");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> svgToBitmapDescriptor(
      String svgString, String fillColor) async {
    try {
      if (!svgString.trim().startsWith('<svg')) {
        svgString = '''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18">
          <path d="$svgString" fill="$fillColor" />
        </svg>
        ''';
      }

      final DrawableRoot svgRoot =
          await svg.fromSvgString(svgString, svgString);

      final picture = svgRoot.toPicture(
        size: const Size(40, 40),
      );

      final image = await picture.toImage(40, 40);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("Error al convertir SVG a BitmapDescriptor: ${e.toString()}");
      return BitmapDescriptor.defaultMarker;
    }
  }
}

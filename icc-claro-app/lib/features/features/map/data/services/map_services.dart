// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/classes/antenna_entity.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/features/map/data/database/tables/icc_coverages_table.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/api_repository.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/db_repository.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/sqlite_repository.dart';
import 'package:icc_claro_app/features/features/map/data/services/webtest_repository.dart';
import 'package:icc_claro_app/core/config/map_config.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MapService {
  final ApiRepository _apiRepository = WebtestClient();
  final DbRepository _dbRepository = SqliteRepository();

  Future<List<Marker>> findAntennas(
      int polygonTypeId, BuildContext context) async {
    final List<AntennaEntity> dbResponse =
        (await _dbRepository.getAntennas(polygonTypeId)).cast<AntennaEntity>();

    if (dbResponse.isNotEmpty) {
      return await _convertEntitiesToMarkers(dbResponse, context);
    }

    final MessageResponse apiResponse =
        await _apiRepository.findAntennas(polygonTypeId, context: context);

    if (!apiResponse.ok) return <Marker>[];

    final List<AntennaEntity> antennas =
        (apiResponse.content as List).cast<AntennaEntity>();

    await _dbRepository.insertAntennas(antennas);

    return await _convertEntitiesToMarkers(antennas, context);
  }

  Future<List<Marker>> _convertEntitiesToMarkers(
      List<AntennaEntity> antennas, BuildContext context) async {
    final List<Marker> markers = [];

    for (final antenna in antennas) {
      final BitmapDescriptor icon = await getIconFromIconData(
        Icons.cell_tower_sharp,
        _getAntennaColor(antenna.polygonTypeId),
        size: MapConfig.antennaIconSize, // Usando configuración centralizada
      );

      markers.add(
        Marker(
          markerId: MarkerId(antenna.siteId),
          position: LatLng(antenna.coordLat, antenna.coordLon),
          infoWindow: InfoWindow.noText,
          icon: icon,
          onTap: () {
            print("Se tocó el marcador: ${antenna.siteName}");
            _showAntennaDialog(
              context: context,
              siteName: antenna.siteName,
              siteId: antenna.siteId,
              lat: antenna.coordLat,
              lon: antenna.coordLon,
            );
          },
        ),
      );
    }

    return markers;
  }

  Color _getAntennaColor(int polygonTypeId) {
    if (polygonTypeId == 16) return Colors.yellow;
    if (polygonTypeId == 3) return Colors.red;
    return Colors.green;
  }

  Future<List<Polyline>> findCoverages(int polygonTypeId, {BuildContext? context}) async {
    final Map<String, dynamic> dbResponse =
        await _dbRepository.getCoverage(polygonTypeId);

    if (dbResponse.isNotEmpty) {
      final MessageResponse polygonsResponse = await _apiRepository.findGeoJson(
        url: dbResponse["url"],
        color: dbResponse["color"],
      );

      if (polygonsResponse.ok) {
        final List<dynamic> features = polygonsResponse.content;
        return _convertGeoJsonToPolylines(features, dbResponse["color"]);
      }
    }

    final MessageResponse apiResponse =
        await _apiRepository.findCoverages(polygonTypeId, context: context);

    if (!apiResponse.ok) return <Polyline>[];

    final polygonType = apiResponse.additionalContent;
    final coverage = IccCoveragesTable.fromMapToEntity(polygonType);
    await _dbRepository.insertCoverage(coverage);

    final List<dynamic> features = apiResponse.content;
    return _convertGeoJsonToPolylines(features, coverage.polygonColor);
  }

  List<Polyline> _convertGeoJsonToPolylines(
      List<dynamic> features, String colorHex) {
    final Color color = _hexToColor(colorHex);

    return features.map((feature) {
      final coordinates = feature['geometry']['coordinates'] as List<dynamic>;
      final List<LatLng> points = coordinates.map((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();

      return Polyline(
        polylineId: PolylineId(feature['properties']['id'].toString()),
        color: color,
        width: 3,
        points: points,
      );
    }).toList();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

Future<BitmapDescriptor> getIconFromIconData(IconData iconData, Color color,
    {double size = MapConfig.antennaIconSize}) async { // Usando configuración centralizada
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.transparent;
  final double iconSize = size;

  canvas.drawRect(Rect.fromLTWH(0, 0, iconSize, iconSize), paint);

  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  )..text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset((iconSize - textPainter.width) / 2,
        (iconSize - textPainter.height) / 2),
  );

  final ui.Image image = await pictureRecorder.endRecording().toImage(
        iconSize.toInt(),
        iconSize.toInt(),
      );

  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List imageData = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(imageData);
}

void _showAntennaDialog({
  required BuildContext context,
  required String siteName,
  required String siteId,
  required double lat,
  required double lon,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                siteName,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "ID: $siteId",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "Lat: $lat",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "Lon: $lon",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    },
  );
}

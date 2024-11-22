// ignore_for_file: unnecessary_import, unused_local_variable, use_build_context_synchronously, unused_import

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icc_maps/data/entities/dialog/disable_pos_group.dart';
import 'package:icc_maps/data/entities/dialog/reason_dialog.dart';
import 'package:icc_maps/data/entities/fisical_present.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/clases/custom_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:provider/provider.dart';

class MarkerEntity {
  static Marker toMarker({
    required int polygonTypeId,
    required double lat,
    required double lon,
    required String siteName,
    required String siteId,
  }) {
    return Marker(
      width: 48,
      height: 48,
      point: LatLng(lat, lon),
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onLongPress: () => showDialog(
              context: context,
              builder: (BuildContext context) => Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.only(
                      right: 30, left: 30, top: 30, bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    "$siteName\n$siteId\nLat: $lat\nLon: $lon",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            child: Icon(
              Icons.cell_tower_sharp,
              color: _getAntennaColor(polygonTypeId),
            ),
          );
        },
      ),
    );
  }

  static Marker toSale({
    required int posLocationId,
    required double latitude,
    required double longitude,
    required String? iconSource,
    required String? posLocationName,
    required String? locType,
    required String? locDescription,
    required String? posLocationCode,
    required String? posOperator,
    required int? posDemographics,
    required String? posTown,
    required String? posAddress,
    required int? posZone,
    required String? posZoneDescription,
    required String? posManager,
    required String? posAssistant,
    required String? channel,
    required double? posShareMktValue,
    required String? posDealer,
    required String? iconFillColor,
    required String? iconStrokeColor,
    required String? iconViewBox,
    required VoidCallback onReload,
  }) {
    return Marker(
      width: 24,
      height: 24,
      point: LatLng(latitude, longitude),
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 300,
                        padding: const EdgeInsets.only(
                            right: 30, left: 30, top: 30, bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "ID: $posLocationId\n"
                              "Nombre: $posLocationName\n"
                              "Ubicación: $locDescription\n"
                              "Tipo de Localidad: $locType\n"
                              "Operador: $posOperator\n"
                              "Demográficos: $posDemographics\n"
                              "Pueblo: $posTown\n"
                              "Dirección: $posAddress\n"
                              "Zona: $posZone\n"
                              "Descripción de Zona: $posZoneDescription\n"
                              "Gerente: $posManager\n"
                              "Asistente: $posAssistant\n"
                              "Canal: $channel\n"
                              "Puntuación: $posShareMktValue\n"
                              "Código de Agente: $posDealer\n"
                              "Código de Localidad: $posLocationCode",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showConfirmationDialog(
                                    context, posLocationId, onReload);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFFb60000),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                              ),
                              child: const Column(
                                children: [
                                  Text('Cerrar'),
                                  Text('Punto de Venta'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: SvgPicture.string(
              '''
                <svg version="1.1" xmlns="http://www.w3.org/2000/svg"  viewBox="$iconViewBox">
                <g id="icomoon-ignore"></g>
                <path d="$iconSource" fill="$iconFillColor"></path>
                </svg>
              ''',
              width: 24,
              height: 24,
            ),
          );
        },
      ),
    );
  }

  static void showConfirmationDialog(
      BuildContext context, int posLocationId, VoidCallback onReload) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Estás seguro de que quieres cerrar el punto de venta?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AlertButton(
                          text: 'Cancelar',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        AlertButton(
                          text: 'Confirmar',
                          onPressed: () {
                            Navigator.of(context).pop();
                            showReasonDialog(context, posLocationId, onReload);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void showMallDialog(BuildContext context, int groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Estás seguro de que quieres Inhabilitar este Centro Comercial?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AlertButton(
                          text: 'Cancelar',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        AlertButton(
                          text: 'Confirmar',
                          onPressed: () {
                            disablePosGroup(context, groupId);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void showReasonDialog(
      BuildContext context, int posLocationId, VoidCallback onReload) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReasonDialog(
          posLocationId: posLocationId,
          onReload: onReload,
        );
      },
    );
  }

  static CustomMarker toMall({
    required int groupId,
    required String groupName,
    required String groupDescription,
    required String town,
    required List<Map<String, String>> locations,
    required List<Map<String, String>> marketShareDetailList,
    required double latitude,
    required double longitude,
  }) {
    return CustomMarker(
      groupId: groupId,
      point: LatLng(latitude, longitude),
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 300,
                          padding: const EdgeInsets.only(
                              right: 30, left: 30, top: 30, bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nombre: $groupName\n"
                                "Descripción: $groupDescription\n"
                                "Pueblo: $town\n",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Ubicaciones:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...locations.map((location) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Nombre: ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: location['location_NAME'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Dirección: ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  location['location_ADDRESS'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FisicalPresent(
                                                    marketShareDetailList:
                                                        marketShareDetailList,
                                                    groupName: groupName),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFFb60000),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.0),
                                      ),
                                      child: const Column(
                                        children: [
                                          Text('Presencia'),
                                          Text('Física'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showMallDialog(context, groupId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFFb60000),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8.0),
                                      ),
                                      child: const Column(
                                        children: [
                                          Text('Inhabilitar'),
                                          Text('Mall'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            child: SvgPicture.string(
              '''
                <svg class="w-6 h-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
                    <g id="icomoon-ignore"></g>
                    <path d="M0 512h256v-512h-256v512zM160 64h64v64h-64v-64zM160 192h64v64h-64v-64zM160 320h64v64h-64v-64zM32 64h64v64h-64v-64zM32 192h64v64h-64v-64zM32 320h64v64h-64v-64zM288 160h224v32h-224zM288 512h64v-128h96v128h64v-288h-224z"
                          fill="#FF0F17"
                          stroke="#FFFFFF"
                          stroke-width="5"></path>
              ''',
              width: 24,
              height: 24,
            ),
          );
        },
      ),
    );
  }

  static Color _getAntennaColor(int polygonTypeId) {
    if (polygonTypeId == 16) return Colors.yellow;
    if (polygonTypeId == 3) return Colors.red;
    return Colors.green;
  }
}

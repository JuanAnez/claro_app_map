import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class CustomMarker extends Marker {
  final int groupId;

  const CustomMarker({
    required this.groupId,
    required LatLng point,
    required Widget child,
    double width = 80.0,
    double height = 80.0,
  }) : super(
          width: width,
          height: height,
          point: point,
          child: child,
        );
}

class MarkerEntity {
  static CustomMarker toMall({
    required int groupId,
    required String groupName,
    required String groupDescription,
    required String town,
    required List<Map<String, String>> locations,
    required double latitude,
    required double longitude,
  }) {
    return CustomMarker(
      groupId: groupId,
      point: LatLng(latitude, longitude),
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onLongPress: () => showDialog(
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
                          padding: const EdgeInsets.all(12.0),
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
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFFb60000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 3.0),
                                  ),
                                  child: const Text('Cerrar'),
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
            ),
            child: SvgPicture.string(
              '''
                <svg class="w-6 h-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                    <g id="icomoon-ignore"></g>
                    <path d="M0 512h256v-512h-256v512zM160 64h64v64h-64v-64zM160 192h64v64h-64v-64zM160 320h64v64h-64v-64zM32 64h64v64h-64v-64zM32 192h64v64h-64v-64zM32 320h64v64h-64v-64zM288 160h224v32h-224zM288 512h64v-128h96v128h64v-288h-224z"
                          fill="#1E40AF"
                          stroke="#FFFFFF"
                          stroke-width="5"></path>
              </svg>
            ''',
              width: 32,
              height: 32,
            ),
          );
        },
      ),
    );
  }
}

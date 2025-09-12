import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/utils/classes/disable_pos_location.dart';
import 'package:icc_claro_app/core/utils/classes/fisical_present.dart';
import 'package:icc_claro_app/core/utils/classes/mall_blueprint_screen.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:provider/provider.dart';

class CustomMarker extends Marker {
  final int groupId;

  CustomMarker({
    required this.groupId,
    required super.markerId,
    required super.position,
    BitmapDescriptor? icon,
    super.onTap,
  }) : super(
          icon: icon ?? BitmapDescriptor.defaultMarker,
        );
}

class MarkerEntity {
  static Future<Marker> toMall({
    required int groupId,
    required String groupName,
    required String groupDescription,
    required String town,
    required List<Map<String, String>> locations,
    required List<Map<String, String>> marketShareDetailList,
    required double latitude,
    required double longitude,
    required String svgString,
    required String iconFillColor,
    required BuildContext context,
  }) async {
    final BitmapDescriptor icon =
        await svgToBitmapDescriptorMall(svgString, iconFillColor);

    return Marker(
      markerId: MarkerId(groupId.toString()),
      position: LatLng(latitude, longitude),
      icon: icon,
      anchor: const Offset(0.5, 1.0),
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => buildInfoDialog(
          context,
          groupId,
          groupName,
          groupDescription,
          town,
          locations,
          marketShareDetailList,
        ),
      ),
    );
  }

  static Widget buildInfoDialog(
    BuildContext context,
    int groupId,
    String groupName,
    String groupDescription,
    String town,
    List<Map<String, String>> locations,
    List<Map<String, String>> marketShareDetailList,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 305,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nombre: $groupName\n"
                      "Descripción: $groupDescription\n"
                      "Pueblo: $town\n",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Ubicaciones:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...locations.map((location) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRichText(
                                'Nombre: ', location['location_NAME']),
                            _buildRichText(
                                'Dirección: ', location['location_ADDRESS']),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildDialogButtons(
                        context,
                        groupId,
                        groupName,
                        groupDescription,
                        town,
                        locations,
                        marketShareDetailList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRichText(String label, String? value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value ?? "N/A",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDialogButtons(
    BuildContext context,
    int groupId,
    String groupName,
    String groupDescription,
    String town,
    List<Map<String, String>> locations,
    List<Map<String, String>> marketShareDetailList,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FisicalPresent(
                  marketShareDetailList: marketShareDetailList,
                  groupName: groupName,
                ),
              ),
            );
          },
          style: _buildButtonStyle(Colors.white, const Color(0xFFb60000)),
          child: const Column(
            children: [
              Text('Presencia'),
              Text('Física'),
            ],
          ),
        ),
        const SizedBox(width: 3),
        // if (hasAdminPermission(Provider.of<UserProvider>(context, listen: false)
        //     .getUser()
        //     ?.authorities))
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //       showMallDialog(context, groupId);
        //     },
        //     style: _buildButtonStyle(const Color(0xFFb60000), Colors.white),
        //     child: const Column(
        //       children: [
        //         Text('Inhabilitar'),
        //         Text('Mall'),
        //       ],
        //     ),
        //   ),
        const SizedBox(width: 3),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MallBlueprintScreen(
                  groupId: groupId,
                  groupName: groupName,
                  groupDescription: groupDescription,
                  town: town,
                  locations: locations,
                  marketShareDetailList: marketShareDetailList,
                ),
              ),
            );
          },
          style: _buildButtonStyle(
              const Color.fromARGB(255, 231, 125, 53), Colors.white),
          child: const Column(
            children: [
              Text('Ver'),
              Text('Planos'),
            ],
          ),
        ),
      ],
    );
  }

  static ButtonStyle _buildButtonStyle(Color bgColor, Color textColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }

  static Future<BitmapDescriptor> svgToBitmapDescriptorMall(
      String svgString, String iconFillColor) async {
    try {
      if (!svgString.trim().startsWith('<svg')) {
        svgString = '''
      <svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 24 24">
        <path d="$svgString" fill="$iconFillColor" /> 
      </svg>
      ''';
      } else {
        svgString = svgString.replaceAll('<svg', '<svg fill="$iconFillColor"');
      }

      final DrawableRoot svgRoot = await svg.fromSvgString(svgString, 'source');

      const double markerWidth = 60;
      const double markerHeight = 60;

      final ui.Picture picture =
          svgRoot.toPicture(size: const Size(markerWidth, markerHeight));

      final ui.Image image =
          await picture.toImage(markerWidth.toInt(), markerHeight.toInt());

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("❌ Error: No se pudo convertir la imagen.");
      }

      return BitmapDescriptor.fromBytes(
        byteData.buffer.asUint8List(),
      );
    } catch (e) {
      print("❌ Error al convertir SVG a BitmapDescriptor: ${e.toString()}");
      return BitmapDescriptor.defaultMarker;
    }
  }
}

bool hasAdminPermission(dynamic authorities) {
  if (authorities == null) return false;

  try {
    if (authorities is String) {
      final decoded = jsonDecode(authorities);
      if (decoded is Map && decoded.containsKey('message')) {
        return decoded['message'].contains('POS_ADMIN');
      }
    }
    if (authorities is Map && authorities.containsKey('message')) {
      return authorities['message'].contains('POS_ADMIN');
    }
  } catch (e) {
    print("Error decoding authorities: $e");
  }

  return false;
}

void showMallDialog(BuildContext context, int groupId) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final user = userProvider.getUser();
  final userAuthorities = user?.authorities;

  if (!hasAdminPermission(userAuthorities)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFb60000),
        content: Text(
          'No tienes permiso para inhabilitar este centro comercial.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 5),
      ),
    );
    return;
  }

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
                        color: const Color(0xFFb60000),
                      ),
                      AlertButton(
                        text: 'Confirmar',
                        onPressed: () {
                          disablePosGroup(context, groupId);
                          Navigator.of(context).pop();
                        },
                        color: const Color(0xFF449D44),
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

Future<BitmapDescriptor> svgToBitmapDescriptor(String svgString) async {
  try {
    if (!svgString.trim().startsWith('<svg')) {
      svgString = '''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="$svgString" />
      </svg>
      ''';
    }

    final DrawableRoot svgRoot = await svg.fromSvgString(svgString, 'source');

    const double markerWidth = 60;
    const double markerHeight = 30;

    final picture =
        svgRoot.toPicture(size: const Size(markerWidth, markerHeight));

    final image =
        await picture.toImage(markerWidth.toInt(), markerHeight.toInt());

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Failed to convert picture to ByteData.");
    }

    return BitmapDescriptor.fromBytes(
      byteData.buffer.asUint8List(),
    );
  } catch (e) {
    print("Error converting SVG to BitmapDescriptor: ${e.toString()}");
    return BitmapDescriptor.defaultMarker;
  }
}

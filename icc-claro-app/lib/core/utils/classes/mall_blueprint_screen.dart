// mall_blueprint_screen.dart

// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/classes/customer_marker.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class MallBlueprintScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String groupDescription;
  final String town;
  final List<Map<String, String>> locations;
  final List<Map<String, String>> marketShareDetailList;

  const MallBlueprintScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.town,
    required this.locations,
    required this.marketShareDetailList,
  }) : super(key: key);
  @override
  _MallBlueprintScreenState createState() => _MallBlueprintScreenState();
}

class _MallBlueprintScreenState extends State<MallBlueprintScreen> {
  String? imageUrl;
  Uint8List? imageBytes;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchBlueprint();
  }

  Future<void> _fetchBlueprint() async {
    print('🏢 Obteniendo plano para groupId: ${widget.groupId}');
    
    try {
      // Usar HttpAuthService para manejar la autenticación correctamente
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getGroupPhotosByGroupId,
        queryParameters: {'groupId': widget.groupId.toString()},
        context: context,
        useCache: true, // Usar caché para planos
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isNotEmpty &&
            jsonResponse[0]['downloadFile'] != null) {
          setState(() {
            final String downloadFile = jsonResponse[0]['downloadFile'];
            if (downloadFile.startsWith("http")) {
              imageUrl = downloadFile;
            } else if (downloadFile.length > 1000) {
              imageBytes = base64Decode(downloadFile);
            } else {
              imageUrl = ApiEndpoints.buildWebtestUrl("/$downloadFile");
            }
            isLoading = false;
          });
          print('✅ Plano obtenido exitosamente');
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
          print("❌ No se encontró ningún plano para este centro comercial.");
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print("❌ Error al obtener el plano: ${response.statusCode}");
        print("   Respuesta del servidor: ${response.body}");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("❌ Excepción al obtener el plano: $e");
      
      // Manejar errores específicos de autenticación
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        print("🔑 Error de autenticación detectado");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plano del Centro Comercial",
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    MarkerEntity.buildInfoDialog(
                  context,
                  widget.groupId,
                  widget.groupName,
                  widget.groupDescription,
                  widget.town,
                  widget.locations,
                  widget.marketShareDetailList,
                ),
              );
            });
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? const LoadingProgress()
            : hasError
                ? const Text(
                    "No se encontró el plano para este centro comercial.")
                : imageBytes != null
                    ? InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text("Error al cargar el plano.");
                          },
                        ),
                      )
                    : InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: LoadingProgress());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Text("Error al cargar el plano.");
                          },
                        ),
                      ),
      ),
    );
  }
}

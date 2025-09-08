// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:path_provider/path_provider.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class PosFilesList extends StatefulWidget {
  final int posLocationId;
  final Map<String, dynamic> location;
  final VoidCallback onReload;
  const PosFilesList({
    super.key,
    required this.posLocationId,
    required this.location,
    required this.onReload,
  });

  @override
  State<PosFilesList> createState() => _PosFilesListState();
}

class _PosFilesListState extends State<PosFilesList> {
  late Future<List<Map<String, dynamic>>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = fetchFiles(widget.posLocationId);
  }

  Future<List<Map<String, dynamic>>> fetchFiles(int posLocationId) async {
    print('📁 Obteniendo archivos para posLocationId: $posLocationId');
    
    try {
      // Usar HttpAuthService para manejar la autenticación correctamente
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosFilesByLocId,
        queryParameters: {'locId': posLocationId.toString()},
        context: context,
        useCache: true, // Usar caché para archivos
      );

      print('📁 Status Code: ${response.statusCode}');
      print('📁 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Archivos obtenidos exitosamente: ${data.length} archivos');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error al cargar archivos: ${response.statusCode}');
        print('   Respuesta del servidor: ${response.body}');
        throw Exception('Error al cargar archivos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción al obtener archivos: $e');
      
      // Manejar errores específicos de autenticación
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        print('🔑 Error de autenticación detectado en archivos');
      }
      
      rethrow;
    }
  }

  Future<void> _downloadAndOpenFile({
    required int fileId,
    required String fileName,
    required String fileExt,
    required String fileFormat,
  }) async {
    print('📥 Descargando archivo: $fileName (ID: $fileId)');
    
    try {
      // Usar HttpAuthService para manejar la autenticación correctamente
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosFileBlobById,
        queryParameters: {'fileId': fileId.toString()},
        context: context,
        useCache: false, // No usar caché para descargas de archivos
      );

      print('📥 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['downloadFile'] != null) {
          final bytes = base64Decode(data['downloadFile']);
          final tempDir = await getTemporaryDirectory();
          final safeName = fileName
              .replaceAll(RegExp(r'[^\w\s.-]'), '')
              .replaceAll(' ', '_')
              .substring(0, fileName.length.clamp(1, 50));

          final filePath = '${tempDir.path}/$safeName.$fileExt';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          print("✅ Archivo guardado en: $filePath (${bytes.length} bytes)");

          final result = await OpenFile.open(filePath, type: fileFormat);
          print("📂 Resultado de OpenFile: ${result.type}, mensaje: ${result.message}");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo no disponible para descargar')),
          );
        }
      } else {
        print('❌ Error al descargar archivo: ${response.statusCode}');
        print('   Respuesta del servidor: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar archivo: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('❌ Excepción al descargar archivo: $e');
      
      // Manejar errores específicos de autenticación
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        print('🔑 Error de autenticación detectado en descarga de archivo');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de autenticación al descargar archivo')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar archivo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Archivos de Localidad',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showMarkerDetails(context, widget.location, widget.onReload);
            });
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingProgress());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)),
            );
          }
          final files = snapshot.data ?? [];
          if (files.isEmpty) {
            return const Center(
              child: Text('No hay archivos para mostrar.',
                  style: TextStyle(color: Colors.white)),
            );
          }
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    file['fileExt'] == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file,
                    color: Colors.white,
                  ),
                  title: Text(file['fileName'] ?? 'Sin nombre',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Tipo: ${file['docType'] ?? "N/A"}',
                      style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () {
                      _downloadAndOpenFile(
                        fileId: file['fileId'],
                        fileName: file['fileName'] ?? 'archivo',
                        fileExt: file['fileExt'] ?? 'dat',
                        fileFormat:
                            file['fileFormat'] ?? 'application/octet-stream',
                      );
                    },
                  ),
                  onTap: () {
                    _downloadAndOpenFile(
                      fileId: file['fileId'],
                      fileName: file['fileName'] ?? 'archivo',
                      fileExt: file['fileExt'] ?? 'dat',
                      fileFormat:
                          file['fileFormat'] ?? 'application/octet-stream',
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

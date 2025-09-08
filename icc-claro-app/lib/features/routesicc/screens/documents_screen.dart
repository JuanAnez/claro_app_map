// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/routesicc/services/route_service.dart';
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentsScreen extends StatefulWidget {
  final int routeId;
  final int locationId;
  final String username;

  const DocumentsScreen({
    super.key,
    required this.routeId,
    required this.locationId,
    required this.username,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<dynamic>> _documentsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    _documentsFuture = RouteService().fetchDocuments(
      routeId: widget.routeId,
      context: context,
    );
  }

  void _refreshAfterUpload(Future<String> uploadFuture) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await uploadFuture;
      if (mounted) {
        setState(() {
          _loadDocuments();
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late final BuildContext scaffoldContext = context;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          "Documentos de Recorrido - ${widget.routeId}",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: LoadingProgress())
          : FutureBuilder<List<dynamic>>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingProgress());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final documents = snapshot.data ?? [];

                  if (documents.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay documentos para mostrar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.grey[800],
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.black,
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('ID de Localidad')),
                          DataColumn(label: Text('Localidad')),
                          DataColumn(label: Text('Pueblo de Localidad')),
                          DataColumn(label: Text('Dirección de Localidad')),
                          DataColumn(label: Text('Ver Documentos')),
                          DataColumn(label: Text('Creado')),
                          DataColumn(label: Text('Creado Por')),
                        ],
                        rows: documents.map((doc) {
                          return DataRow(
                            onSelectChanged: (_) {
                              showDialog(
                                context: context,
                                builder: (_) => Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 300,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Confirmar Eliminación',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            doc['fileName'] ??
                                                '¿Eliminar documento?',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          const Text(
                                            '¿Estás seguro de que deseas eliminar este documento?',
                                            style:
                                                TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              AlertButton(
                                                text: 'Cancelar',
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                color: const Color(0xFFb60000),
                                              ),
                                              AlertButton(
                                                text: 'Eliminar',
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Future.delayed(Duration.zero,
                                                      () {
                                                    _handleDelete(
                                                        scaffoldContext,
                                                        doc['fileId']);
                                                  });
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
                            cells: [
                              DataCell(Text(doc['fileName'] ?? '')),
                              DataCell(Text(doc['fileDescription'] ?? '')),
                              DataCell(Text(
                                  doc['fileLocationId']?.toString() ?? '')),
                              DataCell(Text(doc['fileLocationName'] ?? '')),
                              DataCell(Text(doc['fileLocationTown'] ?? '')),
                              DataCell(Text(doc['fileLocationAddress'] ?? '')),
                              DataCell(
                                TextButton(
                                  child: const Text("Ver documento"),
                                  onPressed: () async {
                                    final base64Data = doc['documentFileBlob'];
                                    final mimeType = doc['fileDocumentType'] ??
                                        'application/octet-stream';
                                    final fileName =
                                        doc['fileName'] ?? 'documento';

                                    if (base64Data != null &&
                                        base64Data.isNotEmpty) {
                                      try {
                                        final bytes = base64Decode(base64Data);

                                        final status = await Permission
                                            .manageExternalStorage
                                            .request();
                                        if (!status.isGranted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Permiso denegado para escribir en Descargas")),
                                          );
                                          return;
                                        }

                                        final downloadsDir = Directory(
                                            '/storage/emulated/0/Download');
                                        final file = File(
                                            '${downloadsDir.path}/$fileName');
                                        await file.writeAsBytes(bytes);
                                        await OpenFile.open(file.path);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Archivo guardado en Descargas: ${file.path}")),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Error al guardar archivo: $e")),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "El archivo no tiene contenido válido")),
                                      );
                                    }
                                  },
                                ),
                              ),
                              DataCell(Text(doc['creationDate'] ?? '')),
                              DataCell(Text(doc['createdBy'] ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
              future: _documentsFuture,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          'Seleccionar una opción',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Future.delayed(Duration.zero, () {
                                _handleCameraUpload();
                              });
                            },
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            label: const Text('Tomar Foto',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF449D44),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Future.delayed(Duration.zero, () {
                                _handleFilePickerUpload(
                                    context, widget.routeId, widget.locationId);
                              });
                            },
                            icon: const Icon(Icons.upload_file,
                                color: Colors.white),
                            label: const Text('Subir Archivo',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb60000),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xFFb60000),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _handleCameraUpload() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    _refreshAfterUpload(
      RouteService().uploadFromCamera(
        locationId: widget.locationId,
        routeId: widget.routeId,
        imageFile: pickedFile,
        context: context,
      ),
    );
  }

  void _handleFilePickerUpload(
      BuildContext context, int routeId, int locationId) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      _refreshAfterUpload(
        RouteService().uploadRouteDocumentsMultipart(
          routeId: widget.routeId,
          locationId: widget.locationId,
          files: result.files,
          context: context,
        ),
      );
    }
  }

  void _handleDelete(BuildContext scaffoldContext, int fileId) async {
    setState(() => _isLoading = true);

    try {
      await RouteService().deleteDocuments(
        routeId: widget.routeId,
        documentIds: [fileId],
        username: widget.username,
        context: context,
      );
      _loadDocuments();
      if (!mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text("Documento eliminado correctamente")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
// import 'package:icc_claro_app/features/routesicc/screens/route_screen.dart';

import 'package:provider/provider.dart';

class CloseRoute extends StatefulWidget {
  final int posLocationRouteID;
  final VoidCallback onReload;
  final VoidCallback onSuccessNavigate;

  const CloseRoute({
    super.key,
    required this.posLocationRouteID,
    required this.onReload,
    required this.onSuccessNavigate,
  });

  @override
  _ReasonDialogState createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<CloseRoute> {
  final TextEditingController locStatusController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedCloseReason;
  List<String> closeReasons = [];

  bool _isLoading = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  late final String username;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    username = userProvider.getUser()?.username ?? "default_username";

    _loadCloseReason();
  }

  Future<void> _loadCloseReason() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response =
          await client.getPosLovByType('POS_CLOSE_REASON');
      if (response.ok) {
        setState(() {
          closeReasons = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        if (kDebugMode) {
          print('Error loading location types: ${response.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception loading location types: $e');
      }
    }
  }

  void showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El punto de venta ha sido cerrado exitosamente.'),
          duration: Duration(seconds: 4),
        ),
      );
      widget.onReload();
    }
  }

  void showErrorMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hubo un problema al cerrar el punto de venta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'Razón para cerrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCloseReasonDropdown(context),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AlertButton(
                  text: 'Cancelar',
                  color: const Color(0xFFb60000),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                AlertButton(
                  text: 'Aceptar',
                  onPressed: () {
                    if (_isLoading) return;
                    if (selectedCloseReason == null ||
                        selectedCloseReason!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, selecciona una razón de cierre.'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    _handleSubmit();
                  },
                  color: const Color(0xFF449D44),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    String reason = reasonController.text.trim();
    String description = descriptionController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una razón de cierre.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await closeRoute(
      widget.posLocationRouteID,
      reason,
      description,
      username,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      showSuccessMessage();
      widget.onSuccessNavigate();
    } else {
      showErrorMessage();
    }
  }

  Widget _buildCloseReasonDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Razón de Cierre',
          labelStyle: TextStyle(color: Colors.white60, fontSize: 20),
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: const Color(0xFF005954).withOpacity(0.9),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            isExpanded: true,
            value: selectedCloseReason,
            items: closeReasons.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCloseReason = value;
                reasonController.text = value ?? '';
              });
            },
            hint: const Text(
              'Razón de Cierre',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  static Future<bool> closeRoute(
    int posLocationRouteID,
    String reason,
    String description,
    String username,
  ) async {
    // final userProvider = Provider.of<UserProvider>( listen: false);
    // final username = userProvider.getUser()?.username ?? "default_username";

    final uri =
        Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.requestCloseRoute));

    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final body = jsonEncode({
      "routeId": posLocationRouteID,
      "closeReasonStr": reason,
      "closeReasonDescStr": description,
      "userName": username,
    });

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set('accept-charset', 'UTF-8');
      request.write(body);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (kDebugMode) {
          print('Response body: $responseBody');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return false;
    }
  }
}

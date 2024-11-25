// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/webtest/mocktest_repository.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/map/map_points_sale.dart';
import 'package:provider/provider.dart';

class ReasonDialog extends StatefulWidget {
  final int posLocationId;
  final VoidCallback onReload;

  const ReasonDialog({
    Key? key,
    required this.posLocationId,
    required this.onReload,
  }) : super(key: key);

  @override
  _ReasonDialogState createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<ReasonDialog> {
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

  @override
  void initState() {
    super.initState();
    _loadCloseReason();
  }

  Future<void> _loadCloseReason() async {
    try {
      MocktestClient client = MocktestClient();
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                AlertButton(
                  text: 'Aceptar',
                  onPressed: () {
                    if (_isLoading) return;
                    setState(() {
                      _isLoading = true;
                    });

                    _handleSubmit();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    String reason = reasonController.text;
    String description = descriptionController.text;

    bool success =
        await closeSale(widget.posLocationId, reason, description, context);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      showSuccessMessage();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MapPointsSale(
                  posLocationId: '',
                  idCentro: '',
                  posLocationName: '',
                  posManager: '',
                  posAddress: '',
                  centro: '',
                  locType: '',
                  operador: '',
                  posTown: '',
                  centrosComerciales: false,
                  locDescription: '',
                  posZoneDescription: '',
                )),
      );
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
                reasonController.text = value!;
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

  static Future<bool> closeSale(int posLocationId, String reason,
      String description, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.getUser()?.username ?? "default_username";

    final uri =
        Uri.parse("https://webtest/icc/api/disablePosLocation");
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final body = jsonEncode({
      "posId": posLocationId,
      "closeReasonStr": reason,
      "closeReasonDescStr": description,
      "userName": username,
    });

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
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

class AlertButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AlertButton({required this.text, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFb60000),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(text),
    );
  }
}

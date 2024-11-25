// ignore_for_file: use_build_context_synchronously, avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/map/map_malls_center.dart';

Future<void> disablePosGroup(BuildContext context, int groupId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userName = userProvider.getUser()?.username ?? "default_username";

  final url = Uri.parse(
    'https://webtest/icc/api/disablePosGroup',
  );

  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

  bool isLoading = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Inhabilitando..."),
          ],
        ),
      );
    },
  );

  try {
    final formData = {
      'groupID': groupId.toString(),
      'userName': userName,
    };

    final request = await client.postUrl(url);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(jsonEncode(formData));

    final response = await request.close();

    if (response.statusCode == 200) {
      isLoading = false;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Centro Comercial inhabilitado con éxito.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MapMallsCenter(),
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error en el envío: ${response.statusCode}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error de red: $e',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ignore_for_file: avoid_print, unused_import

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:icc_maps/data/network/payload/MessageResponse.dart';

class LoginService {
  Future<MessageResponse> doLogin(String username, String password) async {
    final url = Uri.parse(
        // 'https://webtest.prt.local/icc/api/getUserAuthorities?us=$username&pw=$password');
        'http://192.168.1.5:8082/getUserAuthorities?us=$username&pw=$password');

    final HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final HttpClientRequest apiRequest = await client.getUrl(url);
      final HttpClientResponse apiResponse = await apiRequest.close();

      if (apiResponse.statusCode == HttpStatus.ok) {
        final String responseBody =
            await apiResponse.transform(utf8.decoder).join();
        final userAuthorities = responseBody.trim();

        if (userAuthorities.isNotEmpty) {
          return MessageResponse(
            ok: true,
            message: 'Inicio de sesión exitoso',
            content: {'username': username, 'authorities': userAuthorities},
          );
        } else {
          return MessageResponse(
            ok: false,
            message: 'Nombre de usuario o contraseña incorrectos',
          );
        }
      } else {
        return MessageResponse(
          ok: false,
          message:
              'Error de inicio de sesión. Código de estado: ${apiResponse.statusCode}',
        );
      }
    } on Exception catch (e) {
      return MessageResponse(
        ok: false,
        message: 'Error de inicio de sesión: $e',
      );
    }
  }

  Future<MessageResponse> doLogout() async {
    throw UnimplementedError();
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/ui/context/user_provider.dart';

class LoginService {
  Future<String?> _getAccessToken(
      String username, String password, UserProvider userProvider) async {
    final url = Uri.parse('https://webtest/icc/api/login-ws');
    // final url = Uri.parse('http://192.168.1.5:7001/icc/api/login-ws');
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final HttpClientRequest apiRequest = await client.postUrl(url);
      apiRequest.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      apiRequest
          .write(jsonEncode({"username": username, "password": password}));

      final HttpClientResponse apiResponse = await apiRequest.close();
      final responseBody = await apiResponse.transform(utf8.decoder).join();

      if (apiResponse.statusCode == HttpStatus.ok) {
        final responseJson = jsonDecode(responseBody);
        if (responseJson['status'] == 200 && responseJson['code'] == "OK") {
          final accessToken = responseJson['message'];
          userProvider.saveAccessToken(accessToken);
          print('Token obtenido: $accessToken');
          final expirationDate = userProvider.getJwtExpirationDate(accessToken);
          if (expirationDate != null) {
            print('Fecha de expiración del token: $expirationDate');
          } else {
            print('No se pudo obtener la fecha de expiración del token.');
          }

          return accessToken;
        } else {
          print('Error en el inicio de sesión: ${responseJson['message']}');
        }
      } else {
        print('Error en el inicio de sesión: Código ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('Excepción durante el inicio de sesión: $e');
    }
    return null;
  }

  Future<MessageResponse> doLogin(
      String username, String password, UserProvider userProvider) async {
    final accessToken = await _getAccessToken(username, password, userProvider);
    if (accessToken == null) {
      return MessageResponse(
        ok: false,
        message: 'No se pudo obtener el token de acceso',
      );
    }

    final url = Uri.parse(
        'https://webtest/icc/api/getUserAuthorities?userName=$username');
    // final url = Uri.parse(
    //     'http://192.168.1.5:7001/icc/api/getUserAuthorities?userName=$username');
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final HttpClientRequest apiRequest = await client.getUrl(url);
      apiRequest.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');

      final HttpClientResponse apiResponse = await apiRequest.close();
      final responseBody = await apiResponse.transform(utf8.decoder).join();
      if (apiResponse.statusCode == HttpStatus.ok) {
        final userAuthorities = responseBody.trim();
        return MessageResponse(
          ok: true,
          message: 'Inicio de sesión exitoso',
          content: {'username': username, 'authorities': userAuthorities},
        );
      } else {
        return MessageResponse(
          ok: false,
          message:
              'Error obteniendo autoridades. Código: ${apiResponse.statusCode}',
        );
      }
    } catch (e) {
      return MessageResponse(
        ok: false,
        message: 'Error obteniendo autoridades: $e',
      );
    }
  }

  Future<MessageResponse> doLogout(UserProvider userProvider) async {
    final url = Uri.parse('https://webtest/icc/api/logout-ws');
    // final url = Uri.parse('http://192.168.1.5:7001/icc/api/logout-ws');
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final accessToken = userProvider.accessToken;
    if (accessToken == null) {
      print(
          'Error: No se ha establecido el token de acceso para cerrar sesión');
      return MessageResponse(
          ok: false, message: 'No hay token para cerrar sesión');
    }

    print('Token utilizado para el logout: $accessToken');

    try {
      final HttpClientRequest apiRequest = await client.postUrl(url);
      apiRequest.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      apiRequest.write(jsonEncode({"accessToken": accessToken}));

      final HttpClientResponse apiResponse = await apiRequest.close();
      final responseBody = await apiResponse.transform(utf8.decoder).join();

      if (apiResponse.statusCode == HttpStatus.ok) {
        final responseJson = jsonDecode(responseBody);

        if (responseJson['status'] == 200 && responseJson['code'] == "OK") {
          print('Logout exitoso, eliminando el token');
          userProvider.clearAccessToken();
          return MessageResponse(
            ok: true,
            message: 'Sesión cerrada exitosamente',
          );
        } else {
          print('Error en el cierre de sesión: ${responseJson['message']}');
          return MessageResponse(
            ok: false,
            message: 'Error en el cierre de sesión: ${responseJson['message']}',
          );
        }
      } else {
        print(
            'Error en el cierre de sesión. Código: ${apiResponse.statusCode}, Respuesta: $responseBody');
        return MessageResponse(
          ok: false,
          message:
              'Error en el cierre de sesión. Código: ${apiResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Excepción durante el cierre de sesión: $e');
      return MessageResponse(
        ok: false,
        message: 'Excepción durante el cierre de sesión: $e',
      );
    }
  }
}
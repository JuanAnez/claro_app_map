// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/data/models/notification_service.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = 'http://192.168.1.5:7001/icc/api';

  Future<String?> _getAccessToken(
      String username, String password, UserProvider userProvider) async {
    final url = Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.loginWs));
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
        // Esperamos ApiResponseDTO {status, code, message}
        final dynamic parsed = _tryJsonDecode(responseBody);
        if (parsed is Map &&
            parsed['status'] == 200 &&
            parsed['code'] == "OK" &&
            parsed['message'] is String) {
          final accessToken = parsed['message'] as String;

          // Guarda en provider
          userProvider.saveAccessToken(accessToken);
          // Si quieres persistir entre sesiones, descomenta:
          // await userProvider.persistAccessToken(accessToken);

          print('Token obtenido: $accessToken');

          return accessToken;
        } else {
          print('Error en el inicio de sesión: $responseBody');
        }
      } else {
        print(
            'Error en el inicio de sesión: Código ${apiResponse.statusCode} Body: $responseBody');
      }
    } catch (e) {
      print('Excepción durante el inicio de sesión: $e');
    } finally {
      client.close(force: true);
    }
    return null;
  }

  Future<MessageResponse> doLogin(
      String username, String password, UserProvider userProvider) async {
    final accessToken = await _getAccessToken(username, password, userProvider);
    if (accessToken == null) {
      return MessageResponse(
          ok: false, message: 'No se pudo obtener el token de acceso');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedIn', true);

    final url = Uri.parse(ApiEndpoints.buildUrlWithParams(ApiEndpoints.getUserAuthorities, {'userName': username}));
    final client = HttpClient()..badCertificateCallback = (c, h, p) => true;

    try {
      final req = await client.getUrl(url);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      print('🔑 Obteniendo autoridades para usuario: $username');
      print('🌐 URL: $url');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      print('📋 Respuesta autoridades: $body');

      if (res.statusCode != HttpStatus.ok) {
        return MessageResponse(
          ok: false,
          message: 'Error obteniendo autoridades. Código: ${res.statusCode}',
        );
      }

      final Map<String, dynamic> jsonMap = jsonDecode(body);

      if (jsonMap['status'] == 200 && jsonMap['code'] == 'OK') {
        // message es el/los roles (ej: "POS_USER" o "POS_USER,POS_ADMIN")
        final raw = (jsonMap['message'] ?? '').toString().trim();

        // Normaliza a lista de roles en mayúsculas, sin espacios
        final List<String> roles = raw
            .split(',')
            .map((s) => s.trim().toUpperCase())
            .where((s) => s.isNotEmpty)
            .toList();

        // Si necesitas guardarlo como string:
        final rolesCsv = roles.join(',');

        return MessageResponse(
          ok: true,
          message: 'Inicio de sesión exitoso',
          content: {'username': username, 'authorities': rolesCsv},
        );
      }

      return MessageResponse(
        ok: false,
        message: 'Error obteniendo autoridades: ${jsonMap['message']}',
      );
    } catch (e) {
      return MessageResponse(
          ok: false, message: 'Error obteniendo autoridades: $e');
    } finally {
      client.close(force: true);
    }
  }

  Future<MessageResponse> doLogout(
      UserProvider userProvider, BuildContext context) async {
    // Cuando muevas a prod, apunta a $baseUrl/logout-ws (o su dominio https)
    final url = Uri.parse('$baseUrl/logout-ws');
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final accessToken = userProvider.accessToken;
    if (accessToken == null) {
      print(
          '❌ Error: No se ha establecido el token de acceso para cerrar sesión');
      return MessageResponse(
          ok: false, message: 'No hay token para cerrar sesión');
    }

    print('🔑 Token utilizado para el logout: $accessToken');

    try {
      final HttpClientRequest apiRequest = await client.postUrl(url);
      apiRequest.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      apiRequest.write(jsonEncode({"accessToken": accessToken}));

      final HttpClientResponse apiResponse = await apiRequest.close();
      final responseBody = await apiResponse.transform(utf8.decoder).join();

      if (apiResponse.statusCode == HttpStatus.ok) {
        final dynamic parsed = _tryJsonDecode(responseBody);

        if (parsed is Map &&
            parsed['status'] == 200 &&
            parsed['code'] == "OK") {
          print('✅ Respuesta del servidor: $parsed');

          await NotificationService.scheduleNotifications();

          final prefs = await SharedPreferences.getInstance();
          final success = await prefs.setBool('hasLoggedIn', false);
          print("🗑️ Estado de sesión limpiado: $success");

          print('✅ Logout exitoso, eliminando el token');
          userProvider.clearAccessToken();
          context.read<PointOfSaleProvider>().clearMarkersCache();
          return MessageResponse(
            ok: true,
            message: 'Sesión cerrada exitosamente',
          );
        } else {
          final msg = (parsed is Map ? parsed['message'] : responseBody);
          print('❌ Error en el cierre de sesión: $msg');
          return MessageResponse(
            ok: false,
            message: 'Error en el cierre de sesión: $msg',
          );
        }
      } else {
        print(
            '❌ Error en el cierre de sesión. Código: ${apiResponse.statusCode}, Respuesta: $responseBody');
        return MessageResponse(
          ok: false,
          message:
              'Error en el cierre de sesión. Código: ${apiResponse.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Excepción durante el cierre de sesión: $e');
      return MessageResponse(
        ok: false,
        message: 'Excepción durante el cierre de sesión: $e',
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Intenta decodificar JSON. Si falla, retorna el string original.
  dynamic _tryJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:icc_claro_app/features/authentication/data/models/user_model.dart';
import 'package:icc_claro_app/features/authentication/data/models/me_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  Me? _me;
  String? _accessToken;
  final Duration _timeAdjustment = const Duration();
  // final Duration _timeAdjustment = const Duration(hours: -1, minutes: -36);


  void saveUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  UserModel? getUser() => _user;
  Me? get me => _me;

  void saveAccessToken(String token) {
    _accessToken = token;
    _printTokenInfo(token);
    notifyListeners();
  }

  String? get accessToken => _accessToken;

  void clearAccessToken() {
    _accessToken = null;
    notifyListeners();
  }

  bool _hasLoggedOut = false;

  bool get hasLoggedOut => _hasLoggedOut;

  void logout() {
    if (_hasLoggedOut) return;
    _hasLoggedOut = true;
    _accessToken = null;
    notifyListeners();
  }

  bool isTokenExpired() {
    if (_accessToken == null) {
      print('🔑 Token: null - expirado');
      return true;
    }

    final expirationDate = getJwtExpirationDate(_accessToken!);
    if (expirationDate == null) {
      print('🔑 Token: fecha de expiración inválida - expirado');
      return true;
    }

    final now = DateTime.now();
    final isExpired = now.isAfter(expirationDate);
    
    // Print información del token
    print('🔑 Token Info:');
    print('   Hora actual: ${now.toIso8601String()}');
    print('   Expira en: ${expirationDate.toIso8601String()}');
    print('   Duración restante: ${expirationDate.difference(now).inSeconds} segundos');
    print('   ¿Expirado?: $isExpired');

    return isExpired;
  }

  Future<void> clearMunicipalitiesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedMunicipalities');
  }

  DateTime? getJwtExpirationDate(String token) {
    try {
      final decodedToken = Jwt.parseJwt(token);
      if (decodedToken.containsKey('exp')) {
        final expirationSeconds = decodedToken['exp'] as int;
        final expirationDate =
            DateTime.fromMillisecondsSinceEpoch(expirationSeconds * 1000);
        final adjustedExpirationDate = expirationDate.add(_timeAdjustment);
        return adjustedExpirationDate;
      } else {
        throw Exception('El token no contiene fecha de expiración');
      }
    } catch (e) {
      return null;
    }
  }

  // Persistencia
  Future<void> persistAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    saveAccessToken(token);
  }

  Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      saveAccessToken(token);
    }
  }
  
  void _printTokenInfo(String token) {
    print('🔑 Token obtenido: $token');
    final expirationDate = getJwtExpirationDate(token);
    if (expirationDate != null) {
      final now = DateTime.now();
      final duration = expirationDate.difference(now);
      print('🔑 Token Info al guardar:');
      print('   Hora actual: ${now.toIso8601String()}');
      print('   Expira en: ${expirationDate.toIso8601String()}');
      print('   Duración total: ${duration.inSeconds} segundos (${duration.inMinutes} minutos)');
    }
  }

  Future<void> loadMe(BuildContext context) async {
    try {
      // Solo intentar cargar si hay token
      if (_accessToken == null) {
        print('⚠️ No hay token disponible para loadMe');
        return;
      }

      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.me,
        context: context,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        // Verificar la estructura de respuesta del backend
        if (jsonData['status'] == 200 && jsonData['code'] == 'OK' && jsonData['data'] != null) {
          _me = Me.fromJson(jsonData['data']);
          notifyListeners();
          print('✅ Usuario cargado desde /me: ${_me?.username} (ID: ${_me?.userId})');
        } else {
          print('❌ Respuesta del backend no válida: $jsonData');
        }
      } else {
        print('❌ Error cargando usuario: ${response.statusCode}');
        // No lanzar excepción, solo loggear el error
      }
    } catch (e) {
      print('❌ Excepción cargando usuario: $e');
      // No lanzar excepción, solo loggear el error
    }
  }
}

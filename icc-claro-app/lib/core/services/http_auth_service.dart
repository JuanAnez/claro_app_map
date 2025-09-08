import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/authentication/presentation/login/login_page.dart';
import 'package:provider/provider.dart';

class HttpAuthService {
  static const String _baseUrl = 'http://192.168.1.5:7001/icc/api';
  static const Duration _timeout = Duration(seconds: 30);
  
  // Cache para respuestas exitosas (opcional, para optimización)
  static final Map<String, dynamic> _responseCache = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Método principal para hacer peticiones GET autenticadas
  static Future<http.Response> authenticatedGet(
    String endpoint, {
    Map<String, String>? queryParameters,
    BuildContext? context,
    bool useCache = false,
    Duration? cacheExpiration,
  }) async {
    final String fullUrl = _buildUrl(endpoint, queryParameters);
    final String cacheKey = _generateCacheKey(endpoint, queryParameters);
    
    // Verificar caché si está habilitado
    if (useCache && _isCacheValid(cacheKey)) {
      return _createCachedResponse(cacheKey);
    }
    
    try {
      // Obtener token de autenticación
      final String? accessToken = await _getAccessToken(context);
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      // Verificar si el token está expirado
      if (await _isTokenExpired(context)) {
        print('❌ Token expirado detectado en HttpAuthService GET');
        await _handleTokenExpired(context);
        throw Exception('Token expirado, redirigiendo al login');
      }
      
      // Configurar headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      
      print('🌐 Realizando petición GET a: $fullUrl');
      print('🔑 Usando token: ${accessToken.substring(0, 20)}...');
      
      // Realizar petición HTTP
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      ).timeout(_timeout);
      
      // Manejar códigos de respuesta
      if (response.statusCode == 200) {
        // Guardar en caché si está habilitado
        if (useCache) {
          _saveToCache(cacheKey, response, cacheExpiration ?? _cacheExpiration);
        }
        return response;
      } else if (response.statusCode == 401) {
        print('❌ Error 401 - No autorizado');
        print('   URL: $fullUrl');
        print('   Token usado: ${accessToken.substring(0, 20)}...');
        print('   Respuesta del servidor: ${response.body}');
        await _handleUnauthorized(context);
        throw Exception('No autorizado: Token inválido o expirado');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado: No tienes permisos suficientes');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método para peticiones POST autenticadas
  static Future<http.Response> authenticatedPost(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    BuildContext? context,
  }) async {
    final String fullUrl = _buildUrl(endpoint, queryParameters);
    
    try {
      // Obtener token de autenticación
      final String? accessToken = await _getAccessToken(context);
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      // Verificar si el token está expirado
      if (await _isTokenExpired(context)) {
        await _handleTokenExpired(context);
        throw Exception('Token expirado, redirigiendo al login');
      }
      
      // Configurar headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      
      // Realizar petición HTTP
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      
      // Manejar códigos de respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        print('❌ Error 401 - No autorizado');
        print('   URL: $fullUrl');
        print('   Token usado: ${accessToken.substring(0, 20)}...');
        print('   Respuesta del servidor: ${response.body}');
        await _handleUnauthorized(context);
        throw Exception('No autorizado: Token inválido o expirado');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado: No tienes permisos suficientes');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método para peticiones PUT autenticadas
  static Future<http.Response> authenticatedPut(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    BuildContext? context,
  }) async {
    final String fullUrl = _buildUrl(endpoint, queryParameters);
    
    try {
      // Obtener token de autenticación
      final String? accessToken = await _getAccessToken(context);
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      // Verificar si el token está expirado
      if (await _isTokenExpired(context)) {
        await _handleTokenExpired(context);
        throw Exception('Token expirado, redirigiendo al login');
      }
      
      // Configurar headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      
      // Realizar petición HTTP
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      
      // Manejar códigos de respuesta
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      } else if (response.statusCode == 401) {
        print('❌ Error 401 - No autorizado');
        print('   URL: $fullUrl');
        print('   Token usado: ${accessToken.substring(0, 20)}...');
        print('   Respuesta del servidor: ${response.body}');
        await _handleUnauthorized(context);
        throw Exception('No autorizado: Token inválido o expirado');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado: No tienes permisos suficientes');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método para peticiones DELETE autenticadas
  static Future<http.Response> authenticatedDelete(
    String endpoint, {
    Map<String, String>? queryParameters,
    BuildContext? context,
  }) async {
    final String fullUrl = _buildUrl(endpoint, queryParameters);
    
    try {
      // Obtener token de autenticación
      final String? accessToken = await _getAccessToken(context);
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      // Verificar si el token está expirado
      if (await _isTokenExpired(context)) {
        await _handleTokenExpired(context);
        throw Exception('Token expirado, redirigiendo al login');
      }
      
      // Configurar headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      
      // Realizar petición HTTP
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: headers,
      ).timeout(_timeout);
      
      // Manejar códigos de respuesta
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      } else if (response.statusCode == 401) {
        print('❌ Error 401 - No autorizado');
        print('   URL: $fullUrl');
        print('   Token usado: ${accessToken.substring(0, 20)}...');
        print('   Respuesta del servidor: ${response.body}');
        await _handleUnauthorized(context);
        throw Exception('No autorizado: Token inválido o expirado');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado: No tienes permisos suficientes');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método para peticiones con HttpClient (para archivos grandes)
  static Future<HttpClientResponse> authenticatedHttpClientRequest(
    String endpoint, {
    Map<String, String>? queryParameters,
    BuildContext? context,
    Future<void> Function(HttpClientRequest)? requestModifier,
  }) async {
    final String fullUrl = _buildUrl(endpoint, queryParameters);
    
    try {
      // Obtener token de autenticación
      final String? accessToken = await _getAccessToken(context);
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      
      // Verificar si el token está expirado
      if (await _isTokenExpired(context)) {
        await _handleTokenExpired(context);
        throw Exception('Token expirado, redirigiendo al login');
      }
      
      // Crear cliente HTTP
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      
      try {
        // Crear petición
        final request = await client.getUrl(Uri.parse(fullUrl));
        
        // Configurar headers
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('Authorization', 'Bearer $accessToken');
        
        // Permitir modificaciones personalizadas
        if (requestModifier != null) {
          await requestModifier(request);
        }
        
        // Realizar petición
        final response = await request.close();
        
        // Manejar códigos de respuesta
        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 401) {
          await _handleUnauthorized(context);
          throw Exception('No autorizado: Token inválido o expirado');
        } else if (response.statusCode == 403) {
          throw Exception('Acceso denegado: No tienes permisos suficientes');
        } else {
          throw Exception('Error HTTP ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Métodos auxiliares privados
  static String _buildUrl(String endpoint, Map<String, String>? queryParameters) {
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      return '$_baseUrl$endpoint?$queryString';
    }
    return '$_baseUrl$endpoint';
  }
  
  static String _generateCacheKey(String endpoint, Map<String, String>? queryParameters) {
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final sortedParams = queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final paramString = sortedParams
          .map((e) => '${e.key}:${e.value}')
          .join('|');
      return '$endpoint|$paramString';
    }
    return endpoint;
  }
  
  static bool _isCacheValid(String cacheKey) {
    if (!_responseCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }
  
  static void _saveToCache(String cacheKey, http.Response response, Duration expiration) {
    _responseCache[cacheKey] = response;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }
  
  static http.Response _createCachedResponse(String cacheKey) {
    final cachedResponse = _responseCache[cacheKey];
    if (cachedResponse is http.Response) {
      return cachedResponse;
    }
    throw Exception('Error en caché: respuesta no válida');
  }
  
  static Future<String?> _getAccessToken(BuildContext? context) async {
    if (context != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        return userProvider.accessToken;
      } catch (e) {
        print('Error al obtener token del contexto: $e');
      }
    }
    
    // Fallback: intentar obtener del contexto global
    try {
      // Aquí podrías implementar un método para obtener el contexto global
      // Por ahora, retornamos null si no hay contexto
      print('⚠️ No se pudo obtener token de autenticación - contexto no disponible');
      return null;
    } catch (e) {
      print('Error al obtener token del contexto global: $e');
      return null;
    }
  }
  
  static Future<bool> _isTokenExpired(BuildContext? context) async {
    if (context != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        return userProvider.isTokenExpired();
      } catch (e) {
        print('Error al verificar expiración del token: $e');
        return true; // Por seguridad, asumir que está expirado
      }
    }
    return true; // Por seguridad, asumir que está expirado
  }
  
  static Future<void> _handleTokenExpired(BuildContext? context) async {
    if (context != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearAccessToken();
        
        // Navegar al login
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        print('Error al manejar token expirado: $e');
      }
    }
  }
  
  static Future<void> _handleUnauthorized(BuildContext? context) async {
    if (context != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearAccessToken();
        
        // Navegar al login
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        print('Error al manejar no autorizado: $e');
      }
    }
  }
  
  // Método para limpiar caché
  static void clearCache() {
    _responseCache.clear();
    _cacheTimestamps.clear();
  }
  
  // Método para limpiar caché de un endpoint específico
  static void clearCacheForEndpoint(String endpoint) {
    final keysToRemove = _responseCache.keys
        .where((key) => key.startsWith(endpoint))
        .toList();
    
    for (final key in keysToRemove) {
      _responseCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
}

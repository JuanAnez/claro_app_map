import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class GoogleClient {
  static const _coverageEndpoint = "/getPolygonTypes";

  Future<List<Map<String, dynamic>>> fetchPolygonTypes({BuildContext? context}) async {
    try {
      print('🔍 Llamando a: $_coverageEndpoint');
      
      // Usar el nuevo servicio de autenticación
      final response = await HttpAuthService.authenticatedGet(
        _coverageEndpoint,
        context: context,
        useCache: true, // Usar caché para tipos de polígonos
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación expirado o inválido');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para acceder a esta funcionalidad');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en fetchPolygonTypes: $e');
      rethrow;
    }
  }

  Future<String> fetchGeoJsonGzip(Uri url) async {
    try {
      print('🔍 Llamando a GeoJSON: $url');
      
      // Para URLs internas con certificados autofirmados, usar HttpClient con verificación SSL deshabilitada
      if (url.host.contains('webtest.prt.local') || url.host.contains('localhost')) {
        print("🔒 Usando HttpClient para URL interna con certificado autofirmado");
        
        final httpClient = HttpClient()
          ..badCertificateCallback = (cert, host, port) {
            print("🔒 Ignorando certificado SSL para: $host:$port");
            return true; // Ignorar certificados autofirmados
          };
        
        try {
          final request = await httpClient.getUrl(url);
          final response = await request.close();
          
          if (response.statusCode == 200) {
            // Obtener bytes directamente para manejar archivos comprimidos
            final bytes = await response.fold<List<int>>(
              <int>[],
              (List<int> previous, List<int> element) => previous..addAll(element),
            );
            
            print("✅ GeoJSON descargado con HttpClient, longitud: ${bytes.length} bytes");
            
            // Verificar si es un archivo comprimido .gz
            if (url.path.endsWith('.gz')) {
              print("🗜️ Detectado archivo .gz, descomprimiendo...");
              final decompressedBytes = GZipCodec().decode(bytes);
              final decompressedString = utf8.decode(decompressedBytes);
              print("✅ Archivo descomprimido, longitud: ${decompressedString.length} caracteres");
              return decompressedString;
            } else {
              // Si no es .gz, decodificar directamente
              final decodedString = utf8.decode(bytes);
              print("✅ Archivo no comprimido, longitud: ${decodedString.length} caracteres");
              return decodedString;
            }
          } else {
            throw Exception('Error HTTP ${response.statusCode}');
          }
        } finally {
          httpClient.close();
        }
      } else {
        // Para URLs externas, usar http package normal
        print("🌐 Usando http package para URL externa");
        final response = await http.get(url).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Timeout: La solicitud tardó demasiado');
          },
        );

        print('🔍 GeoJSON Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          // Asumiendo que el contenido ya está descomprimido
          final gzipData = response.bodyBytes;

          // Verificar si es un archivo comprimido .gz
          if (url.path.endsWith('.gz')) {
            print("🗜️ Detectado archivo .gz, descomprimiendo...");
            final decompressedBytes = GZipCodec().decode(gzipData);
            final decompressedString = utf8.decode(decompressedBytes);
            print("✅ Archivo descomprimido, longitud: ${decompressedString.length} caracteres");
            return decompressedString;
          } else {
            // Si no es .gz, decodificar directamente
            final decodedString = utf8.decode(gzipData);
            print("✅ Archivo no comprimido, longitud: ${decodedString.length} caracteres");
            return decodedString;
          }
        } else {
          throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error en fetchGeoJsonGzip: $e');
      rethrow;
    }
  }
}

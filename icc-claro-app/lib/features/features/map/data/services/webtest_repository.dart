import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:icc_claro_app/core/utils/classes/antenna_entity.dart';
import 'package:icc_claro_app/core/utils/classes/hex_color.dart';
import 'package:icc_claro_app/core/utils/classes/poligon_entity.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/api_repository.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class WebtestClient extends ApiRepository {
  static const _antennasEndpoint = "/getBaseCoords";
  static const _coverageEndpoint = "/getPolygonTypes";

  @override
  Future<MessageResponse> findAntennas(int polygonTypeId, {BuildContext? context}) async {
    try {
      print('🔍 Llamando a antenas para tipo: $polygonTypeId');
      
      // Usar el nuevo servicio de autenticación
      final response = await HttpAuthService.authenticatedGet(
        _antennasEndpoint,
        queryParameters: {'polygonTypeID': polygonTypeId.toString()},
        context: context,
        useCache: true, // Usar caché para antenas
      );

      print('🔍 Antennas Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonApi = jsonDecode(response.body);

        final List<AntennaEntity> antennas = jsonApi.map((item) {
          return AntennaEntity(
            icBaseCoordsId: item['ic_BASE_COORDS_ID'],
            creationDate: item['creation_DATE'],
            creationUser: item['creation_USER'],
            coordLat: double.parse(item['coord_LAT'].toString()),
            coordLon: double.parse(item['coord_LON'].toString()),
            siteId: item['site_ID'],
            updateDate: item['update_DATE'],
            updateUser: item['update_USER'],
            expirationDate: item['expiration_DATE'],
            siteName: item['site_NAME'],
            siteTown: item['site_TOWN'],
            polygonTypeId: polygonTypeId,
          );
        }).toList();

        print('✅ Antenas cargadas exitosamente: ${antennas.length} elementos');
        return MessageResponse(ok: true, content: antennas, additionalContent: jsonApi);
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación expirado o inválido');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para acceder a esta funcionalidad');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en findAntennas: $e');
      return MessageResponse(message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findCoverages(int id, {BuildContext? context}) async {
    try {
      print('🔍 Llamando a: $_coverageEndpoint');
      
      // Usar el nuevo servicio de autenticación
      final response = await HttpAuthService.authenticatedGet(
        _coverageEndpoint,
        context: context,
        useCache: true, // Usar caché para tipos de cobertura
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> polygonTypesList = jsonDecode(response.body);

        final polygonType = polygonTypesList.firstWhere(
            (polygon) => polygon["polygon_TYPE_ID"] == id,
            orElse: () => {});

        if (polygonType.isEmpty) {
          throw Exception("Polygon type not found");
        }

        final polygonURL = Uri.parse(polygonType["polygon_URL"]);
        final polygonColor = HexColor(polygonType["polygon_COLOR"]);

        final MessageResponse polygonsResponse =
            await findGeoJson(url: polygonURL, color: polygonColor);

        if (!polygonsResponse.ok) throw Exception(polygonsResponse.message);

        return MessageResponse(
            ok: true, content: polygonsResponse.content, additionalContent: polygonType);
      } else if (response.statusCode == 401) {
        throw Exception("Token de autenticación expirado o inválido");
      } else if (response.statusCode == 403) {
        throw Exception("No tienes permisos para acceder a esta funcionalidad");
      } else {
        throw Exception("API error: Coverages not found. Código: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error en findCoverages: $e');
      return MessageResponse(message: e.toString());
    }
  }

  @override
  Future<MessageResponse> findGeoJson({
    required Uri url,
    required Color color,
    HttpClient? client,
  }) async {
    try {
      print('🔍 Llamando a GeoJSON: $url');
      
      // Para URLs internas con certificados autofirmados, usar HttpClient con verificación SSL deshabilitada
      if (url.host.contains('webtest.prt.local') || url.host.contains('localhost')) {
        print("🔒 Usando HttpClient para URL interna con certificado autofirmado");
        
        final httpClient = client ?? HttpClient()
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
              
              final List<Polygon> polygons =
                  PolygonEntity.fromGeoJson(decompressedString, color);

              return MessageResponse(ok: true, content: polygons);
            } else {
              // Si no es .gz, procesar directamente
              final geoJsonString = utf8.decode(bytes);
              print("✅ Archivo no comprimido, longitud: ${geoJsonString.length} caracteres");
              
              final List<Polygon> polygons =
                  PolygonEntity.fromGeoJson(geoJsonString, color);

              return MessageResponse(ok: true, content: polygons);
            }
          } else {
            throw Exception('Error HTTP ${response.statusCode}');
          }
        } finally {
          if (client == null) {
            httpClient.close();
          }
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
            
                         final List<Polygon> polygons =
                 PolygonEntity.fromGeoJson(decompressedString, color);

             return MessageResponse(ok: true, content: polygons);
          } else {
            // Si no es .gz, procesar directamente
            final geoJsonString = utf8.decode(gzipData);
            print("✅ Archivo no comprimido, longitud: ${geoJsonString.length} caracteres");
            
                         final List<Polygon> polygons =
                 PolygonEntity.fromGeoJson(geoJsonString, color);

             return MessageResponse(ok: true, content: polygons);
          }
        } else {
          throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error en findGeoJson: $e');
      return MessageResponse(ok: false, message: e.toString());
    }
  }
}

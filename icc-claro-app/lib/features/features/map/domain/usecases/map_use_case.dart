import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/types/antennas_types.dart';
import 'package:icc_claro_app/core/types/coverages_types.dart';
import 'package:icc_claro_app/core/utils/classes/poligon_entity.dart';
import 'package:icc_claro_app/core/config/memory_config.dart';
import 'package:icc_claro_app/features/features/map/data/services/google_client.dart';
import 'package:icc_claro_app/features/features/map/data/services/map_services.dart';
import 'dart:convert';

class MapUseCase {
  final MapService mapService = MapService();
  final GoogleClient _client = GoogleClient();

  // Constantes para optimización de memoria
  static const int _maxInitialPolygons = MemoryConfig.maxInitialPolygons;
  static const int _maxPolygonsPerBatch = MemoryConfig.maxPolygonsPerBatch;

  Future<List<Marker>> getAntennas(
      AntennasTypes type, BuildContext context) async {
    return await mapService.findAntennas(type.polygonTypeId, context);
  }

  Future<List<Polygon>> getPolygonsById(int polygonTypeId, {BuildContext? context}) async {
    print("🔄 getPolygonsById iniciado para tipo: $polygonTypeId");
    
    final polygonTypes = await _client.fetchPolygonTypes(context: context);
    print("📋 Tipos de polígonos obtenidos: ${polygonTypes.length} elementos");
    
    final selectedPolygon = polygonTypes.firstWhere(
      (polygon) => polygon["polygon_TYPE_ID"] == polygonTypeId,
      orElse: () => throw Exception("Polygon not found."),
    );
    
    print("🎯 Polígono seleccionado: ${selectedPolygon["polygon_NAME"]} - URL: ${selectedPolygon["polygon_URL"]}");

    if (selectedPolygon["polygon_URL"] == null) {
      throw Exception("Polygon URL is missing.");
    }

    print("🌐 Descargando GeoJSON desde: ${selectedPolygon["polygon_URL"]}");
    
    try {
      final geoJson = await _client.fetchGeoJsonGzip(Uri.parse(selectedPolygon["polygon_URL"]));
      print("📄 GeoJSON descargado, longitud: ${geoJson.length} caracteres");
      
      final color = _hexToColor(selectedPolygon["polygon_COLOR"]);
      print("🎨 Color del polígono: ${selectedPolygon["polygon_COLOR"]} -> $color");

      // Procesar GeoJSON en background para evitar bloqueo de UI
      final polygons = await compute(_processGeoJsonInBackground, {
        'geoJson': geoJson,
        'color': color.value,
        'maxPolygons': _maxInitialPolygons,
      });
      
      print("📍 Polígonos generados: ${polygons.length} elementos (carga completa)");
      
      return polygons;
    } catch (e) {
      print("❌ Error al procesar GeoJSON: $e");
      if (e.toString().contains("GZIP") || e.toString().contains("extension byte")) {
        throw Exception("Error al descomprimir archivo GZIP. Verifique que el archivo no esté corrupto.");
      }
      rethrow;
    }
  }

  // Método para cargar polígonos adicionales de forma progresiva (deshabilitado)
  Future<List<Polygon>> getPolygonsByIdProgressive(
    int polygonTypeId, 
    int currentCount, 
    {BuildContext? context}
  ) async {
    // Este método está deshabilitado, siempre retorna lista vacía
    print("⚠️ Carga progresiva deshabilitada - retornando lista vacía");
    return [];
  }

  // Método estático para procesar GeoJSON en background
  static List<Polygon> _processGeoJsonInBackground(Map<String, dynamic> params) {
    final String geoJson = params['geoJson'];
    final int colorValue = params['color'];
    final int maxPolygons = params['maxPolygons'];
    
    final color = Color(colorValue);
    final polygons = PolygonEntity.fromGeoJson(geoJson, color);
    
    // Si maxPolygons es 0, cargar todos los polígonos
    if (maxPolygons == 0) {
      print("✅ Cargando todos los polígonos: ${polygons.length} elementos");
      return polygons;
    }
    
    // Limitar la cantidad inicial de polígonos (solo si está configurado)
    if (polygons.length > maxPolygons) {
      print("⚠️ Limitando polígonos de ${polygons.length} a $maxPolygons para optimizar memoria");
      return polygons.take(maxPolygons).toList();
    }
    
    return polygons;
  }

  // Método estático para procesar un lote específico de polígonos (deshabilitado)
  static List<Polygon> _processGeoJsonBatch(Map<String, dynamic> params) {
    // Este método está deshabilitado, siempre retorna lista vacía
    return [];
  }

  // Método para obtener el total de polígonos disponibles
  Future<int> getTotalPolygonCount(int polygonTypeId, {BuildContext? context}) async {
    final polygonTypes = await _client.fetchPolygonTypes(context: context);
    final selectedPolygon = polygonTypes.firstWhere(
      (polygon) => polygon["polygon_TYPE_ID"] == polygonTypeId,
      orElse: () => throw Exception("Polygon not found."),
    );

    if (selectedPolygon["polygon_URL"] == null) {
      throw Exception("Polygon URL is missing.");
    }

    try {
      final geoJson = await _client.fetchGeoJsonGzip(Uri.parse(selectedPolygon["polygon_URL"]));
      
      // Solo contar features sin crear objetos completos
      final count = await compute(_countGeoJsonFeatures, geoJson);
      return count;
    } catch (e) {
      print("❌ Error al contar features: $e");
      return 0;
    }
  }

  // Método estático para contar features sin procesar
  static int _countGeoJsonFeatures(String geoJson) {
    try {
      final Map<String, dynamic> data = jsonDecode(geoJson);
      final List<dynamic> features = data["features"] ?? [];
      return features.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<dynamic>> getCoverage(CoveragesTypes type, {BuildContext? context}) async {
    final List<PolygonEntity> coverages =
        (await mapService.findCoverages(type.id, context: context)).cast<PolygonEntity>();

    if (type == CoveragesTypes.lte || type == CoveragesTypes.threeG) {
      return coverages.map((coverage) {
        return Polyline(
          polylineId: PolylineId(coverage.id.toString()),
          points: coverage.points,
          color: coverage.color,
          width: 3,
        );
      }).toList(); 
    } else {
      return coverages.map((coverage) {
        return Polygon(
          polygonId: PolygonId(coverage.id.toString()),
          points: coverage.points,
          strokeColor: coverage.color,
          fillColor: coverage.color.withOpacity(0.3),
          strokeWidth: 2,
        );
      }).toList();
    }
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

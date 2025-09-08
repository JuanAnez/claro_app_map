import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:icc_claro_app/core/actions/buttons_action_type.dart';
import 'package:icc_claro_app/core/types/antennas_types.dart';
import 'package:icc_claro_app/core/types/coverages_types.dart';
import 'package:icc_claro_app/core/config/memory_config.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/map_use_case.dart';

class CoverageProvider extends ChangeNotifier {
  CoverageProvider() {
    initializeCache();
  }
  GoogleMapController? _mapController;

  final MapUseCase _mapUseCase = MapUseCase();

  final Map<String, Set<Marker>> _mapAntennas = {};
  final Map<String, Set<Polyline>> _mapPolylines = {};

  // final Set<Polyline> _polyLines = {};

  final Map<int, List<Polygon>> _cache = {};
  
  // Nuevo: Cache para polígonos cargados progresivamente
  final Map<int, List<Polygon>> _progressiveCache = {};
  final Map<int, int> _loadedPolygonCounts = {};
  final Map<int, int> _totalPolygonCounts = {};

  final Set<AntennasTypes> _selectedAntennas = {};
  Set<AntennasTypes> get selectedAntennas => _selectedAntennas;

  bool _isLoadingData = false;

  bool get isLoadingData => _isLoadingData;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  // Nuevo: Estado de carga progresiva
  bool _isLoadingMorePolygons = false;
  bool get isLoadingMorePolygons => _isLoadingMorePolygons;

  static LatLngBounds bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;

  final Set<CoveragesTypes> _selectedButtons = <CoveragesTypes>{};
  Set<CoveragesTypes> get selectedButtons => _selectedButtons;

  Set<Polygon> get visiblePolygons {
    return _selectedButtons
        .map((type) => _progressiveCache[type.id] ?? _cache[type.id] ?? <Polygon>[])
        .expand((polygons) => polygons)
        .toSet();
  }

  // Obtener información de polígonos cargados
  int getLoadedPolygonCount(int typeId) => _loadedPolygonCounts[typeId] ?? 0;
  int getTotalPolygonCount(int typeId) => _totalPolygonCounts[typeId] ?? 0;
  bool canLoadMorePolygons(int typeId) => false; // Siempre false ya que se cargan todos

  Future<void> _collapseButtons() async {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  Future<void> _zoomMap(bool zoomIn) async {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.zoomBy(zoomIn ? 1.0 : -1.0),
      );
    }
  }

  Future<void> _changeMapDisplay() async {
    List<MapType> availableMapTypes =
        MapType.values.where((type) => type != MapType.none).toList();

    int currentIndex = availableMapTypes.indexOf(_mapType);
    _mapType = availableMapTypes[(currentIndex + 1) % availableMapTypes.length];
    notifyListeners();
  }

  Set<Marker> get mapMarkers =>
      _mapAntennas.values.expand((markers) => markers).toSet();

  Set<Polyline> get polyLines =>
      _mapPolylines.values.expand((polylines) => polylines).toSet();

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  static final LatLngBounds _bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  // Nuevo: Método para limpiar polígonos de un tipo específico
  void clearPolygonsForType(int typeId) {
    if (_progressiveCache.containsKey(typeId)) {
      print("🧹 Limpiando polígonos para tipo $typeId");
      _progressiveCache.remove(typeId);
      _loadedPolygonCounts.remove(typeId);
      _totalPolygonCounts.remove(typeId);
      
      // Forzar limpieza de memoria
      _forceGarbageCollection();
    }
  }

  void handleButtonAction(
      ButtonsActionType action, BuildContext context) async {
    if (_isLoadingData) return;

    _isLoadingData = true;
    notifyListeners();

    if (action is CollapseButtons) {
      await _collapseButtons();
    } else if (action is ZoomMap) {
      await _zoomMap(action.zoomIn);
    } else if (action is ShowAntennas) {
      await toggleAntennaVisibility(action.antennaType, context);
    } else if (action is ShowCoverages) {
      await togglePolygonVisibility(action.coverageType, context);
    } else if (action is ChangeMapDisplay) {
      await _changeMapDisplay();
    }

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> toggleAntennaVisibility(
      AntennasTypes type, BuildContext context) async {
    if (_selectedAntennas.contains(type)) {
      _selectedAntennas.remove(type);
      _mapAntennas.remove(type.key);
      notifyListeners();
    } else {
      _selectedAntennas.add(type);
      _isLoadingData = true;
      notifyListeners();

      final List<Marker> response =
          await _mapUseCase.getAntennas(type, context);

      if (response.isNotEmpty) {
        _mapAntennas[type.key] = response.toSet();
      }

      _isLoadingData = false;
      notifyListeners();
      print("⚪ isLoadingData desactivado ESTE ES EL DE ANTENNA");
    }
  }

  void updateMarker(LatLng position) {
    final marker = Marker(
      markerId: const MarkerId("current"),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    _mapAntennas['current'] = {marker};
    notifyListeners();
  }

  Future<void> togglePolygonVisibility(CoveragesTypes type, BuildContext context) async {
    if (_selectedButtons.contains(type)) {
      _selectedButtons.remove(type);
      _isLoadingData = true;
      notifyListeners();

      // Limpiar polígonos del tipo deseleccionado para liberar memoria
      clearPolygonsForType(type.id);

      await Future.delayed(const Duration(seconds: 4));

      _isLoadingData = false;
      notifyListeners();
      return;
    }

    // Limpiar tipo anterior si existe
    if (_selectedButtons.isNotEmpty) {
      final previousType = _selectedButtons.first;
      print("🧹 Limpiando tipo anterior: ${previousType.name} (ID: ${previousType.id})");
      clearPolygonsForType(previousType.id);
    }

    _selectedButtons.clear();
    _selectedButtons.add(type);

    _isLoadingData = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final stopwatch = Stopwatch()..start();

    try {
      List<Polygon> polygons;

      if (_progressiveCache.containsKey(type.id)) {
        polygons = _progressiveCache[type.id]!;
        print("✅ Polígonos obtenidos desde cache progresivo");
      } else if (_cache.containsKey(type.id)) {
        polygons = _cache[type.id]!;
        print("✅ Polígonos obtenidos desde _cache");
      } else {
        print("🔄 Cargando polígonos desde red para tipo: ${type.id}");
        polygons = await _loadPolygons(type.id, context);
        print("📦 Polígonos obtenidos: ${polygons.length} elementos");
        print("📦 Polígonos cargados desde red y cacheados");
      }

      final elapsed = stopwatch.elapsedMilliseconds;
      const minVisibleDuration = 400;

      if (elapsed < minVisibleDuration) {
        await Future.delayed(
            Duration(milliseconds: minVisibleDuration - elapsed));
      }
      
      print("🎯 Estado final - Polígonos visibles: ${visiblePolygons.length}");
      print("🎯 Botones seleccionados: ${_selectedButtons.map((e) => e.name).join(', ')}");
      print("🎯 Cache contiene: ${_cache.keys.join(', ')}");
    } catch (e) {
      debugPrint("❌ Error al cargar polígonos: $e");
    } finally {
      _isLoadingData = false;
      notifyListeners();
      print("⚪ isLoadingData desactivado ESTE ES EL DE POLIGON");
    }
  }

  Future<List<Polygon>> _loadPolygons(int typeId, BuildContext context) async {
    final box = await Hive.openBox('polygonCache');

    // Intentar cargar desde caché primero
    if (box.containsKey(typeId)) {
      final rawData = box.get(typeId) as String;
      final List<Map<String, dynamic>> decodedList =
          await compute(decodePolygonsData, rawData);

      final cachedPolygons = decodedList.map((polygonData) {
        return Polygon(
          polygonId: PolygonId(polygonData["id"]),
          points: (polygonData["points"] as List<dynamic>).map((point) {
            return LatLng(point["latitude"], point["longitude"]);
          }).toList(),
          strokeColor: Color(polygonData["strokeColor"]),
          fillColor: Color(polygonData["fillColor"]),
          strokeWidth: polygonData["strokeWidth"],
        );
      }).toList();

      // Guardar en cache progresivo
      _progressiveCache[typeId] = cachedPolygons;
      _loadedPolygonCounts[typeId] = cachedPolygons.length;
      _totalPolygonCounts[typeId] = cachedPolygons.length;
      
      print("📦 Polígonos cargados desde caché: ${cachedPolygons.length} elementos");
      return cachedPolygons;
    }

    print("🔄 Llamando a getPolygonsById para tipo: $typeId");
    
    try {
      // Cargar todos los polígonos de una vez
      final polygons = await _mapUseCase.getPolygonsById(typeId, context: context);
      print("📦 Todos los polígonos cargados: ${polygons.length} elementos");
      
      if (polygons.isNotEmpty) {
        print("📍 Primer polígono - ID: ${polygons.first.polygonId.value}, Puntos: ${polygons.first.points.length}");
      }
      
      // Guardar en cache progresivo
      _progressiveCache[typeId] = polygons;
      _loadedPolygonCounts[typeId] = polygons.length;
      _totalPolygonCounts[typeId] = polygons.length;
      
      // Solo guardar en caché Hive si se obtuvieron polígonos exitosamente
      if (polygons.isNotEmpty) {
        await box.put(typeId, _encodePolygons(polygons));
        print("💾 Polígonos guardados en caché para tipo: $typeId");
      }
      
      return polygons;
    } catch (e) {
      print("❌ Error al cargar polígonos: $e");
      
      // Si hay error, intentar cargar desde caché si existe
      if (box.containsKey(typeId)) {
        print("🔄 Intentando cargar desde caché debido al error...");
        final cachedData = box.get(typeId) as String;
        final cachedPolygons = _decodePolygons(cachedData);
        print("📦 Polígonos cargados desde caché: ${cachedPolygons.length} elementos");
        
        // Guardar en cache progresivo
        _progressiveCache[typeId] = cachedPolygons;
        _loadedPolygonCounts[typeId] = cachedPolygons.length;
        _totalPolygonCounts[typeId] = cachedPolygons.length;
        
        return cachedPolygons;
      }
      
      rethrow;
    }
  }

  // Método para cargar polígonos adicionales (deshabilitado)
  Future<void> loadMorePolygons(int typeId, BuildContext context) async {
    print("⚠️ Carga progresiva deshabilitada - no se pueden cargar más polígonos");
  }

  // Método para limpiar memoria (simplificado)
  void _cleanupMemoryIfNeeded() {
    // No se necesita limpieza automática cuando se cargan todos los polígonos
    print("ℹ️ Limpieza automática de memoria deshabilitada");
  }

  // Método para forzar limpieza de memoria
  void _forceGarbageCollection() {
    // Limpiar caché Hive si es necesario
    _cache.clear();
    
    // Notificar cambios para que Flutter pueda liberar memoria
    notifyListeners();
    
    print("🧹 Limpieza de memoria forzada completada");
  }

  Future<void> initializeCache() async {
    try {
      final box = await Hive.openBox('polygonCache');

      if (box.isNotEmpty) {
        for (final key in box.keys) {
          final polygonData = box.get(key);
          if (polygonData != null) {
            _cache[key as int] = _decodePolygons(polygonData);
          }
        }
      }

      print("Caché inicializada con ${box.keys.length} elementos.");
    } catch (e) {
      debugPrint("Error al inicializar la caché: $e");
    }
    notifyListeners();
  }

  List<Polygon> _decodePolygons(String data) {
    try {
      final decodedData = jsonDecode(data) as List<dynamic>;
      return decodedData.map((polygonData) {
        return Polygon(
          polygonId: PolygonId(polygonData["id"]),
          points: (polygonData["points"] as List<dynamic>).map((point) {
            return LatLng(point["latitude"], point["longitude"]);
          }).toList(),
          strokeColor: Color(polygonData["strokeColor"]),
          fillColor: Color(polygonData["fillColor"]),
          strokeWidth: polygonData["strokeWidth"],
        );
      }).toList();
    } catch (e) {
      throw Exception("Failed to decode polygons: $e");
    }
  }

  void checkBounds(LatLng position) {
    if (!_bounds.contains(position)) {
      final double newLat = position.latitude
          .clamp(_bounds.southwest.latitude, _bounds.northeast.latitude);
      final double newLng = position.longitude
          .clamp(_bounds.southwest.longitude, _bounds.northeast.longitude);
      if (_mapController != null) {
        _mapController!.moveCamera(
          CameraUpdate.newLatLng(LatLng(newLat, newLng)),
        );
      }
    }
  }

  String _encodePolygons(List<Polygon> polygons) {
    try {
      final encodedData = polygons.map((polygon) {
        return {
          "id": polygon.polygonId.value,
          "points": polygon.points.map((point) {
            return {
              "latitude": point.latitude,
              "longitude": point.longitude,
            };
          }).toList(),
          "strokeColor": polygon.strokeColor.value,
          "fillColor": polygon.fillColor.value,
          "strokeWidth": polygon.strokeWidth,
        };
      }).toList();

      return jsonEncode(encodedData);
    } catch (e) {
      throw Exception("Failed to encode polygons: $e");
    }
  }
}

List<Map<String, dynamic>> decodePolygonsData(String data) {
  final decodedData = jsonDecode(data) as List<dynamic>;
  return decodedData.cast<Map<String, dynamic>>();
}

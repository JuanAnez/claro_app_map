import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/point_of_sale_repository.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/main.dart';

class PointOfSaleProvider with ChangeNotifier {
  final PointOfSaleRepository repository;
  final Map<String, Map<String, dynamic>> cache = {};

  static Set<Marker> _cachedMarkers = {};

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  bool isExpanded = false;

  MapType mapType = MapType.normal;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void zoomIn() {
    _mapController?.moveCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController?.moveCamera(CameraUpdate.zoomOut());
  }

  void goToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Servicio de ubicación desactivado.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 Permiso de ubicación denegado.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Permiso denegado permanentemente.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));
      print("📍 Mapa centrado en: $userLatLng");
    } catch (e) {
      print("❌ Error obteniendo ubicación actual: $e");
    }
  }

  void toggleMapType() {
    final List<MapType> mapTypes = [
      MapType.normal,
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
    ];

    int currentIndex = mapTypes.indexOf(mapType);
    int nextIndex = (currentIndex + 1) % mapTypes.length;

    mapType = mapTypes[nextIndex];
    notifyListeners();
  }

  void toggleExpand() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  bool isLoading = false;
  Set<Marker> markers = {};

  List<String> activePosTypeIds = [];
  List<String> activeOperatorIds = [];

  void updateActiveFilters({
    required List<String> posTypeIds,
    required List<String> operatorIds,
  }) {
    activePosTypeIds = posTypeIds;
    activeOperatorIds = operatorIds;
    notifyListeners();
  }

  static final LatLngBounds _bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  PointOfSaleProvider(this.repository);
  void checkBounds(LatLng position) {
    if (!_bounds.contains(position)) {
      final double newLat = position.latitude
          .clamp(_bounds.southwest.latitude, _bounds.northeast.latitude);
      final double newLng = position.longitude
          .clamp(_bounds.southwest.longitude, _bounds.northeast.longitude);
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(LatLng(newLat, newLng)),
      );
    }
  }

  void clearMarkersCache() {
    markers.clear();
    cache.clear();
    _cachedMarkers = {};
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadMarkers(BuildContext context) async {
    if (_isDisposed) return;

    if (_cachedMarkers.isNotEmpty) {
      markers = _cachedMarkers;
      if (!_isDisposed &&
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks) {
        notifyListeners();
      }
      print("✅ Usando marcadores desde caché");
      return;
    }

    isLoading = true;
    if (!_isDisposed &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    }

    final locations = await repository.fetchLocations(context: context);

    for (final loc in locations) {
      final id = loc['posLocationId'].toString();
      cache.putIfAbsent(id, () => loc);
    }

    final newMarkers = await createMarkers(context, cache.values.toList());
    markers = newMarkers;
    _cachedMarkers = newMarkers;

    isLoading = false;
    if (!_isDisposed &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    }
  }

  Future<Set<Marker>> createMarkers(
      BuildContext context, List<Map<String, dynamic>> locations) async {
    Set<Marker> result = {};

    for (var location in locations) {
      try {
        final id = location['posLocationId']?.toString();
        final lat =
            double.tryParse(location['latitude']?.toString() ?? '') ?? 0.0;
        final lng =
            double.tryParse(location['longitude']?.toString() ?? '') ?? 0.0;

        if (lat == 0 || lng == 0 || id == null) continue;

        final icon = await _getMarkerIcon(location);

        result.add(
          Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, lng),
              icon: icon,
              onTap: () {
                final data = cache[id];
                final safeContext = navigatorKey.currentContext;

                if (data != null && safeContext != null) {
                  showMarkerDetails(safeContext, data, () {
                    Future.delayed(Duration(milliseconds: 300), () {
                      loadMarkers(safeContext);
                    });
                  });
                }
              }),
        );
      } catch (e) {
        print("⚠️ Error creando marcador: $e");
      }
    }

    return result;
  }

  Future<BitmapDescriptor> _getMarkerIcon(Map<String, dynamic> loc) async {
    try {
      final posIcon = loc['posIcon'] ?? {};
      final String svgPath = posIcon['iconSource'] ?? '';
      final String fillColor = posIcon['iconFillColor'] ?? '#FF0000';

      if (svgPath.isEmpty) return BitmapDescriptor.defaultMarker;

      final svgString = '''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="$svgPath" fill="$fillColor" />
        </svg>
      ''';

      final DrawableRoot svgRoot =
          await svg.fromSvgString(svgString, svgString);
      final picture = svgRoot.toPicture(size: const Size(60, 60));
      final image = await picture.toImage(60, 60);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("❌ Error SVG a ícono: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }
}
/*
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/point_of_sale_repository.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/main.dart';

class PointOfSaleProvider with ChangeNotifier {
  final PointOfSaleRepository repository;
  final Map<String, Map<String, dynamic>> cache = {};

  static Set<Marker> _cachedMarkers = {};

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  bool isExpanded = false;

  MapType mapType = MapType.normal;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void zoomIn() {
    _mapController?.moveCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController?.moveCamera(CameraUpdate.zoomOut());
  }

  void goToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Servicio de ubicación desactivado.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 Permiso de ubicación denegado.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Permiso denegado permanentemente.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));
      print("📍 Mapa centrado en: $userLatLng");
    } catch (e) {
      print("❌ Error obteniendo ubicación actual: $e");
    }
  }

  void toggleMapType() {
    final List<MapType> mapTypes = [
      MapType.normal,
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
    ];

    int currentIndex = mapTypes.indexOf(mapType);
    int nextIndex = (currentIndex + 1) % mapTypes.length;

    mapType = mapTypes[nextIndex];
    notifyListeners();
  }

  void toggleExpand() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  bool isLoading = false;
  Set<Marker> markers = {};

  List<String> activePosTypeIds = [];
  List<String> activeOperatorIds = [];

  static final LatLngBounds _bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  PointOfSaleProvider(this.repository);
  void checkBounds(LatLng position) {
    if (!_bounds.contains(position)) {
      final double newLat = position.latitude
          .clamp(_bounds.southwest.latitude, _bounds.northeast.latitude);
      final double newLng = position.longitude
          .clamp(_bounds.southwest.longitude, _bounds.northeast.longitude);
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(LatLng(newLat, newLng)),
      );
    }
  }

  void clearMarkersCache() {
    markers.clear();
    cache.clear();
    _cachedMarkers = {};
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadMarkers(BuildContext context) async {
    if (_isDisposed) return;

    if (_cachedMarkers.isNotEmpty) {
      markers = _cachedMarkers;
      if (!_isDisposed &&
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks) {
        notifyListeners();
      }
      print("✅ Usando marcadores desde caché");
      return;
    }

    isLoading = true;
    if (!_isDisposed &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    }

    final locations = await repository.fetchLocations(context: context);

    for (final loc in locations) {
      final id = loc['posLocationId'].toString();
      cache.putIfAbsent(id, () => loc);
    }

    final newMarkers = await createMarkers(context, cache.values.toList());
    markers = newMarkers;
    _cachedMarkers = newMarkers;

    isLoading = false;
    if (!_isDisposed &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    }
  }

  Future<Set<Marker>> createMarkers(
      BuildContext context, List<Map<String, dynamic>> locations) async {
    Set<Marker> result = {};

    for (var location in locations) {
      try {
        final id = location['posLocationId']?.toString();
        final lat =
            double.tryParse(location['latitude']?.toString() ?? '') ?? 0.0;
        final lng =
            double.tryParse(location['longitude']?.toString() ?? '') ?? 0.0;

        if (lat == 0 || lng == 0 || id == null) continue;

        final icon = await _getMarkerIcon(location);

        result.add(
          Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, lng),
              icon: icon,
              onTap: () {
                final data = cache[id];
                final safeContext = navigatorKey.currentContext;

                if (data != null && safeContext != null) {
                  showMarkerDetails(safeContext, data, () {
                    if (safeContext.mounted) {
                      loadMarkers(safeContext);
                    }
                  });
                }
              }),
        );
      } catch (e) {
        print("⚠️ Error creando marcador: $e");
      }
    }

    return result;
  }

  Future<BitmapDescriptor> _getMarkerIcon(Map<String, dynamic> loc) async {
    try {
      final posIcon = loc['posIcon'] ?? {};
      final String svgPath = posIcon['iconSource'] ?? '';
      final String fillColor = posIcon['iconFillColor'] ?? '#FF0000';

      if (svgPath.isEmpty) return BitmapDescriptor.defaultMarker;

      final svgString = '''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="$svgPath" fill="$fillColor" />
        </svg>
      ''';

      final DrawableRoot svgRoot =
          await svg.fromSvgString(svgString, svgString);
      final picture = svgRoot.toPicture(size: const Size(60, 60));
      final image = await picture.toImage(60, 60);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("❌ Error SVG a ícono: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }
}
*/
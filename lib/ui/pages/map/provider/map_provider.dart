// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/domain/types/antennas_types.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';
import 'package:icc_maps/ui/pages/map/type/map_display_types.dart';
import 'package:icc_maps/domain/use_cases/map_use_case.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:latlong2/latlong.dart';

class MapProvider extends ChangeNotifier {
  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  static const double _zoomValue = 0.5;

  final MapUseCase mapUseCase = MapUseCase();

  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  bool _isLoadingData = false;
  bool get isLoadingData => _isLoadingData;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  MapDisplayTypes _mapType = MapDisplayTypes.streets;
  MapDisplayTypes get mapType => _mapType;

  final Set<Enum> _selectedButtons = <Enum>{};
  Set<Enum> get selectedButtons => _selectedButtons;

  final Map<String, List<Polygon>> _mapCoveragesCache = {};
  final Map<String, List<Polygon>> _mapCoverages = {};

  static final LatLngBounds bounds = LatLngBounds(
    const LatLng(17.729101, -67.546335),
    const LatLng(18.759204, -65.112048),
  );

  List<Polygon> get mapCoverages =>
      _mapCoverages.values.expand((c) => c).toList();

  final Map<String, List<Marker>> _mapAntennasCache = {};
  final Map<String, List<Marker>> _mapAntennas = {};
  List<Marker> get mapAntennas => _mapAntennas.values.expand((a) => a).toList();

  final Map<String, List<Polyline>> _polyLines = <String, List<Polyline>>{};
  List<Polyline> get polyLines =>
      _polyLines.values.expand((pol) => pol).toList();

  final Map<String, List<CircleMarker>> _circles = {};
  List<CircleMarker> get circles =>
      _circles.values.expand((cir) => cir).toList();

  void handleButtonAction(ButtonsActionType action) async {
    if (!_isLoadingData) {
      _isLoadingData = true;
      notifyListeners();

      if (action is CollapseButtons) {
        await _collapseButtons();
      } else if (action is ZoomMap) {
        await _zoomMap(action.zoomIn);
      } else if (action is ShowAntennas) {
        await _showAntennas(action.antennaType);
      } else if (action is ShowCoverages) {
        await _showCoverages(action.coverageType);
      } else if (action is ChangeMapDisplay) {
        await _changeMapDisplay();
      }

      _isLoadingData = false;
      notifyListeners();
    }
  }

  String getMapTemplateURL() {
    return 'https://api.mapbox.com/styles/v1/mapbox/${mapType.name}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}';
  }

  Map<String, String> getMapAccessToken() => {
        "accessToken":
            "pk.eyJ1IjoiaXN5OTk4MDEiLCJhIjoiY20wbWpyOTE0MDM1YjJqcHIxODNuZDc1cCJ9.-G1o8fZuKwIPe__J1BWoqg"
      };

  LatLng? _lastCenter;
  double? _lastZoom;

  void _storeMapState() {
    _lastCenter = _mapController.center;
    _lastZoom = _mapController.zoom;
  }

  void _restoreMapState() {
    if (_lastCenter != null && _lastZoom != null) {
      _mapController.move(_lastCenter!, _lastZoom!);
    }
  }

  Future<void> _collapseButtons() async {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  Future<void> _zoomMap(bool zoomIn) async {
    _storeMapState();
    _mapController.move(
      _mapController.center,
      _mapController.zoom + (zoomIn ? _zoomValue : -_zoomValue),
    );
    notifyListeners();
  }

  Future<void> _changeMapDisplay() async {
    _storeMapState();
    int index = MapDisplayTypes.values.indexOf(_mapType);
    bool reachTheLastIndex = index >= MapDisplayTypes.values.length - 1;

    if (reachTheLastIndex) {
      _mapType = MapDisplayTypes.values[0];
    } else {
      _mapType = MapDisplayTypes.values[index + 1];
    }
    _restoreMapState();
    notifyListeners();
  }

  Future<void> _showAntennas(AntennasTypes antenna) async {
    _storeMapState();
    if (!_selectedButtons.add(antenna)) {
      _selectedButtons.remove(antenna);
      _mapAntennas.remove(antenna.key);
      _restoreMapState();
      notifyListeners();
      return;
    }

    if (_mapAntennasCache.containsKey(antenna.key)) {
      _putAntennasOnMap(antenna.key, _mapAntennasCache[antenna.key] ?? []);
      _restoreMapState();
      return;
    }

    final List<Marker> response = await mapUseCase.getAntennas(antenna);
    if (response.isNotEmpty) {
      _mapAntennasCache.putIfAbsent(antenna.key, () => response);
      _putAntennasOnMap(antenna.key, response);
    }
    _restoreMapState();
    notifyListeners();
  }

  void _putAntennasOnMap(String key, List<Marker> markers) {
    _mapAntennas[key] = markers;
    notifyListeners();
  }

  Future<void> _showCoverages(CoveragesTypes coverage) async {
    if (!_selectedButtons.add(coverage)) {
      _selectedButtons.remove(coverage);
      _mapCoverages.remove(coverage.key);
      notifyListeners();
      return;
    }

    if (_mapCoveragesCache.containsKey(coverage.key)) {
      _putCoveragesOnMap(coverage.key, _mapCoveragesCache[coverage.key] ?? []);
      return;
    }

    final List<Polygon> response = await mapUseCase.getCoverage(coverage);
    if (response.isNotEmpty) {
      _mapCoveragesCache.putIfAbsent(coverage.key, () => response);
      _putCoveragesOnMap(coverage.key, response);
    }
  }

  void _putCoveragesOnMap(String key, List<Polygon> coverages) {
    _mapCoverages[key] = coverages;
    notifyListeners();
  }

  Set<String> getCoveragesContainingPoint(LatLng point) {
    final List<Polygon> coveragesContainingPoint = [];
    final Set<String> coverageFinder = {};

    _mapCoverages.forEach((key, polygons) {
      for (final coverage in polygons) {
        if (isPointInPolygon(point, coverage)) {
          coveragesContainingPoint.add(coverage);
          coverageFinder.add(key);
        }
      }
    });

    return coverageFinder;
  }

  bool isPointInPolygon(LatLng point, Polygon polygon) {
    final coordinates = polygon.points;
    int i;
    int j = coordinates.length - 1;
    bool isInside = false;

    for (i = 0; i < coordinates.length; j = i++) {
      final xi = coordinates[i].latitude, yi = coordinates[i].longitude;
      final xj = coordinates[j].latitude, yj = coordinates[j].longitude;

      final intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude <
              (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
      if (intersect) {
        isInside = !isInside;
      }
    }

    return isInside;
  }

  Marker? _currentMarker;
  Marker? get currentMarker => _currentMarker;

  void updateMarker(LatLng point) {
    if (_currentMarker != null) {
      for (var markers in _mapAntennas.values) {
        markers.removeWhere((marker) => marker == _currentMarker);
      }
    }
    _currentMarker = Marker(
      point: point,
      child: const Icon(Icons.location_on, color: Colors.red),
    );

    _mapAntennas['currentMarker'] = [_currentMarker!];
    notifyListeners();
  }

  Future<void> loadAllGeoJson() async {
    _isInitialLoading = true;
    notifyListeners();
    List<CoveragesTypes> allCoverages = [
      CoveragesTypes.fiveM,
      CoveragesTypes.gpn,
      CoveragesTypes.lte,
      CoveragesTypes.tenM,
      CoveragesTypes.threeG
    ];

    for (CoveragesTypes coverage in allCoverages) {
      await _showCoverages(coverage);
    }

    _isInitialLoading = false;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1), () {
      _deactivateAllCoverages();
    });
  }

  void _deactivateAllCoverages() {
    _selectedButtons.removeWhere((button) {
      if (button is CoveragesTypes) {
        _mapCoverages.remove(button.key);
        return true;
      }
      return false;
    });
    notifyListeners();
  }

  void checkBounds(MapController controller, MapPosition position) {
    final LatLng center = position.center!;
    if (!bounds.contains(center)) {
      final double newLat = center.latitude
          .clamp(bounds.southWest.latitude, bounds.northEast.latitude);
      final double newLng = center.longitude
          .clamp(bounds.southWest.longitude, bounds.northEast.longitude);
      controller.move(LatLng(newLat, newLng), position.zoom!);
    }
  }
}
// ignore_for_file: unused_field
/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';
import 'package:icc_maps/domain/use_cases/map_use_case.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';

class MapProvider extends ChangeNotifier {
  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  GoogleMapController? _mapController;
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  final Set<Enum> _selectedButtons = <Enum>{};
  Set<Enum> get selectedButtons => _selectedButtons;

  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polyLines = {};
  final Set<Circle> _circles = {};

  Set<Marker> get markers => _markers;
  Set<Polygon> get polygons => _polygons;
  Set<Polyline> get polyLines => _polyLines;
  Set<Circle> get circles => _circles;
  final MapUseCase mapUseCase = MapUseCase();

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> handleButtonAction(dynamic action) async {
    if (action is CollapseButtons) {
      _isExpanded = !_isExpanded;
      notifyListeners();
    } else if (action is ShowCoverages) {
      await _showCoverages(action.coverageType);
    }
    notifyListeners();
  }

  Future<void> loadAllGeoJson() async {
    _isInitialLoading = true;
    notifyListeners();
    List<CoveragesTypes> allCoverages = [
      CoveragesTypes.fiveM,
      CoveragesTypes.gpn,
      CoveragesTypes.lte,
      CoveragesTypes.tenM,
      CoveragesTypes.threeG
    ];

    for (CoveragesTypes coverage in allCoverages) {
      await _showCoverages(coverage);
    }

    _isInitialLoading = false;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1), () {
      _deactivateAllCoverages();
    });
  }

  void _deactivateAllCoverages() {
    _selectedButtons.removeWhere((button) {
      if (button is CoveragesTypes) {
        _mapCoverages.remove(button.key);
        return true;
      }
      return false;
    });
    notifyListeners();
  }

  Future<void> _showCoverages(CoveragesTypes coverage) async {
    if (!_selectedButtons.add(coverage)) {
      _selectedButtons.remove(coverage);
      _mapCoverages.remove(coverage.key);
      notifyListeners();
      return;
    }

    try {
      final List<Polygon> response =
          (await mapUseCase.getCoverage(coverage)).cast<Polygon>();

      if (response.isNotEmpty) {
        _putCoveragesOnMap(coverage.key, response);
      }
    } catch (e) {
      print("Error al cargar las coberturas: $e");
    }
  }

  void _putCoveragesOnMap(String key, List<Polygon> coverages) {
    _mapCoverages[key] = coverages;

    // Limpia y actualiza el conjunto de polígonos del mapa
    _polygons.clear();
    _mapCoverages.forEach((_, polygonList) {
      _polygons.addAll(polygonList);
    });
    notifyListeners();
  }

  final Map<String, List<Polygon>> _mapCoverages = {};

  void updateMarker(LatLng point) {
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId("currentMarker"),
      position: point,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    notifyListeners();
  }

  Set<String> getCoveragesContainingPoint(LatLng point) {
    return {};
  }
}
*/
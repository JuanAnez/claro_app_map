import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';
import 'package:icc_maps/domain/use_cases/google_use_case.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';

class GoogleMapProvider extends ChangeNotifier {
  GoogleMapProvider() {
    initializeCache();
  }

  late GoogleMapController _mapController;

  bool _isLoadingData = false;
  bool get isLoading => _isLoadingData;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  Future<void> _collapseButtons() async {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  static LatLngBounds bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;

  final Set<CoveragesTypes> _selectedButtons = <CoveragesTypes>{};
  Set<CoveragesTypes> get selectedButtons => _selectedButtons;

  Future<void> _zoomMap(bool zoomIn) async {
    _mapController.animateCamera(
      CameraUpdate.zoomBy(zoomIn ? 1.0 : -1.0),
    );
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void handleButtonAction(
      ButtonsActionType action, BuildContext context) async {
    if (!_isLoadingData) {
      _isLoadingData = true;
      notifyListeners();

      if (action is CollapseButtons) {
        await _collapseButtons();
      } else if (action is ShowCoverages) {
        togglePolygonVisibility(action.coverageType);
      } else if (action is ZoomMap) {
        await _zoomMap(action.zoomIn);
      } else if (action is ChangeMapDisplay) {
        await _changeMapDisplay();
      }

      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _changeMapDisplay() async {
    List<MapType> availableMapTypes =
        MapType.values.where((type) => type != MapType.none).toList();

    int currentIndex = availableMapTypes.indexOf(_mapType);
    _mapType = availableMapTypes[(currentIndex + 1) % availableMapTypes.length];
    notifyListeners();
  }

  final GoogleUseCase _useCase = GoogleUseCase();
  final Map<int, List<Polygon>> _cache = {};

  List get visiblePolygons =>
      _selectedButtons.expand((type) => _cache[type.id] ?? []).toList();

  bool isPolygonVisible(CoveragesTypes type) => _selectedButtons.contains(type);

  Future<void> togglePolygonVisibility(CoveragesTypes type) async {
    if (_selectedButtons.contains(type)) {
      _selectedButtons.remove(type);
    } else {
      _selectedButtons.add(type);

      if (_cache.containsKey(type.id)) {
        print("Data is cached for coverage type: ${type.id}");
      } else {
        print("Data is not cached for coverage type: ${type.id}");

        _isLoadingData = true;
        notifyListeners();

        try {
          final polygons = await _useCase.getPolygonsById(type.id);
          _cache[type.id] = polygons;

          final box = await Hive.openBox('polygonCache');
          await box.put(type.id, _encodePolygons(polygons));
        } catch (e) {
          debugPrint("Error loading polygons: $e");
        }

        _isLoadingData = false;
      }
    }

    notifyListeners();
  }

  Future<void> initializeCache() async {
    try {
      final box = await Hive.openBox('polygonCache');
      for (final key in box.keys) {
        final polygonData = box.get(key);
        if (polygonData != null) {
          _cache[key as int] = _decodePolygons(polygonData);
        }
      }
    } catch (e) {
      debugPrint("Error initializing cache: $e");
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

class PolygonType {
  final int id;
  final String name;

  PolygonType({required this.id, required this.name});
}

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_maps/data/network/webtest/google_client_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GoogleMapExample extends StatefulWidget {
  const GoogleMapExample({super.key});

  @override
  State<GoogleMapExample> createState() => GoogleMapExampleState();
}

class GoogleMapExampleState extends State<GoogleMapExample> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(18.192150, -66.340428),
    zoom: 9,
  );

  LatLngBounds bounds = LatLngBounds(
    southwest: const LatLng(17.729101, -67.546335),
    northeast: const LatLng(18.759204, -65.112048),
  );

  final Set<Polygon> _visiblePolygons = {};
  final Map<int, List<Polygon>> _cachedPolygons = {};
  bool _isLoading = true;
  final Map<int, bool> _polygonVisibility = {
    5: false, // GPN
    11: false, // VRAD
    2: false, // FWA
    7: false, // LTE
    6: false, // 3G
  };
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadAllPolygons();
  }

  Database? _database;

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'polygon_cache.db'),
      onCreate: (db, version) {
        print("Creando tabla de caché en SQLite");
        return db.execute(
          'CREATE TABLE polygons(id INTEGER PRIMARY KEY, data TEXT)',
        );
      },
      version: 1,
    );
  }

  // Cargar todos los polígonos desde la API o caché
  Future<void> _loadAllPolygons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> polygonIds = [5, 11, 2, 7, 6];
    for (int id in polygonIds) {
      String cacheKey = 'polygon_$id';
      String? cachedGeoJson = prefs.getString(cacheKey);

      if (cachedGeoJson != null) {
        print('Cargando polígono desde caché para ID = $id');
        List<Polygon> cachedPolygons = _parsePolygonsFromCache(cachedGeoJson);
        _cachedPolygons[id] = cachedPolygons;
      } else {
        print('Descargando polígono desde API para ID = $id');
        await _loadPolygonFromApi(id, cacheKey);
      }
    }
    // Una vez que todos los polígonos están cargados, mostramos el mapa
    setState(() {
      _isLoading = false; // Ocultar el indicador de carga
    });
  }

  // Guardar polígonos en SQLite
  Future<void> _savePolygonToSQLite(int id, String data) async {
    final db = _database;
    if (db != null) {
      print("Guardando polígono en SQLite: ID = $id");
      await db.insert(
        'polygons',
        {'id': id, 'data': data},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Polígono guardado en SQLite correctamente.");
    } else {
      print("Error: La base de datos SQLite no está inicializada.");
    }
  }

  // Cargar polígono desde la API
  Future<void> _loadPolygonFromApi(int id, String cacheKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GoogleClient client = GoogleClient();

    try {
      print('Llamando a la API para obtener polígono con ID = $id');
      final response = await client.findCoverages(id);
      if (response.ok) {
        print('Polígono obtenido desde API. Guardando en caché y SQLite.');
        setStateIfMounted(() {
          _cachedPolygons[id] = Set<Polygon>.of(response.content).toList();
        });

        String jsonData = jsonEncode(response.content);
        await prefs.setString(cacheKey, jsonData); // Guardar en caché
        await _savePolygonToSQLite(id, jsonData); // Guardar en SQLite
      } else {
        print("Error al cargar polígonos desde la API: ${response.message}");
      }
    } catch (e) {
      print("Error al cargar los polígonos desde la API: $e");
    }
  }

  // Parsear los polígonos desde la caché
  List<Polygon> _parsePolygonsFromCache(String cachedData) {
    final List<dynamic> decodedData = jsonDecode(cachedData);

    final List<Polygon> polygons = [];

    for (var feature in decodedData) {
      if (feature is Map &&
          feature.containsKey('points') &&
          feature['points'] is List) {
        final List<dynamic> coordinates = feature['points'];

        final int strokeColor = feature['strokeColor'] ?? Colors.blue.value;
        final int fillColor =
            feature['fillColor'] ?? Colors.blue.withOpacity(0.3).value;

        final List<LatLng> points = coordinates
            .where((coord) => coord is List && coord.length >= 2)
            .map<LatLng>((coord) => LatLng(coord[0], coord[1]))
            .toList();

        if (points.isNotEmpty) {
          polygons.add(
            Polygon(
              polygonId:
                  PolygonId(feature['polygonId']?.toString() ?? 'defaultId'),
              points: points,
              strokeWidth: 1,
              strokeColor: Color(strokeColor),
              fillColor: Color(fillColor),
            ),
          );
        }
      } else {
        print("Feature no contiene los datos esperados");
      }
    }

    return polygons;
  }

  Future<void> _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _database?.close();
    super.dispose();
  }

  void setStateIfMounted(void Function() fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              rotateGesturesEnabled: false,
              mapType: _currentMapType,
              initialCameraPosition: _kGooglePlex,
              polygons: _visiblePolygons,
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);
                _mapController = controller;

                await controller.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 50),
                );
              },
              zoomControlsEnabled: false,
            ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: Colors.blueGrey[900], size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: MenuButtonsContainer(
        isMenuOpen: false,
        toggleMenu: () {},
        onZoomIn: _zoomIn,
        onZoomOut: _zoomOut,
        changeMapType: _changeMapType,
        togglePolygon: _togglePolygon,
      ),
    );
  }

  void _changeMapType() {
    setStateIfMounted(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.hybrid
              : _currentMapType == MapType.hybrid
                  ? MapType.terrain
                  : MapType.normal;
    });
  }

  Future<void> _togglePolygon(int id, String cacheKey) async {
    if (_polygonVisibility[id]!) {
      // Si ya está visible, ocultarlo
      print("Ocultando polígono con ID = $id");
      setStateIfMounted(() {
        _visiblePolygons.removeAll(_cachedPolygons[id] ?? []);
        _polygonVisibility[id] = false;
      });
    } else {
      print("Mostrando polígono con ID = $id");
      setStateIfMounted(() {
        _visiblePolygons.addAll(_cachedPolygons[id] ?? []);
        _polygonVisibility[id] = true;
      });
    }
  }
}

class MenuButtonsContainer extends StatelessWidget {
  final bool isMenuOpen;
  final VoidCallback toggleMenu;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback changeMapType;
  final Function(int, String) togglePolygon;

  const MenuButtonsContainer({
    super.key,
    required this.isMenuOpen,
    required this.toggleMenu,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.changeMapType,
    required this.togglePolygon,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return verticalButtons();
        } else {
          return horizontalButtons();
        }
      },
    );
  }

  Column verticalButtons() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFloatingActionButton(
              Icons.map, "Change Map", Colors.green, changeMapType),
          const SizedBox(height: 10),
          _buildFloatingActionButton(
              Icons.add, "Zoom In", Colors.blue, onZoomIn),
          const SizedBox(height: 10),
          _buildFloatingActionButton(
              Icons.remove, "Zoom Out", Colors.orange, onZoomOut),
          const SizedBox(height: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle GPN", Colors.purple,
              () => togglePolygon(5, 'gpn')),
          const SizedBox(height: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle VRAD", Colors.red,
              () => togglePolygon(11, 'vrad')),
          const SizedBox(height: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle FWA", Colors.amber,
              () => togglePolygon(2, 'fwa')),
          const SizedBox(height: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle LTE", Colors.green,
              () => togglePolygon(7, 'lte')),
          const SizedBox(height: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle 3G", Colors.cyan,
              () => togglePolygon(6, '3g')),
        ],
      );

  Row horizontalButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFloatingActionButton(
              Icons.map, "Change Map", Colors.green, changeMapType),
          const SizedBox(width: 10),
          _buildFloatingActionButton(
              Icons.add, "Zoom In", Colors.blue, onZoomIn),
          const SizedBox(width: 10),
          _buildFloatingActionButton(
              Icons.remove, "Zoom Out", Colors.orange, onZoomOut),
          const SizedBox(width: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle GPN", Colors.purple,
              () => togglePolygon(5, 'gpn')),
          const SizedBox(width: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle VRAD", Colors.red,
              () => togglePolygon(11, 'vrad')),
          const SizedBox(width: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle FWA", Colors.amber,
              () => togglePolygon(2, 'fwa')),
          const SizedBox(width: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle LTE", Colors.green,
              () => togglePolygon(7, 'lte')),
          const SizedBox(width: 10),
          _buildFloatingActionButton(Icons.layers, "Toggle 3G", Colors.cyan,
              () => togglePolygon(6, '3g')),
        ],
      );

  FloatingActionButton _buildFloatingActionButton(
      IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: color,
      child: Icon(icon),
    );
  }
}

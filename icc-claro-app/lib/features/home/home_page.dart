// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/custom_drawer.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_coverage_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_malls_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_municipalities_screen.dart';
// import 'package:icc_claro_app/features/features/map/presentation/map_pos_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/point_of_sale_map_screen.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String password;

  const HomePage({super.key, required this.username, required this.password});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bool _isLoadingData = false;
  bool _didLoadMarkers = false;
  bool _didLoadMunicipalities = false;
  bool _didLoadMalls = false;

  void _initLoadData() {
    _loadMarkersIfNeeded();
    _loadMunicipalitiesIfNeeded();
    _loadMallsIfNeeded();
  }

  void _loadMarkersIfNeeded() {
    final provider = context.read<PointOfSaleProvider>();
    if (!_didLoadMarkers) {
      provider.loadMarkers(context).then((_) {
        if (mounted) {
          setState(() => _didLoadMarkers = true);
        }
      });
    }
  }

  void _loadMunicipalitiesIfNeeded() {
    final provider = context.read<MapProvider>();
    if (!_didLoadMunicipalities) {
      provider.loadMunicipalities(context).then((_) {
        if (mounted) {
          setState(() => _didLoadMunicipalities = true);
        }
      });
    }
  }

  void _loadMallsIfNeeded() {
    final mapProvider = context.read<MapProvider>();
    if (!_didLoadMalls) {
      mapProvider.loadMalls(context, null).then((_) {
        setState(() => _didLoadMalls = true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoadData());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().getUser();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(
            child: Text('No se pudo obtener la información del usuario')),
      );
    }

    final fullName = user.username.toUpperCase();
    final userProfile = user.authorities;
    if (_isLoadingData) {
      return const Center(child: LoadingProgress());
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, weight: 60),
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, weight: 60),
              color: Colors.white,
              onPressed: () => _navigateTo(context, const SearchFormPos()),
              // onPressed: () =>
              //     _navigateTo(context, const SearchFormPointOfSale()),
            )
          ],
          title: Image.asset(
            'assets/images/icc_claro_appbar.png',
            height: 30,
          ),
          centerTitle: true,
        ),
        drawer: const Drawer(
          child: CustomDrawer(),
        ),
        backgroundColor: Colors.teal[30],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Bienvenido',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Text.rich(
                    TextSpan(
                      text: fullName,
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 16.0,
                      ),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (userProfile.contains('POS')) ...[
                          _customCardHome(
                            context: context,
                            icon: Icons.store,
                            iconColor: Colors.white38,
                            label: 'Ventas',
                            description: 'Gestión de puntos de venta.',
                            iconSize: 100,
                            fontSize: 30,
                            onTap: () => _navigateTo(
                                context, const PointOfSaleMapScreen()),
                          ),
                          _customCardHome(
                            context: context,
                            icon: Icons.location_city,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Municipios',
                            description: 'Participación de Mercado',
                            onTap: () {
                              final mapsRepository = MapsRepository();
                              final getMarkersUseCase =
                                  GetMarkersUseCase(mapsRepository);

                              _navigateTo(
                                context,
                                MapMunicipalities(
                                  getMarkersUseCase: getMarkersUseCase,
                                  mapsRepository: mapsRepository,
                                ),
                              );
                            },
                          ),
                          _customCardHome(
                            context: context,
                            icon: Icons.shopping_bag,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Malls',
                            description: 'Información de Centros Comerciales',
                            onTap: () {
                              final mapsRepository = MapsRepository();
                              final getMarkersUseCase =
                                  GetMarkersUseCase(mapsRepository);

                              _navigateTo(
                                context,
                                MapMallsScreen(
                                  getMarkersUseCase: getMarkersUseCase,
                                  mapsRepository: mapsRepository,
                                ),
                              );
                            },
                          ),
                          _customCardHome(
                            context: context,
                            icon: Icons.map,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Coberturas',
                            description: 'Información de Coverturas',
                            onTap: () =>
                                _navigateTo(context, const MapCoverageScreen()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      );
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/clarologo.png',
            height: 16,
          ),
          const SizedBox(width: 12),
          const Text(
            'Todos los derechos reservados, Claro 2024',
            style: TextStyle(color: Colors.white, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

Widget _customCardHome({
  required BuildContext context,
  required IconData icon,
  required Color? iconColor,
  required String label,
  required String description,
  required VoidCallback onTap,
  double iconSize = 40.0,
  double fontSize = 16.0,
}) {
  return Card(
    elevation: 10,
    color: Colors.blueGrey[700],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: iconSize),
              const SizedBox(height: 10),
              Column(
                children: [
                  Center(
                    widthFactor: 1.2,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    widthFactor: 1.2,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

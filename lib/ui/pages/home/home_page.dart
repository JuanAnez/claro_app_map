import 'package:flutter/material.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/drawer/custom_drawer.dart';
import 'package:icc_maps/ui/pages/map/map_malls_center.dart';
import 'package:icc_maps/ui/pages/map/map_municipalities.dart';
import 'package:icc_maps/ui/pages/map/map_page.dart';
import 'package:icc_maps/ui/pages/map/map_points_sale.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/search_form_pos.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_map.dart';
// import 'package:icc_maps/ui/pages/map/widgets/map/google_map.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final String username;
  final String password;
  final bool _isLoadingData = false;

  const HomePage({Key? key, required this.username, required this.password})
      : super(key: key);

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
    if (_isLoadingData)
      return const SkeletonMap();
    else
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
                              context,
                              const MapPointsSale(
                                posLocationId: '',
                                idCentro: '',
                                posLocationName: '',
                                posManager: '',
                                posAddress: '',
                                centro: '',
                                locType: '',
                                operador: '',
                                posTown: '',
                                centrosComerciales: false,
                                locDescription: '',
                                posZoneDescription: '',
                              ),
                            ),
                          ),
                          _customCardHome(
                            context: context,
                            icon: Icons.location_city,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Municipios',
                            description: 'Información de Municipios y Región',
                            onTap: () =>
                                _navigateTo(context, const MapMunicipalities()),
                          ),
                          _customCardHome(
                            context: context,
                            icon: Icons.shopping_bag,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Malls',
                            description: 'Información de Centros Comerciales',
                            onTap: () =>
                                _navigateTo(context, const MapMallsCenter()),
                          ),
                        ],
                        if (userProfile.contains('IC')) ...[
                          _customCardHome(
                            context: context,
                            icon: Icons.map,
                            iconColor: Colors.white38,
                            iconSize: 90,
                            fontSize: 30,
                            label: 'Coberturas',
                            description: 'Información de Coverturas',
                            onTap: () => _navigateTo(context, MapPage()),
                          ),
                          // _customCardHome(
                          //   context: context,
                          //   icon: Icons.map,
                          //   iconColor: Colors.white38,
                          //   iconSize: 90,
                          //   fontSize: 30,
                          //   label: 'GoogleMap',
                          //   description: 'Prueba con GoogleMap',
                          //   onTap: () =>
                          //       _navigateTo(context, const GoogleMapExample()),
                          // )
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

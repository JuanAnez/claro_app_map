// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/info/app_info.dart';
import 'package:icc_claro_app/core/widgets/create_form_mall.dart';
import 'package:icc_claro_app/core/widgets/create_form_pos.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:icc_claro_app/features/authentication/presentation/login/login_page.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _recorridosExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.getUser()?.username ?? 'Invitado';
    final loginUseCase = LoginUseCase();
    final user = userProvider.getUser();
    final auths = user?.authorities ?? '';
    bool has(String role) => auths.contains(role);

    final userProfile = has('POS_LOC_ADMIN')
        ? 'POS_LOC_ADMIN'
        : has('POS_LOC_ASSISTANT')
            ? 'POS_LOC_ASSISTANT'
            : has('POS_ADMIN')
                ? 'POS_ADMIN'
                : has('POS_USER')
                    ? 'POS_USER'
                    : 'USER';

    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(
        username.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: null,
      currentAccountPicture: const CircleAvatar(
        child: Icon(Icons.person, size: 42.0, color: Colors.white60),
        backgroundColor: Colors.black54,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFb60000),
      ),
    );

    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            drawerHeader,
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: const Text(
                      'Buscar POS',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo(context, const SearchFormPos());
                    },
                  ),
                  if (userProfile == 'ADMIN') ...[
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.white),
                      title: const Text(
                        'Añadir POS',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, const CreateFormPos());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.store, color: Colors.white),
                      title: const Text(
                        'Añadir Mall',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, const CreateFormMall());
                      },
                    ),
                  ],
                  ExpansionTile(
                    leading: const Icon(
                      Symbols.alt_route,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Recorridos',
                      style: TextStyle(color: Colors.white),
                    ),
                    collapsedBackgroundColor: Colors.black,
                    backgroundColor: Colors.black,
                    initiallyExpanded: _recorridosExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _recorridosExpanded = expanded;
                      });
                    },
                    iconColor: const Color(0xFFb60000),
                    children: _buildMenuOptions(context, userProfile),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.white),
                    title: const Text(
                      'Información',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      AppInfo.showAppInfo(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await userProvider.clearMunicipalitiesCache();
                    final logoutResponse =
                        await loginUseCase.logoutUser(userProvider, context);
                    if (logoutResponse.ok) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    } else {
                      _showLogoutError(context, logoutResponse.message);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15.0),
                    backgroundColor: const Color(0xFFb60000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Versión 0.0.3',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuOptions(BuildContext context, String userProfile) {
    final incoming = _buildSubOption(
      'Recorridos en Proceso',
      context,
      const RouteScreen(routeType: 'incomingRoutes'),
    );

    final open = _buildSubOption(
      'Recorridos Abiertos',
      context,
      const RouteScreen(routeType: 'openRoutes'),
    );

    final worked = _buildSubOption(
      'Recorridos Trabajados',
      context,
      const RouteScreen(routeType: 'workedRoutes'),
    );

    switch (userProfile) {
      case 'POS_LOC_ADMIN':
      case 'POS_LOC_ASSISTANT':
      case 'POS_ADMIN':
        return [incoming, open, worked];

      case 'POS_USER':
        return [open, worked];

      default:
        return [open, worked];
    }
  }

  Widget _buildSubOption(String title, BuildContext context, Widget screen) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      tileColor: Colors.grey[800],
      dense: true,
      onTap: () {
        Navigator.pop(context);
        _navigateTo(context, screen);
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLogoutError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error al cerrar sesión"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 40,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      onTap: onTap,
    );
  }
}

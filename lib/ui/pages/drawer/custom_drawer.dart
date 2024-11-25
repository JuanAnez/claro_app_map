import 'package:flutter/material.dart';
import 'package:icc_maps/domain/use_cases/login_use_case.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/login/login_page.dart';
import 'package:icc_maps/ui/pages/map/widgets/app_info.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/create_form_pos.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/create_form_mall.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/search_form_pos.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
       final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.getUser()?.username ?? 'Invitado';   
    final loginUseCase = LoginUseCase();
    final user = userProvider.getUser();
    final userProfile = user?.authorities;

    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const SizedBox(height: 40),
                  AppBar(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          username.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 4,
                    automaticallyImplyLeading: false,
                  ),
                  const SizedBox(height: 40),
                  CustomListTile(
                    icon: Symbols.search_check_2,
                    title: 'Buscar POS',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo(context, const SearchFormPos());
                    },
                  ),
                  const SizedBox(height: 20),
                  if (userProfile!.contains('ADMIN')) ...[
                    CustomListTile(
                      icon: Symbols.post_add,
                      title: 'Añadir POS',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, const CreateFormPos());
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomListTile(
                      icon: Symbols.add_business,
                      title: 'Añadir Mall',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, const CreateFormMall());
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  CustomListTile(
                    icon: Symbols.info,
                    title: 'Información',
                    onTap: () {
                      AppInfo.showAppInfo(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await userProvider.clearMunicipalitiesCache();
                  final logoutResponse =
                      await loginUseCase.logoutUser(userProvider);
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(220.0, 50.0),
                    backgroundColor: const Color(0xFFb60000)),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

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
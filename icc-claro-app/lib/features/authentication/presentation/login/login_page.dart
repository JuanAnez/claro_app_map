// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/login_buttons.dart';
import 'package:icc_claro_app/core/widgets/inactivity_logout_widget.dart';
import 'package:icc_claro_app/core/widgets/loading_animation.dart';
import 'package:icc_claro_app/core/widgets/update_required_screen.dart';
import 'package:icc_claro_app/core/services/version_check_service.dart';
import 'package:icc_claro_app/core/types/login_error_types.dart';
import 'package:icc_claro_app/features/authentication/data/models/user_model.dart';
import 'package:icc_claro_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/home/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginUseCase _loginUseCase = LoginUseCase();
  UserProvider? _userProvider;

  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🎯 LoginPage initState ejecutado');
    _printVersionInfoSync();
    _printVersionInfo(); 
    _checkVersionAndLoadToken();
  }

  void _printVersionInfoSync() {
    print('📱 Método síncrono ejecutado');
    print('🔧 Flutter version: ${WidgetsBinding.instance.platformDispatcher.platformBrightness}');
  }

  Future<void> _printVersionInfo() async {
    try {
      print('🔍 Iniciando obtención de información del paquete...');
      final packageInfo = await PackageInfo.fromPlatform();
      print('🚀 App iniciada - Versión: ${packageInfo.version}');
      print('📱 Build: ${packageInfo.buildNumber}');
      print('📦 Package: ${packageInfo.packageName}');
      print('✅ Información del paquete obtenida correctamente');
    } catch (e) {
      print('❌ Error obteniendo info del paquete: $e');
    }
  }
  /// Verifica la versión de la app y carga el token si es compatible
  Future<void> _checkVersionAndLoadToken() async {
    try {
      // Verificar si la versión es compatible
      final isCompatible = await VersionCheckService.isVersionCompatible();
      
      if (!isCompatible) {
        // Si la versión no es compatible, mostrar pantalla de actualización
        final currentVersion = await VersionCheckService.getCurrentVersion();
        final requiredVersion = await VersionCheckService.getMinRequiredVersion();
        _showUpdateRequiredScreen(currentVersion, requiredVersion);
        return;
      }
      
      // Si la versión es compatible, cargar token normalmente
      _loadTokenIfExists();
    } catch (e) {
      print('Error verificando versión: $e');
      // En caso de error, continuar con el flujo normal
      _loadTokenIfExists();
    }
  }

  /// Muestra la pantalla de actualización requerida
  void _showUpdateRequiredScreen(String currentVersion, String requiredVersion) {
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateRequiredScreen(
          currentVersion: currentVersion,
          requiredVersion: requiredVersion,
        ),
      ),
    );
  }

  Future<void> _loadTokenIfExists() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadAccessToken();
    } catch (e) {
      print('Error cargando token: $e');
    }
  }

  void _onPressed() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (!mounted) return;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor ingrese nombre de usuario y contraseña.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Verificación adicional de versión durante el login
    try {
      final isVersionValid = await VersionCheckService.verifyVersionForLogin(username, password);
      
      if (!isVersionValid) {
        setState(() {
          _isLoading = false;
        });
        final currentVersion = await VersionCheckService.getCurrentVersion();
        final requiredVersion = await VersionCheckService.getMinRequiredVersion();
        _showUpdateRequiredScreen(currentVersion, requiredVersion);
        return;
      }
    } catch (e) {
      print('Error verificando versión para login: $e');
      // Continuar con el login en caso de error
    }

    final response =
        await _loginUseCase.loginUserWithError(username, password, _userProvider!);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.ok) {
      // Login exitoso
      final userModel = UserModel.fromJson(response.content);
      _userProvider?.saveUser(userModel);
      
      // Cargar información del usuario después del login (opcional)
      // No bloqueamos el login si falla loadMe
      try {
        _userProvider?.loadMe(context);
      } catch (e) {
        print('Error cargando información del usuario: $e');
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InactivityLogoutWidget(
              child: HomePage(username: username, password: password)),
        ),
      );
    } else {
      // Manejar diferentes tipos de error
      if (response.errorType == LoginErrorType.versionOutdated) {
        // Mostrar pantalla de actualización
        final currentVersion = await VersionCheckService.getCurrentVersion();
        final requiredVersion = await VersionCheckService.getMinRequiredVersion();
        _showUpdateRequiredScreen(currentVersion, requiredVersion);
      } else {
        // Mostrar error genérico
        _showErrorDialog(response.message.isNotEmpty ? response.message : 'Error de inicio de sesión');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: const Text(
            'Error de inicio de sesión',
            style: TextStyle(color: Color(0xFFb60000)),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFb60000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(5.0),
        child: AppBar(backgroundColor: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 80),
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/icclaro.png',
                          height: 100,
                        ),
                        const SizedBox(height: 80),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 40),
                        LoginButton(onPressed: _onPressed),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/clarologo.png',
                      height: 16,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Todos los derechos reservados, Claro 2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Color(0xFFC21618),
                child: Center(child: LoadingAnimation()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

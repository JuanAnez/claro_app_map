// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/login_buttons.dart';
import 'package:icc_claro_app/core/widgets/inactivity_logout_widget.dart';
import 'package:icc_claro_app/core/widgets/loading_animation.dart';
import 'package:icc_claro_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/home/home_page.dart';
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

    final response =
        await _loginUseCase.loginUser(username, password, _userProvider!);

    if (!mounted) return;

    if (response.username.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      _userProvider?.saveUser(response);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InactivityLogoutWidget(
              child: HomePage(username: username, password: password)),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Nombre de usuario o contraseña incorrectos');
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

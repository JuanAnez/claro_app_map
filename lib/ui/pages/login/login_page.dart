// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:icc_maps/domain/use_cases/login_use_case.dart';
import 'package:icc_maps/ui/context/user_provider.dart';
import 'package:icc_maps/ui/pages/home/home_page.dart';
import 'package:icc_maps/ui/pages/login/widgets/login_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginUseCase _loginUseCase = LoginUseCase();
  UserProvider? _userProvider;

  bool _passwordVisible = false;

  void _onPressed() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor ingrese nombre de usuario y contraseña.');
      return;
    }

    final response = await _loginUseCase.loginUser(username, password);

    if (response.username.isNotEmpty) {
      _userProvider?.saveUser(response);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(username: username, password: password),
        ),
      );
    } else {
      _showErrorDialog('Nombre de usuario o contraseña incorrectos');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(26.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Error de inicio de sesión',
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Color(0xFFb60000),
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          message,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFb60000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 3.0),
                          ),
                          child: const Text('Cerrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        child: AppBar(
          backgroundColor: Colors.black,
        ),
      ),
      body: Column(
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:icc_claro_app/features/authentication/presentation/login/login_page.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:provider/provider.dart';

class InactivityLogoutWidget extends StatefulWidget {
  final Widget child;
  const InactivityLogoutWidget({Key? key, required this.child})
      : super(key: key);

  @override
  _InactivityLogoutWidgetState createState() => _InactivityLogoutWidgetState();
}

class _InactivityLogoutWidgetState extends State<InactivityLogoutWidget> {
  Timer? _inactivityTimer;
  Timer? _tokenCheckTimer;
  final Duration _inactivityLimit = const Duration(seconds: 1800);
  final Duration _tokenCheckInterval = const Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
    _startTokenCheckTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityLimit, _logout);
  }

  // void _resetInactivityTimer() {
  //   _inactivityTimer?.cancel();
  //   _startInactivityTimer();
  // }

  void _startTokenCheckTimer() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = Timer.periodic(_tokenCheckInterval, (timer) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isTokenExpired() && !userProvider.hasLoggedOut) {
        print("Token expirado, ejecutando logout...");
        _logout();
      }
    });
  }

  void _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loginUseCase = LoginUseCase();

    _inactivityTimer?.cancel();
    _tokenCheckTimer?.cancel();

    if (userProvider.hasLoggedOut) return;

    await loginUseCase.logoutUser(userProvider, context);
    userProvider.clearAccessToken();
    userProvider.clearMunicipalitiesCache();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      // onPanDown: (_) => _resetInactivityTimer(),
      // onTap: _resetInactivityTimer,
      // onTapDown: (_) => _resetInactivityTimer(),
      child: widget.child,
    );
  }
}

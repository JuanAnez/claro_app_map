// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/login/login_page.dart';
import 'package:provider/provider.dart';
import 'package:icc_maps/domain/use_cases/login_use_case.dart';
import 'package:icc_maps/ui/context/user_provider.dart';


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

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }

  void _startTokenCheckTimer() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = Timer.periodic(_tokenCheckInterval, (timer) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isTokenExpired()) {
        print("Token expirado, ejecutando logout...");
        _logout();
      }
    });
  }

  void _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loginUseCase = LoginUseCase();

    await loginUseCase.logoutUser(userProvider);
    userProvider.clearAccessToken();
    userProvider.clearMunicipalitiesCache();

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => _resetInactivityTimer(),
      onTap: _resetInactivityTimer,
      onTapDown: (_) => _resetInactivityTimer(),
      child: widget.child,
    );
  }
}

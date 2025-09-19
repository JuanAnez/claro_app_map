

import 'package:flutter/material.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/authentication/data/models/user_model.dart';
import 'package:icc_claro_app/features/authentication/data/services/login_services.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';

class LoginUseCase {
  final LoginService _loginService = LoginService();

  Future<MessageResponse> doLogin(
      String username, String password, UserProvider userProvider) async {
    return _loginService.doLogin(username, password, userProvider);
  }

  Future<UserModel> loginUser(
      String username, String password, UserProvider userProvider) async {
    final response =
    await _loginService.doLogin(username, password, userProvider);
    if (!response.ok) {
      return UserModel.emptyUser();
    }
    return UserModel.fromJson(response.content);
  }

  Future<MessageResponse> loginUserWithError(
      String username, String password, UserProvider userProvider) async {
    return await _loginService.doLogin(username, password, userProvider);
  }

  Future<MessageResponse> logoutUser(UserProvider userProvider, BuildContext context) async {
    return await _loginService.doLogout(userProvider, context);
  }
}

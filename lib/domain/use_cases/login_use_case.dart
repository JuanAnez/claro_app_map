import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/services/login_service.dart';
import 'package:icc_maps/domain/model/user_model.dart';
import 'package:icc_maps/ui/context/user_provider.dart';

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

  Future<MessageResponse> logoutUser(UserProvider userProvider) async {
    return await _loginService.doLogout(userProvider);
  }
}

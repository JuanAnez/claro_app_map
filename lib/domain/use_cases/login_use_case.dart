import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/services/login_service.dart';
import 'package:icc_maps/domain/model/user_model.dart';

class LoginUseCase {
  final LoginService _loginService = LoginService();

  Future<MessageResponse> doLogin(String username, String password) async {
    return _loginService.doLogin(username, password);
  }

  Future<UserModel> loginUser(String username, String password) async {
    final response = await _loginService.doLogin(username, password);
    if (!response.ok) {
      return UserModel.emptyUser();
    }
    return UserModel.fromJson(response.content);
  }

  Future<void> logoutUser() async {
    return Future<void>(() {});
  }
}

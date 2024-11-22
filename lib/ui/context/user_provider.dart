import 'package:flutter/cupertino.dart';
import 'package:icc_maps/domain/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  void saveUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  UserModel? getUser() {
    return _user;
  }
}

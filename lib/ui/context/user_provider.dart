import 'package:flutter/cupertino.dart';
import 'package:icc_maps/domain/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  String? _accessToken;
  final Duration _timeAdjustment = const Duration(hours: -1, minutes: -36);

  void saveUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  UserModel? getUser() {
    return _user;
  }

  void saveAccessToken(String token) {
    _accessToken = token;
    notifyListeners();
  }

  String? get accessToken => _accessToken;

  void clearAccessToken() {
    _accessToken = null;
    notifyListeners();
  }

  bool isTokenExpired() {
    if (_accessToken == null) return true;
    final expirationDate = getJwtExpirationDate(_accessToken!);
    if (expirationDate == null) return true;

    // Compara la fecha de expiración ajustada con la fecha actual
    return DateTime.now().isAfter(expirationDate);
  }

  Future<void> clearMunicipalitiesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedMunicipalities');
  }

  DateTime? getJwtExpirationDate(String token) {
    try {
      final decodedToken = Jwt.parseJwt(token);
      if (decodedToken.containsKey('exp')) {
        final expirationSeconds = decodedToken['exp'] as int;
        final expirationDate =
        DateTime.fromMillisecondsSinceEpoch(expirationSeconds * 1000);
        final adjustedExpirationDate = expirationDate.add(_timeAdjustment);
        return adjustedExpirationDate;
      } else {
        throw Exception('El token no contiene fecha de expiración');
      }
    } catch (e) {
      print('Error al obtener la fecha de expiración del token: $e');
      return null;
    }
  }
}

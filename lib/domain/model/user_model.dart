class UserModel {
  final String username;
  final String authorities;

  UserModel({required this.username, required this.authorities});

  static UserModel emptyUser() {
    return UserModel(username: '', authorities: '');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      authorities: json['authorities'] ?? '',
    );
  }
}

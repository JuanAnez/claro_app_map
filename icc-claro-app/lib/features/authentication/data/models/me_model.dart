class Me {
  final int userId;
  final String username;
  final String roles;
  final String? fullName;
  final String? email;
  final String? lastName;
  final String? lastLogin;

  Me({
    required this.userId, 
    required this.username, 
    required this.roles,
    this.fullName,
    this.email,
    this.lastName,
    this.lastLogin,
  });

  factory Me.fromJson(Map<String, dynamic> j) => Me(
    userId: _asInt(j['userId']), // Ahora usa 'userId' directamente
    username: j['username'] as String? ?? '',
    roles: j['roles'] as String? ?? '', // Ahora usa 'roles' directamente
    fullName: j['name'] as String?,
    email: j['email'] as String?,
    lastName: j['lastName'] as String?,
    lastLogin: j['lastLogin'] as String?,
  );

  // Helper para castear ints del JSON de forma segura
  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

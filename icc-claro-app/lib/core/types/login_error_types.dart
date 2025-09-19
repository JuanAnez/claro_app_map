/// Tipos de errores que pueden ocurrir durante el login
enum LoginErrorType {
  invalidCredentials,
  versionOutdated,
  networkError,
  serverError,
  unknown
}

/// Clase para manejar errores de login con contexto
class LoginError {
  final LoginErrorType type;
  final String message;
  final String? details;

  LoginError({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'LoginError(type: $type, message: $message, details: $details)';
  }
}

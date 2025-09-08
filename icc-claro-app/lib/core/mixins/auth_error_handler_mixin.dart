import 'package:flutter/material.dart';
import 'package:icc_claro_app/features/authentication/presentation/login/login_page.dart';

mixin AuthErrorHandlerMixin {
  /// Maneja errores de autenticación de manera consistente
  void handleAuthError(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('Token expirado') || 
        errorMessage.contains('No autorizado') ||
        errorMessage.contains('401') ||
        errorMessage.contains('403')) {
      
      // Mostrar snackbar informativo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sesión expirada. Redirigiendo al login...'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navegar al login después de un breve delay
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
    } else {
      // Para otros errores, mostrar mensaje genérico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  /// Maneja errores de red de manera consistente
  void handleNetworkError(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('Timeout') || 
        errorMessage.contains('Connection failed') ||
        errorMessage.contains('Network is unreachable')) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error de conexión. Verifica tu conexión a internet.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () {
              // Aquí podrías implementar lógica de reintento
            },
          ),
        ),
      );
    } else {
      // Para otros errores de red
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de red: ${errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  /// Maneja errores de permisos de manera consistente
  void handlePermissionError(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('403') || 
        errorMessage.contains('Acceso denegado') ||
        errorMessage.contains('No tienes permisos')) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No tienes permisos para acceder a esta funcionalidad.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  /// Maneja errores de manera inteligente basándose en el tipo
  void handleErrorIntelligently(BuildContext context, dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('Token expirado') || 
        errorMessage.contains('No autorizado') ||
        errorMessage.contains('401')) {
      handleAuthError(context, error);
    } else if (errorMessage.contains('403') || 
               errorMessage.contains('Acceso denegado')) {
      handlePermissionError(context, error);
    } else if (errorMessage.contains('Timeout') || 
               errorMessage.contains('Connection failed')) {
      handleNetworkError(context, error);
    } else {
      // Error genérico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  /// Muestra un diálogo de confirmación antes de redirigir al login
  Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesión Expirada'),
          content: const Text('Tu sesión ha expirado. ¿Deseas iniciar sesión nuevamente?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Iniciar Sesión'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
}

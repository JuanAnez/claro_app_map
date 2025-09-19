import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Pantalla que se muestra cuando la aplicación requiere una actualización obligatoria
class UpdateRequiredScreen extends StatelessWidget {
  final String currentVersion;
  final String requiredVersion;
  
  const UpdateRequiredScreen({
    super.key,
    required this.currentVersion,
    required this.requiredVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC21618),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de Claro
              Image.asset(
                'assets/images/icclaro.png',
                height: 120,
                width: 120,
              ),
              
              const SizedBox(height: 40),
              
              // Título
              const Text(
                'Actualización Requerida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Mensaje principal
              const Text(
                'Tu versión de la aplicación está desactualizada y ya no es compatible.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // Información de versiones
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Versión actual:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currentVersion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Versión requerida:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          requiredVersion,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botón para ir a la página de Claro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _launchStore(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFC21618),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Actualizar Ahora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mensaje adicional
              const Text(
                'Por favor, actualiza la aplicación para continuar usando todos los servicios de Claro.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/clarologo.png',
                      height: 16,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Todos los derechos reservados, Claro 2024',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Abre la página de Claro para descargar la actualización
  Future<void> _launchStore() async {
    try {
      // URL de Claro para todas las plataformas
      const String url = 'https://www.claro.com/';
      
      final Uri uri = Uri.parse(url);
      
      // Intentar diferentes modos de lanzamiento
      bool launched = false;
      
      // Primero intentar con externalApplication
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        } catch (e) {
          print('Error con externalApplication: $e');
        }
      }
      
      // Si falla, intentar con platformDefault
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          launched = true;
        } catch (e) {
          print('Error con platformDefault: $e');
        }
      }
      
      // Si falla, intentar con inAppWebView
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          launched = true;
        } catch (e) {
          print('Error con inAppWebView: $e');
        }
      }
      
      if (!launched) {
        print('No se pudo abrir la página de Claro con ningún método');
      }
    } catch (e) {
      print('Error abriendo la página de Claro: $e');
    }
  }
}

import 'package:flutter/material.dart';

class AppInfo {
  static const String appName = 'Claro Puerto Rico - Gestión de Coberturas';
  static const String companyName = 'Claro Puerto Rico';
  static const String description = '''
    Esta aplicación es una herramienta de gestión para Claro Puerto Rico, enfocada en:
    - Gestión de coberturas de la empresa.
    - Visualización de ubicaciones de puntos de ventas en el mapa de Puerto Rico.
    - Activación y desactivación de puntos de ventas.
    - Monitoreo de compañías competidoras de Claro en Puerto Rico.
    La aplicación utiliza un mapa interactivo para mostrar todas estas características de manera intuitiva.
  ''';

  static const String version = '1.0.0';
  static const String contactEmail = 'soporte@claropr.com';

  static const List<Feature> features = [
    Feature(
      title: 'Coberturas',
      description:
          'Ver y gestionar las áreas de cobertura de Claro Puerto Rico en un mapa interactivo.',
    ),
    Feature(
      title: 'Puntos de Ventas',
      description:
          'Activar, ver, y desactivar puntos de ventas distribuidos por todo Puerto Rico.',
    ),
    Feature(
      title: 'Competencia',
      description:
          'Monitorear la información de compañías competidoras que ofrecen servicios similares en Puerto Rico.',
    ),
    Feature(
      title: 'Mapa interactivo',
      description:
          'Ver las ubicaciones de coberturas, puntos de ventas, y empresas competidoras en el mapa de Puerto Rico.',
    ),
  ];

  static void showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información de la Aplicación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(appName),
                const SizedBox(height: 10),
                const Text(description),
                const SizedBox(height: 10),
                const Text('Características:'),
                for (var feature in features)
                  Text('- ${feature.title}: ${feature.description}'),
                const SizedBox(height: 10),
                const Text('Versión: $version'),
                const Text('Contacto: $contactEmail'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Feature {
  final String title;
  final String description;

  const Feature({
    required this.title,
    required this.description,
  });
}

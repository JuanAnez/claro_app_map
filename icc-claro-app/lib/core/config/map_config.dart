/// Configuración para el mapa y elementos visuales
class MapConfig {
  // Configuración de antenas
  static const double antennaIconSize = 64.0; // Tamaño del icono de antena en píxeles
  static const double antennaIconSizeLarge = 80.0; // Tamaño grande para antenas importantes
  static const double antennaIconSizeSmall = 48.0; // Tamaño pequeño para antenas secundarias
  
  // Configuración de marcadores
  static const double markerIconSize = 48.0; // Tamaño por defecto para otros marcadores
  static const double markerIconSizeLarge = 64.0; // Tamaño grande para marcadores importantes
  
  // Configuración de polígonos
  static const double polygonStrokeWidth = 2.0; // Grosor del borde de polígonos
  static const double polygonFillOpacity = 0.3; // Opacidad del relleno de polígonos
  
  // Configuración de polilíneas
  static const double polylineWidth = 3.0; // Grosor de las líneas de cobertura
  
  // Configuración de zoom
  static const double defaultZoom = 9.5; // Zoom por defecto del mapa
  static const double minZoom = 8.0; // Zoom mínimo permitido
  static const double maxZoom = 18.0; // Zoom máximo permitido
  
  // Configuración de animaciones
  static const Duration markerAnimationDuration = Duration(milliseconds: 300);
  static const Duration mapAnimationDuration = Duration(milliseconds: 500);
}

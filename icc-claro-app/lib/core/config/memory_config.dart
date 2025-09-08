/// Configuración para optimización de memoria en la aplicación
class MemoryConfig {
  // Configuración de polígonos
  static const int maxInitialPolygons = 0; // 0 = sin límite, cargar todos
  static const int maxPolygonsPerBatch = 0; // 0 = sin lotes, cargar todo de una vez
  static const int maxPolygonsInMemory = 0; // 0 = sin límite de memoria
  static const int cleanupThreshold = 0; // 0 = sin limpieza automática
  
  // Configuración de geometrías
  static const double coordinatePrecision = 0.0001; // Precisión de coordenadas
  static const int maxPointsPerPolygon = 100; // Máximo puntos por polígono
  
  // Configuración de caché
  static const int maxCacheSize = 50; // Máximo elementos en caché
  static const Duration cacheExpiration = Duration(hours: 24); // Expiración de caché
  
  // Configuración de UI
  static const Duration loadingDelay = Duration(milliseconds: 300); // Delay de carga
  static const Duration cleanupDelay = Duration(seconds: 5); // Delay de limpieza
  
  // Configuración de procesamiento
  static const bool enableBackgroundProcessing = true; // Procesamiento en background
  static const bool enableProgressiveLoading = false; // Carga progresiva deshabilitada
  static const bool enableMemoryCleanup = true; // Limpieza automática de memoria
  static const bool enableAutoCleanupPrevious = true; // Limpiar tipo anterior automáticamente
}

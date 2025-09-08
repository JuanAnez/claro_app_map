/// Configuración centralizada de endpoints de la API
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://192.168.1.5:7001/icc/api';
  
  // Autenticación
  static const String login = '/login-ws';
  static const String logout = '/logout-ws';
  static const String getUserAuthorities = '/getUserAuthorities';
  
  // Polígonos y Cobertura
  static const String getPolygonTypes = '/getPolygonTypes';
  static const String getBaseCoords = '/getBaseCoords';
  
  // POS Locations
  static const String getPosLocationsInfo = '/getPosLocationsInfo';
  static const String getPosLocationsReferences = '/getPosLocationsReferences';
  static const String getPosLocationsReferencesByTown = '/getPosLocationsReferencesByTown';
  
  // Municipios y Poblaciones
  static const String getMunicipalities = '/getMunicipalities';
  static const String getTowns = '/getTowns';
  static const String getTownDemographic = '/getTownDemographic';
  
  // Market Share y Análisis
  static const String getMarketShareForTown = '/getMarketShareForTown';
  static const String getMarketShareValue = '/getMarketShareValue';
  
  // Grupos y Centros Comerciales
  static const String findPosGroupsWithLocRef = '/findPosGroupsWithLocRef';
  static const String getGroupPhotosByGroupId = '/getGroupPhotosByGroupId';
  
  // Configuraciones y LOV
  static const String getPosLovByType = '/getPosLovByType';
  static const String getPosLocDropdownInputs = '/getPosLocDropdownInputs';
  
  // Dealers y Distribuidores
  static const String getAllMatchPosDealers = '/getAllMatchPosDealers';
  static const String getAllMatchPosFixedDealers = '/getAllMatchPosFixedDealers';
  
  // Predicciones
  static const String getPosTypePredictions = '/getPosTypePredictions';
  
  // Archivos y Documentos
  static const String getPosFilesByLocId = '/getPosFilesByLocId';
  static const String getPosFileBlobById = '/getPosFileBlobById';
  
  // Contactos
  static const String getAllPosContactsByLocation = '/getAllPosContactsByLocation';
  
  // Rutas y Recorridos
  static const String getRouteCloseDates = '/getRouteCloseDates';
  static const String getNextRouteCloseDate = '/getNextRouteCloseDate';
  static const String getRouteUserManagerStatus = '/getRouteUserManagerStatus';
  static const String findRouteComments = '/findRouteComments';
  static const String findRouteDocuments = '/findRouteDocuments';
  static const String insertRouteComment = '/insertRouteComment';
  static const String updateRouteComment = '/updateRouteComment';
  static const String deleteRouteComment = '/deleteRouteComment';
  static const String insertPosRouteDocuments = '/insertPosRouteDocuments';
  static const String deleteRouteDocuments = '/deleteRouteDocuments';
  static const String getRouteById = '/getRouteById';
  static const String userRoutes = '/user-routes';
  static const String finishRouteBatch = '/finishRouteBatch';
  static const String insertPosRoute = '/insertPosRoute';
  static const String approveByAssistant = '/approveByAssistant';
  static const String approveByManager = '/approveByManager';
  static const String returnRouteToPosUser = '/returnRouteToPosUser';
  static const String cancelRoute = '/cancelRoute';
  static const String closeRoute = '/closeRoute';
  static const String validateRoute = '/validateRoute';
  static const String updateRouteV2 = '/updateRouteV2';
  
  // Gestión de Ubicaciones POS
  static const String uploadPosLocationToDb = '/uploadPosLocationToDb';
  static const String disablePosLocation = '/disablePosLocation';
  static const String requestCloseRoute = '/requestCloseRoute';
  static const String updateRoute = '/updateRoute';
  
  // Gestión de Grupos POS
  static const String uploadPosGroupToDb = '/uploadPosGroupToDb';
  static const String uploadBlueprintToDb = '/uploadBlueprintToDb';
  static const String disablePosGroup = '/disablePosGroup';
  
  // Historial y Agentes
  static const String getPosLocAgentHistByLocId = '/getPosLocAgentHistByLocId';
  
  // Autenticación
  static const String loginWs = '/login-ws';
  
  // URLs externas (GeoJSON)
  static const String municipalitiesGeoJson = 'https://webtest.prt.local/geojson/municipalities.geojson?d=2';
  
  // URLs base para descarga de archivos
  static const String webtestBaseUrl = 'https://webtest.prt.local';
  
  /// Construye una URL completa con el endpoint
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Construye una URL completa con query parameters
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    if (params.isEmpty) return buildUrl(endpoint);
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl$endpoint?$queryString';
  }
  
  /// Construye una URL completa para webtest (archivos y recursos externos)
  static String buildWebtestUrl(String path) {
    return '$webtestBaseUrl$path';
  }
  
  /// Lista de endpoints que requieren caché
  static const Set<String> cachedEndpoints = {
    getPolygonTypes,
    getBaseCoords,
    getPosLocationsInfo,
    getPosLocationsReferences,
    getMunicipalities,
    getTowns,
    getMarketShareForTown,
    getMarketShareValue,
    findPosGroupsWithLocRef,
    getPosLovByType,
    getPosLocDropdownInputs,
    getGroupPhotosByGroupId,
    getPosFilesByLocId,
    getPosFileBlobById,
    getAllPosContactsByLocation,
    getRouteCloseDates,
    getNextRouteCloseDate,
    getRouteUserManagerStatus,
    findRouteComments,
    findRouteDocuments,
    getRouteById,
    userRoutes,
  };
  
  /// Lista de endpoints que NO requieren caché (búsquedas dinámicas)
  static const Set<String> nonCachedEndpoints = {
    getAllMatchPosDealers,
    getAllMatchPosFixedDealers,
    getPosLocationsReferencesByTown,
    getTownDemographic,
    insertRouteComment,
  };
  
  /// Verifica si un endpoint debe usar caché
  static bool shouldUseCache(String endpoint) {
    return cachedEndpoints.contains(endpoint);
  }
  
  /// Verifica si un endpoint es de búsqueda dinámica
  static bool isSearchEndpoint(String endpoint) {
    return nonCachedEndpoints.contains(endpoint);
  }
  
  /// Obtiene la duración de caché recomendada para un endpoint
  static Duration getCacheDuration(String endpoint) {
    if (isSearchEndpoint(endpoint)) {
      return const Duration(minutes: 1); // Caché corto para búsquedas
    } else if (endpoint == getPolygonTypes || endpoint == getBaseCoords) {
      return const Duration(minutes: 10); // Caché largo para datos estáticos
    } else {
      return const Duration(minutes: 5); // Caché estándar
    }
  }
}

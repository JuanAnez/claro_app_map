import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';

class VersionCheckService {
  static Future<bool> isVersionCompatible() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final minVersion = await _getMinVersionFromServer();
      
      if (minVersion != null) {
        return _compareVersions(currentVersion, minVersion) >= 0;
      }
      
      return _compareVersions(currentVersion, '0.0.3') >= 0;
      
    } catch (e) {
      print('Error verificando versión: $e');
      return true;
    }
  }
  
  static Future<String?> _getMinVersionFromServer() async {
    try {
      final url = Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.minVersion));
      final client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      
      final request = await client.getUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
        
        if (jsonMap['status'] == 200 && jsonMap['code'] == 'OK') {
          return jsonMap['message'] as String?;
        }
      }
      
      print('Error obteniendo versión mínima del servidor: ${response.statusCode}');
      return null;
      
    } catch (e) {
      print('Excepción obteniendo versión mínima: $e');
      return null;
    }
  }
  
  static Future<bool> verifyVersionForLogin(String username, String password) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final url = Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.versionCheck));
      final client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      
      final request = await client.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({
        'username': username,
        'password': password,
        'appVersion': currentVersion
      }));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
        
        if (jsonMap['status'] == 200 && jsonMap['code'] == 'OK') {
          return true; 
        } else if (jsonMap['status'] == 426 && jsonMap['code'] == 'VERSION_OUTDATED') {
          return false; 
        }
      }
      
      return true;
      
    } catch (e) {
      print('Error verificando versión para login: $e');
      return true;
    }
  }
  
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    while (v1Parts.length < maxLength) v1Parts.add(0);
    while (v2Parts.length < maxLength) v2Parts.add(0);
    
    for (int i = 0; i < maxLength; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    
    return 0;
  }
  
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getMinRequiredVersion() async {
    final minVersion = await _getMinVersionFromServer();
    return minVersion ?? '0.0.3'; 
  }

  static Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }
}

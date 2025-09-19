// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
// import 'package:icc_claro_app/core/utils/helpers/user_role_resolver.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../models/route_model.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

class RouteService {
  final client = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  Future<List<RouteModel>> fetchRoutes({
    required BuildContext context,
    required String routeType,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.getUser()?.username ?? 'Invitado';

      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.userRoutes,
        queryParameters: {'username': username},
        context: context,
        useCache: false,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        List<dynamic> dataList = [];
        switch (routeType) {
          case 'workedRoutes':
            dataList = jsonData['workedRoutes'] ?? [];
            break;
          case 'openRoutes':
            dataList = jsonData['openRoutes'] ?? [];
            break;
          case 'incomingRoutes':
            dataList = jsonData['incomingRoutes'] ?? [];
            break;
          default:
            throw Exception("Tipo de ruta no válido: $routeType");
        }

        dataList = dataList.where((item) {
          final locType = item['locType'];
          if (locType == null) return true;
          return !locType.toString().toUpperCase().contains('GCPVNT');
        }).toList();

        return dataList.map((item) => RouteModel.fromJson(item)).toList();
      } else {
        throw Exception(
            "Error al cargar datos. Código: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al cargar rutas: $e");
    }
  }

  Future<String> submitBatch({
    required List<int> routeIds,
    required String userName,
    required List<String> roles,
    required RouteModel anyRoute,
    required String currentUsername,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.getUser()?.username ?? 'Invitado';

      print(username);

      final isPosUser = roles.contains('POS_USER');
      final isLocAdmin = roles.contains('POS_LOC_ADMIN');
      final isLocAssistant = roles.contains('POS_LOC_ASSISTANT');
      final isAdmin = roles.contains('POS_ADMIN');

      String endpoint;
      if (isPosUser) {
        endpoint = ApiEndpoints.finishRouteBatch; 
      } else if (isLocAssistant) {
        endpoint =
            ApiEndpoints.approveByAssistant;
      } else if (isLocAdmin) {
        endpoint =
            ApiEndpoints.approveByManager; 
      } else if (isAdmin) {
        endpoint = ApiEndpoints.validateRoute;
      } else {
        throw Exception("Rol no autorizado para esta acción.");
      }

      final response = await HttpAuthService.authenticatedPost(
        endpoint,
        body: {
          "routeIds": routeIds.join(','),
          "userName": userName,
        },
        context: context,
      );

      if (response.statusCode == 200) {
        return "Éxito: Recorridos procesados correctamente.";
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<RouteModel> fetchRouteById(int routeId,
      {BuildContext? context}) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getRouteById,
        queryParameters: {'routeId': routeId.toString()},
        context: context,
        useCache: false,
      );

      if (response.statusCode == 200) {
        // print('🔍 Respuesta de getRouteById: ${response.body}');

        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);

          if (jsonData['posLocationID'] == null) {
            print('⚠️ posLocationID es null en la respuesta');
            throw Exception(
                'posLocationID no encontrado en la respuesta del servidor');
          }

          return RouteModel.fromJson(jsonData);
        } catch (parseError) {
          print('❌ Error al parsear JSON: $parseError');
          print('📄 Contenido de la respuesta: ${response.body}');
          throw Exception(
              'Error al procesar la respuesta del servidor: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'Token de autenticación expirado o inválido. Por favor, inicie sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para acceder a esta ruta');
      } else if (response.statusCode == 404) {
        throw Exception('Ruta no encontrada');
      } else {
        throw Exception(
            "Error al cargar datos. Código: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al cargar ruta por ID: $e");
    }
  }

  Future<List<dynamic>> fetchComments({
    required BuildContext context,
    required int routeId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.getUser()?.username ?? 'Invitado';

      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.findRouteComments,
        queryParameters: {
          'routeId': routeId.toString(),
          'userName': username,
        },
        context: context,
        useCache: false,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error al cargar comentarios: $e');
    }
  }

  Future<void> insertRouteComment({
    required BuildContext context,
    required String comment,
    required int location,
    required int routeId,
    required String userName,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.insertRouteComment,
        body: {
          "routeComment": comment,
          "posLocId": location,
          "posLocRouteId": routeId,
        },
        context: context,
      );

      print('POST -> ${ApiEndpoints.insertRouteComment}');

      if (response.statusCode != 200) {
        throw Exception('Error al insertar comentario: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de red al insertar comentario: $e');
    }
  }

  Future<void> updateRouteComment({
    required BuildContext context,
    required int commentId,
    required String newComment,
    required String userName,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPut(
        ApiEndpoints.updateRouteComment,
        body: {
          "posLocRouteCommentId": commentId,
          "routeComment": newComment,
          "updatedBy": userName,
        },
        context: context,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar comentario: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de red al actualizar comentario: $e');
    }
  }

  Future<void> deleteComment({
    required BuildContext context,
    required int commentId,
  }) async {
    try {
      final userName = Provider.of<UserProvider>(context, listen: false)
              .getUser()
              ?.username ??
          'Invitado';

      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.deleteRouteComment,
        body: {
          'commentId': commentId,
          'userName': userName,
        },
        context: context,
      );

      if (response.statusCode == 200) {
        final success = jsonDecode(response.body);
        if (success != true) {
          throw Exception("Respuesta falsa del servidor");
        }
      } else {
        throw Exception("Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print('Error al eliminar comentario: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar comentario')),
        );
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchDocuments({
    required int routeId,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.findRouteDocuments,
        queryParameters: {
          'routeId': routeId.toString(),
        },
        context: context,
        useCache: false, // No usar caché para obtener datos actualizados
      );

      if (response.statusCode == 200) {
        // print('🗂️ Documentos obtenidos: ${response.body}');
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      throw Exception('Error al cargar documentos: $e');
    }
  }

  Future<void> deleteDocuments({
    required int routeId,
    required List<int> documentIds,
    required String username,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.deleteRouteDocuments,
        body: {
          "routeId": routeId,
          "documentIds": documentIds,
          "username": username,
        },
        context: context,
      );

      if (response.statusCode != 200) {
        throw Exception('Error eliminando documentos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar documentos: $e');
    }
  }

  Future<String> uploadRouteDocumentsMultipart({
    required int routeId,
    required int locationId,
    required List<PlatformFile> files,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final accessToken = userProvider.accessToken;

      final uri = Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.insertPosRouteDocuments));
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final request = await client.postUrl(uri);

      // Agregar token de autenticación
      if (accessToken != null) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }

      final boundary =
          '----dartFormBoundary${DateTime.now().millisecondsSinceEpoch}';

      request.headers.set(HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary');
      final multipartBody = BytesBuilder();

      // Helper para agregar campos
      void writeField(String name, String value) {
        multipartBody.add(utf8.encode('--$boundary\r\n'));
        multipartBody.add(utf8
            .encode('Content-Disposition: form-data; name="$name"\r\n\r\n'));
        multipartBody.add(utf8.encode('$value\r\n'));
      }

      for (var file in files) {
        final fileBytes = await File(file.path!).readAsBytes();
        final mimeType =
            lookupMimeType(file.path!) ?? 'application/octet-stream';

        multipartBody.add(utf8.encode('--$boundary\r\n'));
        multipartBody.add(utf8.encode(
            'Content-Disposition: form-data; name="files"; filename="${file.name}"\r\n'));
        multipartBody.add(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
        multipartBody.add(fileBytes);
        multipartBody.add(utf8.encode('\r\n'));
      }

      // Campos
      for (var file in files) {
        writeField("fileNames", file.name);
        writeField("fileDescriptions", "Subido desde app movil");
        writeField("fileLocations", locationId.toString());
        writeField("fileRouteIds", routeId.toString());
        final type = file.extension == 'pdf'
            ? 'application/pdf'
            : 'image/${file.extension}';
        writeField("fileDocumentTypes", type);
        // No enviar userName - se obtiene del token
      }

      multipartBody.add(utf8.encode('--$boundary--\r\n'));

      request.add(multipartBody.toBytes());

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return "Documentos subidos correctamente.";
      } else {
        throw Exception(
            "Error del servidor (${response.statusCode}): $responseBody");
      }
    } catch (e) {
      throw Exception("Error al subir documentos: $e");
    }
  }

  Future<String> uploadFromCamera({
    required int routeId,
    required int locationId,
    required XFile imageFile,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final accessToken = userProvider.accessToken;

      final uri = Uri.parse(ApiEndpoints.buildUrl(ApiEndpoints.insertPosRouteDocuments));
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final request = await client.postUrl(uri);

      // Agregar token de autenticación
      if (accessToken != null) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }

      final boundary =
          '----dartFormBoundary${DateTime.now().millisecondsSinceEpoch}';

      request.headers.set(HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary');
      final multipartBody = BytesBuilder();

      final fileBytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      // 📎 Agregar archivo
      multipartBody.add(utf8.encode('--$boundary\r\n'));
      multipartBody.add(utf8.encode(
          'Content-Disposition: form-data; name="files"; filename="${imageFile.name}"\r\n'));
      multipartBody.add(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
      multipartBody.add(fileBytes);
      multipartBody.add(utf8.encode('\r\n'));

      // 📄 Campos adicionales
      void writeField(String name, String value) {
        multipartBody.add(utf8.encode('--$boundary\r\n'));
        multipartBody.add(utf8
            .encode('Content-Disposition: form-data; name="$name"\r\n\r\n'));
        multipartBody.add(utf8.encode('$value\r\n'));
      }

      writeField("fileNames", imageFile.name);
      writeField("fileDescriptions", "Foto desde camara");
      writeField("fileLocations", locationId.toString());
      writeField("fileRouteIds", routeId.toString());
      writeField("fileDocumentTypes", mimeType);
      // No enviar userName - se obtiene del token

      multipartBody.add(utf8.encode('--$boundary--\r\n'));

      request.add(multipartBody.toBytes());

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return "Documento subido correctamente.";
      } else {
        throw Exception(
            "Error del servidor (${response.statusCode}): $responseBody");
      }
    } catch (e) {
      throw Exception("Error al subir documento: $e");
    }
  }

  Future<String> returnRoutesToPosUser({
    required List<int> routeIds,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.returnRouteToPosUser,
        body: {
          "routeIds": routeIds.join(','),
        },
        context: context,
      );

      if (response.statusCode == 200) {
        return "Éxito: Recorridos devueltos correctamente.";
      } else {
        throw Exception("Error devolviendo recorridos: ${response.body}");
      }
    } catch (e) {
      throw Exception("Excepción al devolver recorridos: $e");
    }
  }

  Future<String> cancelRoute({
    required int routeId,
    required String userName,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.cancelRoute,
        body: {
          "routeId": routeId.toString(),
          "userName": userName,
        },
        context: context,
      );

      if (response.statusCode == 200) {
        return "Recorrido cancelado exitosamente.";
      } else {
        throw Exception("Respuesta inválida del servidor: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<String> closeRoute({
    required int routeId,
    required String userName,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpAuthService.authenticatedPost(
        ApiEndpoints.closeRoute,
        body: {
          "routeId": routeId.toString(),
          "userName": userName,
        },
        context: context,
      );

      if (response.statusCode == 200) {
        return "Punto de Venta cerrado exitosamente.";
      } else {
        throw Exception("Respuesta inválida del servidor: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<String> submitSingleRoute({
    required RouteModel route,
    required String username,
    required List<String> roles,
    required BuildContext context,
  }) async {
    return submitBatch(
      routeIds: [route.posLocationRouteID],
      userName: username,
      roles: roles,
      anyRoute: route,
      currentUsername: username,
      context: context,
    );
  }

  Future<String> returnSingleRoute({
    required RouteModel route,
    required String username,
    required List<String> roles,
    required BuildContext context,
  }) async {
    return returnRoutesToPosUser(
      routeIds: [route.posLocationRouteID],
      context: context,
    );
  }

  Future<RouteModel?> fetchRouteByPosLocationId({
    required BuildContext context,
    required int posLocationId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.getUser()?.username ?? 'Invitado';

      print("🔍 fetchRouteByPosLocationId - username: $username");
      print("🔍 fetchRouteByPosLocationId - posLocationId: $posLocationId");

      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.userRoutes,
        queryParameters: {'username': username},
        context: context,
        useCache: false, // No usar caché para obtener datos actualizados
      );

      print(
          "🔍 fetchRouteByPosLocationId - Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("🔍 fetchRouteByPosLocationId - Response Body: ${response.body}");

        Map<String, dynamic> jsonData = json.decode(response.body);

        final List<dynamic> openRoutes =
            (jsonData['openRoutes'] ?? []).where((item) {
          final locType = item['locType'];
          if (locType == null) return true;
          return !locType.toString().toUpperCase().contains('GCPVNT');
        }).toList();

        print(
            "🔍 fetchRouteByPosLocationId - openRoutes encontradas: ${openRoutes.length}");

        final match = openRoutes.firstWhere(
          (item) => item['posLocationID'] == posLocationId,
          orElse: () => null,
        );

        print("🔍 fetchRouteByPosLocationId - match encontrado: $match");

        if (match == null) {
          print(
              "🔍 fetchRouteByPosLocationId - No se encontró match para posLocationId: $posLocationId");
          return null;
        }

        return RouteModel.fromJson(match);
      } else {
        throw Exception(
            "Error al cargar rutas. Código: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al buscar ruta por posLocationId: $e");
    }
  }
}

class MediaTypeParser {
  static MediaType fromExtension(String ext) {
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}

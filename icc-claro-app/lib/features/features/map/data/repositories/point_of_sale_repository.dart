import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class PointOfSaleRepository {
  // URL centralizada en ApiEndpoints

  Future<List<Map<String, dynamic>>> fetchLocations({BuildContext? context}) async {
    try {
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getPosLocationsInfo,
        context: context,
        useCache: true,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> locations = [];

        if (jsonData is List) {
          locations = jsonData;
        } else if (jsonData['locations'] is List) {
          locations = jsonData['locations'];
        }

        return locations
            .where((loc) => loc['closeDate'] == null)
            .cast<Map<String, dynamic>>()
            .toList();
      } else {
        throw Exception("Código inválido: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error cargando ubicaciones: $e");
      return [];
    }
  }
}

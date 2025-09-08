import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:icc_claro_app/data/models/payload/message_response.dart';


abstract class ApiRepository {
  Future<MessageResponse> findAntennas(int polygonTypeId, {BuildContext? context});
  Future<MessageResponse> findCoverages(int id, {BuildContext? context});
  Future<MessageResponse> findGeoJson(
      {required Uri url, required Color color, HttpClient? client});
}

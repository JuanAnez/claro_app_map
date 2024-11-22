import 'dart:io';
import 'dart:ui';

import 'package:icc_maps/data/network/payload/MessageResponse.dart';

abstract class ApiRepository {
  Future<MessageResponse> findAntennas(int polygonTypeId);
  Future<MessageResponse> findCoverages(int id);
  Future<MessageResponse> findGeoJson(
      {required Uri url, required Color color, HttpClient? client});
}

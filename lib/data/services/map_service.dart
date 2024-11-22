// ignore_for_file: unused_local_variable

import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/databases/db_repository.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_antennas_table.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_coverages_table.dart';
import 'package:icc_maps/data/databases/sqlite/sqlite_repository.dart';
import 'package:icc_maps/data/network/api_repository.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/webtest/webtest_repository.dart';

class MapService {
  final ApiRepository _apiRepository = WebtestClient();
  final DbRepository _dbRepository = SqliteRepository();

  Future<List<Marker>> findAntennas(int polygonTypeId) async {
    // Get from Database
    // print("***** Getting ANTENNAS from Database *****");
    final List<Marker> dbResponse =
        await _dbRepository.getAntennas(polygonTypeId);
    // print("DbResponse is Empty? -> ${dbResponse.isEmpty}");
    if (dbResponse.isNotEmpty) return dbResponse;

    // return <Marker>[];

    // Get from API
    // print("***** Getting ANTENNAS  COVERfrom API *****");
    final MessageResponse apiResponse =
        await _apiRepository.findAntennas(polygonTypeId);
    if (!apiResponse.ok) return <Marker>[];

    // Save Antennas from API into Database
    final jsonData = apiResponse.additionalContent as List<dynamic>;
    final antennas =
        jsonData.map((data) => IccAntennasTable.fromMapToEntity(data)).toList();

    // print("Saving into Database...");
    final insert = await _dbRepository.insertAntennas(antennas);

    return apiResponse.content as List<Marker>;
  }

  Future<List<Polygon>> findCoverages(int polygonTypeId) async {
    // Get from Database
    // print("***** Getting COVERAGE from Database *****");
    final Map<String, dynamic> dbResponse =
        await _dbRepository.getCoverage(polygonTypeId);

    // print("DbResponse is Empty? -> ${dbResponse.isEmpty}");
    if (dbResponse.isNotEmpty) {
      // Fetch Polygon_URL
      final polygonsResponse = await _apiRepository.findGeoJson(
          url: dbResponse["url"], color: dbResponse["color"]);
      if (polygonsResponse.ok) return polygonsResponse.content;
      // print("Polygon error: ${polygonsResponse.message}");
    }

    // return <Polygon>[];

    // Get from API
    // print("***** Getting COVERAGE from API *****");
    final MessageResponse apiResponse =
        await _apiRepository.findCoverages(polygonTypeId);
    if (!apiResponse.ok) return <Polygon>[];

    // Save Coverages from API into Database
    final polygonType = apiResponse.additionalContent;
    final coverage = IccCoveragesTable.fromMapToEntity(polygonType);

    // print("Saving into Database...");
    final insert = await _dbRepository.insertCoverage(coverage);

    return apiResponse.content as List<Polygon>;
  }
}

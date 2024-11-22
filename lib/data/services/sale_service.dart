// ignore_for_file: unused_local_variable

import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/databases/db_repository.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_sales_table.dart';
import 'package:icc_maps/data/databases/sqlite/sqlite_repository.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/sale_repository.dart';
import 'package:icc_maps/data/network/webtest/mocktest_repository.dart';

class SaleService {
  final SaleRepository _apiRepository = MocktestClient();
  final DbRepository _dbRepository = SqliteRepository();

  Future<List<Marker>> findSales(int posLocationId) async {
    // Get from Database
    // print("***** Getting ANTENNAS from Database *****");
    // final List<Marker> dbResponse = await _dbRepository.getSales(posLocationId);
    // print("DbResponse is Empty? -> ${dbResponse.isEmpty}");
    // if (dbResponse.isNotEmpty) return dbResponse;

    // return <Marker>[];

    // Get from API
    // print("***** Getting ANTENNAS  COVERfrom API *****");
    final MessageResponse apiResponse =
        await _apiRepository.findSales(posLocationId);
    if (!apiResponse.ok) return <Marker>[];

    // Save Antennas from API into Database
    final jsonData = apiResponse.additionalContent as List<dynamic>;
    final sales =
        jsonData.map((data) => IccSalesTable.fromMapToEntity(data)).toList();

    // print("Saving into Database...");
    final insert = await _dbRepository.insertSales(sales);

    return apiResponse.content as List<Marker>;
  }
}

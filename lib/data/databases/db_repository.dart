import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/entities/antenna_entity.dart';
import 'package:icc_maps/data/entities/coverage_entity.dart';
import 'package:icc_maps/data/entities/sale_entity.dart';

abstract class DbRepository {
  // PolygonTypeId It's NOT the icBaseCoordsId of each antenna.
  Future<List<Marker>> getAntennas(int polygonTypeId);

  Future<bool> insertAntennas(List<AntennaEntity> antennas);
  Future<bool> updateAntennas(List<AntennaEntity> antennas);
  Future<bool> deleteAntennas(List<int> icBaseCoordsIds);

  // PolygonTypeId IT'S the ID of each coverage (LTE, 10M, 3G...)
  Future<Map<String, dynamic>> getCoverage(int polygonTypeId);
  Future<bool> insertCoverage(CoverageEntity coverage);
  Future<bool> updateCoverage(CoverageEntity coverage);
  Future<bool> deleteCoverage(int polygonTypeId);

  // PosLocationId It's NOT the posLocationId of each location.
  Future<List<Marker>> getSales(int posLocationId);

  Future<bool> insertSales(List<SaleEntity> location);
  Future<bool> updateSales(List<SaleEntity> location);
  Future<bool> deleteSales(List<int> posLocationId);
}

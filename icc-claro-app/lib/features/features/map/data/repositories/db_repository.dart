import 'package:icc_claro_app/core/utils/classes/antenna_entity.dart';
import 'package:icc_claro_app/core/utils/classes/coverage_entity.dart';

abstract class DbRepository {
  Future<List<AntennaEntity>> getAntennas(int polygonTypeId);

  Future<bool> insertAntennas(List<AntennaEntity> antennas);
  Future<bool> updateAntennas(List<AntennaEntity> antennas);
  Future<bool> deleteAntennas(List<int> icBaseCoordsIds);

  Future<Map<String, dynamic>> getCoverage(int polygonTypeId);

  Future<bool> insertCoverage(CoverageEntity coverage);
  Future<bool> updateCoverage(CoverageEntity coverage);
  Future<bool> deleteCoverage(int polygonTypeId);

}

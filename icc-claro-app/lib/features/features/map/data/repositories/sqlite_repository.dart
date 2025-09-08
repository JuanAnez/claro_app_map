// ignore_for_file: override_on_non_overriding_member, avoid_print, implementation_imports

import 'package:icc_claro_app/core/utils/classes/antenna_entity.dart';
import 'package:icc_claro_app/core/utils/classes/coverage_entity.dart';
import 'package:icc_claro_app/core/utils/classes/hex_color.dart';
import 'package:icc_claro_app/features/features/map/data/dao/antennas_dao.dart';
import 'package:icc_claro_app/features/features/map/data/dao/coverages_dao.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/db_repository.dart';

class SqliteRepository extends DbRepository {
  AntennasDAO antennasDAO = AntennasDAO();
  CoveragesDAO coveragesDAO = CoveragesDAO();

  @override
  Future<bool> deleteAntennas(List<int> icBaseCoordsIds) async {
    final results =
        icBaseCoordsIds.map((id) async => await antennasDAO.deleteAntenna(id));
    print("****** DELETE RESULTS -> $results");
    return false;
  }

 @override
Future<List<AntennaEntity>> getAntennas(int polygonTypeId) async {
  return await antennasDAO.getAntennas(polygonTypeId);
}



  @override
  Future<bool> insertAntennas(List<AntennaEntity> antennas) async {
    final results =
        antennas.map((ant) async => await antennasDAO.insertAntenna(ant));
    print("****** INSERT RESULTS -> $results");
    return false;
  }

  @override
  Future<bool> updateAntennas(List<AntennaEntity> antennas) async {
    final results =
        antennas.map((ant) async => await antennasDAO.updateAntenna(ant));
    print("****** UPDATE RESULTS -> $results");
    return false;
  }

  @override
  Future<bool> deleteCoverage(int polygonTypeId) async {
    final result = await coveragesDAO.deleteCoverage(polygonTypeId);
    print("****** DELETE RESULTS -> $result");
    return false;
  }

  @override
  Future<Map<String, dynamic>> getCoverage(int polygonTypeId) async {
    final CoverageEntity coverage =
        await coveragesDAO.getCoverage(polygonTypeId);
    if (coverage.isEmpty) {
      return {};
    } else {
      return {
        "color": HexColor(coverage.polygonColor),
        "url": Uri.parse(coverage.polygonURL)
      };
    }
  }

  @override
  Future<bool> insertCoverage(CoverageEntity coverage) async {
    final result = await coveragesDAO.insertCoverage(coverage);
    print("****** INSERT RESULTS -> $result");
    return false;
  }

  @override
  Future<bool> updateCoverage(CoverageEntity coverage) async {
    final result = await coveragesDAO.updateCoverage(coverage);
    print("****** UPDATE RESULTS -> $result");
    return false;
  }
}

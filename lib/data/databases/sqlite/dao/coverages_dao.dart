// ignore_for_file: unused_local_variable

import 'package:icc_maps/data/databases/sqlite/database/database_service.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_coverages_table.dart';
import 'package:icc_maps/data/entities/coverage_entity.dart';
import 'package:sqflite/sqflite.dart';

class CoveragesDAO {
  Future<CoverageEntity> getCoverage(int polygonTypeId) async {
    final Database db = await DatabaseService().database;
    final data = await db.query(IccCoveragesTable.tableName,
        where: "polygon_TYPE_ID = ?", whereArgs: [polygonTypeId]);
    if (data.isEmpty)
      return CoverageEntity.empty();
    else
      return IccCoveragesTable.fromMapToEntity(data.first);
  }

  // NOT USED
  Future<bool> coverageExists(int polygonTypeId) async {
    final Database db = await DatabaseService().database;
    return false;
  }

  Future<int> insertCoverage(CoverageEntity coverage) async {
    final Database db = await DatabaseService().database;
    return await db.rawInsert("""
        INSERT INTO ${IccCoveragesTable.tableName} 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """, coverage.toWhereArgs());
  }

  Future<int> deleteCoverage(int polygonTypeId) async {
    final Database db = await DatabaseService().database;
    return await db.delete(IccCoveragesTable.tableName,
        where: "polygon_TYPE_ID = ?", whereArgs: [polygonTypeId]);
  }

  Future<int> updateCoverage(CoverageEntity coverage) async {
    final Database db = await DatabaseService().database;
    return await db.update(IccCoveragesTable.tableName,
        IccCoveragesTable.fromEntityToMap(coverage),
        where: "polygon_TYPE_ID = ?", whereArgs: [coverage.polygonTypeId]);
  }
}

import 'package:icc_maps/data/databases/sqlite/database/database_service.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_antennas_table.dart';
import 'package:icc_maps/data/entities/antenna_entity.dart';
import 'package:sqflite/sqflite.dart';

class AntennasDAO {
  Future<List<AntennaEntity>> getAntennas(int polygonTypeId) async {
    final Database db = await DatabaseService().database;
    final data = await db.query(IccAntennasTable.tableName,
        where: "polygon_TYPE_ID = ?", whereArgs: [polygonTypeId]);
    return data
        .map((antenna) => IccAntennasTable.fromMapToEntity(antenna))
        .toList();
  }

  // NOT USED
  Future<int> antennaExists(String id) async {
    final Database db = await DatabaseService().database;
    return await db.rawInsert("""
    SELECT EXISTS(
      SELECT * FROM ${IccAntennasTable.tableName} WHERE polygon_TYPE_ID = ?
    ) AS `antennas_exists`;
    """, [id]);
  }

  Future<int> insertAntenna(AntennaEntity antenna) async {
    final Database db = await DatabaseService().database;
    return await db.rawInsert("""
        INSERT INTO ${IccAntennasTable.tableName} 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """, antenna.toWhereArgs());
  }

  Future<int> deleteAntenna(int icBaseCoordsId) async {
    final Database db = await DatabaseService().database;
    return await db.delete(IccAntennasTable.tableName,
        where: "ic_BASE_COORDS_ID = ?", whereArgs: [icBaseCoordsId]);
  }

  Future<int> updateAntenna(AntennaEntity antenna) async {
    final Database db = await DatabaseService().database;
    return await db.update(
        IccAntennasTable.tableName, IccAntennasTable.fromEntityToMap(antenna),
        where: "ic_BASE_COORDS_ID = ?", whereArgs: [antenna.icBaseCoordsId]);
  }
}

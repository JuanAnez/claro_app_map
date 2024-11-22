import 'package:icc_maps/data/databases/sqlite/database/database_service.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_sales_table.dart';
import 'package:icc_maps/data/entities/sale_entity.dart';
import 'package:sqflite/sqflite.dart';

class SalesDAO {
  Future<List<SaleEntity>> getSales(int posLocationId) async {
    final Database db = await DatabaseService().database;
    final data = await db.query(IccSalesTable().toString(),
        where: "pos_LOCATION_ID = ?", whereArgs: [posLocationId]);
    return data
        .map((location) => IccSalesTable.fromMapToEntity(location))
        .toList();
  }

  // NOT USED
  Future<int> saleExists(String id) async {
    final Database db = await DatabaseService().database;
    return await db.rawInsert("""
    SELECT EXISTS(
      SELECT * FROM ${IccSalesTable.tableName} WHERE pos_LOCATION_ID = ?
    ) AS `sales_exists`;
    """, [id]);
  }

  Future<int> insertSale(SaleEntity location) async {
    final Database db = await DatabaseService().database;
    return await db.rawInsert("""
        INSERT INTO ${IccSalesTable.tableName} 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """, location.toWhereArgs());
  }

  Future<int> deleteSale(int posLocationId) async {
    final Database db = await DatabaseService().database;
    return await db.delete(IccSalesTable.tableName,
        where: "pos_LOCATION_ID = ?", whereArgs: [posLocationId]);
  }

  Future<int> updateSale(SaleEntity location) async {
    final Database db = await DatabaseService().database;
    return await db.update(
        IccSalesTable.tableName, IccSalesTable.fromEntityToMap(location),
        where: "pos_LOCATION_ID = ?", whereArgs: [location.posLocationId]);
  }
}

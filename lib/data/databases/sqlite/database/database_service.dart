import 'package:icc_maps/data/databases/sqlite/database/tables/icc_antennas_table.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_coverages_table.dart';
import 'package:icc_maps/data/databases/sqlite/database/tables/icc_sales_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const name = "icc_app1.db";

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialize();
    return _database!;
  }

  Future<String> _fullPath() async {
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await _fullPath();
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: _create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> _create(Database database, int version) async =>
      await createTables(database);

  Future<void> createTables(Database database) async {
    await database
        .execute("DROP TABLE IF EXISTS `${IccCoveragesTable.tableName}`;");
    await database
        .execute("DROP TABLE IF EXISTS `${IccAntennasTable.tableName}`;");
    await database
        .execute("DROP TABLE IF EXISTS `${IccSalesTable.tableName}`;");

    await database.execute(IccCoveragesTable.createTableQuery());
    await database.execute(IccAntennasTable.createTableQuery());
    await database.execute(IccSalesTable.createTableQuery());
  }
}

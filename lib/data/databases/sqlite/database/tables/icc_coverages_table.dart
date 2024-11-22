import 'package:icc_maps/data/entities/coverage_entity.dart';

class IccCoveragesTable {
  static const tableName = "icc_coverages";

  static const _polygonTypeIdColumn = "polygon_TYPE_ID";
  static const _creationDateColumn = "creation_DATE";
  static const _createdByColumn = "created_BY";
  static const _updateDateColumn = "update_DATE";
  static const _updatedBnColumn = "updated_BY";
  static const _expirationDateColumn = "expiration_DATE";
  static const _polygonNameColumn = "polygon_NAME";
  static const _polygonDescriptionColumn = "polygon_DESCRIPTION";
  static const _polygonColorColumn = "polygon_COLOR";
  static const _polygonShapeColumn = "polygon_SHAPE";
  static const _polygonURLColumn = "polygon_URL";
  static const _priorityColumn = "priority";

  static String createTableQuery() => """
    CREATE TABLE `$tableName`(
         `$_polygonTypeIdColumn`     INTEGER  NOT NULL PRIMARY KEY 
        ,`$_creationDateColumn`       INTEGER  NOT NULL
        ,`$_createdByColumn`          INTEGER  NOT NULL
        ,`$_updateDateColumn`         INTEGER  NOT NULL
        ,`$_updatedBnColumn`          INTEGER  NOT NULL
        ,`$_expirationDateColumn`     VARCHAR(50)
        ,`$_polygonNameColumn`        VARCHAR(50) NOT NULL
        ,`$_polygonDescriptionColumn` VARCHAR(50) NOT NULL
        ,`$_polygonColorColumn`       VARCHAR(50) NOT NULL
        ,`$_polygonShapeColumn`       VARCHAR(50) NOT NULL
        ,`$_polygonURLColumn`         VARCHAR(50)
        ,`$_priorityColumn`            INTEGER NOT NULL
      );
  """;

  static Map<String, dynamic> fromEntityToMap(CoverageEntity coverage) => {
        _polygonTypeIdColumn: coverage.polygonTypeId,
        _creationDateColumn: coverage.creationDate,
        _createdByColumn: coverage.createdBy,
        _updateDateColumn: coverage.updatedDate,
        _updatedBnColumn: coverage.updatedBy,
        _expirationDateColumn: coverage.expirationDate,
        _polygonNameColumn: coverage.polygonName,
        _polygonDescriptionColumn: coverage.polygonDescription,
        _polygonColorColumn: coverage.polygonColor,
        _polygonShapeColumn: coverage.polygonShape,
        _polygonURLColumn: coverage.polygonURL,
        _priorityColumn: coverage.priority,
      };

  static CoverageEntity fromMapToEntity(Map<String, dynamic> map) =>
      CoverageEntity(
          polygonTypeId: map[_polygonTypeIdColumn],
          creationDate: map[_creationDateColumn],
          createdBy: map[_createdByColumn],
          updatedDate: map[_updateDateColumn],
          updatedBy: map[_updatedBnColumn],
          expirationDate: map[_expirationDateColumn],
          polygonName: map[_polygonNameColumn],
          polygonDescription: map[_polygonDescriptionColumn],
          polygonColor: map[_polygonColorColumn],
          polygonShape: map[_polygonShapeColumn],
          polygonURL: map[_polygonURLColumn],
          priority: map[_priorityColumn]);
}

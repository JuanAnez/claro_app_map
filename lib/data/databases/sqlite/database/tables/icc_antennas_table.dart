import 'package:icc_maps/data/entities/antenna_entity.dart';

class IccAntennasTable {
  static const tableName = "icc_antennas";

  static const _icBaseCoordsIdColumn = "ic_BASE_COORDS_ID";
  static const _creationDateColumn = "creation_DATE";
  static const _creationUserColumn = "creation_USER";
  static const _coordLatColumn = "coord_LAT";
  static const _coordLonColumn = "coord_LON";
  static const _siteIdColumn = "site_ID";
  static const _updateDateColumn = "update_DATE";
  static const _updateUserColumn = "update_USER";
  static const _expirationDateColumn = "expiration_DATE";
  static const _siteNameColumn = "site_NAME";
  static const _siteTownColumn = "site_TOWN";
  static const _polygonTypeColumn = "polygon_TYPE_ID";

  static String createTableQuery() => """
    CREATE TABLE `$tableName`(
         `$_icBaseCoordsIdColumn`  INTEGER  NOT NULL PRIMARY KEY 
        ,`$_creationDateColumn`     INTEGER  NOT NULL
        ,`$_creationUserColumn`     VARCHAR(50) NOT NULL
        ,`$_coordLatColumn`         NUMERIC(12,8) NOT NULL
        ,`$_coordLonColumn`         NUMERIC(12,8) NOT NULL
        ,`$_siteIdColumn`           VARCHAR(50) NOT NULL
        ,`$_updateDateColumn`       INTEGER
        ,`$_updateUserColumn`       VARCHAR(50)
        ,`$_expirationDateColumn`   VARCHAR(50)
        ,`$_siteNameColumn`         VARCHAR(50) NOT NULL
        ,`$_siteTownColumn`         VARCHAR(50) NOT NULL
        ,`$_polygonTypeColumn`   INTEGER  NOT NULL
      );
  """;

  static Map<String, dynamic> fromEntityToMap(AntennaEntity antenna) => {
        _icBaseCoordsIdColumn: antenna.icBaseCoordsId,
        _creationDateColumn: antenna.creationDate,
        _creationUserColumn: antenna.creationUser,
        _coordLatColumn: antenna.coordLat,
        _coordLonColumn: antenna.coordLon,
        _siteIdColumn: antenna.siteId,
        _updateDateColumn: antenna.updateDate,
        _updateUserColumn: antenna.updateUser,
        _expirationDateColumn: antenna.expirationDate,
        _siteNameColumn: antenna.siteName,
        _siteTownColumn: antenna.siteTown,
        _polygonTypeColumn: antenna.polygonTypeId,
      };

  static AntennaEntity fromMapToEntity(Map<String, dynamic> map) {
    final lat = map[_coordLatColumn];
    final lon = map[_coordLonColumn];

    double doubleLat;
    double doubleLon;

    if (lat is double && lon is double) {
      doubleLat = lat;
      doubleLon = lon;
    } else {
      final stringLat = lat.toString();
      final stringLon = lon.toString();
      doubleLat = double.parse(stringLat);
      doubleLon = double.parse(stringLon);
    }

    return AntennaEntity(
        icBaseCoordsId: map[_icBaseCoordsIdColumn],
        creationDate: map[_creationDateColumn],
        creationUser: map[_creationUserColumn],
        coordLat: doubleLat,
        coordLon: doubleLon,
        siteId: map[_siteIdColumn],
        updateDate: map[_updateDateColumn],
        updateUser: map[_updateUserColumn],
        expirationDate: map[_expirationDateColumn],
        siteName: map[_siteNameColumn],
        siteTown: map[_siteTownColumn],
        polygonTypeId: map[_polygonTypeColumn]);
  }
}

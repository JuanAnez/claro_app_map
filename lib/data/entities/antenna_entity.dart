// ignore_for_file: prefer_typing_uninitialized_variables

class AntennaEntity {
  final icBaseCoordsId;
  final creationDate;
  final creationUser;
  final double coordLat;
  final double coordLon;
  final siteId;
  final updateDate;
  final updateUser;
  final expirationDate;
  final siteName;
  final siteTown;
  final polygonTypeId;

  AntennaEntity(
      {required this.icBaseCoordsId,
      required this.creationDate,
      required this.creationUser,
      required this.coordLat,
      required this.coordLon,
      required this.siteId,
      required this.updateDate,
      required this.updateUser,
      required this.expirationDate,
      required this.siteName,
      required this.siteTown,
      required this.polygonTypeId});

  List<dynamic> toWhereArgs() => [
        icBaseCoordsId,
        creationDate,
        creationUser,
        coordLat,
        coordLon,
        siteId,
        updateDate,
        updateUser,
        expirationDate,
        siteName,
        siteTown,
        polygonTypeId,
      ];
}

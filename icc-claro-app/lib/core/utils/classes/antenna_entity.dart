class AntennaEntity {
  final int icBaseCoordsId;
  final int creationDate;
  final String creationUser;
  final double coordLat;
  final double coordLon;
  final String siteId;
  final int? updateDate;
  final String? updateUser;
  final String? expirationDate;
  final String siteName;
  final String siteTown;
  final int polygonTypeId;

  AntennaEntity({
    required this.icBaseCoordsId,
    required this.creationDate,
    required this.creationUser,
    required this.coordLat,
    required this.coordLon,
    required this.siteId,
    this.updateDate,
    this.updateUser,
    this.expirationDate,
    required this.siteName,
    required this.siteTown,
    required this.polygonTypeId,
  });

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

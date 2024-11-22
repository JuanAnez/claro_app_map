// ignore_for_file: prefer_typing_uninitialized_variables

class CoverageEntity {
  final bool isEmpty;
  final polygonTypeId;
  final creationDate;
  final createdBy;
  final updatedDate;
  final updatedBy;
  final expirationDate;
  final polygonName;
  final polygonDescription;
  final polygonColor;
  final polygonShape;
  final polygonURL;
  final priority;

  CoverageEntity(
      {this.isEmpty = false,
      required this.polygonTypeId,
      required this.creationDate,
      required this.createdBy,
      required this.updatedDate,
      required this.updatedBy,
      required this.expirationDate,
      required this.polygonName,
      required this.polygonDescription,
      required this.polygonColor,
      required this.polygonShape,
      required this.polygonURL,
      required this.priority});

  factory CoverageEntity.empty() => CoverageEntity(
      isEmpty: true,
      polygonTypeId: null,
      creationDate: null,
      createdBy: null,
      updatedDate: null,
      updatedBy: null,
      expirationDate: null,
      polygonName: null,
      polygonDescription: null,
      polygonColor: null,
      polygonShape: null,
      polygonURL: null,
      priority: null);

  List<dynamic> toWhereArgs() => [
        polygonTypeId,
        creationDate,
        createdBy,
        updatedDate,
        updatedBy,
        expirationDate,
        polygonName,
        polygonDescription,
        polygonColor,
        polygonShape,
        polygonURL,
        priority
      ];
}

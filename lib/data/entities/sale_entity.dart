import 'package:icc_maps/data/databases/sqlite/database/tables/icc_pos_icon_table.dart';

class SaleEntity {
  final DateTime creationDate;
  final String createdBy;
  final DateTime? lastUpdateDate;
  final String? lastUpdatedBy;
  final int posLocationId;
  final String? posLocationName;
  final String locType;
  final String? locDescription;
  final int? posDemographics;
  final String posOperator;
  final double latitude;
  final double longitude;
  final int posZone;
  final int channelId;
  final double? posShareMktValue;
  final DateTime? closeDate;
  final String? closeReason;
  final String? posTown;
  final String? posAddress;
  final String? posZoneDescription;
  final String? posManager;
  final String? posAssistant;
  final String? posDealer;
  final String? closeReasonDescription;
  final String? posLocationCode;
  final DateTime lastRouteDate;
  final int? routeLocStatus;
  final int? routeManager;
  final int? routeAssistant;
  final int? routeAssigned;
  final PosIcon? posIcon;
  final int posOperatorId;
  final String? manager;
  final String? assistant;
  final String? channel;
  final String? posCloseReasonDescription;
  final int? routeManagerId;
  final int? routeAssistantId;
  final int? routeAssignedId;
  final String? routeManagerName;
  final String? routeAssistantName;
  final String? routeAssignedName;
  final String? closedWithoutChanges;
  final String? routeType;
  final DateTime? routeExpectedCloseDate;
  final String? contractNum;
  final String? contractCLM;
  final DateTime? updateDate;
  final String? updatedBy;
  final int? locTypeId;

  SaleEntity({
    required this.creationDate,
    required this.createdBy,
    this.lastUpdateDate,
    this.lastUpdatedBy,
    required this.posLocationId,
    this.posLocationName,
    required this.locType,
    this.locDescription,
    this.posDemographics,
    required this.posOperator,
    required this.latitude,
    required this.longitude,
    required this.posZone,
    required this.channelId,
    this.posShareMktValue,
    this.closeDate,
    this.closeReason,
    this.posTown,
    this.posAddress,
    this.posZoneDescription,
    this.posManager,
    this.posAssistant,
    this.posDealer,
    this.closeReasonDescription,
    this.posLocationCode,
    required this.lastRouteDate,
    this.routeLocStatus,
    this.routeManager,
    this.routeAssistant,
    this.routeAssigned,
    this.posIcon,
    required this.posOperatorId,
    this.manager,
    this.assistant,
    this.channel,
    this.posCloseReasonDescription,
    this.routeManagerId,
    this.routeAssistantId,
    this.routeAssignedId,
    this.routeManagerName,
    this.routeAssistantName,
    this.routeAssignedName,
    this.closedWithoutChanges,
    this.routeType,
    this.routeExpectedCloseDate,
    this.contractNum,
    this.contractCLM,
    this.updateDate,
    this.updatedBy,
    this.locTypeId,
  });

  static SaleEntity fromMap(Map<String, dynamic> map) {
    return SaleEntity(
      creationDate: DateTime.parse(map['creationDate']),
      createdBy: map['createdBy'] ?? '',
      lastUpdateDate: map['lastUpdateDate'] != null
          ? DateTime.parse(map['lastUpdateDate'])
          : null,
      lastUpdatedBy: map['lastUpdatedBy'],
      posLocationId: map['posLocationId'] ?? 0,
      posLocationName: map['posLocationName'],
      locType: map['locType'] ?? 0,
      locDescription: map['locDescription'],
      posDemographics: map['posDemographics'],
      posOperator: map['posOperator'] ?? 0,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      posZone: map['posZone'] ?? 0,
      channelId: map['channelId'] ?? 0,
      posShareMktValue: map['posShareMktValue'],
      closeDate:
          map['closeDate'] != null ? DateTime.parse(map['closeDate']) : null,
      closeReason: map['closeReason'],
      posTown: map['posTown'],
      posAddress: map['posAddress'],
      posZoneDescription: map['posZoneDescription'],
      posManager: map['posManager'],
      posAssistant: map['posAssistant'],
      posDealer: map['posDealer'],
      closeReasonDescription: map['closeReasonDescription'],
      posLocationCode: map['posLocationCode'],
      lastRouteDate: DateTime.parse(map['lastRouteDate']),
      routeLocStatus: map['routeLocStatus'],
      routeManager: map['routeManager'],
      routeAssistant: map['routeAssistant'],
      routeAssigned: map['routeAssigned'],
      posIcon: map['posIcon'] != null ? PosIcon.fromJson(map['posIcon']) : null,
      posOperatorId: map['posOperatorId'] ?? 0,
      manager: map['manager'],
      assistant: map['assistant'],
      channel: map['channel'],
      posCloseReasonDescription: map['posCloseReasonDescription'],
      routeManagerId: map['routeManagerId'],
      routeAssistantId: map['routeAssistantId'],
      routeAssignedId: map['routeAssignedId'],
      routeManagerName: map['routeManagerName'],
      routeAssistantName: map['routeAssistantName'],
      routeAssignedName: map['routeAssignedName'],
      closedWithoutChanges: map['closedWithoutChanges'],
      routeType: map['routeType'],
      routeExpectedCloseDate: map['routeExpectedCloseDate'] != null
          ? DateTime.parse(map['routeExpectedCloseDate'])
          : null,
      contractNum: map['contractNum'],
      contractCLM: map['contractCLM'],
      updateDate:
          map['updateDate'] != null ? DateTime.parse(map['updateDate']) : null,
      updatedBy: map['updatedBy'],
      locTypeId: map['locTypeId'],
    );
  }

  List<dynamic> toWhereArgs() => [
        creationDate,
        createdBy,
        lastUpdateDate,
        lastUpdatedBy,
        posLocationId,
        posLocationName,
        locType,
        locDescription,
        posDemographics,
        posOperator,
        latitude,
        longitude,
        posZone,
        channelId,
        posShareMktValue,
        closeDate,
        closeReason,
        posTown,
        posAddress,
        posZoneDescription,
        posManager,
        posAssistant,
        posDealer,
        closeReasonDescription,
        posLocationCode,
        lastRouteDate,
        routeLocStatus,
        routeManager,
        routeAssistant,
        routeAssigned,
        posIcon?.toJson(),
        posOperatorId,
        manager,
        assistant,
        channel,
        posCloseReasonDescription,
        routeManagerId,
        routeAssistantId,
        routeAssignedId,
        routeManagerName,
        routeAssistantName,
        routeAssignedName,
        closedWithoutChanges,
        routeType,
        routeExpectedCloseDate,
        contractNum,
        contractCLM,
        updateDate,
        updatedBy,
        locTypeId,
      ];
}

import 'package:icc_maps/data/databases/sqlite/database/tables/icc_pos_icon_table.dart';
import 'package:icc_maps/data/entities/sale_entity.dart';

class IccSalesTable {
  static const tableName = "pos_location";

  static const _creationDateColumn = "creationDate";
  static const _createdByColumn = "createdBy";
  static const _lastUpdateDateColumn = "updateDate";
  static const _lastUpdatedByColumn = "updatedBy";
  static const _posLocationIdColumn = "posLocationId";
  static const _posLocationNameColumn = "posLocationName";
  static const _locTypeColumn = "locType";
  static const _locTypeIdColumn = "locTypeId";
  static const _locDescriptionColumn = "locDescription";
  static const _posDemographicsColumn = "posDemographics";
  static const _posOperatorColumn = "posOperator";
  static const _posOperatorIdColumn = "posOperatorId";
  static const _latitudeColumn = "latitude";
  static const _longitudeColumn = "longitude";
  static const _posZoneColumn = "posZone";
  static const _posZoneDescriptionColumn = "posZoneDescription";
  static const _managerColumn = "manager";
  static const _assistantColumn = "assistant";
  static const _channelColumn = "channel";
  static const _channelIdColumn = "channelId";
  static const _posShareMktValueColumn = "posShareMktValue";
  static const _closeDateColumn = "closeDate";
  static const _closeReasonColumn = "closeReason";
  static const _posTownColumn = "posTown";
  static const _posAddressColumn = "posAddress";
  static const _posDealerColumn = "posDealer";
  static const _posLocationCodeColumn = "posLocationCode";
  static const _closeReasonDescriptionColumn = "posCloseReasonDescription";
  static const _lastRouteDateColumn = "lastRouteDate";
  static const _routeLocStatusColumn = "routeLocStatus";
  static const _routeManagerIdColumn = "routeManagerId";
  static const _routeAssistantIdColumn = "routeAssistantId";
  static const _routeAssignedIdColumn = "routeAssignedId";
  static const _routeManagerNameColumn = "routeManagerName";
  static const _routeAssistantNameColumn = "routeAssistantName";
  static const _routeAssignedNameColumn = "routeAssignedName";
  static const _closedWithoutChangesColumn = "closedWithoutChanges";
  static const _routeTypeColumn = "routeType";
  static const _routeExpectedCloseDateColumn = "routeExpectedCloseDate";
  static const _contractNumColumn = "contractNum";
  static const _contractCLMColumn = "contractCLM";
  static const _posIconColumn = "posIcon";

  static String createTableQuery() => """
    CREATE TABLE `$tableName`(
         `$_creationDateColumn` DATE NOT NULL,
         `$_createdByColumn` VARCHAR2(20) NOT NULL,
         `$_lastUpdateDateColumn` DATE,
         `$_lastUpdatedByColumn` VARCHAR2(20),
         `$_posLocationIdColumn` NUMBER NOT NULL PRIMARY KEY,
         `$_posLocationNameColumn` VARCHAR2(60),
         `$_locTypeColumn` VARCHAR2(60),
         `$_locTypeIdColumn` NUMBER NOT NULL,
         `$_locDescriptionColumn` VARCHAR2(200),
         `$_posDemographicsColumn` NUMBER,
         `$_posOperatorColumn` VARCHAR2(60) NOT NULL,
         `$_posOperatorIdColumn` NUMBER NOT NULL,
         `$_latitudeColumn` VARCHAR2(30) NOT NULL,
         `$_longitudeColumn` VARCHAR2(30) NOT NULL,
         `$_posZoneColumn` NUMBER NOT NULL,
         `$_posZoneDescriptionColumn` VARCHAR2(300),
         `$_managerColumn` VARCHAR2(100),
         `$_assistantColumn` VARCHAR2(100),
         `$_channelColumn` VARCHAR2(100),
         `$_channelIdColumn` NUMBER NOT NULL,
         `$_posShareMktValueColumn` NUMBER,
         `$_closeDateColumn` DATE,
         `$_closeReasonColumn` VARCHAR2(2000),
         `$_posTownColumn` VARCHAR2(100),
         `$_posAddressColumn` VARCHAR2(300),
         `$_posDealerColumn` VARCHAR2(100),
         `$_posLocationCodeColumn` VARCHAR2(4),
         `$_closeReasonDescriptionColumn` VARCHAR2(4000),
         `$_lastRouteDateColumn` DATE DEFAULT SYSDATE NOT NULL,
         `$_routeLocStatusColumn` VARCHAR2(30),
         `$_routeManagerIdColumn` NUMBER,
         `$_routeAssistantIdColumn` NUMBER,
         `$_routeAssignedIdColumn` NUMBER,
         `$_routeManagerNameColumn` VARCHAR2(100),
         `$_routeAssistantNameColumn` VARCHAR2(100),
         `$_routeAssignedNameColumn` VARCHAR2(100),
         `$_closedWithoutChangesColumn` VARCHAR2(30),
         `$_routeTypeColumn` VARCHAR2(30),
         `$_routeExpectedCloseDateColumn` DATE,
         `$_contractNumColumn` VARCHAR2(100),
         `$_contractCLMColumn` VARCHAR2(100),
         `$_posIconColumn` CLOB
      );
  """;

  static Map<String, dynamic> fromEntityToMap(SaleEntity location) => {
        _creationDateColumn: location.creationDate,
        _createdByColumn: location.createdBy,
        _lastUpdateDateColumn: location.updateDate,
        _lastUpdatedByColumn: location.updatedBy,
        _posLocationIdColumn: location.posLocationId,
        _posLocationNameColumn: location.posLocationName,
        _locTypeColumn: location.locType,
        _locTypeIdColumn: location.locTypeId,
        _locDescriptionColumn: location.locDescription,
        _posDemographicsColumn: location.posDemographics,
        _posOperatorColumn: location.posOperator,
        _posOperatorIdColumn: location.posOperatorId,
        _latitudeColumn: location.latitude,
        _longitudeColumn: location.longitude,
        _posZoneColumn: location.posZone,
        _posZoneDescriptionColumn: location.posZoneDescription,
        _managerColumn: location.manager,
        _assistantColumn: location.assistant,
        _channelColumn: location.channel,
        _channelIdColumn: location.channelId,
        _posShareMktValueColumn: location.posShareMktValue,
        _closeDateColumn: location.closeDate,
        _closeReasonColumn: location.closeReason,
        _posTownColumn: location.posTown,
        _posAddressColumn: location.posAddress,
        _posDealerColumn: location.posDealer,
        _posLocationCodeColumn: location.posLocationCode,
        _closeReasonDescriptionColumn: location.posCloseReasonDescription,
        _lastRouteDateColumn: location.lastRouteDate,
        _routeLocStatusColumn: location.routeLocStatus,
        _routeManagerIdColumn: location.routeManagerId,
        _routeAssistantIdColumn: location.routeAssistantId,
        _routeAssignedIdColumn: location.routeAssignedId,
        _routeManagerNameColumn: location.routeManagerName,
        _routeAssistantNameColumn: location.routeAssistantName,
        _routeAssignedNameColumn: location.routeAssignedName,
        _closedWithoutChangesColumn: location.closedWithoutChanges,
        _routeTypeColumn: location.routeType,
        _routeExpectedCloseDateColumn: location.routeExpectedCloseDate,
        _contractNumColumn: location.contractNum,
        _contractCLMColumn: location.contractCLM,
        _posIconColumn: location.posIcon?.toJson(),
      };

  static SaleEntity fromMapToEntity(Map<String, dynamic> map) {
    return SaleEntity(
      creationDate: map[_creationDateColumn],
      createdBy: map[_createdByColumn],
      updateDate: map[_lastUpdateDateColumn],
      updatedBy: map[_lastUpdatedByColumn],
      posLocationId: map[_posLocationIdColumn],
      posLocationName: map[_posLocationNameColumn],
      locType: map[_locTypeColumn],
      locTypeId: map[_locTypeIdColumn],
      locDescription: map[_locDescriptionColumn],
      posDemographics: map[_posDemographicsColumn],
      posOperator: map[_posOperatorColumn],
      posOperatorId: map[_posOperatorIdColumn],
      latitude: map[_latitudeColumn],
      longitude: map[_longitudeColumn],
      posZone: map[_posZoneColumn],
      posZoneDescription: map[_posZoneDescriptionColumn],
      posManager: map[_managerColumn],
      assistant: map[_assistantColumn],
      channel: map[_channelColumn],
      channelId: map[_channelIdColumn],
      posShareMktValue: map[_posShareMktValueColumn],
      closeDate: map[_closeDateColumn],
      closeReason: map[_closeReasonColumn],
      posTown: map[_posTownColumn],
      posAddress: map[_posAddressColumn],
      posDealer: map[_posDealerColumn],
      posLocationCode: map[_posLocationCodeColumn],
      posCloseReasonDescription: map[_closeReasonDescriptionColumn],
      lastRouteDate: map[_lastRouteDateColumn],
      routeLocStatus: map[_routeLocStatusColumn],
      routeManagerId: map[_routeManagerIdColumn],
      routeAssistantId: map[_routeAssistantIdColumn],
      routeAssignedId: map[_routeAssignedIdColumn],
      routeManagerName: map[_routeManagerNameColumn],
      routeAssistantName: map[_routeAssistantNameColumn],
      routeAssignedName: map[_routeAssignedNameColumn],
      closedWithoutChanges: map[_closedWithoutChangesColumn],
      routeType: map[_routeTypeColumn],
      routeExpectedCloseDate: map[_routeExpectedCloseDateColumn],
      contractNum: map[_contractNumColumn],
      contractCLM: map[_contractCLMColumn],
      posIcon: map[_posIconColumn] != null
          ? PosIcon.fromJson(map[_posIconColumn])
          : null,
    );
  }
}

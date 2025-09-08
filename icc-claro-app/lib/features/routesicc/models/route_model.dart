class RouteModel {
  final String creationDate;
  final String createdBy;
  late String updateDate;
  late String updatedBy;
  final int posLocationRouteID;
  final int posLocationID;
  final int assignedUser;
  late String posLocationInfo;
  late String? locGroupName;
  final String? posLocationLastRouteDate;
  final String? posLocationNextRouteDate;
  final int posLocationRouteStatus;
  final String status;
  final String? expirationDate;
  late String posLocationName;
  final String? description;
  late String locType;
  final int locTypeId;
  late String locDescription;
  late String posDemographics;
  late String posOperator;
  final int posOperatorId;
  late double latitude;
  late double longitude;
  late String posZone;
  late String channel;
  late int channelId;
  late String posShareMktValue;
  final String? closeDate;
  final String? closeReason;
  late String posTown;
  late String posAddress;
  late String posZoneDescription;
  final String? posManager;
  final String? posAssistant;
  late String? posDealer;
  final String? posDealerFixed;
  final String? closeReasonDescription;
  late String? posLocationCode;
  final String? assignedUserName;
  late int routeManagerId;
  late int routeAssistantId;
  late int routeAssignedId;
  final int routeAdminId;
  late String routeManagerName;
  late String routeAssistantName;
  final String routeAssignedName;
  final String approvalManagerDate;
  final String approvalAssistantDate;
  final String approvalAssignedDate;
  final String approvalAdminDate;
  final String routeTypeAssigned;
  final String routeTypeAssistant;
  final String routeTypeManager;
  final String currentlyAssignedToName;
  final String currentlyAssignedStatus;
  final String currentlyAssignedDate;
  final String currentlyAging;
  final String agingRouteAssigned;
  final String agingRouteAssistant;
  final String agingRouteManager;
  final String? agingRouteAdmin;
  final String statusRouteAssigned;
  final String statusRouteAssistant;
  final String statusRouteManager;
  final String closedWithoutChanges;
  final String? closedWithoutChangesAssistant;
  final String? closedWithoutChangesManager;
  final String cumplimiento;
  final String routeExpectedCloseDate;
  final String returnedState;
  final String aging;
  final String routeType;
  late Map<String, dynamic>? modifiedFields;

  RouteModel({
    required this.creationDate,
    required this.createdBy,
    required this.updateDate,
    required this.updatedBy,
    required this.posLocationRouteID,
    required this.posLocationID,
    required this.assignedUser,
    required this.posLocationInfo,
    this.locGroupName,
    this.posLocationLastRouteDate,
    this.posLocationNextRouteDate,
    required this.posLocationRouteStatus,
    required this.status,
    this.expirationDate,
    required this.posLocationName,
    this.description,
    required this.locType,
    required this.locTypeId,
    required this.locDescription,
    required this.posDemographics,
    required this.posOperator,
    required this.posOperatorId,
    required this.latitude,
    required this.longitude,
    required this.posZone,
    required this.channel,
    required this.channelId,
    required this.posShareMktValue,
    this.closeDate,
    this.closeReason,
    required this.posTown,
    required this.posAddress,
    required this.posZoneDescription,
    this.posManager,
    this.posAssistant,
    this.posDealer,
    this.posDealerFixed,
    this.closeReasonDescription,
    this.posLocationCode,
    this.assignedUserName,
    required this.routeManagerId,
    required this.routeAssistantId,
    required this.routeAssignedId,
    required this.routeAdminId,
    required this.routeManagerName,
    required this.routeAssistantName,
    required this.routeAssignedName,
    required this.approvalManagerDate,
    required this.approvalAssistantDate,
    required this.approvalAssignedDate,
    required this.approvalAdminDate,
    required this.routeTypeAssigned,
    required this.routeTypeAssistant,
    required this.routeTypeManager,
    required this.currentlyAssignedToName,
    required this.currentlyAssignedStatus,
    required this.currentlyAssignedDate,
    required this.currentlyAging,
    required this.agingRouteAssigned,
    required this.agingRouteAssistant,
    required this.agingRouteManager,
    this.agingRouteAdmin,
    required this.statusRouteAssigned,
    required this.statusRouteAssistant,
    required this.statusRouteManager,
    required this.closedWithoutChanges,
    this.closedWithoutChangesAssistant,
    this.closedWithoutChangesManager,
    required this.cumplimiento,
    required this.routeExpectedCloseDate,
    required this.returnedState,
    required this.aging,
    required this.routeType,
    this.modifiedFields,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      creationDate: json["creationDate"] ?? '',
      createdBy: json["createdBy"] ?? '',
      updateDate: json["updateDate"] ?? '',
      updatedBy: json["updatedBy"] ?? '',
      posLocationRouteID: json["posLocationRouteID"] ?? 0,
      posLocationID: json["posLocationID"] ?? 0,
      assignedUser: json["assignedUser"] ?? 0,
      posLocationInfo: json["posLocationInfo"] ?? '',
      locGroupName: json["locGroupName"],
      posLocationLastRouteDate: json["posLocationLastRouteDate"],
      posLocationNextRouteDate: json["posLocationNextRouteDate"],
      posLocationRouteStatus: json["posLocationRouteStatus"] ?? 0,
      status: json["status"] ?? '',
      expirationDate: json["expirationDate"],
      posLocationName: json["posLocationName"] ?? '',
      description: json["description"],
      locType: json["locType"] ?? '',
      locTypeId: json["locTypeId"] ?? 0,
      locDescription: json["locDescription"] ?? '',
      posDemographics: json["posDemographics"] ?? '',
      posOperator: json["posOperator"] ?? '',
      posOperatorId: json["posOperatorId"] ?? 0,
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
      posZone: json["posZone"] ?? '',
      channel: json["channel"] ?? '',
      channelId: json["channelId"] ?? 0,
      posShareMktValue: json["posShareMktValue"] ?? '0.0',
      closeDate: json["closeDate"],
      closeReason: json["closeReason"],
      posTown: json["posTown"] ?? '',
      posAddress: json["posAddress"] ?? '',
      posZoneDescription: json["posZoneDescription"] ?? '',
      posManager: json["posManager"],
      posAssistant: json["posAssistant"],
      posDealer: json["posDealer"],
      posDealerFixed: json["posDealerFixed"],
      closeReasonDescription: json["closeReasonDescription"],
      posLocationCode: json["posLocationCode"],
      assignedUserName: json["assignedUserName"],
      routeManagerId: json["routeManagerId"] ?? 0,
      routeAssistantId: json["routeAssistantId"] ?? 0,
      routeAssignedId: json["routeAssignedId"] ?? 0,
      routeAdminId: json["routeAdminId"] ?? 0,
      routeManagerName: json["routeManagerName"] ?? '',
      routeAssistantName: json["routeAssistantName"] ?? '',
      routeAssignedName: json["routeAssignedName"] ?? '',
      approvalManagerDate: json["approvalManagerDate"] ?? '',
      approvalAssistantDate: json["approvalAssistantDate"] ?? '',
      approvalAssignedDate: json["approvalAssignedDate"] ?? '',
      approvalAdminDate: json["approvalAdminDate"] ?? '',
      routeTypeAssigned: json["routeTypeAssigned"] ?? '',
      routeTypeAssistant: json["routeTypeAssistant"] ?? '',
      routeTypeManager: json["routeTypeManager"] ?? '',
      currentlyAssignedToName: json["currentlyAssignedToName"] ?? '',
      currentlyAssignedStatus: json["currentlyAssignedStatus"] ?? '',
      currentlyAssignedDate: json["currentlyAssignedDate"] ?? '',
      currentlyAging: json["currentlyAging"] ?? '',
      agingRouteAssigned: json["agingRouteAssigned"] ?? '',
      agingRouteAssistant: json["agingRouteAssistant"] ?? '',
      agingRouteManager: json["agingRouteManager"] ?? '',
      agingRouteAdmin: json["agingRouteAdmin"],
      statusRouteAssigned: json["statusRouteAssigned"] ?? '',
      statusRouteAssistant: json["statusRouteAssistant"] ?? '',
      statusRouteManager: json["statusRouteManager"] ?? '',
      closedWithoutChanges: json["closedWithoutChanges"] ?? 'N',
      closedWithoutChangesAssistant: json["closedWithoutChangesAssistant"],
      closedWithoutChangesManager: json["closedWithoutChangesManager"],
      cumplimiento: json["cumplimiento"] ?? '',
      routeExpectedCloseDate: json["routeExpectedCloseDate"] ?? '',
      returnedState: json["returnedState"] ?? '',
      aging: json["aging"] ?? '',
      routeType: json["routeType"] ?? '',
      modifiedFields: json["modifiedFields"] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate,
      'createdBy': createdBy,
      'updateDate': updateDate,
      'updatedBy': updatedBy,
      'posLocationRouteID': posLocationRouteID,
      'posLocationID': posLocationID,
      'assignedUser': assignedUser,
      'posLocationInfo': posLocationInfo,
      'locGroupName': locGroupName,
      'posLocationLastRouteDate': posLocationLastRouteDate,
      'posLocationNextRouteDate': posLocationNextRouteDate,
      'posLocationRouteStatus': posLocationRouteStatus,
      'status': status,
      'expirationDate': expirationDate,
      'posLocationName': posLocationName,
      'description': description,
      'locType': locType,
      'locTypeId': locTypeId,
      'locDescription': locDescription,
      'posDemographics': posDemographics,
      'posOperator': posOperator,
      'posOperatorId': posOperatorId,
      'latitude': latitude,
      'longitude': longitude,
      'posZone': posZone,
      'channel': channel,
      'channelId': channelId,
      'posShareMktValue': posShareMktValue,
      'closeDate': closeDate,
      'closeReason': closeReason,
      'posTown': posTown,
      'posAddress': posAddress,
      'posZoneDescription': posZoneDescription,
      'posManager': posManager,
      'posAssistant': posAssistant,
      'posDealer': posDealer,
      'posDealerFixed': posDealerFixed,
      'closeReasonDescription': closeReasonDescription,
      'posLocationCode': posLocationCode,
      'assignedUserName': assignedUserName,
      'routeManagerId': routeManagerId,
      'routeAssistantId': routeAssistantId,
      'routeAssignedId': routeAssignedId,
      'routeAdminId': routeAdminId,
      'routeManagerName': routeManagerName,
      'routeAssistantName': routeAssistantName,
      'routeAssignedName': routeAssignedName,
      'approvalManagerDate': approvalManagerDate,
      'approvalAssistantDate': approvalAssistantDate,
      'approvalAssignedDate': approvalAssignedDate,
      'approvalAdminDate': approvalAdminDate,
      'routeTypeAssigned': routeTypeAssigned,
      'routeTypeAssistant': routeTypeAssistant,
      'routeTypeManager': routeTypeManager,
      'currentlyAssignedToName': currentlyAssignedToName,
      'currentlyAssignedStatus': currentlyAssignedStatus,
      'currentlyAssignedDate': currentlyAssignedDate,
      'currentlyAging': currentlyAging,
      'agingRouteAssigned': agingRouteAssigned,
      'agingRouteAssistant': agingRouteAssistant,
      'agingRouteManager': agingRouteManager,
      'agingRouteAdmin': agingRouteAdmin,
      'statusRouteAssigned': statusRouteAssigned,
      'statusRouteAssistant': statusRouteAssistant,
      'statusRouteManager': statusRouteManager,
      'closedWithoutChanges': closedWithoutChanges,
      'closedWithoutChangesAssistant': closedWithoutChangesAssistant,
      'closedWithoutChangesManager': closedWithoutChangesManager,
      'cumplimiento': cumplimiento,
      'routeExpectedCloseDate': routeExpectedCloseDate,
      'returnedState': returnedState,
      'aging': aging,
      'routeType': routeType,
    };
  }

  void updateFrom(RouteModel newRoute) {
    posLocationInfo = newRoute.posLocationInfo;
    posAddress = newRoute.posAddress;
    posDemographics = newRoute.posDemographics;
    posOperator = newRoute.posOperator;
    locType = newRoute.locType;
    locGroupName = newRoute.locGroupName;
    locDescription = newRoute.locDescription;
    channelId = newRoute.channelId;
    posZone = newRoute.posZone;
    posZoneDescription = newRoute.posZoneDescription;
    posShareMktValue = newRoute.posShareMktValue;
    updateDate = newRoute.updateDate;
    updatedBy = newRoute.updatedBy;

  }

  Map<String, dynamic> toJsonForUpdateRouteV2() {
    return {
      "posLocationRouteID": posLocationRouteID,
      "posLocationID": posLocationID,
      "posLocationRouteStatus": posLocationRouteStatus,
      "status": status,
      // "posLocationInfo": posLocationInfo,
      "posLocationName": posLocationName,
      "locDescription": locDescription,
      "locType": locType,
      "posOperator": posOperator,
      "channelId": channelId,
      "posAddress": posAddress,
      "posTown": posTown,
      "posZone": posZone,
      "posZoneDescription": posZoneDescription,
      "posDemographics": posDemographics,
      "posShareMktValue": posShareMktValue,
      "updatedBy": updatedBy,
      "latitude": latitude,
      "longitude": longitude,
      "routeManagerName": routeManagerName,
      "routeAssistantName": routeAssistantName,
      "routeManagerId": routeManagerId,
      "routeAssistantId": routeAssistantId,
      "posDealer": posDealer,
      "posLocationCode": posLocationCode,
    };
  }
}

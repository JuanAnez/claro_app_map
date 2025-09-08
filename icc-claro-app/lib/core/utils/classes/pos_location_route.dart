class PosLocationRoute {
  dynamic posLocationRouteId;
  dynamic posLocationId;
  String posLocName;
  String posLocDesc;
  dynamic posLocType;
  dynamic posLocOperator;
  dynamic posLocChannel;
  String posLocAddress;
  String posLocTown;
  dynamic posLocZone;
  String posLocZoneDesc;
  dynamic posLocDemo;
  String posLocShareMktValue;
  String posLocLat;
  String posLocLon;
  String? posLocManager;
  String? posLocAssistant;
  String? posDealer;
  // String? posDealerFixed;
  String? posLocationCode;
  // String userName;
  int routeManagerId;
  int routeAssistantId;
  int routeAssignedId;
  String? closeReason;
  String? closeReasonDescription;
  String userName;

  PosLocationRoute({
    required this.posLocationRouteId,
    required this.posLocationId,
    required this.posLocName,
    required this.posLocDesc,
    required this.posLocType,
    required this.posLocOperator,
    required this.posLocChannel,
    required this.posLocAddress,
    required this.posLocTown,
    required this.posLocZone,
    required this.posLocZoneDesc,
    required this.posLocDemo,
    required this.posLocShareMktValue,
    required this.posLocLat,
    required this.posLocLon,
    this.posLocManager,
    this.posLocAssistant,
    this.posDealer,
    // this.posDealerFixed,
    this.posLocationCode,
    // required this.userName,
    required this.routeManagerId,
    required this.routeAssistantId,
    required this.routeAssignedId,
    this.closeReason,
    this.closeReasonDescription,
    required this.userName,
  });

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final data = {
      "posLocName": posLocName,
      "posLocDesc": posLocDesc,
      "posLocType": forUpdate ? posLocType.toString() : posLocType,
      "posLocOperator": forUpdate ? posLocOperator.toString() : posLocOperator,
      "posLocChannel": forUpdate ? posLocChannel.toString() : posLocChannel,
      "posLocAddress": posLocAddress,
      "posLocTown": posLocTown,
      "posLocZone": forUpdate ? posLocZone.toString() : posLocZone,
      "posLocZoneDesc": posLocZoneDesc,
      "posLocDemo": forUpdate ? posLocDemo.toString() : posLocDemo,
      "posLocShareMktValue": posLocShareMktValue,
      "posLocLat": posLocLat,
      "posLocLon": posLocLon,
      "posLocManager": posLocManager,
      "posLocAssistant": posLocAssistant,
      "posDealer": posDealer,
      // "posDealerFixed": posDealerFixed,
      "posLocationCode": posLocationCode,
      // "userName": userName,
      "routeManager": routeManagerId,
      "routeAssistant": routeAssistantId,
      "routeAssigned": routeAssignedId,
      "userName": userName,
    };

    if (forUpdate) {
      data["closeReason"] = closeReason;
      data["closeReasonDescription"] = closeReasonDescription;
      data["posLocationRouteId"] = posLocationRouteId.toString();
      data["posLocationId"] = posLocationId.toString();
    }

    return data;
  }
}

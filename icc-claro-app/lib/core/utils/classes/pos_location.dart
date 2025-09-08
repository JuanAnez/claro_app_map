class PosLocation {
  String posLocName;
  String posLocDesc;
  String description;
  int posLocType;
  int posLocOperator;
  int posLocChannel;
  String posLocAddress;
  String posLocTown;
  int posLocZone;
  String posLocZoneDesc;
  int posLocDemo;
  String posLocShareMktValue;
  String posLocLat;
  String posLocLon;
  String? posLocManager;
  String? posLocAssistant;
  String? posDealer;
  String? posDealerFixed;
  String? posLocationCode;
  String userName;
  String posLocStatus;

  PosLocation({
    required this.posLocName,
    required this.posLocDesc,
    required this.description,
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
    this.posDealerFixed,
    this.posLocationCode,
    required this.userName,
    required this.posLocStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      "posLocName": posLocName,
      "description": description,
      "posLocType": posLocType,
      "posLocOperator": posLocOperator,
      "posLocChannel": posLocChannel,
      "posLocAddress": posLocAddress,
      "posLocTown": posLocTown,
      "posLocZone": posLocZone,
      "posLocZoneDesc": posLocZoneDesc,
      "posLocDemo": posLocDemo,
      "posLocShareMktValue": posLocShareMktValue,
      "posLocLat": posLocLat,
      "posLocLon": posLocLon,
      "posLocManager": posLocManager,
      "posLocAssistant": posLocAssistant,
      "posDealer": posDealer,
      "posDealerFixed": posDealerFixed,
      "posLocationCode": posLocationCode,
      "userName": userName,
      "locStatus": posLocStatus,
    };
  }
}

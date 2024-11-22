class PosLocation {
  String posLocName;
  String posLocDesc;
  int posLocType;
  int posLocOperator;
  int posLocChannel;
  String posLocAddress;
  String posLocTown;
  int posLocZone;
  String posLocZoneDesc;
  int posLocDemo;
  double posLocShareMktValue;
  String posLocLat;
  String posLocLon;
  String? posLocManager;
  String? posLocAssistant;
  String? posDealer;
  String? posLocationCode;
  String userName;

  PosLocation({
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
    this.posLocationCode,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      "posLocName": posLocName,
      "posLocDesc": posLocDesc,
      "posLocType": posLocType,
      "posLocOperator": posLocOperator,
      "posLocChannel": posLocChannel,
      "posLocAddress": posLocAddress,
      "posLocTown": posLocTown,
      "posLocZone": posLocZone,
      "posLocZoneDesc": posLocZoneDesc,
      "posLocDemo": posLocDemo,
      "posLocShareMktValue":
          double.parse(posLocShareMktValue.toStringAsFixed(1)),
      "posLocLat": posLocLat,
      "posLocLon": posLocLon,
      "posLocManager": posLocManager,
      "posLocAssistant": posLocAssistant,
      "posDealer": posDealer,
      "posLocationCode": posLocationCode,
      "userName": userName,
    };
  }
}

class PosIcon {
  final String creationDate;
  final String createdBy;
  final String updateDate;
  final String updatedBy;
  final int posIconId;
  final String iconName;
  final String iconDescription;
  final String? iconSource;
  final double iconScale;
  final String iconFillColor;
  final double iconFillOpacity;
  final String iconStrokeColor;
  final int iconStrokeWeight;
  final String iconViewBox;
  final int posIconType;
  final int posIconOperator;
  final String expirationDate;
  final String iconUsage;

  PosIcon({
    required this.creationDate,
    required this.createdBy,
    required this.updateDate,
    required this.updatedBy,
    required this.posIconId,
    required this.iconName,
    required this.iconDescription,
    required this.iconSource,
    required this.iconScale,
    required this.iconFillColor,
    required this.iconFillOpacity,
    required this.iconStrokeColor,
    required this.iconStrokeWeight,
    required this.iconViewBox,
    required this.posIconType,
    required this.posIconOperator,
    required this.expirationDate,
    required this.iconUsage,
  });

  factory PosIcon.fromJson(Map<String, dynamic> json) {
    return PosIcon(
      creationDate: json['creationDate'],
      createdBy: json['createdBy'],
      updateDate: json['updateDate'],
      updatedBy: json['updatedBy'],
      posIconId: json['posIconId'],
      iconName: json['iconName'],
      iconDescription: json['iconDescription'],
      iconSource: json['iconSource'],
      iconScale: json['iconScale'],
      iconFillColor: json['iconFillColor'],
      iconFillOpacity: json['iconFillOpacity'],
      iconStrokeColor: json['iconStrokeColor'],
      iconStrokeWeight: json['iconStrokeWeight'],
      iconViewBox: json['iconViewBox'],
      posIconType: json['posIconType'],
      posIconOperator: json['posIconOperator'],
      expirationDate: json['expirationDate'],
      iconUsage: json['iconUsage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate,
      'createdBy': createdBy,
      'updateDate': updateDate,
      'updatedBy': updatedBy,
      'posIconId': posIconId,
      'iconName': iconName,
      'iconDescription': iconDescription,
      'iconSource': iconSource,
      'iconScale': iconScale,
      'iconFillColor': iconFillColor,
      'iconFillOpacity': iconFillOpacity,
      'iconStrokeColor': iconStrokeColor,
      'iconStrokeWeight': iconStrokeWeight,
      'iconViewBox': iconViewBox,
      'posIconType': posIconType,
      'posIconOperator': posIconOperator,
      'expirationDate': expirationDate,
      'iconUsage': iconUsage,
    };
  }
}

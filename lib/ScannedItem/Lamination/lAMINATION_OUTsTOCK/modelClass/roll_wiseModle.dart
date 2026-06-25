class Roll {
  final int id;
  final bool active;
  final int srNo;
  final String rollCode;
  final String bomNo;

  final String barcode;
  final String fabricCode;
  final String grossWeight;
  final String tareWeight;
  final String netWeight;
  final String rollLength;
  final String avgWeight;

  Roll({
    required this.id,
    required this.active,
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.fabricCode,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.bomNo,
  });

  factory Roll.fromJson(Map<String, dynamic> json) => Roll(
    id: json['id'],
    active: json['active'],
    srNo: json['srNo'],
    rollCode: json['rollCode'],
    barcode: json['barcode'],
    fabricCode: json['fabricCode'],
    grossWeight: json['grossWeight'],
    tareWeight: json['tareWeight'],
    netWeight: json['netWeight'],
    rollLength: json['rollLength'],
    avgWeight: json['avgWeight'],
    bomNo: json['boM_NO'],
  );

}

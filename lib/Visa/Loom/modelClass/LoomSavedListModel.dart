class LoomSavedModel {
  final int id;
  final String rollCode;
  final String barcode;
  final String supervisor;
  final String operator;
  final String date;
  final String time;
  final String orderNo;
  final String workOrderNo;
  final String partyName;
  final String loomNo;
  final String loomType;
  final String fabricCode;
  final String mesh;
  final String color;
  final String laminationType;
  final String fabricWidth;
  final String gsm;
  final String grossWeight;
  final String netWeight;
  final String rollLength;
  final String avgWeight;

  LoomSavedModel({
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.supervisor,
    required this.operator,
    required this.date,
    required this.time,
    required this.orderNo,
    required this.workOrderNo,
    required this.partyName,
    required this.loomNo,
    required this.loomType,
    required this.fabricCode,
    required this.mesh,
    required this.color,
    required this.fabricWidth,
    required this.gsm,
    required this.grossWeight,
    required this.netWeight,
    required this.rollLength,
    required this.avgWeight, required this.laminationType,
  });

  factory LoomSavedModel.fromJson(Map<String, dynamic> json) {
    return LoomSavedModel(
      id: json['id'] ?? 0,
      rollCode: json['rollCode'] ?? '',
      barcode: json['barcode'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      orderNo: json['orderNo'] ?? '',
      workOrderNo: json['workOrderNo'] ?? '',
      partyName: json['partyName'] ?? '',
      loomNo: json['loomNo'] ?? '',
      loomType: json['loomType'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      mesh: json['mesh'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      gsm: json['gsm'] ?? '',
      grossWeight: json['grossWeight'] ?? '',
      netWeight: json['netWeight'] ?? '',
      rollLength: json['rollLength'] ?? '',
      avgWeight: json['avgWeight'] ?? '',
      laminationType: json['laminationType'] ?? '',
    );
  }
}
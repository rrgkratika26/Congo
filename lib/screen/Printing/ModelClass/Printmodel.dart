class PrintingOutModel {
  final int id;
  final bool active;
  final String rollCode;
  final String barcode;
  final String grossWeight;
  final String tareWeight;
  final String netWeight;
  final String rollLength;
  final String avgWeight;
  final String partyName;
  final String poNo;
  final String bomNo;
  final String orderNo;
  final String articleNo;
  final String mesh;
  final String loomNo;
  final String loomType;
  final String fabricCode;

  PrintingOutModel({
    required this.id,
    required this.active,
    required this.rollCode,
    required this.barcode,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.partyName,
    required this.poNo,
    required this.bomNo,
    required this.orderNo,
    required this.articleNo,
    required this.mesh,
    required this.loomNo,
    required this.loomType,
    required this.fabricCode,
  });

  factory PrintingOutModel.fromJson(Map<String, dynamic> json) {
    return PrintingOutModel(
      id: json["id"] ?? 0,
      active: json["active"] ?? false,
      rollCode: json["rollCode"].toString(),
      barcode: json["barcode"] ?? "",
      grossWeight: json["grossWeight"].toString(),
      tareWeight: json["tareWeight"].toString(),
      netWeight: json["netWeight"].toString(),
      rollLength: json["rollLength"].toString(),
      avgWeight: json["avgWeight"].toString(),
      partyName: json["partyName"] ?? "",
      poNo: json["poNo"] ?? "",
      bomNo: json["bomNo"] ?? "",
      orderNo: json["orderNo"] ?? "",
      articleNo: json["articleNo"] ?? "",
      mesh: json["mesh"] ?? "",
      loomNo: json["loomNo"] ?? "",
      loomType: json["loomType"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
    );
  }
}
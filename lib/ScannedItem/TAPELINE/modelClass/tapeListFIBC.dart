class TapeFIBCModel {
  final String inquiryNo;
  final String customerName;
  final String articleNo;
  final String bomNo;
  final String extra13;
  final double totalMtr;
  final double totalKg;

  TapeFIBCModel({
    required this.inquiryNo,
    required this.customerName,
    required this.articleNo,
    required this.extra13,
    required this.totalMtr,
    required this.totalKg, required this.bomNo,
  });

  factory TapeFIBCModel.fromJson(Map<String, dynamic> json) {
    return TapeFIBCModel(
      inquiryNo: json["generateD_INQUIRY"] ?? "",
      customerName: json["customeR_NAME"] ?? "",
      articleNo: json["articlE_NO"] ?? "",
      extra13: json["extrA13"] ?? "",
      totalMtr: (json["total_MTR"] ?? 0).toDouble(),
      totalKg: (json["total_KG"] ?? 0).toDouble(),
      bomNo: json["generateD_INQUIRY"] ?? "",
    );
  }
}
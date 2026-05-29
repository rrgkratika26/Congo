class BalingDetailsModel {
  final String packingNo;
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int pcs;
  final double packingNetWt;
  final double perPcsWt;
  final double grossWt;
  final double tareWt;
  final double netWt;
  final double diffWt;
  final String date;

  BalingDetailsModel({
    required this.packingNo,
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.pcs,
    required this.packingNetWt,
    required this.perPcsWt,
    required this.grossWt,
    required this.tareWt,
    required this.netWt,
    required this.diffWt,
    required this.date,
  });

  factory BalingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BalingDetailsModel(
      packingNo: json["packinG_NO"] ?? "",
      partyName: json["partY_NAME"] ?? "",
      bomNo: json["boM_NO"] ?? "",
      articleNo: json["articlE_NO"] ?? "",
      pcs: json["nO_OF_PCS_PER_PACKING"] ?? 0,
      packingNetWt: (json["packinG_NET_WT"] ?? 0).toDouble(),
      perPcsWt: (json["peR_PCS_WT"] ?? 0).toDouble(),
      grossWt: (json["bailinG_GROSS_WT"] ?? 0).toDouble(),
      tareWt: (json["bailinG_TARE_WT"] ?? 0).toDouble(),
      netWt: (json["bailinG_NET_WT"] ?? 0).toDouble(),
      diffWt: (json["bailinG_STAGE_DIFF_NET_WT"] ?? 0).toDouble(),
      date: json["bailinG_DATE"] ?? "",
    );
  }
}
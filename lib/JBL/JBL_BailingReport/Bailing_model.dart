class JBLBalingReportModel {
  final String packingNo;
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int noOfPcsPerPacking;
  final double packingNetWt;
  final double perPcsWt;
  final double bailingGrossWt;
  final double bailingTareWt;
  final double bailingNetWt;
  final double stageDiffNetWt;
  final DateTime bailingDate;

  JBLBalingReportModel({
    required this.packingNo,
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.noOfPcsPerPacking,
    required this.packingNetWt,
    required this.perPcsWt,
    required this.bailingGrossWt,
    required this.bailingTareWt,
    required this.bailingNetWt,
    required this.stageDiffNetWt,
    required this.bailingDate,
  });

  factory JBLBalingReportModel.fromJson(Map<String, dynamic> json) {
    return JBLBalingReportModel(
      packingNo: json['packinG_NO'] ?? '',
      partyName: json['partY_NAME'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      noOfPcsPerPacking: json['nO_OF_PCS_PER_PACKING'] ?? 0,
      packingNetWt: (json['packinG_NET_WT'] ?? 0).toDouble(),
      perPcsWt: (json['peR_PCS_WT'] ?? 0).toDouble(),
      bailingGrossWt: (json['bailinG_GROSS_WT'] ?? 0).toDouble(),
      bailingTareWt: (json['bailinG_TARE_WT'] ?? 0).toDouble(),
      bailingNetWt: (json['bailinG_NET_WT'] ?? 0).toDouble(),
      stageDiffNetWt: (json['bailinG_STAGE_DIFF_NET_WT'] ?? 0).toDouble(),
      bailingDate: DateTime.parse(json['bailinG_DATE']),
    );
  }
}
class CuttingReportModel {
  final String pono;
  final String articleNo;
  final String woNo;
  final String partyName;
  final String compName;
  final int woQty;
  final double rollSize;
  final double pcs;
  final int noOfPcs;
  final double wastage;
  final int pending;

  CuttingReportModel({
    required this.pono,
    required this.articleNo,
    required this.woNo,
    required this.partyName,
    required this.compName,
    required this.woQty,
    required this.rollSize,
    required this.pcs,
    required this.noOfPcs,
    required this.wastage,
    required this.pending,
  });

  factory CuttingReportModel.fromJson(Map<String, dynamic> json) {
    return CuttingReportModel(
      pono: json['pono'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      woNo: json['wO_NO'] ?? '',
      partyName: json['partY_NAME'] ?? '',
      compName: json['comP_NAME'] ?? '',
      woQty: json['wO_QTY'] ?? 0,
      rollSize: json['rolL_SIZE'] ?? 0.0,
      pcs: (json['pcs'] ?? 0).toDouble(),
      noOfPcs: json['nO_OF_PCS'] ?? 0,
      wastage: (json['wastage'] ?? 0).toDouble(),
      pending: json['pending'] ?? 0,
    );
  }
}
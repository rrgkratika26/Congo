class Comp_NardanaReportModel {
  final String pono;
  final String articleNo;
  final String woNo;
  final String partyName;
  final String compName;
  final int woQty;
  final String rollSize;
  final double pcs;
  final int noOfPcs;
  final double wastage;
  final int pending;

  Comp_NardanaReportModel({
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

  factory Comp_NardanaReportModel.fromJson(Map<String, dynamic> json) {
    return Comp_NardanaReportModel(
      pono: json['pono'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      woNo: json['wO_NO'] ?? '',
      partyName: json['partY_NAME'] ?? '',
      compName: json['comP_NAME'] ?? '',
      woQty: json['wO_QTY'] ?? 0,
      rollSize: json['rolL_SIZE'] ?? '',
      pcs: (json['pcs'] ?? 0).toDouble(),
      noOfPcs: json['nO_OF_PCS'] ?? 0,
      wastage: (json['wastage'] ?? 0).toDouble(),
      pending: json['pending'] ?? 0,
    );
  }
}
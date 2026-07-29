class DispatchReport {
  final String srNo;
  final String date;
  final String barcode;
  final String partyName;
  final String workOrder;
  final String articleNo;
  final String bagType;
  final String shift;
  final String baleNo;
  final int bagQty;
  final double netWt;
  final double grossWt;
  final String bagSize;
  final String palletSize;
  final String supervisor;
  final String operatorName;
  final String remark;

  DispatchReport({
    required this.srNo,
    required this.date,
    required this.barcode,
    required this.partyName,
    required this.workOrder,
    required this.articleNo,
    required this.bagType,
    required this.shift,
    required this.baleNo,
    required this.bagQty,
    required this.netWt,
    required this.grossWt,
    required this.bagSize,
    required this.palletSize,
    required this.supervisor,
    required this.operatorName,
    required this.remark,
  });

  factory DispatchReport.fromJson(Map<String, dynamic> json) {
    return DispatchReport(
      srNo: json['sR_NO'] ?? '',
      date: json['date'] ?? '',
      barcode: json['barcode'] ?? '',
      partyName: json['partY_NAME'] ?? '',
      workOrder: json['worK_ORDER'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      bagType: json['baG_TYPE'] ?? '',
      shift: json['shift'] ?? '',
      baleNo: json['balE_NO'] ?? '',
      bagQty: json['baG_QTY_IN_PCS'] ?? 0,
      netWt: (json['balE_PALLET_NWT'] ?? 0).toDouble(),
      grossWt: (json['balE_PALLET_GROSS_WT'] ?? 0).toDouble(),
      bagSize: json['baG_SIZE'] ?? '',
      palletSize: json['palleT_SIZE'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operatorName: json['operator'] ?? '',
      remark: json['remark'] ?? '',
    );
  }
}

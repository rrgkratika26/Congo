class RollWiseReportModel {
  final String srno;
  final String articleNo;
  final String bom;
  final String customerName;
  final String pono;
  final String fabricWidth;
  final String fabricGsm;
  final String rollNo;
  final String partyName;
  final DateTime cutDate;
  final double rollMtr;
  final String rollSize;
  final double grossWt;
  final double tareWt;
  final double netWt;
  final double usedNetWt;
  final double usedWastage;
  final double balance;
  final int cutPcs;
  final String remark;

  RollWiseReportModel({
    required this.srno,
    required this.articleNo,
    required this.bom,
    required this.customerName,
    required this.pono,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.rollNo,
    required this.partyName,
    required this.cutDate,
    required this.rollMtr,
    required this.rollSize,
    required this.grossWt,
    required this.tareWt,
    required this.netWt,
    required this.usedNetWt,
    required this.usedWastage,
    required this.balance,
    required this.cutPcs,
    required this.remark,
  });

  factory RollWiseReportModel.fromJson(Map<String, dynamic> json) {
    return RollWiseReportModel(
      srno: json['srno'],
      articleNo: json['articlE_NO'],
      bom: json['bom'],
      customerName: json['customeR_NAME'],
      pono: json['pono'],
      fabricWidth: json['fabriC_WIDTH'],
      fabricGsm: json['fabriC_GSM'],
      rollNo: json['rolL_NO'],
      partyName: json['partY_NAME'],
      cutDate: DateTime.parse(json['cuT_DATE']),
      rollMtr: double.parse(json['rolL_MTR']),
      rollSize: json['rolL_SIZE'],
      grossWt: double.parse(json['grosS_WT']),
      tareWt: double.parse(json['tarE_WT']),
      netWt: double.parse(json['neT_WT']),
      usedNetWt: double.parse(json['useD_NET_WT']),
      usedWastage: double.parse(json['useD_WASTAGE']),
      balance: double.parse(json['balance']),
      cutPcs: int.parse(json['cuT_PCS']),
      remark: json['remark'],
    );
  }
}
// class RollWiseReportModel {
//   final String srno;
//   final String articleNo;
//   final String bom;
//   final String customerName;
//   final String pono;
//   final String fabricWidth;
//   final String fabricGsm;
//   final String rollNo;
//   final String partyName;
//   final DateTime cutDate;
//   final double rollMtr;
//   final String rollSize;
//   final double grossWt;
//   final double tareWt;
//   final double netWt;
//   final double usedNetWt;
//   final double usedWastage;
//   final double balance;
//   final int cutPcs;
//   final String remark;
//
//   RollWiseReportModel({
//     required this.srno,
//     required this.articleNo,
//     required this.bom,
//     required this.customerName,
//     required this.pono,
//     required this.fabricWidth,
//     required this.fabricGsm,
//     required this.rollNo,
//     required this.partyName,
//     required this.cutDate,
//     required this.rollMtr,
//     required this.rollSize,
//     required this.grossWt,
//     required this.tareWt,
//     required this.netWt,
//     required this.usedNetWt,
//     required this.usedWastage,
//     required this.balance,
//     required this.cutPcs,
//     required this.remark,
//   });
//
//   factory RollWiseReportModel.fromJson(Map<String, dynamic> json) {
//     return RollWiseReportModel(
//       srno: json['srno'],
//       articleNo: json['articlE_NO'],
//       bom: json['bom'],
//       customerName: json['customeR_NAME'],
//       pono: json['pono'],
//       fabricWidth: json['fabriC_WIDTH'],
//       fabricGsm: json['fabriC_GSM'],
//       rollNo: json['rolL_NO'],
//       partyName: json['partY_NAME'],
//       cutDate: DateTime.parse(json['cuT_DATE']),
//       rollMtr: double.parse(json['rolL_MTR']),
//       rollSize: json['rolL_SIZE'],
//       grossWt: double.parse(json['grosS_WT']),
//       tareWt: double.parse(json['tarE_WT']),
//       netWt: double.parse(json['neT_WT']),
//       usedNetWt: double.parse(json['useD_NET_WT']),
//       usedWastage: double.parse(json['useD_WASTAGE']),
//       balance: double.parse(json['balance']),
//       cutPcs: int.parse(json['cuT_PCS']),
//       remark: json['remark'],
//     );
//   }
// }





class RollWiseReportModel {
  final int srno;
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
      srno: json['srno'] ?? 0,
      articleNo: json['articlE_NO'] ?? '',
      bom: json['bom'] ?? '',
      customerName: json['customeR_NAME'] ?? '',
      pono: json['pono'] ?? '',
      fabricWidth: json['fabriC_WIDTH'] ?? '',
      fabricGsm: json['fabriC_GSM'] ?? '',
      rollNo: json['rolL_NO']?.toString() ?? '',
      partyName: json['partY_NAME'] ?? '',
      cutDate: DateTime.parse(json['cuT_DATE']),
      rollMtr: (json['rolL_MTR'] ?? 0).toDouble(),
      rollSize: json['rolL_SIZE'] ?? '',
      grossWt: (json['grosS_WT'] ?? 0).toDouble(),
      tareWt: (json['tarE_WT'] ?? 0).toDouble(),
      netWt: (json['neT_WT'] ?? 0).toDouble(),
      usedNetWt: (json['useD_NET_WT'] ?? 0).toDouble(),
      usedWastage: (json['useD_WASTAGE'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      cutPcs: json['cuT_PCS'] ?? 0,
      remark: json['remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "srno": srno,
      "articlE_NO": articleNo,
      "bom": bom,
      "customeR_NAME": customerName,
      "pono": pono,
      "fabriC_WIDTH": fabricWidth,
      "fabriC_GSM": fabricGsm,
      "rolL_NO": rollNo,
      "partY_NAME": partyName,
      "cuT_DATE": cutDate.toIso8601String(),
      "rolL_MTR": rollMtr,
      "rolL_SIZE": rollSize,
      "grosS_WT": grossWt,
      "tarE_WT": tareWt,
      "neT_WT": netWt,
      "useD_NET_WT": usedNetWt,
      "useD_WASTAGE": usedWastage,
      "balance": balance,
      "cuT_PCS": cutPcs,
      "remark": remark,
    };
  }
}
// class CuttingReportModel {
//   final String pono;
//   final String articleNo;
//   final String woNo;
//   final String partyName;
//   final String compName;
//   final int woQty;
//   final double rollSize;
//   final double pcs;
//   final int noOfPcs;
//   final double wastage;
//   final int pending;
//
//   CuttingReportModel({
//     required this.pono,
//     required this.articleNo,
//     required this.woNo,
//     required this.partyName,
//     required this.compName,
//     required this.woQty,
//     required this.rollSize,
//     required this.pcs,
//     required this.noOfPcs,
//     required this.wastage,
//     required this.pending,
//   });
//
//   factory CuttingReportModel.fromJson(Map<String, dynamic> json) {
//     return CuttingReportModel(
//       pono: json['pono']?.toString() ?? '',
//       articleNo: json['articlE_NO']?.toString() ?? '',
//       woNo: json['wO_NO']?.toString() ?? '',
//       partyName: json['partY_NAME']?.toString() ?? '',
//       compName: json['comP_NAME']?.toString() ?? '',
//
//       woQty: int.tryParse(json['wO_QTY'].toString()) ?? 0,
//
//       rollSize: double.tryParse(json['rolL_SIZE'].toString()) ?? 0,
//
//       pcs: double.tryParse(json['pcs'].toString()) ?? 0,
//
//       noOfPcs: int.tryParse(json['nO_OF_PCS'].toString()) ?? 0,
//
//       wastage: double.tryParse(json['wastage'].toString()) ?? 0,
//
//       pending: int.tryParse(json['pending'].toString()) ?? 0,
//     );
//   }
// }



class CuttingReportModel {
  final String pono;
  final String articleNo;
  final String woNo;
  final String partyName;
  final String compName;

  final double woQty;
  final double rollSize;
  final double rollWt; // NEW
  final double pcs;
  final double noOfPcs;
  final double wastage;
  final double pending;

  CuttingReportModel({
    required this.pono,
    required this.articleNo,
    required this.woNo,
    required this.partyName,
    required this.compName,
    required this.woQty,
    required this.rollSize,
    required this.rollWt,
    required this.pcs,
    required this.noOfPcs,
    required this.wastage,
    required this.pending,
  });

  factory CuttingReportModel.fromJson(Map<String, dynamic> json) {
    return CuttingReportModel(
      pono: json['pono']?.toString() ?? '',
      articleNo: json['articlE_NO']?.toString() ?? '',
      woNo: json['wO_NO']?.toString() ?? '',
      partyName: json['partY_NAME']?.toString() ?? '',
      compName: json['comP_NAME']?.toString() ?? '',

      woQty: double.tryParse(json['wO_QTY'].toString()) ?? 0,
      rollSize: double.tryParse(json['rolL_SIZE'].toString()) ?? 0,
      rollWt: double.tryParse(json['rolL_WT'].toString()) ?? 0, // NEW
      pcs: double.tryParse(json['pcs'].toString()) ?? 0,
      noOfPcs: double.tryParse(json['nO_OF_PCS'].toString()) ?? 0,
      wastage: double.tryParse(json['wastage'].toString()) ?? 0,
      pending: double.tryParse(json['pending'].toString()) ?? 0,
    );
  }
}
// import '../../JBL_BagProduction/ReportModel/baseModel.dart';
//
// class OverallModel implements BaseReportModel{
//   final String packingNo;
//   final String partyName;
//   final String bomNo;
//   final String articleNo;
//   final int noOfPcsPerPacking;
//   final double packingNetWt;
//   final int perPcsWt;
//   final double? bailingGrossWt;
//   final double? bailingTareWt;
//   final double? bailingNetWt;
//   final double? bailingStageDiffNetWt;
//   final String? bailingDate;
//
//   OverallModel({
//     required this.packingNo,
//     required this.partyName,
//     required this.bomNo,
//     required this.articleNo,
//     required this.noOfPcsPerPacking,
//     required this.packingNetWt,
//     required this.perPcsWt,
//     this.bailingGrossWt,
//     this.bailingTareWt,
//     this.bailingNetWt,
//     this.bailingStageDiffNetWt,
//     this.bailingDate,
//   });
//
//   factory OverallModel.fromJson(Map<String, dynamic> json) {
//     return OverallModel(
//       packingNo: json['PACKING_NO']?.toString() ?? '',
//       partyName: json['PARTY_NAME']?.toString() ?? '',
//       bomNo: json['BOM_NO']?.toString() ?? '',
//       articleNo: json['ARTICLE_NO']?.toString() ?? '',
//       noOfPcsPerPacking: _parseInt(json['NO_OF_PCS_PER_PACKING']),
//       packingNetWt: _parseDouble(json['PACKING_NET_WT']) ?? 0,
//       perPcsWt: _parseInt(json['PER_PCS_WT']),
//       bailingGrossWt: _parseDouble(json['BAILING_GROSS_WT']),
//       bailingTareWt: _parseDouble(json['BAILING_TARE_WT']),
//       bailingNetWt: _parseDouble(json['BAILING_NET_WT']),
//       bailingStageDiffNetWt: _parseDouble(json['BAILING_STAGE_DIFF_NET_WT']),
//       bailingDate: json['BAILING_DATE']?.toString(),
//     );
//   }
//
//   static int _parseInt(dynamic v) {
//     if (v == null || v == '') return 0;
//     if (v is int) return v;
//     return int.tryParse(v.toString()) ?? 0;
//   }
//
//   static double? _parseDouble(dynamic v) {
//     if (v == null) return null;
//
//     if (v is num) return v.toDouble();
//
//     if (v is String) {
//       if (v.trim().isEmpty) return null;
//       return double.tryParse(v);
//     }
//
//     return null;
//   }
//
//   Map<String, dynamic> toJson() => {
//     'PACKING_NO': packingNo,
//     'PARTY_NAME': partyName,
//     'BOM_NO': bomNo,
//     'ARTICLE_NO': articleNo,
//     'NO_OF_PCS_PER_PACKING': noOfPcsPerPacking,
//     'PACKING_NET_WT': packingNetWt,
//     'PER_PCS_WT': perPcsWt,
//     'BAILING_GROSS_WT': bailingGrossWt,
//     'BAILING_TARE_WT': bailingTareWt,
//     'BAILING_NET_WT': bailingNetWt,
//     'BAILING_STAGE_DIFF_NET_WT': bailingStageDiffNetWt,
//     'BAILING_DATE': bailingDate,
//   };
// }



import '../../JBL_BagProduction/ReportModel/baseModel.dart';

class OverallModel implements BaseReportModel {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int totalQty;
  final int bagProduction;
  final int bailQty;
  final int dispatchQty;

  OverallModel({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.totalQty,
    required this.bagProduction,
    required this.bailQty,
    required this.dispatchQty,
  });

  factory OverallModel.fromJson(Map<String, dynamic> json) {
    return OverallModel(
      partyName: json['PARTY_NAME']?.toString() ?? '',
      bomNo: json['BOM_NO']?.toString() ?? '',
      articleNo: json['ARTICLE_NO']?.toString() ?? '',
      totalQty: _parseInt(json['TOTAL QTY']),
      bagProduction: _parseInt(json['BAG_PRODUCTION']),
      bailQty: _parseInt(json['BAIL QTY']),
      dispatchQty: _parseInt(json['DISPATCH QTY']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null || v == '') return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Map<String, dynamic> toJson() => {
    'PARTY_NAME': partyName,
    'BOM_NO': bomNo,
    'ARTICLE_NO': articleNo,
    'TOTAL QTY': totalQty,
    'BAG_PRODUCTION': bagProduction,
    'BAIL QTY': bailQty,
    'DISPATCH QTY': dispatchQty,
  };
}
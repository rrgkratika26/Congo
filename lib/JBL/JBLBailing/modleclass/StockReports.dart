import '../../JBL_BagProduction/ReportModel/baseModel.dart';


class BaleStockReportModel  implements BaseReportModel{
  final String packingNo;
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int noOfPcsPerPacking;
  final double packingNetWt;
  final int perPcsWt;
  final double? bailingGrossWt;
  final double? bailingTareWt;
  final double? bailingNetWt;
  final double? bailingStageDiffNetWt;
  final String? bailingDate;

  BaleStockReportModel({
    required this.packingNo,
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.noOfPcsPerPacking,
    required this.packingNetWt,
    required this.perPcsWt,
    this.bailingGrossWt,
    this.bailingTareWt,
    this.bailingNetWt,
    this.bailingStageDiffNetWt,
    this.bailingDate,
  });

  factory BaleStockReportModel.fromJson(Map<String, dynamic> json) {
    return BaleStockReportModel(
      packingNo: json['PACKING_NO']?.toString() ?? '',
      partyName: json['PARTY_NAME']?.toString() ?? '',
      bomNo: json['BOM_NO']?.toString() ?? '',
      articleNo: json['ARTICLE_NO']?.toString() ?? '',
      noOfPcsPerPacking: (json['NO_OF_PCS_PER_PACKING'] ?? 0) as int,
      packingNetWt: (json['PACKING_NET_WT'] ?? 0).toDouble(),
      perPcsWt: (json['PER_PCS_WT'] ?? 0) as int,
      bailingGrossWt: _parseDouble(json['BAILING_GROSS_WT']),
      bailingTareWt: _parseDouble(json['BAILING_TARE_WT']),
      bailingNetWt: _parseDouble(json['BAILING_NET_WT']),
      bailingStageDiffNetWt: _parseDouble(json['BAILING_STAGE_DIFF_NET_WT']),
      bailingDate: json['BAILING_DATE']?.toString() ?? '',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null || value == '') return null;
    return (value as num).toDouble();
  }

  @override
  Map<String, dynamic> toJson() => {
    'PACKING_NO': packingNo,
    'PARTY_NAME': partyName,
    'BOM_NO': bomNo,
    'ARTICLE_NO': articleNo,
    'NO_OF_PCS_PER_PACKING': noOfPcsPerPacking,
    'PACKING_NET_WT': packingNetWt,
    'PER_PCS_WT': perPcsWt,
    'BAILING_GROSS_WT': bailingGrossWt,
    'BAILING_TARE_WT': bailingTareWt,
    'BAILING_NET_WT': bailingNetWt,
    'BAILING_STAGE_DIFF_NET_WT': bailingStageDiffNetWt,
    'BAILING_DATE': bailingDate,
  };
}
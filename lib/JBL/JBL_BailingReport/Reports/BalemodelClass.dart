// bale_report_model.dart

int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class BaleReportModel {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int totalQty;
  final int bagProduction;
  final int bailQty;
  final int dispatchQty;

  BaleReportModel({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.totalQty,
    required this.bagProduction,
    required this.bailQty,
    required this.dispatchQty,
  });

  factory BaleReportModel.fromJson(Map<String, dynamic> json) {
    return BaleReportModel(
      partyName:     json['PARTY_NAME']    ?? '',
      bomNo:         json['BOM_NO']        ?? '',
      articleNo:     json['ARTICLE_NO']    ?? '',
      totalQty:      parseInt(json['TOTAL QTY']),      // ← space in key
      bagProduction: parseInt(json['BAG_PRODUCTION']),
      bailQty:       parseInt(json['BAIL QTY']),       // ← space in key
      dispatchQty:   parseInt(json['DISPATCH QTY']),   // ← space in key
    );
  }

  Map<String, dynamic> toJson() => {
    'Party Name':    partyName,
    'BOM No':        bomNo,
    'Article No':    articleNo,
    'Total Qty':     totalQty,
    'Bag Production': bagProduction,
    'Bail Qty':      bailQty,
    'Dispatch Qty':  dispatchQty,
  };
}
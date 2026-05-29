// =======================================================
// BaleStockModel.dart
// =======================================================

class BaleStockModel {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int totalQty;
  final int bagProduction;
  final int totalBale;
  final int baleQty;
  final int dispatchQty;
  final int balanceQty;

  BaleStockModel({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.totalQty,
    required this.bagProduction,
    required this.totalBale,
    required this.baleQty,
    required this.dispatchQty,
    required this.balanceQty,
  });

  factory BaleStockModel.fromJson(Map<String, dynamic> json) {
    return BaleStockModel(
      partyName: json['partY_NAME'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      totalQty: json['totaL_QTY'] ?? 0,
      bagProduction: json['baG_PRODUCTION'] ?? 0,
      totalBale: json['totaL_BALE'] ?? 0,
      baleQty: json['balE_QTY'] ?? 0,
      dispatchQty: json['dispatcH_QTY'] ?? 0,
      balanceQty: json['balancE_QTY'] ?? 0,
    );
  }
}
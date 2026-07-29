// =======================================================
// BaleStockModel.dart
// =======================================================
//
// class BaleStockModel {
//   final String partyName;
//   final String bomNo;
//   final String articleNo;
//   final int totalQty;
//   final double bagProduction;
//   final double totalBale;
//   final double baleQty;
//   final double dispatchQty;
//   final double balanceQty;
//
//   BaleStockModel({
//     required this.partyName,
//     required this.bomNo,
//     required this.articleNo,
//     required this.totalQty,
//     required this.bagProduction,
//     required this.totalBale,
//     required this.baleQty,
//     required this.dispatchQty,
//     required this.balanceQty,
//   });
//
//   factory BaleStockModel.fromJson(Map<String, dynamic> json) {
//     return BaleStockModel(
//       partyName: json['partY_NAME'] ?? '',
//       bomNo: json['boM_NO'] ?? '',
//       articleNo: json['articlE_NO'] ?? '',
//       totalQty: json['totaL_QTY'] ?? 0.0,
//       bagProduction: json['baG_PRODUCTION'] ?? 0.0,
//       totalBale: json['totaL_BALE'] ?? 0.0,
//       baleQty: json['balE_QTY'] ?? 0.0,
//       dispatchQty: json['dispatcH_QTY'] ?? 0.0,
//       balanceQty: json['balancE_QTY'] ?? 0.0,
//     );
//   }
// }



class BaleStockModel {
  final String partyName;
  final String bomNo;
  final String articleNo;

  final double totalQty;
  final double bagProduction;
  final double totalBale;
  final double baleQty;
  final double dispatchQty;
  final double balanceQty;

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
      partyName: json['partY_NAME']?.toString() ?? '',
      bomNo: json['boM_NO']?.toString() ?? '',
      articleNo: json['articlE_NO']?.toString() ?? '',

      totalQty: (json['totaL_QTY'] as num?)?.toDouble() ?? 0.0,
      bagProduction: (json['baG_PRODUCTION'] as num?)?.toDouble() ?? 0.0,
      totalBale: (json['totaL_BALE'] as num?)?.toDouble() ?? 0.0,
      baleQty: (json['balE_QTY'] as num?)?.toDouble() ?? 0.0,
      dispatchQty: (json['dispatcH_QTY'] as num?)?.toDouble() ?? 0.0,
      balanceQty: (json['balancE_QTY'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
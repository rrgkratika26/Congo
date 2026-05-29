class BailingSummaryModel {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int totalQty;
  final int bagProduction;
  final int bailQty;
  final int dispatchQty;

  BailingSummaryModel({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.totalQty,
    required this.bagProduction,
    required this.bailQty,
    required this.dispatchQty,
  });

  factory BailingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BailingSummaryModel(
      partyName: json['partY_NAME'] ?? "",
      bomNo: json['boM_NO'] ?? "",
      articleNo: json['articlE_NO'] ?? "",
      totalQty: json['totaL_QTY'] ?? 0,
      bagProduction: json['baG_PRODUCTION'] ?? 0,
      bailQty: json['baiL_QTY'] ?? 0,
      dispatchQty: json['dispatcH_QTY'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "partyName": partyName,
      "bomNo": bomNo,
      "articleNo": articleNo,
      "totalQty": totalQty,
      "bagProduction": bagProduction,
      "bailQty": bailQty,
      "dispatchQty": dispatchQty,
    };
  }
}
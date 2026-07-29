class CombineToLoomModel {
  final int orderNo;
  final String BomNo;
  final int mtr;
  final int kg;
  final String poNum;
  final String articleNum;

  CombineToLoomModel({
    required this.orderNo,
    required this.mtr,
    required this.kg,
    required this.poNum,
    required this.articleNum, required this.BomNo,
  });

  factory CombineToLoomModel.fromJson(
      Map<String, dynamic> json) {
    return CombineToLoomModel(
      orderNo: json['ordeR_NO'] ?? 0,
      BomNo: json['boM_NO']?.toString() ?? '',
      mtr: json['mtr'] ?? 0,
      kg: json['kg'] ?? 0,
      poNum: json['pO_NUM'] ?? '',
      articleNum: json['articlE_NUM'] ?? '',
    );
  }
}
class ForwardListModel {
  final int orderNo;
  final String bomNo;
  final String component;
  final String fabricCode;
  final String mtr;
  final String kg;
  final String poNum;
  final String articleNum;

  ForwardListModel({
    required this.orderNo,
    required this.bomNo,
    required this.component,
    required this.fabricCode,
    required this.mtr,
    required this.kg,
    required this.poNum,
    required this.articleNum,
  });

  factory ForwardListModel.fromJson(
      Map<String,dynamic> json){

    return ForwardListModel(
      orderNo: json["ordeR_NO"] ?? 0,
      bomNo: json["boM_NO"] ?? "",
      component: json["component"] ?? "",
      fabricCode: json["fabriC_CODE"] ?? "",
      mtr: json["mtr"] ?? "",
      kg: json["kg"] ?? "",
      poNum: json["pO_NUM"] ?? "",
      articleNum: json["articlE_NUM"] ?? "",
    );
  }
}
class OrderCompositionModel {
  bool selected;

  final String woNumber;
  final String component;
  final String fabricCode;
  final String orderRequiredMtr;
  final String orderRequiredKg;
  final String idForWo;
  final String poNum;
  final String articleNum;

  OrderCompositionModel({
    this.selected = false,
    required this.woNumber,
    required this.component,
    required this.fabricCode,
    required this.orderRequiredMtr,
    required this.orderRequiredKg,
    required this.idForWo,
    required this.poNum,
    required this.articleNum,
  });

  factory OrderCompositionModel.fromJson(
      Map<String, dynamic> json) {
    return OrderCompositionModel(
      selected: false,

      woNumber: json["wO_NUMBER"]?.toString() ?? "",

      component: json["component"]?.toString() ?? "",

      fabricCode: json["fabriC_CODE"]?.toString() ?? "",

      orderRequiredMtr:
      json["ordeR_REQUIRED_MTR"]?.toString() ?? "",

      orderRequiredKg:
      json["ordeR_REQUIRED_KG"]?.toString() ?? "",

      idForWo:
      json["iD_FOR_WO"]?.toString() ?? "",

      poNum:
      json["pO_NUM"]?.toString() ?? "",

      articleNum:
      json["articlE_NUM"]?.toString() ?? "",
    );
  }
}
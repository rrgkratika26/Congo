class ManualPlanningModel {
  final int sr;
  final int orderNo;
  final String bomNo;
  final String customerName;
  final String poNum;
  final String fabricCode;
  final double requiredMtr;
  final double requiredKg;
  final double extraMtr;
  final double extraKg;
  final double actualRequiredMtr;
  final double actualRequiredKg;
  final String createDate;
  final String forwardBy;

  ManualPlanningModel({
    required this.sr,
    required this.orderNo,
    required this.bomNo,
    required this.customerName,
    required this.poNum,
    required this.fabricCode,
    required this.requiredMtr,
    required this.requiredKg,
    required this.extraMtr,
    required this.extraKg,
    required this.actualRequiredMtr,
    required this.actualRequiredKg,
    required this.createDate,
    required this.forwardBy,
  });

  factory ManualPlanningModel.fromJson(Map<String, dynamic> json) {
    return ManualPlanningModel(
      sr: json["sr"] ?? 0,
      orderNo: json["orderNo"] ?? 0,
      bomNo: json["boM_NO"] ?? "",
      customerName: json["customeR_NAME"] ?? "",
      poNum: json["pO_NUM"] ?? "",
      fabricCode: json["fabriC_CODE"] ?? "",
      requiredMtr: double.tryParse(json["requireD_MTR"].toString()) ?? 0,
      requiredKg: double.tryParse(json["requireD_KG"].toString()) ?? 0,
      extraMtr: double.tryParse(json["extrA_MTR"].toString()) ?? 0,
      extraKg: double.tryParse(json["extrA_KG"].toString()) ?? 0,
      actualRequiredMtr:
      double.tryParse(json["actuaL_REQUIRED_MTR"].toString()) ?? 0,
      actualRequiredKg:
      double.tryParse(json["actuaL_REQUIRED_KG"].toString()) ?? 0,
      createDate: json["createDate"] ?? "",
      forwardBy: json["forward_By"] ?? "",
    );
  }
}
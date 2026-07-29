class WebbingOutDetailsModel {
  final List<WebbingOutItem> items;

  WebbingOutDetailsModel({
    required this.items,
  });

  factory WebbingOutDetailsModel.fromJson(List<dynamic> json) {
    return WebbingOutDetailsModel(
      items: json.map((e) => WebbingOutItem.fromJson(e)).toList(),
    );
  }
}

class WebbingOutItem {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;
  final double rollWeight;
  final double rollLength;
  final String supervisorName;
  final String operatorName;
  final DateTime date;
  final String time;
  final String weekNo;
  final String partyName;
  final String workOrderNo;
  final String orderType;
  final double requiredQuantityKg;
  final double requiredQuantityMtr;
  final String machineNo;
  final String machineType;
  final String mesh;
  final String beltType;
  final String beltConstruction;
  final String color;
  final String beltWidth;
  final String beltGSM;
  final String materialType;
  final String colorIdentification;
  final String department;
  final String mash;
  final String loomOperator1;
  final String loomOperator2;
  final String remark;
  final String hold;
  final String holdRemark;
  final String location;

  WebbingOutItem({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.fabricCode,
    required this.rollWeight,
    required this.rollLength,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.weekNo,
    required this.partyName,
    required this.workOrderNo,
    required this.orderType,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.machineNo,
    required this.machineType,
    required this.mesh,
    required this.beltType,
    required this.beltConstruction,
    required this.color,
    required this.beltWidth,
    required this.beltGSM,
    required this.materialType,
    required this.colorIdentification,
    required this.department,
    required this.mash,
    required this.loomOperator1,
    required this.loomOperator2,
    required this.remark,
    required this.hold,
    required this.holdRemark,
    required this.location,
  });

  factory WebbingOutItem.fromJson(Map<String, dynamic> json) {
    return WebbingOutItem(
      srNo: json["srNo"] ?? 0,
      rollCode: json["rollCode"] ?? "",
      barcode: json["barcode"] ?? "",
      lotNo: json["lotNo"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
      rollWeight: (json["rollWeight"] ?? 0).toDouble(),
      rollLength: (json["rollLength"] ?? 0).toDouble(),
      supervisorName: json["supervisorName"] ?? "",
      operatorName: json["operatorName"] ?? "",
      date: DateTime.tryParse(json["date"] ?? "") ?? DateTime.now(),
      time: json["time"] ?? "",
      weekNo: json["weekNo"] ?? "",
      partyName: json["partyName"] ?? "",
      workOrderNo: json["workOrderNo"] ?? "",
      orderType: json["orderType"] ?? "",
      requiredQuantityKg:
      (json["requiredQuantityKg"] ?? 0).toDouble(),
      requiredQuantityMtr:
      (json["requiredQuantityMtr"] ?? 0).toDouble(),
      machineNo: json["machineNo"] ?? "",
      machineType: json["machineType"] ?? "",
      mesh: json["mesh"] ?? "",
      beltType: json["beltType"] ?? "",
      beltConstruction: json["beltConstruction"] ?? "",
      color: json["color"] ?? "",
      beltWidth: json["beltWidth"] ?? "",
      beltGSM: json["beltGSM"] ?? "",
      materialType: json["materialType"] ?? "",
      colorIdentification: json["colorIdentification"] ?? "",
      department: json["department"] ?? "",
      mash: json["mash"] ?? "",
      loomOperator1: json["loomOperator1"] ?? "",
      loomOperator2: json["loomOperator2"] ?? "",
      remark: json["remark"] ?? "",
      hold: json["hold"] ?? "",
      holdRemark: json["holdRemark"] ?? "",
      location: json["location"] ?? "",
    );
  }
}
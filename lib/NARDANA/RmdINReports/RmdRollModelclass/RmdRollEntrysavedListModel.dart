class RmdRollEntrySavedListModel {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String supervisorName;
  final String operatorName;
  final DateTime? date;
  final String time;
  final String weekNo;
  final String partyName;
  final String workOrderNo;
  final String orderType;
  final String requiredQuantityKg;
  final String requiredQuantityMtr;
  final String loomNo;
  final String loomType;
  final String mesh;
  final String fabricType;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutType;
  final String specialIdentification;
  final String rollWeight;
  final String rollLength;
  final String remark;
  final String department;
  final String fabricCode;
  final String loomOperator1;
  final String loomOperator2;
  final String location;
  final String component;

  RmdRollEntrySavedListModel({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.supervisorName,
    required this.operatorName,
    this.date,
    required this.time,
    required this.weekNo,
    required this.partyName,
    required this.workOrderNo,
    required this.orderType,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.loomNo,
    required this.loomType,
    required this.mesh,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutType,
    required this.specialIdentification,
    required this.rollWeight,
    required this.rollLength,
    required this.remark,
    required this.department,
    required this.fabricCode,
    required this.loomOperator1,
    required this.loomOperator2,
    required this.location,
    required this.component,
  });

  factory RmdRollEntrySavedListModel.fromJson(Map<String, dynamic> json) {
    return RmdRollEntrySavedListModel(
      srNo: json["srNo"] ?? 0,
      rollCode: json["rollCode"] ?? "",
      barcode: json["barcode"] ?? "",
      supervisorName: json["supervisorName"] ?? "",
      operatorName: json["operatorName"] ?? "",
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      time: json["time"] ?? "",
      weekNo: json["weekNo"] ?? "",
      partyName: json["partyName"] ?? "",
      workOrderNo: json["workOrderNo"] ?? "",
      orderType: json["orderType"] ?? "",
      requiredQuantityKg: json["requiredQuantityKg"] ?? "",
      requiredQuantityMtr: json["requiredQuantityMtr"] ?? "",
      loomNo: json["loomNo"] ?? "",
      loomType: json["loomType"] ?? "",
      mesh: json["mesh"] ?? "",
      fabricType: json["fabricType"] ?? "",
      fabricConstruction: json["fabricConstruction"] ?? "",
      color: json["color"] ?? "",
      fabricWidth: json["fabricWidth"] ?? "",
      fabricGsm: json["fabricGsm"] ?? "",
      laminationType: json["laminationType"] ?? "",
      cutType: json["cutType"] ?? "",
      specialIdentification: json["specialIdentification"] ?? "",
      rollWeight: json["rollWeight"] ?? "",
      rollLength: json["rollLength"] ?? "",
      remark: json["remark"] ?? "",
      department: json["department"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
      loomOperator1: json["loomOperator1"] ?? "",
      loomOperator2: json["loomOperator2"] ?? "",
      location: json["location"] ?? "",
      component: json["component"] ?? "",
    );
  }
}
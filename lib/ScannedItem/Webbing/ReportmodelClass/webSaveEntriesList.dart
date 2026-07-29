class WebbingSavedEntryResponse {
  final bool success;
  final List<WebbingSavedEntry> data;

  WebbingSavedEntryResponse({
    required this.success,
    required this.data,
  });

  factory WebbingSavedEntryResponse.fromJson(Map<String, dynamic> json) {
    return WebbingSavedEntryResponse(
      success: json["success"] ?? false,
      data: (json["data"] as List? ?? [])
          .map((e) => WebbingSavedEntry.fromJson(e))
          .toList(),
    );
  }
}

class WebbingSavedEntry {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String orderNo;
  final String partyName;
  final String workOrderNo;
  final String orderType;
  final String requiredQuantityKg;
  final String requiredQuantityMtr;
  final String machineNo;
  final String machineType;
  final String beltType;
  final String color;
  final String beltWidth;
  final String beltGsm;
  final String materialType;
  final String rollWeight;
  final String remark;
  final String fabricCode;
  final String loomOperator1;
  final String loomOperator2;

  WebbingSavedEntry({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.orderNo,
    required this.partyName,
    required this.workOrderNo,
    required this.orderType,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.machineNo,
    required this.machineType,
    required this.beltType,
    required this.color,
    required this.beltWidth,
    required this.beltGsm,
    required this.materialType,
    required this.rollWeight,
    required this.remark,
    required this.fabricCode,
    required this.loomOperator1,
    required this.loomOperator2,
  });

  factory WebbingSavedEntry.fromJson(Map<String, dynamic> json) {
    return WebbingSavedEntry(
      srNo: json["srNo"] ?? 0,
      rollCode: json["rollCode"] ?? "",
      barcode: json["barcode"] ?? "",
      lotNo: json["lotNo"] ?? "",
      supervisorName: json["supervisorName"] ?? "",
      operatorName: json["operatorName"] ?? "",
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      orderNo: json["orderNo"] ?? "",
      partyName: json["partyName"] ?? "",
      workOrderNo: json["workOrderNo"] ?? "",
      orderType: json["orderType"] ?? "",
      requiredQuantityKg: json["requiredQuantityKg"] ?? "",
      requiredQuantityMtr: json["requiredQuantityMtr"] ?? "",
      machineNo: json["machineNo"] ?? "",
      machineType: json["machineType"] ?? "",
      beltType: json["beltType"] ?? "",
      color: json["color"] ?? "",
      beltWidth: json["beltWidth"] ?? "",
      beltGsm: json["beltGsm"] ?? "",
      materialType: json["materialType"] ?? "",
      rollWeight: json["rollWeight"] ?? "",
      remark: json["remark"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
      loomOperator1: json["loomOperator1"] ?? "",
      loomOperator2: json["loomOperator2"] ?? "",
    );
  }
}
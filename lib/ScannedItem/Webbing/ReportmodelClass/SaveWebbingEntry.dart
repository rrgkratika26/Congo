class WebbingSaveRequest {
  final String machineNo;
  final String shift;
  final String supervisor;
  final String operator1;
  final String operator2;
  final String generateCode;
  final String beltWidth;
  final String beltColor;
  final String idCode;
  final String beltGrm;
  final String materialType;
  final String remark;
  final String partyName;
  final String poNo;
  final String bomNo;
  final String beltType;
  final String newType;
  final String articleNo;
  final String batchNo;
  final String plant;
  final String lotNo;
  final double rollWeight;

  WebbingSaveRequest({
    required this.machineNo,
    required this.shift,
    required this.supervisor,
    required this.operator1,
    required this.operator2,
    required this.generateCode,
    required this.beltWidth,
    required this.beltColor,
    required this.idCode,
    required this.beltGrm,
    required this.materialType,
    required this.remark,
    required this.partyName,
    required this.poNo,
    required this.bomNo,
    required this.beltType,
    required this.newType,
    required this.articleNo,
    required this.batchNo,
    required this.plant,
    required this.lotNo,
    required this.rollWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      "machineNo": machineNo,
      "shift": shift,
      "supervisor": supervisor,
      "operator1": operator1,
      "generateCode": generateCode,
      "beltWidth": beltWidth,
      "beltColor": beltColor,
      "idCode": idCode,
      "beltGrm": beltGrm,
      "materialType": materialType,
      "remark": remark,
      "partyName": partyName,
      "poNo": poNo,
      "bomNo": bomNo,
      "beltType": beltType,
      "newType": newType,
      "operator2": operator2,
      "articleNo": articleNo,
      "batchNo": batchNo,
      "plant": plant,
      "lotNo": lotNo,
      "rollWeight": rollWeight,
    };
  }
}

class WebbingSaveResponse {
  final bool success;
  final String message;

  WebbingSaveResponse({
    required this.success,
    required this.message,
  });

  factory WebbingSaveResponse.fromJson(Map<String, dynamic> json) {
    return WebbingSaveResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}
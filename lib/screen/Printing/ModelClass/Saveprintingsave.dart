class SaveprintingModel {
  final String rollId;
  final int srNo;
  final String barcode;
  final String machineType;
  final String generateCode;
  final String supervisorName;
  final String operatorName;
  // final String specialId;
  final String fabricTypeUse;
  final String fabricWidth;
  final String color;
  final String mesh;
  final String loomType;
  final String laminationType;
  final String fabricGsm;
  final String cutType;
  final String sid;
  final String fabricBaffleType;
  final String rollWeightKg;
  final String rollLengthMtr;
  final String grossWeight;
  final String avgWeight;
  final String tareWeight;
  final String partyName;
  final String poNumber;
  final String articleNumber;
  final String loomNo;
  final String avgweightmtrgm;
  final String opname;
  final String bomno;
  final String batchNo;
  final String shift;
  final String unit;

  SaveprintingModel({
    required this.rollId,
    required this.srNo,
    required this.barcode,
    required this.machineType,
    required this.generateCode,
    required this.supervisorName,
    required this.operatorName,
    // required this.specialId,
    required this.fabricTypeUse,
    required this.fabricWidth,
    required this.color,
    required this.mesh,
    required this.loomType,
    required this.laminationType,
    required this.fabricGsm,
    required this.cutType,
    required this.sid,
    required this.fabricBaffleType,
    required this.rollWeightKg,
    required this.rollLengthMtr,
    required this.grossWeight,
    required this.avgWeight,
    required this.tareWeight,
    required this.partyName,
    required this.poNumber,
    required this.articleNumber,
    required this.loomNo,
    required this.avgweightmtrgm,
    required this.opname,
    required this.bomno,
    required this.batchNo,
    required this.shift,
    required this.unit,
  });

  factory SaveprintingModel.fromJson(Map<String, dynamic> json) {
    return SaveprintingModel(
      rollId: json['rollId'] ?? '',
      srNo: json['srNo'] ?? 0,
      barcode: json['barcode'] ?? '',
      machineType: json['machineType'] ?? '',
      generateCode: json['generateCode'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      operatorName: json['operatorName'] ?? '',
      // specialId: json['specialId'] ?? '',
      fabricTypeUse: json['fabricTypeUse'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      color: json['color'] ?? '',
      mesh: json['mesh'] ?? '',
      loomType: json['loomType'] ?? '',
      laminationType: json['laminationType'] ?? '',
      fabricGsm: json['fabricGsm'] ?? '',
      cutType: json['cutType'] ?? '',
      sid: json['sid'] ?? '',
      fabricBaffleType: json['fabricBaffleType'] ?? '',
      rollWeightKg: json['rollWeightKg'] ?? '',
      rollLengthMtr: json['rollLengthMtr'] ?? '',
      grossWeight: json['grossWeight'] ?? '',
      avgWeight: json['avgWeight'] ?? '',
      tareWeight: json['tareWeight'] ?? '',
      partyName: json['partyName'] ?? '',
      poNumber: json['poNumber'] ?? '',
      articleNumber: json['articleNumber'] ?? '',
      loomNo: json['loomNo'] ?? '',
      avgweightmtrgm: json['avgweightmtrgm'] ?? '',
      opname: json['opname'] ?? '',
      bomno: json['bomno'] ?? '',
      batchNo: json['batchNo'] ?? '',
      shift: json['shift'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rollId': rollId,
      'srNo': srNo,
      'barcode': barcode,
      'machineType': machineType,
      'generateCode': generateCode,
      'supervisorName': supervisorName,
      'operatorName': operatorName,
      // 'specialId': specialId,
      'fabricTypeUse': fabricTypeUse,
      'fabricWidth': fabricWidth,
      'color': color,
      'mesh': mesh,
      'loomType': loomType,
      'laminationType': laminationType,
      'fabricGsm': fabricGsm,
      'cutType': cutType,
      'sid': sid,
      'fabricBaffleType': fabricBaffleType,
      'rollWeightKg': rollWeightKg,
      'rollLengthMtr': rollLengthMtr,
      'grossWeight': grossWeight,
      'avgWeight': avgWeight,
      'tareWeight': tareWeight,
      'partyName': partyName,
      'poNumber': poNumber,
      'articleNumber': articleNumber,
      'loomNo': loomNo,
      'avgweightmtrgm': avgweightmtrgm,
      'opname': opname,
      'bomno': bomno,
      'batchNo': batchNo,
      'shift': shift,
      'unit': unit,
    };
  }
}

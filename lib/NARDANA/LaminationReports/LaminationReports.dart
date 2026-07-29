class LaminationReportModel {
  final String id;
  final String rollCode;
  final String barcode;
  final String bomNo;

  final String batchNo;
  final String loomType;
  final String loomNo;
  final String fabricCode;
  final double grossWeight;
  final double netWeight;
  final double rollLength;
  final double avgWeight;
  final String operatorName;
  final DateTime date;
  final String time;
  final String loomOperator1;
  final double gsm;
  final String supervisorName;
  final String partyName;
  final String workOrderNo;
  final String contNo;
  final double requiredQuantity;
  final double requiredQuantityMtr;
  final double tareWeight;
  final String department;
  final String issueToDept;
  final String status;
  final String entryIn;
  final String entryOut;
  final String mash;
  final String fabricType;

  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final double fabricGsm;
  final String laminationType;
  final String cutSlipType;
  final String specialIdentification;

  LaminationReportModel({
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.batchNo,
    required this.loomType,
    required this.loomNo,
    required this.fabricCode,
    required this.grossWeight,
    required this.netWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.loomOperator1,
    required this.gsm,
    required this.supervisorName,
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.requiredQuantity,
    required this.requiredQuantityMtr,
    required this.tareWeight,
    required this.department,
    required this.issueToDept,
    required this.status,
    required this.entryIn,
    required this.entryOut,
    required this.mash,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutSlipType,
    required this.specialIdentification, required this.bomNo,
  });

  factory LaminationReportModel.fromJson(Map<String, dynamic> json) {
    return LaminationReportModel(
      id: json['id']?.toString() ?? '',
      rollCode: json['rollCode']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      batchNo: json['batchNo']?.toString() ?? '',
      loomType: json['loomType']?.toString() ?? '',
      loomNo: json['loomNo']?.toString() ?? '',
      fabricCode: json['fabricCode']?.toString() ?? '',
      grossWeight: double.tryParse(json['grossWeight']?.toString() ?? '0') ?? 0.0,
      netWeight: double.tryParse(json['netWeight']?.toString() ?? '0') ?? 0.0,
      rollLength: double.tryParse(json['rollLength']?.toString() ?? '0') ?? 0.0,
      avgWeight: double.tryParse(json['avgWeight']?.toString() ?? '0') ?? 0.0,
      operatorName: json['operatorName']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: json['time']?.toString() ?? '',
      loomOperator1: json['loomOperator1']?.toString() ?? '',
      gsm: double.tryParse(json['gsm']?.toString() ?? '0') ?? 0.0,
      supervisorName: json['supervisorName']?.toString() ?? '',
      partyName: json['partyName']?.toString() ?? '',
      workOrderNo: json['workOrderNo']?.toString() ?? '',
      contNo: json['contNo']?.toString() ?? '',
      requiredQuantity: double.tryParse(json['requiredQuantity']?.toString() ?? '0') ?? 0.0,
      requiredQuantityMtr: double.tryParse(json['requiredQuantityMtr']?.toString() ?? '0') ?? 0.0,
      tareWeight: double.tryParse(json['tareWeight']?.toString() ?? '0') ?? 0.0,
      department: json['department']?.toString() ?? '',
      issueToDept: json['issueToDept']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      entryIn: json['entryIn']?.toString() ?? '',
      entryOut: json['entryOut']?.toString() ?? '',
      mash: json['mash']?.toString() ?? '',
      fabricType: json['fabricType']?.toString() ?? '',
      fabricConstruction: json['fabricConstruction']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      fabricWidth: json['fabricWidth']?.toString() ?? '',
      fabricGsm: double.tryParse(json['fabricGsm']?.toString() ?? '0') ?? 0.0,
      laminationType: json['laminationType']?.toString() ?? '',
      cutSlipType: json['cutSlipType']?.toString() ?? '',
      specialIdentification: json['specialIdentification']?.toString() ?? '',
      bomNo: json['boM_NO']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rollCode': rollCode,
      'barcode': barcode,
      'bomNo': bomNo,
      'batchNo': batchNo,
      'loomType': loomType,
      'loomNo': loomNo,
      'fabricCode': fabricCode,
      'grossWeight': grossWeight,
      'netWeight': netWeight,
      'rollLength': rollLength,
      'avgWeight': avgWeight,
      'operatorName': operatorName,
      'date': date.toIso8601String(),
      'time': time,
      'loomOperator1': loomOperator1,
      'gsm': gsm,
      'supervisorName': supervisorName,
      'partyName': partyName,
      'workOrderNo': workOrderNo,
      'contNo': contNo,
      'requiredQuantity': requiredQuantity,
      'requiredQuantityMtr': requiredQuantityMtr,
      'tareWeight': tareWeight,
      'department': department,
      'issueToDept': issueToDept,
      'status': status,
      'entryIn': entryIn,
      'entryOut': entryOut,
      'mash': mash,
      'fabricType': fabricType,
      'fabricConstruction': fabricConstruction,
      'color': color,
      'fabricWidth': fabricWidth,
      'fabricGsm': fabricGsm,
      'laminationType': laminationType,
      'cutSlipType': cutSlipType,
      'specialIdentification': specialIdentification,
    };
  }
}
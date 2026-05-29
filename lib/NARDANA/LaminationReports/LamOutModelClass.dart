class LamNardanaOutModel {
  final int id;
  final String rollCode;
  final String barcode;
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

  LamNardanaOutModel({
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
    required this.specialIdentification,
  });

  factory LamNardanaOutModel.fromJson(Map<String, dynamic> json) {
    double d(val) => double.tryParse(val.toString()) ?? 0;

    return LamNardanaOutModel(
      id: json["id"] ?? 0,
      rollCode: json["rollCode"] ?? '',
      barcode: json["barcode"] ?? '',
      batchNo: json["batchNo"] ?? '',
      loomType: json["loomType"] ?? '',
      loomNo: json["loomNo"] ?? '',
      fabricCode: json["fabricCode"] ?? '',
      grossWeight: d(json["grossWeight"]),
      netWeight: d(json["netWeight"]),
      rollLength: d(json["rollLength"]),
      avgWeight: d(json["avgWeight"]),
      operatorName: json["operatorName"] ?? '',
      date: DateTime.tryParse(json["date"] ?? '') ?? DateTime.now(),
      time: json["time"] ?? '',
      gsm: d(json["gsm"]),
      supervisorName: json["supervisorName"] ?? '',
      partyName: json["partyName"] ?? '',
      workOrderNo: json["workOrderNo"] ?? '',
      contNo: json["contNo"] ?? '',
      requiredQuantity: d(json["requiredQty"]),
      requiredQuantityMtr: d(json["requiredQtyMtr"]),
      tareWeight: d(json["tareWeight"]),
      department: json["department"] ?? '',
      issueToDept: json["issueToDept"] ?? '',
      status: json["status"] ?? '',
      entryIn: json["entryIn"] ?? '',
      entryOut: json["entryOut"] ?? '',
      mash: json["mash"] ?? '',
      fabricType: json["fabricType"] ?? '',
      fabricConstruction: json["fabricConstruction"] ?? '',
      color: json["color"] ?? '',
      fabricWidth: json["fabricWidth"] ?? '',
      fabricGsm: d(json["fabricGsm"]),
      laminationType: json["laminationType"] ?? '',
      cutSlipType: json["cutSlipType"] ?? '',
      specialIdentification: json["specialIdentification"] ?? '',
    );
  }
}
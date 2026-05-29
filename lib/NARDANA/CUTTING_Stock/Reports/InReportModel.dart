class CuttingInReportModel {
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
  final String loomOperator1;
  final double gsmMtrGm;
  final String supervisorName;
  final String partyName;
  final String workOrderNo;
  final String contNo;
  final double requiredQuantityKg;
  final double requiredQuantityMtr;
  final String tareWeight;
  final String department;
  final String issueToDept;
  final String status;
  final String entryIn;
  final String entryOut;
  final String mash;
  final String fabricTypeFabricUse;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutSlipType;
  final String specialIdentification;

  CuttingInReportModel({
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
    required this.gsmMtrGm,
    required this.supervisorName,
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.tareWeight,
    required this.department,
    required this.issueToDept,
    required this.status,
    required this.entryIn,
    required this.entryOut,
    required this.mash,
    required this.fabricTypeFabricUse,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutSlipType,
    required this.specialIdentification,
  });

  factory CuttingInReportModel.fromJson(Map<String, dynamic> json) {
    return CuttingInReportModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      rollCode: json['rollCode'] ?? '',
      barcode: json['barcode'] ?? '',
      batchNo: json['batchNo'] ?? '',
      loomType: json['loomType'] ?? '',
      loomNo: json['loomNo'] ?? '',
      fabricCode: json['fabricCode'] ?? '',

      grossWeight: double.tryParse(json['grossWeight'].toString()) ?? 0.0,

      netWeight: double.tryParse(json['netWeight'].toString()) ?? 0.0,

      rollLength: double.tryParse(json['rollLength'].toString()) ?? 0.0,

      avgWeight: double.tryParse(json['avgWeight'].toString()) ?? 0.0,

      operatorName: json['operatorName'] ?? '',

      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),

      time: json['time'] ?? '',

      loomOperator1: json['loomOperator1'] ?? '',

      gsmMtrGm: double.tryParse(json['gsmMtrGm'].toString()) ?? 0.0,

      supervisorName: json['supervisorName'] ?? '',
      partyName: json['partyName'] ?? '',
      workOrderNo: json['workOrderNo'] ?? '',
      contNo: json['contNo'] ?? '',

      requiredQuantityKg:
          double.tryParse(json['requiredQuantityKg'].toString()) ?? 0.0,

      requiredQuantityMtr:
          double.tryParse(json['requiredQuantityMtr'].toString()) ?? 0.0,

      tareWeight: json['tareWeight'] ?? '',
      department: json['department'] ?? '',
      issueToDept: json['issueToDept'] ?? '',
      status: json['status'] ?? '',
      entryIn: json['entryIn'] ?? '',
      entryOut: json['entryOut'] ?? '',
      mash: json['mash'] ?? '',
      fabricTypeFabricUse: json['fabricTypeFabricUse'] ?? '',
      fabricConstruction: json['fabricConstruction'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      fabricGsm: json['fabricGsm'] ?? '',
      laminationType: json['laminationType'] ?? '',
      cutSlipType: json['cutSlipType'] ?? '',
      specialIdentification: json['specialIdentification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "rollCode": rollCode,
      "barcode": barcode,
      "batchNo": batchNo,
      "loomType": loomType,
      "loomNo": loomNo,
      "fabricCode": fabricCode,
      "grossWeight": grossWeight,
      "netWeight": netWeight,
      "rollLength": rollLength,
      "avgWeight": avgWeight,
      "operatorName": operatorName,
      "date": date.toIso8601String(),
      "time": time,
      "loomOperator1": loomOperator1,
      "gsmMtrGm": gsmMtrGm,
      "supervisorName": supervisorName,
      "partyName": partyName,
      "workOrderNo": workOrderNo,
      "contNo": contNo,
      "requiredQuantityKg": requiredQuantityKg,
      "requiredQuantityMtr": requiredQuantityMtr,
      "tareWeight": tareWeight,
      "department": department,
      "issueToDept": issueToDept,
      "status": status,
      "entryIn": entryIn,
      "entryOut": entryOut,
      "mash": mash,
      "fabricTypeFabricUse": fabricTypeFabricUse,
      "fabricConstruction": fabricConstruction,
      "color": color,
      "fabricWidth": fabricWidth,
      "fabricGsm": fabricGsm,
      "laminationType": laminationType,
      "cutSlipType": cutSlipType,
      "specialIdentification": specialIdentification,
    };
  }
}

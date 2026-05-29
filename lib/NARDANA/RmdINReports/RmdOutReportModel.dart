class RmdOutReport {
  final int srNo;
  final int rollCode;

  final String barcode;
  final String batchNo;

  final String loomType;
  final String loomNo;

  final String fabricCode;
  final String fabricWidth;
  final String fabricGsm;
  final String color;

  final double grossWeight;
  final double netWeight;
  final double tareWeight;

  final double rollLength;
  final double avgWeight;

  final String operatorName;
  final String loomOperator;

  final DateTime date;
  final String time;

  final String supervisorName;
  final String rmdSupervisor;

  final String partyName;
  final String workOrderNo;

  final int contNo;

  final double reqQtyKg;
  final double reqQtyMtr;

  final String department;
  final String issueToDept;

  final String status;
  final String entryIn;
  final String entryOut;

  final String mash;
  final String laminationType;

  final String fabricType;
  final String fabricConstruction;
  final String cutType;
  final String specialId;

  RmdOutReport({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.batchNo,
    required this.loomType,
    required this.loomNo,
    required this.fabricCode,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.color,
    required this.grossWeight,
    required this.netWeight,
    required this.tareWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.operatorName,
    required this.loomOperator,
    required this.date,
    required this.time,
    required this.supervisorName,
    required this.rmdSupervisor,
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.reqQtyKg,
    required this.reqQtyMtr,
    required this.department,
    required this.issueToDept,
    required this.status,
    required this.entryIn,
    required this.entryOut,
    required this.mash,
    required this.laminationType,
    required this.fabricType,
    required this.fabricConstruction,
    required this.cutType,
    required this.specialId,
  });

  factory RmdOutReport.fromJson(Map<String, dynamic> json) {

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v.toString().trim().isEmpty) return 0.0;
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v.toString().trim().isEmpty) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    return RmdOutReport(
      srNo: _toInt(json["Sr. No."]),
      rollCode: _toInt(json["ROLL_CODE"]),

      barcode: json["BARCODE"] ?? '',
      batchNo: json["BATCH_NO"] ?? '',

      loomType: json["LOOM_TYPE"] ?? '',
      loomNo: json["LOOM_NO"] ?? '',

      fabricCode: json["FABRIC_CODE"] ?? '',
      fabricWidth: json["FABRIC_WIDTH"] ?? '',
      fabricGsm: json["FABRIC_GSM"] ?? '',
      color: json["COLOR"] ?? '',

      grossWeight: _toDouble(json["GROSS_WEIGHT (Kg)"]),
      netWeight: _toDouble(json["NET_WEIGHT (Kg)"]),
      tareWeight: _toDouble(json["TARE_WEIGHT (Kg)"]),

      rollLength: _toDouble(json["ROLL_LENGTH (Mtr)"]),
      avgWeight: _toDouble(json["AVG_WEIGHT (Gm)"]),

      operatorName: json["OPERATOR_NAME"] ?? '',
      loomOperator: json["LOOMOPARETOR1"] ?? '',

      date: DateTime.tryParse(json["DATE"] ?? '') ?? DateTime.now(),
      time: json["TIME"] ?? '',

      supervisorName: json["SUPERVISOR_NAME"] ?? '',
      rmdSupervisor: json["RMD_SUPERVISOR1"] ?? '',

      partyName: json["PARTYNAME"] ?? '',
      workOrderNo: json["WORK_ORDER_NO"] ?? '',

      contNo: _toInt(json["CONT._NO."]),

      reqQtyKg: _toDouble(json["REQUIRED_QUANTITY (Kg)"]),
      reqQtyMtr: _toDouble(json["REQUIRED_QUANTITY_MTR"]),

      department: json["DEPARTMENT"] ?? '',
      issueToDept: json["ISSUE TO DEPT"] ?? '',

      status: json["STATUS"] ?? '',
      entryIn: json["ENTRYIN"] ?? '',
      entryOut: json["ENTRYOUT"] ?? '',

      mash: json["MASH"] ?? '',
      laminationType: json["LAMINATION_TYPE"] ?? '',

      fabricType: json["FABRIC_TYPE_FABRIC_USE"] ?? '',
      fabricConstruction: json["FABRIC_CONSTRUCTION"] ?? '',
      cutType: json["CUT_SLIP_TYPE"] ?? '',
      specialId: json["SPECIAL_IDENTIFICATION"] ?? '',
    );
  }
}
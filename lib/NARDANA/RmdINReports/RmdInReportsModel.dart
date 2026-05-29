class RmdInReport {
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
  final String partyName;
  final String workOrderNo;
  final int contNo;

  final String department;
  final String issueToDept;

  final String status;
  final String entryIn;
  final String entryOut;

  final String mash;
  final String fabTypeuse;
  final String laminationType;

  final String fromRoll;

  final double reqQtKg;
  final double reqQtMtr;

  final String spId;
  final String fabType;
  final String fabTypeBaffle;
  final String cutType;

  RmdInReport({
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
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.department,
    required this.issueToDept,
    required this.status,
    required this.entryIn,
    required this.entryOut,
    required this.mash,
    required this.fabTypeuse,
    required this.laminationType,
    required this.fromRoll,
    required this.reqQtKg,
    required this.reqQtMtr,
    required this.spId,
    required this.fabType,
    required this.fabTypeBaffle,
    required this.cutType,
  });

  factory RmdInReport.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is int) return v.toDouble();
      if (v is double) return v;
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return RmdInReport(
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

      // grossWeight: _toDouble(json["GROSS_WEIGHT (Kg)"]),
      // netWeight: _toDouble(json["NET_WEIGHT (Kg)"]),
      // tareWeight: _toDouble(json["TARE_WEIGHT (Kg)"]),

      // rollLength: _toDouble(json["ROLL_LENGTH (Mtr)"]),
      // avgWeight: _toDouble(json["AVG_WEIGHT (Gm)"]),

      operatorName: json["OPERATOR_NAME"] ?? '',
      loomOperator: json["LOOMOPARETOR1"] ?? '',

      date: DateTime.tryParse(json["DATE"] ?? '') ?? DateTime.now(),
      time: json["TIME"] ?? '',

      supervisorName: json["SUPERVISOR_NAME"] ?? '',
      partyName: json["PARTYNAME"] ?? '',
      workOrderNo: json["WORK_ORDER_NO"] ?? '',
      contNo: _toInt(json["CONT._NO."]),

      department: json["DEPARTMENT"] ?? '',
      issueToDept: json["ISSUE TO DEPT"] ?? '',

      status: json["STATUS"] ?? '',
      entryIn: json["ENTRYIN"] ?? '',
      entryOut: json["ENTRYOUT"] ?? '',

      mash: json["MASH"] ?? '',
      fabTypeuse:json["FABRIC_TYPE_FABRIC_USE"] ?? '',
      laminationType: json["LAMINATION_TYPE"] ?? '',

      fromRoll: json["From_ROLL"] ?? '',

      reqQtKg: _toDouble(json["REQUIRED_QUANTITY (Kg)"]),
      reqQtMtr: _toDouble(json["REQUIRED_QUANTITY_MTR"]),
      tareWeight: _toDouble(json["TARE_WEIGHT (Kg)"]),
      grossWeight: _toDouble(json["GROSS_WEIGHT (Kg)"]),
      netWeight: _toDouble(json["NET_WEIGHT (Kg)"]),
      rollLength: _toDouble(json["ROLL_LENGTH (Mtr)"]),
      avgWeight: _toDouble(json["AVG_WEIGHT (Gm)"]),

      spId: json["SPECIAL_IDENTIFICATION"] ?? '',
      fabType: json["FABRIC_TYPE_FABRIC_USE"] ?? '',
      fabTypeBaffle: json["FABRIC_CONSTRUCTION"] ?? '',
      cutType: json["CUT_SLIP_TYPE"] ?? '',
    );
  }
}
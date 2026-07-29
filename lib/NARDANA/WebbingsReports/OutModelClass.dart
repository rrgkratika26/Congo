class WebOutReportModel {
  final int id;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;

  final double rollWeight;
  final double rollLength;

  final String supervisorName;
  final String operatorName;

  final String date;
  final String time;

  final String weekNo;
  final String partyName;
  final String workOrderNo;
  final String orderType;

  final double requiredQty;
  final double requiredQtyMtr;

  final String machineNo;
  final String machineType;

  final String color;
  final String beltWidth;
  final String beltType;
  final String mesh;
  final String materialtype;

  final String loomOp1;
  final String loomOp2;
  final String hold;

  final String remark;








  final String gsm;

  final String loom1;
  final String loom2;

  final String department;
  final String status;
  final String location;

  WebOutReportModel({
    required this.id,
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
    required this.requiredQty,
    required this.requiredQtyMtr,
    required this.machineNo,
    required this.machineType,
    required this.color,
    required this.beltWidth,
    required this.gsm,
    required this.loom1,
    required this.loom2,
    required this.department,
    required this.status,
    required this.location, required this.beltType,
    required this.mesh,
    required this.materialtype,
    required this.loomOp1,
    required this.loomOp2,
    required this.hold,
    required this.remark,
  });

  factory WebOutReportModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return WebOutReportModel(
      id: json['id'] ?? 0,

      rollCode: json['rolL_CODE'] ?? '',
      barcode: json['barcode'] ?? '',
      lotNo: json['loT_NO'] ?? '',
      fabricCode: json['fabriC_CODE'] ?? '',

      rollWeight: _toDouble(json['rolL_WEIGHT']),
      rollLength: _toDouble(json['rolL_LENGTH']),

      supervisorName: json['supervisoR_NAME'] ?? '',
      operatorName: json['operatoR_NAME'] ?? '',

      date: (json['date'] ?? '').toString().split('T').first,
      time: json['time'] ?? '',

      weekNo: json['weeK_NO'] ?? '',
      partyName: json['partyname'] ?? '',
      workOrderNo: json['worK_ORDER_NO'] ?? '',
      orderType: json['ordeR_TYPE'] ?? '',

      requiredQty: _toDouble(json['requireD_QTY']),
      requiredQtyMtr: _toDouble(json['requireD_QTY_MTR']),

      machineNo: json['machinE_NO'] ?? '',
      machineType: json['machinE_TYPE'] ?? '',

      color: json['color'] ?? '',
      beltWidth: json['belT_WIDTH'] ?? '',
      gsm: json['gsm'] ?? '',

      loom1: json['loomoparetoR1'] ?? '',
      loom2: json['loomoparetoR2'] ?? '',

      department: json['department'] ?? '',
      status: json['hold'] ?? '', // ACTIVE / HOLD
      location: json['location'] ?? '',
      beltType: json['belT_TYPE'] ?? '',
      mesh: json['mesh'] ?? '',
      materialtype: json['materiaL_TYPE'] ?? '',
      loomOp1: json['loomoparetoR1'] ?? '',
      loomOp2:json['loomoparetoR2'] ?? '',
      hold: json['hold'] ?? '',
      remark: json['remark'] ?? '',
    );
  }

  // Optional computed fields
  double get netWeight => rollWeight;
  double get quantity => rollLength;
}
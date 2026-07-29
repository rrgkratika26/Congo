class WebStockReportModel {
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
  final String requiredQty;
  final String requiredQtyMtr;
  final String machineNo;
  final String machineType;
  final String mesh;
  final String beltType;
  final String beltConstruction;
  final String color;
  final String beltWidth;
  final String gsm;
  final String materialType;
  final String colorIdentification;
  final String department;
  final String mash;
  final String loom1;
  final String loom2;
  final String remark;
  final String? hold;
  final String? holdRemark;
  final String location;

  WebStockReportModel({
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
    required this.mesh,
    required this.beltType,
    required this.beltConstruction,
    required this.color,
    required this.beltWidth,
    required this.gsm,
    required this.materialType,
    required this.colorIdentification,
    required this.department,
    required this.mash,
    required this.loom1,
    required this.loom2,
    required this.remark,
    this.hold,
    this.holdRemark,
    required this.location,
  });

  factory WebStockReportModel.fromJson(Map<String, dynamic> json) {
    return WebStockReportModel(
      id: json['id'] ?? 0,
      rollCode: json['rolL_CODE'] ?? '',
      barcode: json['barcode'] ?? '',
      lotNo: json['loT_NO'] ?? '',
      fabricCode: json['fabriC_CODE'] ?? '',
      rollWeight: (json['rolL_WEIGHT'] ?? 0).toDouble(),
      rollLength: (json['rolL_LENGTH'] ?? 0).toDouble(),
      supervisorName: json['supervisoR_NAME'] ?? '',
      operatorName: json['operatoR_NAME'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      weekNo: json['weeK_NO'] ?? '',
      partyName: json['partyname'] ?? '',
      workOrderNo: json['worK_ORDER_NO'] ?? '',
      orderType: json['ordeR_TYPE'] ?? '',
      requiredQty: json['requireD_QTY'] ?? '',
      requiredQtyMtr: json['requireD_QTY_MTR'] ?? '',
      machineNo: json['machinE_NO'] ?? '',
      machineType: json['machinE_TYPE'] ?? '',
      mesh: json['mesh'] ?? '',
      beltType: json['belT_TYPE'] ?? '',
      beltConstruction: json['belT_CONSTRUCTION'] ?? '',
      color: json['color'] ?? '',
      beltWidth: json['belT_WIDTH'] ?? '',
      gsm: json['gsm'] ?? '',
      materialType: json['materiaL_TYPE'] ?? '',
      colorIdentification: json['coloR_IDENTIFICATION'] ?? '',
      department: json['department'] ?? '',
      mash: json['mash'] ?? '',
      loom1: json['loomoparetoR1'] ?? '',
      loom2: json['loomoparetoR2'] ?? '',
      remark: json['remark'] ?? '',
      hold: json['hold']?.toString(),
      holdRemark: json['holD_REMARK']?.toString(),
      location: json['location'] ?? '',
    );
  }
}
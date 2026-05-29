class OpenQtyDetailsModel {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;
  final String mash;
  final String rollWeightKg;
  final String rollLengthMtr;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String weekNo;
  final String partyName;
  final String workOrderNo;
  final String orderType;
  final String requiredQtyKg;
  final String requiredQtyMtr;
  final String machineNo;
  final String machineType;
  final String mesh;
  final String beltType;
  final String beltConstruction;
  final String color;
  final String beltWidthCm;
  final String beltGsm;
  final String materialType;
  final String colorIdentification;
  final String department;
  final String loomOperator1;
  final String loomOperator2;
  final String remark;
  final String hold;
  final String holdRemark;
  final String location;

  OpenQtyDetailsModel({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.fabricCode,
    required this.rollWeightKg,
    required this.rollLengthMtr,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.weekNo,
    required this.partyName,
    required this.workOrderNo,
    required this.orderType,
    required this.requiredQtyKg,
    required this.requiredQtyMtr,
    required this.machineNo,
    required this.machineType,
    required this.mesh,
    required this.beltType,
    required this.beltConstruction,
    required this.color,
    required this.beltWidthCm,
    required this.beltGsm,
    required this.materialType,
    required this.colorIdentification,
    required this.department,
    required this.loomOperator1,
    required this.loomOperator2,
    required this.remark,
    required this.hold,
    required this.holdRemark,
    required this.location, required this.mash,
  });

  factory OpenQtyDetailsModel.fromJson(Map<String, dynamic> json) {
    return OpenQtyDetailsModel(
      srNo: json['srNo'] ?? 0,
      rollCode: json['rolL_CODE']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      lotNo: json['loT_NO']?.toString() ?? '',
      mash: json['mash']?.toString() ?? '',
      fabricCode: json['fabriC_CODE']?.toString() ?? '',
      rollWeightKg: json['rolL_WEIGHT_KG']?.toString() ?? '',
      rollLengthMtr: json['rolL_LENGTH_MTR']?.toString() ?? '',
      supervisorName: json['supervisoR_NAME']?.toString() ?? '',
      operatorName: json['operatoR_NAME']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      weekNo: json['weeK_NO']?.toString() ?? '',
      partyName: json['partyname']?.toString() ?? '',
      workOrderNo: json['worK_ORDER_NO']?.toString() ?? '',
      orderType: json['ordeR_TYPE']?.toString() ?? '',
      requiredQtyKg: json['requireD_QTY_KG']?.toString() ?? '',
      requiredQtyMtr: json['requireD_QTY_MTR']?.toString() ?? '',
      machineNo: json['machinE_NO']?.toString() ?? '',
      machineType: json['machinE_TYPE']?.toString() ?? '',
      mesh: json['mesh']?.toString() ?? '',
      beltType: json['belT_TYPE']?.toString() ?? '',
      beltConstruction: json['belT_CONSTRUCTION']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      beltWidthCm: json['belT_WIDTH_CM']?.toString() ?? '',
      beltGsm: json['belT_GSM']?.toString() ?? '',
      materialType: json['materiaL_TYPE']?.toString() ?? '',
      colorIdentification:
      json['coloR_IDENTIFICATION']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      loomOperator1: json['loomoparetoR1']?.toString() ?? '',
      loomOperator2: json['loomoparetoR2']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      hold: json['hold']?.toString() ?? '',
      holdRemark: json['holD_REMARK']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}
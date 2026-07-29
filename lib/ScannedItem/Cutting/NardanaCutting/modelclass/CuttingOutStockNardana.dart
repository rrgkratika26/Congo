class CuttingOutstockNaradana {
  final String active;
  final int id;
  final int rollCode;
  final String bomNo;
  final String barcode;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String weekNo;
  final String partyname;
  final String workOrderNo;
  final String orderType;
  final double requiredQtyKg;
  final double requiredQtyMtr;
  final String loomNo;
  final String loomType;
  final String fabricType;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutType;
  final String specialIdentification;
  final double rollWeight;
  final double rollLength;
  final String remark;
  final String department;
  final String fabricCode;
  final String inFromDept;
  final String issueToDept;
  final String status;
  final String inStock;
  final String location;
  final String component;
  final String productionType;

  CuttingOutstockNaradana({
    required this.active,
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.weekNo,
    required this.partyname,
    required this.workOrderNo,
    required this.orderType,
    required this.requiredQtyKg,
    required this.requiredQtyMtr,
    required this.loomNo,
    required this.loomType,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutType,
    required this.specialIdentification,
    required this.rollWeight,
    required this.rollLength,
    required this.remark,
    required this.department,
    required this.fabricCode,
    required this.inFromDept,
    required this.issueToDept,
    required this.status,
    required this.inStock,
    required this.location,
    required this.component,
    required this.productionType,
    required this.bomNo,
  });

  factory CuttingOutstockNaradana.fromJson(Map<String, dynamic> json) {
    return CuttingOutstockNaradana(
      active: json['active'] ?? '',
      id: int.tryParse(json['id'].toString()) ?? 0,
      rollCode: int.tryParse(json['rollCode'].toString()) ?? 0,
      barcode: json['barcode'] ?? '',
      supervisorName: json['supervisoR_NAME'] ?? json['supervisorName'] ?? '',
      operatorName: json['operatoR_NAME'] ?? json['operatorName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      weekNo: json['weeK_NO'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      partyname: json['partyname'] ?? '',
      workOrderNo: json['worK_ORDER_NO'] ?? '',
      orderType: json['ordeR_TYPE'] ?? '',

      requiredQtyKg: double.tryParse(json['requireD_QUANTITY_KG'].toString()) ?? 0.0,
      requiredQtyMtr: double.tryParse(json['requireD_QUANTITY_MTR'].toString()) ?? 0.0,
      rollLength: double.tryParse(json['rolL_LENGTH'].toString()) ?? 0.0,
      loomNo: json['looM_NO'] ?? '',
      loomType: json['looM_TYPE'] ?? '',
      fabricType: json['fabriC_TYPE'] ?? '',
      fabricConstruction: json['fabriC_CONSTRUCTION'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabriC_WIDTH'] ?? '',
      fabricGsm: json['fabriC_GSM'] ?? '',
      laminationType: json['laminatioN_TYPE'] ?? '',
      cutType: json['cuT_TYPE'] ?? '',
      specialIdentification: json['speciaL_IDENTIFICATION'] ?? '',

      rollWeight: double.tryParse(json['rolL_WEIGHT'].toString()) ?? 0.0,
      // rollWeight: json['rolL_WEIGHT'] ?? '',

      remark: json['remark'] ?? '',
      department: json['department'] ?? '',
      fabricCode: json['fabriC_CODE'] ?? '',
      inFromDept: json['iN_FROM_DEPT'] ?? '',
      issueToDept: json['issuE_TO_DEPT'] ?? '',
      status: json['status'] ?? '',
      inStock: json['iN_STOCK'] ?? '',
      location: json['location'] ?? '',
      component: json['component'] ?? '',
      productionType: json['productioN_TYPE'] ?? '',
    );
  }
}
class PrintingSavedListModel {
  final bool active;
  final int id;
  final int rollCode;
  final String barcode;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String partyName;
  final String workOrderNo;
  final String contractNo;
  final String requiredQuantityKg;
  final String requiredQuantityMtr;
  final String loomNo;
  final String loomType;
  final String fabricTypeUse;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutSlipType;
  final String specialIdentification;
  final String rollWeightKg;
  final String rollLengthMtr;
  final String avgWeight;
  final String tareWeight;
  final String grossWeight;
  final String remark;
  final String department;
  final String fabricCode;
  final String inFromDept;
  final String issueToDept;
  final String status;
  final bool inStock;
  final String location;
  final String hold;

  PrintingSavedListModel({
    required this.active,
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.partyName,
    required this.workOrderNo,
    required this.contractNo,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.loomNo,
    required this.loomType,
    required this.fabricTypeUse,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutSlipType,
    required this.specialIdentification,
    required this.rollWeightKg,
    required this.rollLengthMtr,
    required this.avgWeight,
    required this.tareWeight,
    required this.grossWeight,
    required this.remark,
    required this.department,
    required this.fabricCode,
    required this.inFromDept,
    required this.issueToDept,
    required this.status,
    required this.inStock,
    required this.location,
    required this.hold,
  });

  factory PrintingSavedListModel.fromJson(Map<String, dynamic> json) {
    return PrintingSavedListModel(
      active: json['active'] ?? false,
      id: json['id'] ?? 0,
      rollCode: json['rollCode'] ?? 0,
      barcode: json['barcode'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      operatorName: json['operatorName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      partyName: json['partyName'] ?? '',
      workOrderNo: json['workOrderNo'] ?? '',
      contractNo: json['contractNo'] ?? '',
      requiredQuantityKg: json['requiredQuantityKg'] ?? '',
      requiredQuantityMtr: json['requiredQuantityMtr'] ?? '',
      loomNo: json['loomNo'] ?? '',
      loomType: json['loomType'] ?? '',
      fabricTypeUse: json['fabricTypeUse'] ?? '',
      fabricConstruction: json['fabricConstruction'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      fabricGsm: json['fabricGsm'] ?? '',
      laminationType: json['laminationType'] ?? '',
      cutSlipType: json['cutSlipType'] ?? '',
      specialIdentification: json['specialIdentification'] ?? '',
      rollWeightKg: json['rollWeightKg'] ?? '',
      rollLengthMtr: json['rollLengthMtr'] ?? '',
      avgWeight: json['avgWeight'] ?? '',
      tareWeight: json['tareWeight'] ?? '',
      grossWeight: json['grossWeight'] ?? '',
      remark: json['remark'] ?? '',
      department: json['department'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      inFromDept: json['inFromDept'] ?? '',
      issueToDept: json['issueToDept'] ?? '',
      status: json['status'] ?? '',
      inStock: json['inStock'] ?? false,
      location: json['location'] ?? '',
      hold: json['hold'] ?? '',
    );
  }
}
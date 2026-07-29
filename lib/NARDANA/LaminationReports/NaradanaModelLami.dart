class NewBarcodeNardanaModel {

  final int srNo;
  final String rollCode;
  final String barcode;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String partyName;
  final String workOrderNo;
  final String contNo;
  final String loomNo;
  final String loomType;
  final String fabricType;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String gsm;
  final String laminationType;
  final String cutType;
  final String specialIdentification;
  final String rollWeight;
  final String rollLength;
  final String avgWeight;
  final String tareWeight;
  final String grossWeight;
  final String fabricCode;
  final String department;
  final String hold;
  // final String? supervisorName;
  // final String? operatorName;
  // final String? workOrderNo;
  // final String? contNo;
  final String? requiredQuantityKg;
  final String? requiredQuantityMtr;
  // final String? loomType;
  // final String? fabricConstruction;
  // final String? laminationType;
  // final String? specialIdentification;
  final String? rollWeightKg;
  final String? rollLengthMtr;
  final String? avgWeightGm;
  final String? tareWeightKg;
  final String? grossWeightKg;
  final String? remark;
  final String? issueToDept;
  final String? inStock;
  final String? status;
  final String? location;

  NewBarcodeNardanaModel({
    required this.rollCode,
    required this.barcode,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.loomNo,
    required this.loomType,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.gsm,
    required this.laminationType,
    required this.cutType,
    required this.specialIdentification,
    required this.rollWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.tareWeight,
    required this.grossWeight,
    required this.fabricCode,
    required this.department,

    required this.hold, required this.srNo, this.requiredQuantityKg, this.requiredQuantityMtr, this.rollWeightKg, this.rollLengthMtr, this.avgWeightGm, this.tareWeightKg, this.grossWeightKg, this.issueToDept, this.inStock, this.status, this.location, this.remark,

  });

  factory NewBarcodeNardanaModel.fromJson(Map<String, dynamic> json) {
    return NewBarcodeNardanaModel(

      srNo: json['srNo'] ?? 0,
      rollCode: json['rollcode']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      supervisorName: json['supervisorname']?.toString() ?? '',
      operatorName: json['operatorname']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      partyName: json['partyname']?.toString() ?? '',
      workOrderNo: json['workorderno']?.toString() ?? '',
      contNo: json['contno']?.toString() ?? '',
      loomNo: json['loomno']?.toString() ?? '',
      loomType: json['loomtype']?.toString() ?? '',
      fabricType: json['fabrictype']?.toString() ?? '',
      fabricConstruction: json['fabricconstruction']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      fabricWidth: json['fabricwidth']?.toString() ?? '',
      gsm: json['fabricgsm']?.toString() ?? '',
      laminationType: json['laminationtype']?.toString() ?? '',
      cutType: json['cuttype']?.toString() ?? '',
      specialIdentification:
      json['specialidentification']?.toString() ?? '',
      rollWeight: json['rollweightkg']?.toString() ?? '',
      rollLength: json['rolllengthmtr']?.toString() ?? '',
      avgWeight: json['avgweightgm']?.toString() ?? '',
      tareWeight: json['tareweightkg']?.toString() ?? '',
      grossWeight: json['grossweightkg']?.toString() ?? '',
      fabricCode: json['fabriccode']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      hold: json['hold']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}
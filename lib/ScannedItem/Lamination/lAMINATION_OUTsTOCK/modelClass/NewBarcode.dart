class NewBarcodeModel {
  final int id;
  final String rollCode;
  final String barcode;
  final String supervisorName;
  final String operatorName;
  final String date;
  final String time;
  final String partyName;
  final String workOrderNo;
  final String contNo;
  final String requiredQtyKg;
  final String requiredQtyMtr;
  final String loomNo;
  final String loomType;
  final String fabricType;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String gsm;
  final String laminationType;
  final String cutType;
  final String specialId;
  final String rollWeight;
  final String rollLength;
  final String avgWeight;
  final String tareWeight;
  final String grossWeight;
  final String remark;
  final String department;
  final String fabricCode;
  final String inFromDept;
  final String issueToDept;
  final String status;
  final String inStock;
  final String location;
  final String hold;

  NewBarcodeModel({
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.supervisorName,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.partyName,
    required this.workOrderNo,
    required this.contNo,
    required this.requiredQtyKg,
    required this.requiredQtyMtr,
    required this.loomNo,
    required this.loomType,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.gsm,
    required this.laminationType,
    required this.cutType,
    required this.specialId,
    required this.rollWeight,
    required this.rollLength,
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

  factory NewBarcodeModel.fromJson(Map<String, dynamic> json) {
    return NewBarcodeModel(
      id: json['id'] ?? 0,
      rollCode: json['rollCode'] ?? '',
      barcode: json['barcode'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      operatorName: json['operatorName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      partyName: json['partyName'] ?? '',
      workOrderNo: json['workOrderNo'] ?? '',
      contNo: json['contNo'] ?? '',
      requiredQtyKg: json['requiredQtyKg'] ?? '',
      requiredQtyMtr: json['requiredQtyMtr'] ?? '',
      loomNo: json['loomNo'] ?? '',
      loomType: json['loomType'] ?? '',
      fabricType: json['fabricType'] ?? '',
      fabricConstruction: json['fabricConstruction'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      gsm: json['gsm'] ?? '',
      laminationType: json['laminationType'] ?? '',
      cutType: json['cutType'] ?? '',
      specialId: json['specialId'] ?? '',
      rollWeight: json['rollWeight'] ?? '',
      rollLength: json['rollLength'] ?? '',
      avgWeight: json['avgWeight'] ?? '',
      tareWeight: json['tareWeight'] ?? '',
      grossWeight: json['grossWeight'] ?? '',
      remark: json['remark'] ?? '',
      department: json['department'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      inFromDept: json['inFromDept'] ?? '',
      issueToDept: json['issueToDept'] ?? '',
      status: json['status'] ?? '',
      inStock: json['inStock'] ?? '',
      location: json['location'] ?? '',
      hold: json['hold'] ?? '',
    );
  }
}


class NewBarcodeResponse {
  final String status;
  final List<NewBarcodeModel> data;

  NewBarcodeResponse({
    required this.status,
    required this.data,
  });

  factory NewBarcodeResponse.fromJson(Map<String, dynamic> json) {
    return NewBarcodeResponse(
      status: json['status'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => NewBarcodeModel.fromJson(e))
          .toList(),
    );
  }
}
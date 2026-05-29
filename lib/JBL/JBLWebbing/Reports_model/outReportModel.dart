


import '../../JBL_Cutting/ModelClass/CuttinfType.dart';

class WebbingOutReportModel extends BaseModel {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;
  final String supervisorName;
  final String operatorName;
  // final DateTime date;
  // final String time;
  // final String machineNo;
  // final String machineType;
  final double rollWeight;
  final double rollLength;
  final double requiredQtyKg;
  final double requiredQtyMtr;
  final String location;

  WebbingOutReportModel({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.fabricCode,
    required this.supervisorName,
    required this.operatorName,
    // required this.date,
    // required this.time,
    // required this.machineNo,
    // required this.machineType,
    required this.rollWeight,
    required this.rollLength,
    required this.requiredQtyKg,
    required this.requiredQtyMtr,
    required this.location,
  });

  // Parse from JSON
  factory WebbingOutReportModel.fromJson(Map<String, dynamic> json) {
    return WebbingOutReportModel(
      srNo: json['Sr. No.'] ?? 0,
      rollCode: json['ROLL CODE'] ?? '',
      barcode: json['BARCODE'] ?? '',
      lotNo: json['LOT_NO'] ?? '',
      fabricCode: json['FABRIC_CODE'] ?? '',
      supervisorName: json['SUPERVISOR NAME'] ?? '',
      operatorName: json['OPERATOR NAME'] ?? '',
      // date: DateTime.tryParse(json['DATE'] ?? '') ?? DateTime.now(),
      // time: json['TIME'] ?? '',
      // machineNo: json['MACHINE NO.'] ?? '',
      // machineType: json['MACHINE TYPE'] ?? '',
      rollWeight: (json['ROLL_WEIGHT(KG)'] ?? 0).toDouble(),
      rollLength: (json['ROLL LENGTH (Mtr)'] ?? 0).toDouble(),
      requiredQtyKg: (json['REQUIRED QUANTITY (Kg)'] ?? 0).toDouble(),
      requiredQtyMtr: (json['REQUIRED QUANTITY MTR'] ?? 0).toDouble(),
      location: json['Location'] ?? '',
    );
  }

  // Convert back to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'Sr. No.': srNo,
      'ROLL CODE': rollCode,
      'BARCODE': barcode,
      'LOT_NO': lotNo,
      'FABRIC_CODE': fabricCode,
      'SUPERVISOR NAME': supervisorName,
      'OPERATOR NAME': operatorName,
      // 'DATE': date.toIso8601String(),
      // 'TIME': time,
      // 'MACHINE NO.': machineNo,
      // 'MACHINE TYPE': machineType,
      'ROLL_WEIGHT(KG)': rollWeight,
      'ROLL LENGTH (Mtr)': rollLength,
      'REQUIRED QUANTITY (Kg)': requiredQtyKg,
      'REQUIRED QUANTITY MTR': requiredQtyMtr,
      'Location': location,
    };
  }
}
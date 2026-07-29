import 'package:intl/intl.dart';

class LoomReport {
  final int srNo;
  final int rollCode;
  final String bomNo;
  final String barcode;
  final String batchNo;
  final String loomType;
  final int loomNo;
  final String fabricCode;
  final double grossWeight;
  final double netWeight;
  final int rollLength;
  final double avgWeight;
  final String operatorName;
  final DateTime date;
  final String time;

  final String loomOperator1;
  final String supervisorName;
  final String partyName;
  final String workOrderNo;
  final String machineNo;

  final double requiredQty;
  final double requiredQtyMtr;
  final double tareWeight;

  final String department;
  final String issueToDept;
  final String status;
  final String entryIn;
  final String entryOut;

  final String mesh;
  final String fabricType;
  final String fabricConstruction;
  final String color;
  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutSlipType;
  final String specialIdentification;

  LoomReport({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.batchNo,
    required this.loomType,
    required this.loomNo,
    required this.fabricCode,
    required this.grossWeight,
    required this.netWeight,
    required this.rollLength,
    required this.avgWeight,
    required this.operatorName,
    required this.date,
    required this.time,
    required this.loomOperator1,
    required this.supervisorName,
    required this.partyName,
    required this.workOrderNo,
    required this.machineNo,
    required this.requiredQty,
    required this.requiredQtyMtr,
    required this.tareWeight,
    required this.department,
    required this.issueToDept,
    required this.status,
    required this.entryIn,
    required this.entryOut,
    required this.mesh,
    required this.fabricType,
    required this.fabricConstruction,
    required this.color,
    required this.fabricWidth,
    required this.fabricGsm,
    required this.laminationType,
    required this.cutSlipType,
    required this.specialIdentification, required this.bomNo,
  });

  factory LoomReport.fromJson(Map<String, dynamic> json) {
    return LoomReport(
      srNo: int.tryParse(json['id'].toString()) ?? 0,
      rollCode: int.tryParse(json['rolL_CODE'].toString()) ?? 0,
      barcode: json['barcode'] ?? '',
      batchNo: json['batcH_NO'] ?? '',
      loomType: json['looM_TYPE'] ?? '',
      loomNo: int.tryParse(json['looM_NO'].toString()) ?? 0,
      fabricCode: json['fabriC_CODE'] ?? '',

      grossWeight: double.tryParse(json['grosS_WEIGHT'].toString()) ?? 0,
      netWeight: double.tryParse(json['neT_WEIGHT'].toString()) ?? 0,
      rollLength: int.tryParse(json['rolL_LENGTH'].toString()) ?? 0,
      avgWeight: double.tryParse(json['avG_WEIGHT'].toString()) ?? 0,

      operatorName: json['operatoR_NAME'] ?? '',
      // date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      date: DateTime.tryParse(
        json['date']?.toString() ?? '',
      ) ??
          DateTime.now(),
      time: json['time'] ?? '',

      loomOperator1: json['loomoparetoR1'] ?? '',
      supervisorName: json['supervisoR_NAME'] ?? '',
      partyName: json['partyname'] ?? '',
      workOrderNo: json['worK_ORDER_NO'] ?? '',
      machineNo: json['machineno'] ?? '',

      requiredQty: double.tryParse(json['requireD_QUANTITY'].toString()) ?? 0,
      requiredQtyMtr: double.tryParse(json['requireD_QUANTITY_MTR'].toString()) ?? 0,
      tareWeight: double.tryParse(json['tarE_WEIGHT'].toString()) ?? 0,

      department: json['department'] ?? '',
      issueToDept: json['issuE_TO_DEPT'] ?? '',
      status: json['status'] ?? '',
      entryIn: json['entryin'] ?? '',
      entryOut: json['entryout'] ?? '',

      mesh: json['mash'] ?? '',
      fabricType: json['fabriC_TYPE'] ?? '',
      fabricConstruction: json['fabriC_CONSTRUCTION'] ?? '',
      color: json['color'] ?? '',
      fabricWidth: json['fabriC_WIDTH'] ?? '',
      fabricGsm: json['fabriC_GSM'] ?? '',
      laminationType: json['laminatioN_TYPE'] ?? '',
      cutSlipType: json['cuT_SLIP_TYPE'] ?? '',
      specialIdentification: json['speciaL_IDENTIFICATION'] ?? '',
      bomNo: json['boM_NO'] ?? '',
    );
  }
}
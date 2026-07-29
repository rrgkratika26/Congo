class RmdStockReportModel {
  final int srNo;
  final int rollCode;
  final String barcode;
  final String batchNo;
  final String loomType;
  final String loomNo;
  final String fabricCode;

  final double grossWeight;
  final double netWeight;
  final double rollLength;
  final double avgWeight;

  final String operatorName;
  final DateTime date;
  final String time;
  final String loomOperator1;

  final String gsm;
  final String supervisorName;
  final String partyName;
  final String workOrderNo;

  final String status;

  RmdStockReportModel({
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
    required this.gsm,
    required this.supervisorName,
    required this.partyName,
    required this.workOrderNo,
    required this.status,
  });

  factory RmdStockReportModel.fromJson(Map<String, dynamic> json) {
    return RmdStockReportModel(
      srNo: json["Sr. No."] ?? 0,
      rollCode: json["ROLL_CODE"] ?? 0,
      barcode: json["BARCODE"] ?? '',
      batchNo: json["BATCH_NO"] ?? '',
      loomType: json["LOOM_TYPE"] ?? '',
      loomNo: json["LOOM_NO"] ?? '',
      fabricCode: json["FABRIC_CODE"] ?? '',

      grossWeight: double.tryParse(json["GROSS_WEIGHT (Kg)"].toString()) ?? 0,
      netWeight: double.tryParse(json["NET_WEIGHT (Kg)"].toString()) ?? 0,
      rollLength: double.tryParse(json["ROLL_LENGTH (Mtr)"].toString()) ?? 0,
      avgWeight: double.tryParse(json["AVG_WEIGHT (Gm)"].toString()) ?? 0,

      operatorName: json["OPERATOR_NAME"] ?? '',
      date: DateTime.tryParse(json["DATE"] ?? '') ?? DateTime.now(),
      time: json["TIME"] ?? '',
      loomOperator1: json["LOOMOPARETOR1"] ?? '',

      gsm: json["GSM_MTR/GM"] ?? '',
      supervisorName: json["SUPERVISOR_NAME"] ?? '',
      partyName: json["PARTYNAME"] ?? '',
      workOrderNo: json["WORK_ORDER_NO"] ?? '',

      status: json["STATUS"] ?? '',
    );
  }
}
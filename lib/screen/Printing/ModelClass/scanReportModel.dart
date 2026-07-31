class PrintingReportModel {
  final String rollcode;
  final String barcode;
  final String fabricCode;
  final String partyName;
  final String supervisor;
  final String operatorName;
  final String bomNo;
  final String poNo;
  final String articleNo;
  final String fabricGSM;
  final String laminationType;
  final String fabricWidth;
  final String grossWeight;
  final String netWeight;
  final String tareWeight;
  final String rollLength;
  final String department;
  final String inFromDept;
  final String issueToDept;
  final String status;
  final String location;
  final String remark;
  final String hold;
  final String date;
  final String time;

  PrintingReportModel({
    required this.rollcode,
    required this.barcode,
    required this.fabricCode,
    required this.partyName,
    required this.supervisor,
    required this.operatorName,
    required this.bomNo,
    required this.poNo,
    required this.articleNo,
    required this.fabricGSM,
    required this.laminationType,
    required this.fabricWidth,
    required this.grossWeight,
    required this.netWeight,
    required this.tareWeight,
    required this.rollLength,
    required this.department,
    required this.inFromDept,
    required this.issueToDept,
    required this.status,
    required this.location,
    required this.remark,
    required this.hold,
    required this.date,
    required this.time,
  });

  factory PrintingReportModel.fromJson(Map<String, dynamic> json) {
    return PrintingReportModel(
      rollcode: json["rollCode"]?.toString() ?? "",
      barcode: json["barcode"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
      partyName: json["partyName"] ?? "",
      supervisor: json["supervisor"] ?? "",
      operatorName: json["operator"] ?? "",
      bomNo: json["bomNo"] ?? "",
      poNo: json["poNo"] ?? "",
      articleNo: json["articleNo"] ?? "",
      fabricGSM: json["fabricGSM"] ?? "",
      laminationType: json["laminationType"] ?? "",
      fabricWidth: json["fabricWidth"] ?? "",
      grossWeight: json["grossWeight"] ?? "",
      netWeight: json["netWeight"] ?? "",
      tareWeight: json["tareWeight"] ?? "",
      rollLength: json["rollLength"] ?? "",
      department: json["department"] ?? "",
      inFromDept: json["inFromDept"] ?? "",
      issueToDept: json["issueToDept"] ?? "",
      status: json["status"] ?? "",
      location: json["location"] ?? "",
      remark: json["remark"] ?? "",
      hold: json["hold"] ?? "",
      date: json["date"] ?? "",
      time: json["time"] ?? "",
    );
  }
}
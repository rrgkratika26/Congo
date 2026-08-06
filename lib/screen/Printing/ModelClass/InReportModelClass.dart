class PrintingInReportModel {
  final String status;
  final List<PrintingInReportData> data;

  PrintingInReportModel({
    required this.status,
    required this.data,
  });

  factory PrintingInReportModel.fromJson(Map<String, dynamic> json) {
    return PrintingInReportModel(
      status: json["status"] ?? "",
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => PrintingInReportData.fromJson(e))
          .toList(),
    );
  }
}

class PrintingInReportData {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String fabricCode;
  final String supervisor;
  final String partyName;
  final String bomNo;
  final String poNo;
  final String articleNo;
  final int fabricGsm;
  final String laminationType;
  final int fabricWidth;
  final double grossWeight;
  final double netWeight;
  final double tareWeight;
  final double rollLength;
  final String department;
  final String inFromDept;
  final String issueToDept;
  final String status;
  final String operator;
  final String location;
  final String remark;
  final String hold;
  final DateTime? date;
  final String time;

  PrintingInReportData({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.fabricCode,
    required this.supervisor,
    required this.partyName,
    required this.bomNo,
    required this.poNo,
    required this.articleNo,
    required this.fabricGsm,
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
    required this.operator,
    required this.location,
    required this.remark,
    required this.hold,
    required this.date,
    required this.time,
  });

  factory PrintingInReportData.fromJson(Map<String, dynamic> json) {
    return PrintingInReportData(
      srNo: json["srNo"] ?? 0,
      rollCode: json["rollCode"] ?? "",
      barcode: json["barcode"] ?? "",
      fabricCode: json["fabricCode"] ?? "",
      supervisor: json["supervisor"] ?? "",
      partyName: json["partyName"] ?? "",
      bomNo: json["bomNo"] ?? "",
      poNo: json["poNo"] ?? "",
      articleNo: json["articleNo"] ?? "",
      fabricGsm: json["fabricGsm"] ?? 0,
      laminationType: json["laminationType"] ?? "",
      fabricWidth: json["fabricWidth"] ?? 0,
      grossWeight: (json["grossWeight"] ?? 0).toDouble(),
      netWeight: (json["netWeight"] ?? 0).toDouble(),
      tareWeight: (json["tareWeight"] ?? 0).toDouble(),
      rollLength: (json["rollLength"] ?? 0).toDouble(),
      department: json["department"] ?? "",
      inFromDept: json["inFromDept"] ?? "",
      issueToDept: json["issueToDept"] ?? "",
      status: json["status"] ?? "",
      operator: json["operator"] ?? "",
      location: json["location"] ?? "",
      remark: json["remark"] ?? "",
      hold: json["hold"] ?? "",
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      time: json["time"] ?? "",
    );
  }
}
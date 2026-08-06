class PrintingOutReportModel {
  final String status;
  final List<PrintingOutReportItem> data;

  PrintingOutReportModel({
    required this.status,
    required this.data,
  });

  factory PrintingOutReportModel.fromJson(Map<String, dynamic> json) {
    return PrintingOutReportModel(
      status: json['status'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PrintingOutReportItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class PrintingOutReportItem {
  final int id;
  final String rollCode;
  final String barcode;
  final String fabricCode;
  final String supervisor;
  final String partyName;
  final String boMNo;
  final String pONo;
  final String articleNo;
  final String fabricGsm;
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
  final String operator;
  final String location;
  final String remark;
  final String hold;
  final DateTime? date;
  final String time;

  PrintingOutReportItem({
    required this.id,
    required this.rollCode,
    required this.barcode,
    required this.fabricCode,
    required this.supervisor,
    required this.partyName,
    required this.boMNo,
    required this.pONo,
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

  factory PrintingOutReportItem.fromJson(Map<String, dynamic> json) {
    return PrintingOutReportItem(
      id: json['id'] ?? 0,
      rollCode: json['rollCode'] ?? '',
      barcode: json['barcode'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      supervisor: json['supervisor'] ?? '',
      partyName: json['partyName'] ?? '',
      boMNo: json['boM_NO'] ?? '',
      pONo: json['pO_NO'] ?? '',
      articleNo: json['articleNo'] ?? '',
      fabricGsm: json['fabricGsm'] ?? '',
      laminationType: json['laminationType'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      grossWeight: json['grossWeight'] ?? '',
      netWeight: json['netWeight'] ?? '',
      tareWeight: json['tareWeight'] ?? '',
      rollLength: json['rollLength'] ?? '',
      department: json['department'] ?? '',
      inFromDept: json['inFromDept'] ?? '',
      issueToDept: json['issueToDept'] ?? '',
      status: json['status'] ?? '',
      operator: json['operator'] ?? '',
      location: json['location'] ?? '',
      remark: json['remark'] ?? '',
      hold: json['hold'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: json['time'] ?? '',
    );
  }
}
class WeBNardanaReportModel {
  final int id;
  final String srno;
  final String barcode;
  final String lotno;
  final String flattubegusset;
  final double netwt;
  final double quantity;
  final String partyname;
  final String workorderno;
  final String purchaseNo;
  final String supervisor;
  final String operator;
  final String date;
  final String time;
  final String machine;
  final String modelno;

  WeBNardanaReportModel({
    required this.id,
    required this.srno,
    required this.barcode,
    required this.lotno,
    required this.flattubegusset,
    required this.netwt,
    required this.quantity,
    required this.partyname,
    required this.workorderno,
    required this.purchaseNo,
    required this.supervisor,
    required this.operator,
    required this.date,
    required this.time,
    required this.machine,
    required this.modelno,
  });

  factory WeBNardanaReportModel.fromJson(Map<String, dynamic> json) {
    return WeBNardanaReportModel(
      id: json['id'] ?? 0,
      srno: json['srno'] ?? '',
      barcode: json['barcode'] ?? '',
      lotno: json['lotno'] ?? '',
      flattubegusset: json['flattubegusset'] ?? '',
      netwt: (json['netwt'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      partyname: json['partyname'] ?? '',
      workorderno: json['workorderno'] ?? '',
      purchaseNo: json['purchasE_NO'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      date: json['date'] ?? '',
      time: json['tIme'] ?? '',
      machine: json['machine'] ?? '',
      modelno: json['modelno'] ?? '',
    );
  }
}



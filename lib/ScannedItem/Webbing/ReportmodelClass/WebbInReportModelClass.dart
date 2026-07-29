class InReportModel {
  final int id;
  final String barcode;
  final String lotNo;
  final double netWt;
  final double quantity;
  final String partyName;
  final String supervisor;
  final String operator;
  final DateTime date;
  final String machine;
  final String department;

  InReportModel({
    required this.id,
    required this.barcode,
    required this.lotNo,
    required this.netWt,
    required this.quantity,
    required this.partyName,
    required this.supervisor,
    required this.operator,
    required this.date,
    required this.machine,
    required this.department,
  });

  factory InReportModel.fromJson(Map<String, dynamic> json) {
    return InReportModel(
      id: json['id'] ?? 0,
      barcode: json['barcode'] ?? '',
      lotNo: json['lotno'] ?? '',
      netWt: (json['netwt'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      partyName: json['partyname'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      date: DateTime.parse(json['date']),
      machine: json['machine'] ?? '',
      department: json['department'] ?? '',
    );
  }
}

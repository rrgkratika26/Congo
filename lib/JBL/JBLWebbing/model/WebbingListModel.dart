class WebbingListModel {
  final int id;
  final String? code;
  final String? barcode;
  final String? lotNo;
  final String? fabricCode;
  final double? netWt;
  final int? quantity;
  final String? supervisor;
  final String? operator;
  final String? date;
  final String? time;
  final String? weekNo;
  final String? partyName;
  final String? workOrderNo;
  final String? machine;
  final String? modelNo;
  final String? department;
  final String? location;

  WebbingListModel({
    required this.id,
    this.code,
    this.barcode,
    this.lotNo,
    this.fabricCode,
    this.netWt,
    this.quantity,
    this.supervisor,
    this.operator,
    this.date,
    this.time,
    this.weekNo,
    this.partyName,
    this.workOrderNo,
    this.machine,
    this.modelNo,
    this.department,
    this.location,
  });

  factory WebbingListModel.fromJson(Map<String, dynamic> json) {
    return WebbingListModel(
      id: json['id'] ?? 0,
      code: json['code'],
      barcode: json['barcode'],
      lotNo: json['lotNo'],
      fabricCode: json['fabricCode'],
      netWt: (json['netWt'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      supervisor: json['supervisor'],
      operator: json['operator'],
      date: json['date'],
      time: json['time'],
      weekNo: json['weekNo'],
      partyName: json['partyName'],
      workOrderNo: json['workOrderNo'],
      machine: json['machine'],
      modelNo: json['modelNo'],
      department: json['department'],
      location: json['location'],
    );
  }
}
class TapelineInReportModel {
  final int id;
  final String code;
  final String supervisor;
  final String party;
  final String contNo;
  final String workOrder;
  final DateTime date;
  final String time;
  final String recipeType;
  final int dnr;
  final int widthMM;
  final double gross;
  final double tare;
  final double net;
  final String remark;
  final String plant;
  final String qualityStatus;
  final double balanceKg;

  TapelineInReportModel({
    required this.id,
    required this.code,
    required this.supervisor,
    required this.party,
    required this.contNo,
    required this.workOrder,
    required this.date,
    required this.time,
    required this.recipeType,
    required this.dnr,
    required this.widthMM,
    required this.gross,
    required this.tare,
    required this.net,
    required this.remark,
    required this.plant,
    required this.qualityStatus,
    required this.balanceKg,
  });

  factory TapelineInReportModel.fromJson(Map<String, dynamic> json) {
    return TapelineInReportModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      supervisor: json['supervisor'] ?? '',
      party: json['party'] ?? '',
      contNo: json['contNo'] ?? '',
      workOrder: json['workOrder'] ?? '',
      date: json['date'] != null && json['date'].toString().isNotEmpty
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      time: json['time'] ?? '',
      recipeType: json['recipeType'] ?? '',
      dnr: (json['dnr'] ?? 0).toInt(),
      widthMM: (json['widthMM'] ?? 0).toInt(),
      gross: (json['gross'] ?? 0).toDouble(),
      tare: (json['tare'] ?? 0).toDouble(),
      net: (json['net'] ?? 0).toDouble(),
      remark: json['remark'] ?? '',
      plant: json['plant'] ?? '',
      qualityStatus: json['qualityStatus'] ?? '',
      balanceKg: (json['balanceKg'] ?? 0).toDouble(),
    );
  }
}
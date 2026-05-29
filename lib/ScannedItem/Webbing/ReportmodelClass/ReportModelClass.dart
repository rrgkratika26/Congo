import 'package:intl/intl.dart';

class WebbingInReportModel {
  final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;
  final double rollWeightKg;
  final String partyName;
  final String poNo;
  final String articleNo;
  final String supervisorName;
  final String shift;
  final DateTime date;
  final String time;
  final String machineNo;
  final int beltWidthCm;

  WebbingInReportModel({
    required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.fabricCode,
    required this.rollWeightKg,
    required this.partyName,
    required this.poNo,
    required this.articleNo,
    required this.supervisorName,
    required this.shift,
    required this.date,
    required this.time,
    required this.machineNo,
    required this.beltWidthCm,
  });

  factory WebbingInReportModel.fromJson(Map<String, dynamic> json) {
    return WebbingInReportModel(
      srNo: json['srNo'] ?? 0,
      rollCode: json['rollCode'] ?? '',
      barcode: json['barcode'] ?? '',
      lotNo: json['lotNo'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      rollWeightKg: (json['rollWeightKg'] ?? 0).toDouble(),
      partyName: json['partyName'] ?? '',
      poNo: json['poNo'] ?? '',
      articleNo: json['articleNo'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      shift: json['shift'] ?? '',
      date: DateFormat("MM/dd/yyyy HH:mm:ss")
          .parse(json['date'])
          .toLocal(),
      time: json['time'] ?? '',
      machineNo: json['machineNo'] ?? '',
      beltWidthCm: json['beltWidthCm'] ?? 0,
    );
  }
}

class WebbingReportModel {
  final bool success;
  final String message;
  final List<WebbingInReportModel> data;

  WebbingReportModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WebbingReportModel.fromJson(Map<String, dynamic> json) {
    return WebbingReportModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => WebbingInReportModel.fromJson(e))
          .toList(),
    );
  }
}

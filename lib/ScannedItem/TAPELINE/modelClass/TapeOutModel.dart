import 'package:intl/intl.dart';

class TapelineOutReportModel {
  final int id;
  final String code;
  final String supervisor;
  final String operator;
  final String party;
  final DateTime date;
  final String recipeType;
  final String contNo;
  final int dnr;
  final int widthMM;
  final double issueKg;
  final String qRemark;

  TapelineOutReportModel({
    required this.id,
    required this.code,
    required this.supervisor,
    required this.operator,
    required this.party,
    required this.date,
    required this.recipeType,
    required this.contNo,
    required this.dnr,
    required this.widthMM,
    required this.issueKg,
    required this.qRemark,
  });

  factory TapelineOutReportModel.fromJson(Map<String, dynamic> json) {
    return TapelineOutReportModel(
      id: (json['id'] ?? 0).toInt(),
      code: json['code'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      party: json['party'] ?? '',

      // API format: 06-Jul-2026
      date: json['date'] != null && json['date'].toString().isNotEmpty
          ? DateTime.parse(
        _formatDate(json['date'].toString()),
      )
          : DateTime.now(),

      recipeType: json['recipeType'] ?? '',
      contNo: json['contNo'] ?? '',
      dnr: (json['dnr'] ?? 0).toInt(),
      widthMM: (json['widthMM'] ?? 0).toInt(),
      issueKg: (json['issueKg'] ?? 0).toDouble(),
      qRemark: json['qRemark'] ?? '',
    );
  }

  /// Converts "06-Jul-2026" -> "2026-07-06"
  static String _formatDate(String value) {
    final input = DateFormat('dd-MMM-yyyy');
    final output = DateFormat('yyyy-MM-dd');
    return output.format(input.parse(value));
  }
}
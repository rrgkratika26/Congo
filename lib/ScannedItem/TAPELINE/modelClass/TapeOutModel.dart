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
      id: _parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      supervisor: json['supervisor']?.toString() ?? '',
      operator: json['operator']?.toString() ?? '',
      party: json['party']?.toString() ?? '',

      // API can return:
      // 8-9-2026
      // 08-09-2026
      // 06-Jul-2026
      // 9/8/2026 12:00:00 AM
      // 2026-09-08
      date: _parseDate(json['date']),

      recipeType: json['recipeType']?.toString() ?? '',
      contNo: json['contNo']?.toString() ?? '',

      dnr: _parseInt(json['dnr']),
      widthMM: _parseInt(json['widthMM']),
      issueKg: _parseDouble(json['issueKg']),

      qRemark: json['qRemark']?.toString() ?? '',
    );
  }

  // ============================================================
  // INTEGER PARSER
  // ============================================================

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // DOUBLE PARSER
  // ============================================================

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    final dateString = value.toString().trim();

    if (dateString.isEmpty) {
      return DateTime.now();
    }

    // ------------------------------------------------------------
    // Supported API formats
    // ------------------------------------------------------------

    final formats = <String>[
      // 8-9-2026
      'd-M-yyyy',

      // 08-09-2026
      'dd-MM-yyyy',

      // 06-Jul-2026
      'dd-MMM-yyyy',

      // 6-Jul-2026
      'd-MMM-yyyy',

      // 9/8/2026 12:00:00 AM
      'M/d/yyyy h:mm:ss a',

      // 09/08/2026 12:00:00 AM
      'MM/dd/yyyy h:mm:ss a',

      // 2026-09-08
      'yyyy-MM-dd',

      // 2026-09-08 12:00:00
      'yyyy-MM-dd HH:mm:ss',

      // 2026-09-08T12:00:00
      'yyyy-MM-ddTHH:mm:ss',

      // 2026-09-08T12:00:00.000
      'yyyy-MM-ddTHH:mm:ss.SSS',
    ];

    // Try each known format
    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {
        // Try next format
      }
    }

    // ------------------------------------------------------------
    // Final fallback for ISO dates
    // ------------------------------------------------------------

    try {
      return DateTime.parse(dateString);
    } catch (_) {
      throw FormatException(
        'Unsupported date format: $dateString',
      );
    }
  }
}
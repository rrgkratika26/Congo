import 'dart:convert';

class CuttingOutReportModel {
  final String partyName;
  final String bomNo;
  final String component;
  final double cutLength;
  final double cutWidth;
  final int pcs;
  final double netWt;
  final double weightPerPcs;
  final String issueDepartment;
  final DateTime issueDate;

  CuttingOutReportModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
    required this.issueDepartment,
    required this.issueDate,
  });

  factory CuttingOutReportModel.fromJson(Map<String, dynamic> json) {
    return CuttingOutReportModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      pcs: _toInt(json['pcs']),
      netWt: _toDouble(json['netWt']),
      weightPerPcs: _toDouble(json['weightPerPcs']),
      issueDepartment: json['issueDepartment']?.toString() ?? '',
      issueDate: _parseDate(json['issueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partyName': partyName,
      'bomNo': bomNo,
      'component': component,
      'cutLength': cutLength,
      'cutWidth': cutWidth,
      'pcs': pcs,
      'netWt': netWt,
      'weightPerPcs': weightPerPcs,
      'issueDepartment': issueDepartment,
      'issueDate': issueDate.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static List<CuttingOutReportModel> listFromJson(dynamic json) {
    if (json is List) {
      return json
          .map(
            (e) => CuttingOutReportModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    return [];
  }

  static String encodeList(List<CuttingOutReportModel> list) {
    return jsonEncode(
      list.map((e) => e.toJson()).toList(),
    );
  }
}
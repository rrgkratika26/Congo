class receiveReportModel {
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final int pcs;

  final double netWt;
  final double weightPerPcs;

  final String transactionType;
  final String receiveFrom;
  final DateTime? receiveDate;

  const receiveReportModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
    required this.transactionType,
    required this.receiveFrom,
    required this.receiveDate,
  });

  factory receiveReportModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return receiveReportModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      pcs: _toInt(json['pcs']),
      netWt: _toDouble(json['netWt']),
      weightPerPcs: _toDouble(json['weightPerPcs']),
      transactionType:
      json['transactionType']?.toString() ?? '',
      receiveFrom:
      json['receiveFrom']?.toString() ?? '',
      receiveDate:
      DateTime.tryParse(
        json['receiveDate']?.toString() ?? '',
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
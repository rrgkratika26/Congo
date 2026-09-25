class PrintingIssueReportModel {
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final int pcs;
  final double netWt;
  final double weightPerPcs;

  final String transactionType;
  final String issueDepartment;
  final DateTime issueDate;

  const PrintingIssueReportModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
    required this.transactionType,
    required this.issueDepartment,
    required this.issueDate,
  });

  factory PrintingIssueReportModel.fromJson(Map<String, dynamic> json) {
    return PrintingIssueReportModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      pcs: _toInt(json['pcs']),
      netWt: _toDouble(json['netWt']),
      weightPerPcs: _toDouble(json['weightPerPcs']),
      transactionType: json['transactionType']?.toString() ?? '',
      issueDepartment: json['issueDepartment']?.toString() ?? '',
      issueDate: DateTime.tryParse(json['issueDate']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String get searchText => [
    partyName,
    bomNo,
    component,
    issueDepartment,
    transactionType,
  ].join(' ').toLowerCase();
}
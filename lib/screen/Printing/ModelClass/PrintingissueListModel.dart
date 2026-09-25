class PrintingIssueListModel {
  final String partyName;
  final String bomNo;
  final String component;
  final double cutLength;
  final double cutWidth;
  final double perPcsWt;
  final int pcs;
  final double netWt;
  final int issuePcs;
  final double issueWt;
  final int balancePcs;
  final double balanceWt;

  PrintingIssueListModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.perPcsWt,
    required this.pcs,
    required this.netWt,
    required this.issuePcs,
    required this.issueWt,
    required this.balancePcs,
    required this.balanceWt,
  });

  factory PrintingIssueListModel.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
    int _i(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

    return PrintingIssueListModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _d(json['cutLength']),
      cutWidth: _d(json['cutWidth']),
      perPcsWt: _d(json['perPcsWt']),
      pcs: _i(json['pcs']),
      netWt: _d(json['netWt']),
      issuePcs: _i(json['issuePcs']),
      issueWt: _d(json['issueWt']),
      balancePcs: _i(json['balancePcs']),
      balanceWt: _d(json['balanceWt']),
    );
  }
}
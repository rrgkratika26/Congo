// ── Model ────────────────────────────────────────────────────────────────────
// File: lib/ScannedItem/Cutting/ReIssueCutPcs/ReIssueCutPcsModel.dart

class ReIssueCutPcsModel {
  final int? iid;
  final String? issueToWorkOrder;
  final String? issueToComponent;
  final String? issueDate;
  final dynamic noOfPcs;
  final double? kg;
  final double? cutWidth;
  final double? cutLength;

  ReIssueCutPcsModel({
    this.iid,
    this.issueToWorkOrder,
    this.issueToComponent,
    this.issueDate,
    this.noOfPcs,
    this.kg,
    this.cutWidth,
    this.cutLength,
  });

  factory ReIssueCutPcsModel.fromJson(Map<String, dynamic> json) {
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String && value.trim().isNotEmpty) {
        return double.tryParse(value);
      }
      return null;
    }

    return ReIssueCutPcsModel(
      iid: json['iid'],
      issueToWorkOrder: json['issuE_TO_WORK_ORDER']?.toString(),
      issueToComponent: json['issuE_TO_COMPONENT']?.toString(),
      issueDate: json['issuE_DATE']?.toString(),
      noOfPcs: json['nO_OF_PCS'],
      kg: parseToDouble(json['kg']),
      cutWidth: parseToDouble(json['cuT_WIDTH']),
      cutLength: parseToDouble(json['cuT_LENGTH']),
    );
  }

  static List<ReIssueCutPcsModel> fromList(List<dynamic> list) =>
      list.map((e) => ReIssueCutPcsModel.fromJson(e)).toList();
}

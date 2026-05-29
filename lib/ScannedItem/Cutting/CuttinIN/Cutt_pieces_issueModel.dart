class CutPieceIssuedModel {
  int? id;
  DateTime? receiveDate;
  String? receiveOrderNo;
  String? component;

  double? receivedNetWt;
  double? receivePcs;

  double? receivedWidth;
  double? receivedCutLength;
  double? perPcsWt;

  double? usedPcs;
  double? usedKg;

  double? remainingPcs;
  double? remainingKg;

  CutPieceIssuedModel({
    this.id,
    this.receiveDate,
    this.receiveOrderNo,
    this.component,
    this.receivedNetWt,
    this.receivePcs,
    this.receivedWidth,
    this.receivedCutLength,
    this.perPcsWt,
    this.usedPcs,
    this.usedKg,
    this.remainingPcs,
    this.remainingKg,
  });

  /// helper converter
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory CutPieceIssuedModel.fromJson(Map<String, dynamic> json) {
    return CutPieceIssuedModel(
      id: json["iid"],

      receiveDate: json["receivE_DATE"] == null
          ? null
          : DateTime.parse(json["receivE_DATE"]),

      receiveOrderNo: json["receivE_ORDER_NO"],
      component: json["component"],

      receivedNetWt: _toDouble(json["receiveD_NET_WT"]),
      receivePcs: _toDouble(json["receivE_PCS"]),

      receivedWidth: _toDouble(json["receiveD_WIDTH"]),
      receivedCutLength: _toDouble(json["receiveD_CUT_LENGTH"]),
      perPcsWt: _toDouble(json["peR_PCS_WT"]),

      usedPcs: _toDouble(json["useD_PCS"]),
      usedKg: _toDouble(json["useD_KG"]),

      remainingPcs: _toDouble(json["remaininG_PCS"]),
      remainingKg: _toDouble(json["remaininG_KG"]),
    );
  }

  static List<CutPieceIssuedModel> fromList(List list) {
    return list.map((e) => CutPieceIssuedModel.fromJson(e)).toList();
  }
}
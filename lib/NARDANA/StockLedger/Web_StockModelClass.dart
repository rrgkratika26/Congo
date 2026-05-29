class StockLedgerModel {
  final int srNo;
  final String fabricCode;

  final double openingQty;
  final double openingWt;

  final double inQty;
  final double inWt;

  final double outQty;

  final double closingQty;
  final double closingWt;

  StockLedgerModel({
    required this.srNo,
    required this.fabricCode,
    required this.openingQty,
    required this.openingWt,
    required this.inQty,
    required this.inWt,
    required this.outQty,
    required this.closingQty,
    required this.closingWt,
  });

  factory StockLedgerModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return StockLedgerModel(
      srNo: json['srNo'] ?? 0,
      fabricCode: json['fabricCode']?.toString() ?? '',

      openingQty: parseDouble(json['opening_Qty']),
      openingWt: parseDouble(json['opening_Wt']),

      inQty: parseDouble(json['in_Qty']),
      inWt: parseDouble(json['in_Wt']),

      outQty: parseDouble(json['out_Qty']),

      closingQty: parseDouble(json['closing_Qty']),
      closingWt: parseDouble(json['closing_Wt']),
    );
  }
}
class LoomProcessModel {
  final String orderNo;
  final String partyName;
  final String fabricCode;
  final double requiredKg;
  final double requiredMtr;
  final double outKg;
  final double outMtr;
  final double balanceKg;
  final double balanceMtr;
  final String flatTubeGusset;
  final String customerName;
  final String poNo;
  final String articleNo;

  LoomProcessModel({
    required this.orderNo,
    required this.partyName,
    required this.fabricCode,
    required this.requiredKg,
    required this.requiredMtr,
    required this.outKg,
    required this.outMtr,
    required this.balanceKg,
    required this.balanceMtr,
    required this.flatTubeGusset,
    required this.customerName,
    required this.poNo,
    required this.articleNo,
  });

  factory LoomProcessModel.fromJson(Map<String, dynamic> json) {
    return LoomProcessModel(
      orderNo: json['orderNo'].toString(),
      partyName: json['partyName'] ?? '',
      fabricCode: json['fabricCode'] ?? '',
      requiredKg: (json['requiredKg'] ?? 0).toDouble(),
      requiredMtr: (json['requiredMtr'] ?? 0).toDouble(),
      outKg: (json['outKg'] ?? 0).toDouble(),
      outMtr: (json['outMtr'] ?? 0).toDouble(),
      balanceKg: (json['balanceKg'] ?? 0).toDouble(),
      balanceMtr: (json['balanceMtr'] ?? 0).toDouble(),
      flatTubeGusset: json['flatTubeGusset'] ?? '',
      customerName: json['customerName'] ?? '',
      poNo: json['poNo'] ?? '',
      articleNo: json['articleNo'] ?? '',
    );
  }
}

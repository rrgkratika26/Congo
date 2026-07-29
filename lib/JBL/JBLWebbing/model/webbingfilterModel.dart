class WebbingFilterModel {
  final String code;
  final String lotNo;
  final String flatTubeGusset;
  final double netWt;
  final String barcode;

  WebbingFilterModel({
    required this.code,
    required this.lotNo,
    required this.flatTubeGusset,
    required this.netWt,
    required this.barcode,
  });

  factory WebbingFilterModel.fromJson(Map<String, dynamic> json) {
    return WebbingFilterModel(
      code: json['code'] ?? '',
      lotNo: json['lotNo'] ?? '',
      flatTubeGusset: json['flatTubeGusset'] ?? '',
      netWt: (json['netWt'] ?? 0).toDouble(),
      barcode: json['barcode'] ?? '',
    );
  }
}
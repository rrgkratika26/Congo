class CuttingStockModel {
  final int id;
  final String code;
  final String barcode;
  final String flattubegusset;
  final double netwt;
  final int quantity;
  final String department;
  final double requirednewt;
  final double requiredqtymtr;

  CuttingStockModel({
    required this.id,
    required this.code,
    required this.barcode,
    required this.flattubegusset,
    required this.netwt,
    required this.quantity,
    required this.department,
    required this.requirednewt,
    required this.requiredqtymtr,
  });

  factory CuttingStockModel.fromJson(Map<String, dynamic> json) {
    return CuttingStockModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      barcode: json['barcode'] ?? '',
      flattubegusset: json['flattubegusset'] ?? '',
      netwt: (json['netwt'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      department: json['department'] ?? '',
      requirednewt: (json['requirednewt'] ?? 0).toDouble(),
      requiredqtymtr: (json['requiredqtymtr'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "barcode": barcode,
      "flattubegusset": flattubegusset,
      "netwt": netwt,
      "quantity": quantity,
      "department": department,
      "requirednewt": requirednewt,
      "requiredqtymtr": requiredqtymtr,
    };
  }

  static List<CuttingStockModel> fromList(List<dynamic> list) {
    return list.map((e) => CuttingStockModel.fromJson(e)).toList();
  }
}
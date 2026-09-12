class ComponentDetailModel {
  final String rollCode;
  final String barcode;
  final double rollWeight;
  final String bomNo;
  final String component;
  final int pcs;
  final double weight;
  final double wastage;

  const ComponentDetailModel({
    required this.rollCode,
    required this.barcode,
    required this.rollWeight,
    required this.bomNo,
    required this.component,
    required this.pcs,
    required this.weight,
    required this.wastage,
  });

  factory ComponentDetailModel.fromJson(Map<String, dynamic> json) {
    return ComponentDetailModel(
      rollCode: json['rollCode']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      rollWeight: _toDouble(json['rollWeight']),
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      pcs: _toInt(json['pcs']),
      weight: _toDouble(json['weight']),
      wastage: _toDouble(json['wastage']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString().replaceAll(',', '').trim(),
    ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().replaceAll(',', '').trim(),
    ) ??
        0.0;
  }

  double get wastagePercentage {
    if (weight <= 0) return 0.0;
    return (wastage / weight) * 100;
  }

  String get searchText {
    return [
      rollCode,
      barcode,
      rollWeight,
      bomNo,
      component,
      pcs,
      weight,
      wastage,
      wastagePercentage,
    ].join(' ').toLowerCase();
  }
}
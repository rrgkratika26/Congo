class ComponentDatewiseModel {
  final String component;
  final int pcs;
  final double weight;
  final double wastage;

  const ComponentDatewiseModel({
    required this.component,
    required this.pcs,
    required this.weight,
    required this.wastage,
  });

  factory ComponentDatewiseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ComponentDatewiseModel(
      component: json['component']?.toString() ?? '',
      pcs: _toInt(json['pcs']),
      weight: _toDouble(json['weight']),
      wastage: _toDouble(json['wastage']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString().replaceAll(',', ''),
    ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().replaceAll(',', ''),
    ) ??
        0.0;
  }

  double get wastagePercentage {
    if (weight <= 0) {
      return 0.0;
    }

    return (wastage / weight) * 100;
  }

  String get searchText {
    return [
      component,
      pcs.toString(),
      weight.toString(),
      wastage.toString(),
      wastagePercentage.toString(),
    ].join(' ').toLowerCase();
  }
}
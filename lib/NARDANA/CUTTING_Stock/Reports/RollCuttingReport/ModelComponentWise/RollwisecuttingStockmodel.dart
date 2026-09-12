class RollWiseCuttingStockModel {
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final double netWt;
  final int pcs;
  final double weightPerPcs;

  final int usedPcs;
  final double usedWt;

  final int balancePcs;
  final double balanceWt;

  const RollWiseCuttingStockModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.netWt,
    required this.pcs,
    required this.weightPerPcs,
    required this.usedPcs,
    required this.usedWt,
    required this.balancePcs,
    required this.balanceWt,
  });

  factory RollWiseCuttingStockModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RollWiseCuttingStockModel(
      partyName: json['partyName']?.toString().trim() ?? '',
      bomNo: json['bomNo']?.toString().trim() ?? '',
      component: json['component']?.toString().trim() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      netWt: _toDouble(json['netWt']),
      pcs: _toInt(json['pcs']),
      weightPerPcs: _toDouble(json['weightPerPcs']),
      usedPcs: _toInt(json['usedPcs']),
      usedWt: _toDouble(json['usedWt']),
      balancePcs: _toInt(json['balancePcs']),
      balanceWt: _toDouble(json['balanceWt']),
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

  String get cutSize {
    if (cutLength == 0 && cutWidth == 0) {
      return '-';
    }

    return '${_formatNumber(cutLength)} × ${_formatNumber(cutWidth)}';
  }

  double get usedPercentage {
    if (netWt <= 0) return 0.0;

    return (usedWt / netWt) * 100;
  }

  double get balancePercentage {
    if (netWt <= 0) return 0.0;

    return (balanceWt / netWt) * 100;
  }

  String get searchText {
    return [
      partyName,
      bomNo,
      component,
      cutLength,
      cutWidth,
      cutSize,
      netWt,
      pcs,
      weightPerPcs,
      usedPcs,
      usedWt,
      balancePcs,
      balanceWt,
    ].join(' ').toLowerCase();
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
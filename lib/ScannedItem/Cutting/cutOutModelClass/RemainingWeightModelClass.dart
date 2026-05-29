class RemainingWeightModel {
  final int code;
  final double rollWeight;
  final int totalUsed;
  final double remaining;

  RemainingWeightModel({
    required this.code,
    required this.rollWeight,
    required this.totalUsed,
    required this.remaining,
  });

  factory RemainingWeightModel.fromJson(Map<String, dynamic> json) {
    return RemainingWeightModel(
      code: int.tryParse(json['code'].toString()) ?? 0,
      rollWeight: json['rollWeight'] ?? 0.0,
      totalUsed: json['totalUsed'] ?? 0,
      remaining: (json['remaining'] ?? 0).toDouble(),
    );
  }
}


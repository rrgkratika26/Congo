class RemainingWeightNardanaModel {
  final double rollWeight;
  final double totalUsed;
  final double remaining;

  RemainingWeightNardanaModel({
    required this.rollWeight,
    required this.totalUsed,
    required this.remaining,
  });

  factory RemainingWeightNardanaModel.fromJson(Map<String, dynamic> json) {
    return RemainingWeightNardanaModel(
      rollWeight: (json['rollWeight'] ?? 0).toDouble(),
      totalUsed: (json['totalUsed'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
    );
  }
}
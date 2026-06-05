class MarketingCountModel {
  final int totalInquiryCount;
  final double netWeight;
  final int rollLength;
  final int noOfRoll;

  MarketingCountModel({
    required this.totalInquiryCount,
    required this.netWeight,
    required this.rollLength,
    required this.noOfRoll,
  });

  factory MarketingCountModel.fromJson(Map<String, dynamic> json) {
    return MarketingCountModel(
      totalInquiryCount: json['totalInquiryCount'] ?? 0,
      netWeight: (json['netWeight'] ?? 0).toDouble(),
      rollLength: json['rollLength'] ?? 0,
      noOfRoll: json['noOfRoll'] ?? 0,
    );
  }
}
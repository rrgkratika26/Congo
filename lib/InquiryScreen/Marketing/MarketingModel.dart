class MarketingCountModel {
  final int totalInquiryCount;
  final double netWeight;
  final double rollLength;
  final int noOfRoll;

  MarketingCountModel({
    required this.totalInquiryCount,
    required this.netWeight,
    required this.rollLength,
    required this.noOfRoll,
  });

  factory MarketingCountModel.fromJson(Map<String, dynamic> json) {
    return MarketingCountModel(
      totalInquiryCount: json["totalInquiryCount"] ?? 0,
      netWeight: (json["netWeight"] as num?)?.toDouble() ?? 0,
      rollLength: (json["rollLength"] as num?)?.toDouble() ?? 0,
      noOfRoll: json["noOfRoll"] ?? 0,
    );
  }
}
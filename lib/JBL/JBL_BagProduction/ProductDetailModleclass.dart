class ProductDetails {
  final bool success;
  final String articleNo;
  final String generatedInquiry;
  final String printStatus;
  final String bagType;
  final String bagSize;
  final String netWeight;

  ProductDetails({
    required this.success,
    required this.articleNo,
    required this.generatedInquiry,
    required this.printStatus,
    required this.bagType,
    required this.bagSize,
    required this.netWeight,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      success: json['success'] ?? false,
      articleNo: json['articleNo'] ?? '',
      generatedInquiry: json['generatedInquiry'] ?? '',
      printStatus: json['printStatus'] ?? '',
      bagType: json['bagType'] ?? '',
      bagSize: json['bagSize'] ?? '',
      netWeight: json['netWeight'] ?? '',
    );
  }
}
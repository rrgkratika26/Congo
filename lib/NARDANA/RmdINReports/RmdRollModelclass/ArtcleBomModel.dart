class ArticleBomModel {
  final List<String> articles;
  final List<String> generatedInquiries;

  ArticleBomModel({
    required this.articles,
    required this.generatedInquiries,
  });

  factory ArticleBomModel.fromJson(Map<String, dynamic> json) {
    return ArticleBomModel(
      articles: List<String>.from(json["articles"] ?? []),
      generatedInquiries:
      List<String>.from(json["generatedInquiries"] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "articles": articles,
      "generatedInquiries": generatedInquiries,
    };
  }
}
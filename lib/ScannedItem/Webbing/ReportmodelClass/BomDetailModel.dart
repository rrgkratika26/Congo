class WebbingBomDetailsModel {
  final List<String> customerNames;
  final List<String> articleNos;
  final List<String> extra13;
  final List<LoopDetail> loopDetails;

  WebbingBomDetailsModel({
    required this.customerNames,
    required this.articleNos,
    required this.extra13,
    required this.loopDetails,
  });

  factory WebbingBomDetailsModel.fromJson(Map<String, dynamic> json) {

    final data = json["data"] ?? {};

    return WebbingBomDetailsModel(
      customerNames: List<String>.from(data["customerNames"] ?? []),
      articleNos: List<String>.from(data["articleNos"] ?? []),
      extra13: List<String>.from(data["extra13"] ?? []),
      loopDetails: (data["loopDetails"] as List<dynamic>? ?? [])
          .map((e) => LoopDetail.fromJson(e))
          .toList(),
    );
  }
}

class LoopDetail {
  final String width;
  final String grm;
  final String extra35;
  final String colorName;
  final String mfLoop;

  LoopDetail({
    required this.width,
    required this.grm,
    required this.extra35,
    required this.colorName,
    required this.mfLoop,
  });

  factory LoopDetail.fromJson(Map<String, dynamic> json) {
    return LoopDetail(
      width: json["width"] ?? "",
      grm: json["grm"] ?? "",
      extra35: json["extra35"] ?? "",
      colorName: json["colorName"] ?? "",
      mfLoop: json["mfLoop"] ?? "",
    );
  }
}

class BomDetailsModel {
  final String width;
  final String grm;
  final String extra35;
  final String colorName;
  final String mfLoop;

  BomDetailsModel({
    required this.width,
    required this.grm,
    required this.extra35,
    required this.colorName,
    required this.mfLoop,
  });

  factory BomDetailsModel.fromJson(Map<String, dynamic> json) {
    return BomDetailsModel(
      width: json["width"] ?? "",
      grm: json["grm"] ?? "",
      extra35: json["extra35"] ?? "",
      colorName: json["colorName"] ?? "",
      mfLoop: json["mfLoop"] ?? "",
    );
  }
}
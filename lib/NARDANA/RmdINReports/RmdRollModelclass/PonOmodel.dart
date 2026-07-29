class PoNumberModel {
  final List<String> poNumbers;

  PoNumberModel({
    required this.poNumbers,
  });

  factory PoNumberModel.fromJson(List<dynamic> json) {
    return PoNumberModel(
      poNumbers: List<String>.from(json),
    );
  }

  List<String> toJson() {
    return poNumbers;
  }
}
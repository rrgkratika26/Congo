class LoomTypeModel {
  final String value;

  LoomTypeModel({required this.value});

  factory LoomTypeModel.fromJson(Map<String, dynamic> json) {
    return LoomTypeModel(
      value: json['value'] ?? '',
    );
  }
}
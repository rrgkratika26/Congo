class LoomMasterModel {
  final String name;

  LoomMasterModel({required this.name});

  factory LoomMasterModel.fromJson(Map<String, dynamic> json) {
    return LoomMasterModel(
      name: json['name'] ?? '',
    );
  }
}
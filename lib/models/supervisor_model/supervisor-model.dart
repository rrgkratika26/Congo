class SupervisorModel {
  final String value;
  final String label;

  SupervisorModel({
    required this.value,
    required this.label,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

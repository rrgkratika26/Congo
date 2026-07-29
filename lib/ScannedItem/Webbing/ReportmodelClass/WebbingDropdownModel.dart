class WebbingDropdownModel {
  final List<String> operators;
  final List<String> supervisors;
  final List<String> locations;

  WebbingDropdownModel({
    required this.operators,
    required this.supervisors,
    required this.locations,
  });

  factory WebbingDropdownModel.fromJson(Map<String, dynamic> json) {
    return WebbingDropdownModel(
      operators: List<String>.from(json['operators'] ?? []),
      supervisors: List<String>.from(json['supervisors'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
    );
  }
}

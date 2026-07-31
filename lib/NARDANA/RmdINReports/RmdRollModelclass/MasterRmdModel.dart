class RmdMasterModel {
  final List<String> customerNames;
  final List<String> supervisors;
  // final List<String> operators;

  final List<String> fabricCodes;
  final List<String> locations;

  RmdMasterModel({
    required this.customerNames,
    required this.supervisors,
    // required this.operators,
    required this.fabricCodes,
    required this.locations,
  });

  factory RmdMasterModel.fromJson(Map<String, dynamic> json) {
    return RmdMasterModel(
      customerNames: List<String>.from(json["customerNames"] ?? []),
      supervisors: List<String>.from(json["supervisors"] ?? []),
      // operators: List<String>.from(json["operators"] ?? []),

      fabricCodes: List<String>.from(json["fabricCodes"] ?? []),
      locations: List<String>.from(json["locations"] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customerNames": customerNames,
      "supervisors": supervisors,
      // "operators": operators,
      "fabricCodes": fabricCodes,
      "locations": locations,
    };
  }
}
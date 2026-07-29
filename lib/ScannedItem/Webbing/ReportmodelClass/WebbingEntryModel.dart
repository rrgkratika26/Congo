class WebbingMasterDropdownModel {
  final List<String> supervisors;
  final List<String> machines;
  final List<String> operators;
  final List<String> sids;

  WebbingMasterDropdownModel({
    required this.supervisors,
    required this.machines,
    required this.operators,
    required this.sids,
  });

  factory WebbingMasterDropdownModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return WebbingMasterDropdownModel(
      supervisors: List<String>.from(data['supervisors'] ?? []),
      machines: List<String>.from(data['machines'] ?? []),
      operators: List<String>.from(data['operators'] ?? []),
      sids: List<String>.from(data['sids'] ?? []),
    );
  }
}




class BomModel {
  final String bomNo;

  BomModel({
    required this.bomNo,
  });

  factory BomModel.fromJson(Map<String, dynamic> json) {
    return BomModel(
      bomNo: json['bomNo'] ?? '',
    );
  }
}
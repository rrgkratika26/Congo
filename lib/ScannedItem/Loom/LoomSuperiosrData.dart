class LoomSupervisorData {
  final List<String> supervisors;
  final List<String> machines;
  final List<String> machineTypes;
  final List<String> operators;

  LoomSupervisorData({
    required this.supervisors,
    required this.machines,
    required this.machineTypes,
    required this.operators,
  });

  factory LoomSupervisorData.fromJson(Map<String, dynamic> json) {
    List<String> parse(dynamic val) =>
        val == null ? [] : List<String>.from(val.map((e) => e.toString()));

    return LoomSupervisorData(
      supervisors: parse(json['supervisors']),
      machines: parse(json['machines']),
      machineTypes: parse(json['machineTypes']),
      operators: parse(json['operator']),
    );
  }
}
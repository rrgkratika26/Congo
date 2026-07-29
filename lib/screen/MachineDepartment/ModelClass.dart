

class MachineModel {
  final int id;
  final String machineType;
  final String machineName;
  final String department;
  final String location;
  final String createdDate;
  final String updatedDate;
  final String capacity;
  final String status;
  final String machineBrId;

  MachineModel({
    required this.id,
    required this.machineType,
    required this.machineName,
    required this.department,
    required this.location,
    required this.createdDate,
    required this.updatedDate,
    required this.capacity,
    required this.status,
    required this.machineBrId,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json["id"] ?? 0,
      machineType: json["machineType"] ?? "",
      machineName: json["machineName"] ?? "",
      department: json["department"] ?? "",
      location: json["location"] ?? "",
      createdDate: json["createdDate"] ?? "",
      updatedDate: json["updatedDate"] ?? "",
      capacity: json["capacity"] ?? "",
      status: json["status"] ?? "",
      machineBrId: json["machineBrId"] ?? "",
    );
  }
}

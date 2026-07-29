class DepartmentModel {
  final String department;

  DepartmentModel({required this.department});

  factory DepartmentModel.fromJson(String dept) {
    return DepartmentModel(department: dept);
  }
}

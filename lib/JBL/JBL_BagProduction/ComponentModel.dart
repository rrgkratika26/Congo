class FibcComponentModel {
  final String component;
  final String department;
  final int requiredPcs;
  final int orderRequiredPcs;
  final int tillProvide;
  final String inquiryNo; // 🔥 ADD THIS

  FibcComponentModel({
    required this.component,
    required this.department,
    required this.requiredPcs,
    required this.orderRequiredPcs,
    required this.tillProvide,
    required this.inquiryNo,
  });

  factory FibcComponentModel.fromJson(Map<String, dynamic> json) {
    return FibcComponentModel(
      component: json['component'] ?? "",
      department: json['department'] ?? "",
      requiredPcs: json['requireD_PCS'] ?? 0,
      orderRequiredPcs: json['ordeR_REQUIRED_PCS'] ?? 0,
      tillProvide: json['tilL_PROVIDE'] ?? 0,
      inquiryNo: json['inquiryNo'] ?? "", // 🔥 check exact key
    );
  }
}
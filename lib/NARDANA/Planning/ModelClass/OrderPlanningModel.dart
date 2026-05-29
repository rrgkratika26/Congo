class OrderPlanningModel {
  final String generatedInquiry;
  String wastage;
  final String customerName;
  final String articleNo;
  final DateTime? todayDate;
  final String quantity;
  final String poNum;

  OrderPlanningModel({
    required this.generatedInquiry,
    required this.wastage,
    required this.customerName,
    required this.articleNo,
    required this.todayDate,
    required this.quantity,
    required this.poNum,
  });

  factory OrderPlanningModel.fromJson(Map<String, dynamic> json) {
    return OrderPlanningModel(
      generatedInquiry: json["generateD_INQUIRY"] ?? "",

      customerName: json["customeR_NAME"] ?? "",

      articleNo: json["articlE_NO"] ?? "",

      todayDate: json["todaY_DATE"] != null
          ? DateTime.parse(json["todaY_DATE"])
          : null,

      quantity: json["quantity"].toString(),

      poNum: json["pO_NUM"] ?? "",
      // API me agar wastage field nahi hai to empty rakho
      wastage: json["wastage"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "generateD_INQUIRY": generatedInquiry,
      "customeR_NAME": customerName,
      "articlE_NO": articleNo,
      "todaY_DATE": todayDate?.toIso8601String(),
      "quantity": quantity,
      "pO_NUM": poNum,
      "wastage": wastage,
    };
  }
}

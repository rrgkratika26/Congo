class CutPcsItem {
  int id;
  String date;
  String orderNo;
  String component;

  double netWt;
  double wastage;

  int pcs;

  double width;
  double cutLength;
  double perPcsWt;

  String poNo;
  String articleNo;
  String bom;
  String customerName;

  bool isSelected;

  CutPcsItem({
    required this.id,
    required this.date,
    required this.orderNo,
    required this.component,
    required this.netWt,
    required this.wastage,
    required this.pcs,
    required this.width,
    required this.cutLength,
    required this.perPcsWt,
    required this.poNo,
    required this.articleNo,
    required this.bom,
    required this.customerName,
    this.isSelected = false,
  });
}


class CuttingApprovalModel {
  String? acceptReject;
  int? id;
  DateTime? date;
  String? orderNo;
  String? component;
  String? netWt;
  String? wastage;
  String? pcs;
  String? width;
  String? cutLength;
  String? perPcsWt;

  CuttingApprovalModel({
    this.acceptReject,
    this.id,
    this.date,
    this.orderNo,
    this.component,
    this.netWt,
    this.wastage,
    this.pcs,
    this.width,
    this.cutLength,
    this.perPcsWt,
  });

  factory CuttingApprovalModel.fromJson(Map<String, dynamic> json) {
    return CuttingApprovalModel(
      acceptReject: json["acceptReject"]?.toString(),

      // 🔹 Convert safely to int
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"].toString()),

      // 🔹 Date parsing
      date: json["date"] != null
          ? DateTime.parse(json["date"])
          : null,

      orderNo: json["orderNo"]?.toString(),
      component: json["component"]?.toString(),

      netWt: json["netWt"]?.toString(),
      wastage: json["wastage"]?.toString(),
      pcs: json["pcs"]?.toString(),
      width: json["width"]?.toString(),
      cutLength: json["cutLength"]?.toString(),
      perPcsWt: json["perPcsWt"]?.toString(),
    );
  }

  static List<CuttingApprovalModel> fromList(List list) {
    return list.map((e) => CuttingApprovalModel.fromJson(e)).toList();
  }
}
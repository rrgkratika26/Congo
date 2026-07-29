class CuttingApprovalModelNardan {
  final String acceptReject;
  final int id;
  final String date;
  final String orderNo;
  final String component;
  final double netWt;
  final double wastage;
  final int pcs;
  final double width;
  final double cutLength;
  final double perPcsWt;
  bool isSelected; // ✅ added

  CuttingApprovalModelNardan({
    required this.acceptReject,
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
    this.isSelected = false, // ✅ added
  });

  factory CuttingApprovalModelNardan.fromJson(Map<String, dynamic> json) {
    return CuttingApprovalModelNardan(
      acceptReject: json["acceptReject"] ?? "",
      id:           json["id"]           ?? 0,
      date:         json["date"]         ?? "",
      orderNo:      json["orderNo"]      ?? "",
      component:    json["component"]    ?? "",
      netWt:        double.tryParse(json["netWt"].toString())     ?? 0.0,
      wastage:      double.tryParse(json["wastage"].toString())   ?? 0.0,
      pcs:          int.tryParse(json["pcs"].toString())          ?? 0,
      width:        double.tryParse(json["width"].toString())     ?? 0.0,
      cutLength:    double.tryParse(json["cutLength"].toString()) ?? 0.0,
      perPcsWt:     double.tryParse(json["perPcsWt"].toString())  ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "acceptReject": acceptReject,
      "id":           id,
      "date":         date,
      "orderNo":      orderNo,
      "component":    component,
      "netWt":        netWt,
      "wastage":      wastage,
      "pcs":          pcs,
      "width":        width,
      "cutLength":    cutLength,
      "perPcsWt":     perPcsWt,
    };
  }

  DateTime? get parsedDate => DateTime.tryParse(date);
}
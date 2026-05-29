class CutPcsItemNardana {
  final int iid;
  final String receiveDate;
  final String partyName;
  final String component;
  final double netWt;
  final int pcs;
  final double width;
  final double cutLength;
  final double perPcsWt;
  final int usedPcs;
  final double usedKg;
  final int remainingPcs;
  final double remainingKg;
  final String poNo;
  final String articleNo;
  final String bom;
  final String customerName;

  bool isSelected;

  CutPcsItemNardana({
    required this.iid,
    required this.receiveDate,
    required this.partyName,
    required this.component,
    required this.netWt,
    required this.pcs,
    required this.width,
    required this.cutLength,
    required this.perPcsWt,
    required this.usedPcs,
    required this.usedKg,
    required this.remainingPcs,
    required this.remainingKg,
    required this.poNo,
    required this.articleNo,
    required this.bom,
    required this.customerName,
    this.isSelected = false,
  });

  factory CutPcsItemNardana.fromJson(Map<String, dynamic> json) {
    return CutPcsItemNardana(
      iid:          json["iid"] ?? 0,
      receiveDate:  json["receivE_DATE"] ?? "",
      partyName:    json["partY_NAME"] ?? "",
      component:    json["component"] ?? "",
      netWt:        double.tryParse(json["neT_WT"].toString()) ?? 0,
      pcs:          int.tryParse(json["pcs"].toString()) ?? 0,
      width:        double.tryParse(json["width"].toString()) ?? 0,
      cutLength:    double.tryParse(json["cuT_LENGTH"].toString()) ?? 0,
      perPcsWt:     double.tryParse(json["peR_PCS_WT"].toString()) ?? 0,
      usedPcs:      int.tryParse(json["useD_PCS"].toString()) ?? 0,
      usedKg:       double.tryParse(json["useD_KG"].toString()) ?? 0,
      remainingPcs: int.tryParse(json["remaininG_PCS"].toString()) ?? 0,
      remainingKg:  double.tryParse(json["remaininG_KG"].toString()) ?? 0,
      poNo:         json["pono"] ?? "",
      articleNo:    json["articlE_NO"] ?? "",
      bom:          json["bom"] ?? "",
      customerName: json["customeR_NAME"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iid":            iid,
      "receivE_DATE":   receiveDate,
      "partY_NAME":     partyName,
      "component":      component,
      "neT_WT":         netWt,
      "pcs":            pcs,
      "width":          width,
      "cuT_LENGTH":     cutLength,
      "peR_PCS_WT":     perPcsWt,
      "useD_PCS":       usedPcs,
      "useD_KG":        usedKg,
      "remaininG_PCS":  remainingPcs,
      "remaininG_KG":   remainingKg,
      "pono":           poNo,
      "articlE_NO":     articleNo,
      "bom":            bom,
      "customeR_NAME":  customerName,
    };
  }
}
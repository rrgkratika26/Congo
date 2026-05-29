// packaging_report_model.dart
import 'baseModel.dart';

int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class PackagingReportModel implements ReportRowModel {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int openingPackages;
  final int openingPcs;
  final double openingKg;
  final int transPackages;
  final int transPcs;
  final double transKg;

  PackagingReportModel({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.openingPackages,
    required this.openingPcs,
    required this.openingKg,
    required this.transPackages,
    required this.transPcs,
    required this.transKg,
  });

  factory PackagingReportModel.fromJson(Map<String, dynamic> json) {
    return PackagingReportModel(
      partyName: json["PARTY_NAME"] ?? "",
      bomNo: json["BOM_NO"] ?? "",
      articleNo: json["ARTICLE_NO"] ?? "",
      openingPackages: parseInt(json["OPENING_PACKAGES"]),
      openingPcs: parseInt(json["OPENING_PCS"]),
      openingKg: parseDouble(json["OPENING_KG"]),
      transPackages: parseInt(json["TRANS_PACKAGES"]),
      transPcs: parseInt(json["TRANS_PCS"]),
      transKg: parseDouble(json["TRANS_KG"]),
    );
  }

  // ✅ Add this method to make it compatible with the table
  Map<String, dynamic> toJson() {
    return {
      "PARTY_NAME": partyName,
      "BOM_NO": bomNo,
      "ARTICLE_NO": articleNo,
      "OPENING_PACKAGES": openingPackages,
      "OPENING_PCS": openingPcs,
      "OPENING_KG": openingKg,
      "TRANS_PACKAGES": transPackages,
      "TRANS_PCS": transPcs,
      "TRANS_KG": transKg,
    };
  }
}
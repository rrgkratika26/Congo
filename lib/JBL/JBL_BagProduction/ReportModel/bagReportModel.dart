// bag_report_model.dart
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

class BagReportModel implements ReportRowModel {
  final String woNumber;
  final int quantity;
  final int openingBalance;
  final int transactionQty;
  final int pendingBags;

  BagReportModel({
    required this.woNumber,
    required this.quantity,
    required this.openingBalance,
    required this.transactionQty,
    required this.pendingBags,
  });

  factory BagReportModel.fromJson(Map<String, dynamic> json) {
    return BagReportModel(
      woNumber: json['WO_NUMBER'] ?? '',
      quantity: parseInt(json['QUANTITY']),
      openingBalance: parseInt(json['OPENING_BALANCE']),
      transactionQty: parseInt(json['TRANSACTION_QTY']),
        pendingBags: parseInt(json['PENDING_BAGS'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WO_NUMBER': woNumber,
      'QUANTITY': quantity,
      'OPENING_BALANCE': openingBalance,
      'TRANSACTION_QTY': transactionQty,
      'PENDING_BAGS':pendingBags,
    };
  }
}
//
// // packaging_report_model.dart
// class PackagingReportModel {
//   final String partyName;
//   final String bomNo;
//   final String articleNo;
//   final int openingPackages;
//   final int openingPcs;
//   final double openingKg;
//   final int transPackages;
//   final int transPcs;
//   final double transKg;
//
//   PackagingReportModel({
//     required this.partyName,
//     required this.bomNo,
//     required this.articleNo,
//     required this.openingPackages,
//     required this.openingPcs,
//     required this.openingKg,
//     required this.transPackages,
//     required this.transPcs,
//     required this.transKg,
//   });
//
//   factory PackagingReportModel.fromJson(Map<String, dynamic> json) {
//     return PackagingReportModel(
//       partyName: json["PARTY_NAME"] ?? "",
//       bomNo: json["BOM_NO"] ?? "",
//       articleNo: json["ARTICLE_NO"] ?? "",
//       openingPackages: parseInt(json["OPENING_PACKAGES"]),
//       openingPcs: parseInt(json["OPENING_PCS"]),
//       openingKg: parseDouble(json["OPENING_KG"]),
//       transPackages: parseInt(json["TRANS_PACKAGES"]),
//       transPcs: parseInt(json["TRANS_PCS"]),
//       transKg: parseDouble(json["TRANS_KG"]),
//     );
//   }
// }

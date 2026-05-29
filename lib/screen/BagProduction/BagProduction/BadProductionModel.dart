import 'package:flutter/cupertino.dart';

class BagEntryModel {
  final String customerName;
  final String generatedInquiry;
  final String articleNo;
  final int quantity;
  final String poNum;
  final int remainingBag;
  final String bagType;
  final String bagSize;
  final int bagWeight;


  BagEntryModel({
    required this.customerName,
    required this.generatedInquiry,
    required this.articleNo,
    required this.quantity,
    required this.poNum,
    required this.remainingBag,
    required this.bagType,        // ✅
    required this.bagSize,        // ✅
    required this.bagWeight,      //
  });

  factory BagEntryModel.fromJson(Map<String, dynamic> json) {
    // debugPrint("REMAINING BAG FROM API: ${json['remaininG_BAG']}");  // ← ADD
    // debugPrint("FULL JSON: $json");
    return BagEntryModel(
      customerName: json['customeR_NAME'] ?? '',
      generatedInquiry: json['generated_inquiry'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      quantity: json['quantity'] ?? 0,
      poNum: json['pO_NUM'] ?? '',
      remainingBag: json['remaininG_BAG'] ?? 0,
      bagType: json['baG_TYPE'] ?? '',
      bagSize: json['baG_SIZE'] ?? '',
      bagWeight: json['baG_WEIGHT'] ?? 0,
    );
  }
}
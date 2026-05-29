import 'package:flutter/cupertino.dart';

class BagProductionReport {
  // final int tableQuantity;
  final int srno;
  final DateTime date;
  final String shift;
  final String partyName;
  final String bomNo;
  final String articleNo;
  final String poNum;
  final String printStatus;
  final String bagType;
  final int productionQty;
  final int bagOut;
  final int requireD_BAG;
  final String bagSize;
  final int bagGwtGm;
  final String line;
  final String contractor;
  final String remark;

  BagProductionReport({
    required this.srno,
    required this.date,
    required this.shift,
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.poNum,
    required this.printStatus,
    required this.bagType,
    required this.productionQty,
    required this.bagOut,
    required this.requireD_BAG,
    required this.bagSize,
    required this.bagGwtGm,
    required this.line,
    required this.contractor,
    required this.remark,
    // required this.tableQuantity,
  });

  factory BagProductionReport.fromJson(Map<String, dynamic> json) {
    // debugPrint("API Required Bag: ${json['requireD_BAG']}");
    // debugPrint("API Table Quantity: ${json['tableQuantity']}");
    return BagProductionReport(
      srno: json['srno'] ?? 0,
      date: DateTime.parse(json['date']),
      shift: json['shift'] ?? '',
      partyName: json['partyname'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      poNum: json['pO_NUM'] ?? '',
      printStatus: json['prinT_STATUS'] ?? '',
      bagType: json['bagtype'] ?? '',
      productionQty: json['productioN_QTY'] ?? 0,
      bagOut: json['baG_OUT'] ?? 0,
      requireD_BAG: json['requireD_BAG'] ?? 0,
      // tableQuantity: json['tableQuantity'] ?? 0,

      bagSize: json['bagsize'] ?? '',
      bagGwtGm: json['baggwtgm'] ?? 0,
      line: json['line'] ?? '',
      contractor: json['contractor'] ?? '',
      remark: json['remark'] ?? '',
      // tableQuantity: json['tableQuantity'] ?? 0,
    );
  }
}

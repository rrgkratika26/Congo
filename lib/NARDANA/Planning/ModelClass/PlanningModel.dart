// class PlanningModel {
//   final String rowList;
//   final String fabricCode;
//   final String fabricGsm;
//   final String lamination;
//   final String fabricSize;
//   final String cutSize;
//   final String reqMtr;
//   final String reqKg;
//   final String reqPcs;
//   final String department;
//   final String totalMtr;
//   final String totalKg;
//   final String combinedColumn;
//   final String articleNo;
//   final String piNo;
//   final String startDate;
//   final String endDate;
//   final String quantity;
//   String wastage;
//
//   PlanningModel({
//     required this.rowList,
//     required this.fabricCode,
//     required this.fabricGsm,
//     required this.lamination,
//     required this.fabricSize,
//     required this.cutSize,
//     required this.reqMtr,
//     required this.reqKg,
//     required this.reqPcs,
//     required this.department,
//     required this.totalMtr,
//     required this.totalKg,
//     required this.combinedColumn,
//     required this.articleNo,
//     required this.piNo,
//     required this.startDate,
//     required this.endDate,
//     required this.quantity,
//     required this.wastage, // <-- add
//   });
//
//   factory PlanningModel.fromJson(Map<String, dynamic> json) {
//     return PlanningModel(
//       rowList: json["roW_LIST"]?.toString() ?? "",
//
//       fabricCode: json["hemminG_FS_DS"]?.toString() ?? "",
//
//       fabricGsm: json["fabriC_GSM"]?.toString() ?? "",
//
//       lamination: json["lamination"]?.toString() ?? "",
//
//       fabricSize: json["fabriC_SIZE"]?.toString() ?? "",
//
//       cutSize: json["cuT_SIZE"]?.toString() ?? "",
//
//       reqMtr: json["extrA12"]?.toString() ?? "",
//
//       reqKg: json["extrA35"]?.toString() ?? "",
//
//       reqPcs: json["valuE_1"]?.toString() ?? "",
//
//       department: json["department"]?.toString() ?? "",
//
//       totalMtr: json["totaL_MTR"]?.toString() ?? "",
//
//       totalKg: json["totaL_KG"]?.toString() ?? "",
//
//       combinedColumn: json["combineD_COLUMN"]?.toString() ?? "",
//
//       articleNo: json["articlE_NO"]?.toString() ?? "",
//
//       piNo: json["extrA13"]?.toString() ?? "",
//
//       startDate: json["extrA38"]?.toString() ?? "",
//
//       endDate: json["extrA39"]?.toString() ?? "",
//
//       quantity: json["quantity"]?.toString() ?? "",
//       wastage: json["wastage"]?.toString() ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "roW_LIST": rowList,
//       "hemminG_FS_DS": fabricCode,
//       "fabriC_GSM": fabricGsm,
//       "lamination": lamination,
//       "fabriC_SIZE": fabricSize,
//       "cuT_SIZE": cutSize,
//       "extrA12": reqMtr,
//       "extrA35": reqKg,
//       "valuE_1": reqPcs,
//       "department": department,
//       "totaL_MTR": totalMtr,
//       "totaL_KG": totalKg,
//       "combineD_COLUMN": combinedColumn,
//       "articlE_NO": articleNo,
//       "extrA13": piNo,
//       "extrA38": startDate,
//       "extrA39": endDate,
//       "quantity": quantity,
//       "wastage": wastage,
//     };
//   }
// }






class PlanningModel {
  final String rowList;
  final String fabricCode;
  final String fabricGsm;
  final String lamination;
  final String fabricSize;
  final String cutSize;
  final String reqMtr;
  final String reqKg;
  final String reqPcs;

  String department; // remove final
  String wastage;    // remove final

  final String totalMtr;
  final String totalKg;
  final String combinedColumn;
  final String articleNo;
  final String piNo;
  final String startDate;
  final String endDate;
  final String quantity;

  PlanningModel({
    required this.rowList,
    required this.fabricCode,
    required this.fabricGsm,
    required this.lamination,
    required this.fabricSize,
    required this.cutSize,
    required this.reqMtr,
    required this.reqKg,
    required this.reqPcs,

    required this.department,
    required this.wastage,

    required this.totalMtr,
    required this.totalKg,
    required this.combinedColumn,
    required this.articleNo,
    required this.piNo,
    required this.startDate,
    required this.endDate,
    required this.quantity,
  });

  factory PlanningModel.fromJson(Map<String, dynamic> json) {
    return PlanningModel(
      rowList: json["roW_LIST"]?.toString() ?? "",
      fabricCode: json["hemminG_FS_DS"]?.toString() ?? "",
      fabricGsm: json["fabriC_GSM"]?.toString() ?? "",
      lamination: json["lamination"]?.toString() ?? "",
      fabricSize: json["fabriC_SIZE"]?.toString() ?? "",
      cutSize: json["cuT_SIZE"]?.toString() ?? "",
      reqMtr: json["extrA12"]?.toString() ?? "",
      reqKg: json["extrA35"]?.toString() ?? "",
      reqPcs: json["valuE_1"]?.toString() ?? "",

      department: json["department"]?.toString() ?? "",
      wastage: json["wastage"]?.toString() ?? "",

      totalMtr: json["totaL_MTR"]?.toString() ?? "",
      totalKg: json["totaL_KG"]?.toString() ?? "",
      combinedColumn: json["combineD_COLUMN"]?.toString() ?? "",
      articleNo: json["articlE_NO"]?.toString() ?? "",
      piNo: json["extrA13"]?.toString() ?? "",
      startDate: json["extrA38"]?.toString() ?? "",
      endDate: json["extrA39"]?.toString() ?? "",
      quantity: json["quantity"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roW_LIST": rowList,
      "hemminG_FS_DS": fabricCode,
      "fabriC_GSM": fabricGsm,
      "lamination": lamination,
      "fabriC_SIZE": fabricSize,
      "cuT_SIZE": cutSize,
      "extrA12": reqMtr,
      "extrA35": reqKg,
      "valuE_1": reqPcs,
      "department": department,
      "wastage": wastage,
      "totaL_MTR": totalMtr,
      "totaL_KG": totalKg,
      "combineD_COLUMN": combinedColumn,
      "articlE_NO": articleNo,
      "extrA13": piNo,
      "extrA38": startDate,
      "extrA39": endDate,
      "quantity": quantity,
    };
  }
}
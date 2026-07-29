// import 'modelClass/RollData.dart';
//
// class LaminationOutModel {
//   final RollData rollData;
//   final List<String> supervisors;
//   final List<String> operators;
//   final List<String> opName;
//
//   // final String? purchsE_ORDER;
//   // final String? requirednewt;
//   // final String? modelno;
// final String bomNo;
//   final String lamination;
//   final String modelNo;
//    // ✅ use only this for BOM
//
//   LaminationOutModel({
//     required this.rollData,
//     required this.supervisors,
//     required this.operators,
//     required this.lamination,
//     required this.modelNo,
//     required this.bomNo, required this.opName,
//
//   });
//
//   factory LaminationOutModel.fromJson(Map<String, dynamic> json) {
//     return LaminationOutModel(
//       rollData: RollData.fromJson(json['rollData'] ?? {}),
//       supervisors: List<String>.from(json['supervisors'] ?? []),
//       operators: List<String>.from(json['operators'] ?? []),
//       opName: List<String>.from(json['oP1NAME'] ?? []),
//
//       lamination: json['lamination']?.toString() ?? '',
//       modelNo: json['modelNo']?.toString() ?? '',
//       // purchsE_ORDER: json['purchsE_ORDER']?.toString() ?? '',
//       // requirednewt: json['requirednewt']?.toString() ?? '',
//
//       // ✅ FIX: BOM should come from rollData if needed
//       bomNo: json['partyName']?.toString() ??
//           json['rollData']?['partyName']?.toString() ?? '',
//     );
//   }
// }

import 'modelClass/RollData.dart';

class LaminationOutModel {
  final RollData rollData;
  final List<String> supervisors;
  final List<String> operators;
  final List<String> opName;

  // final String? purchsE_ORDER;
  // final String? requirednewt;
  // final String? modelno;

  final String lamination;
  final String modelNo;
  final String bomNo; // ✅ use only this for BOM

  LaminationOutModel({
    required this.rollData,
    required this.supervisors,
    required this.operators,
    required this.lamination,
    required this.modelNo,
    required this.bomNo, required this.opName,
  });

  factory LaminationOutModel.fromJson(Map<String, dynamic> json) {
    return LaminationOutModel(
      rollData: RollData.fromJson(json['rollData'] ?? {}),
      supervisors: List<String>.from(json['supervisors'] ?? []),
      operators: List<String>.from(json['operators'] ?? []),
      opName: List<String>.from(json['oP1NAME'] ?? []),

      lamination: json['lamination']?.toString() ?? '',
      modelNo: json['modelNo']?.toString() ?? '',
      // purchsE_ORDER: json['purchsE_ORDER']?.toString() ?? '',
      // requirednewt: json['requirednewt']?.toString() ?? '',

      // ✅ FIX: BOM should come from rollData if needed
      bomNo: json['boM_NO']?.toString() ??
          json['boM_NO']?['boM_NO']?.toString() ?? '',
    );
  }
}
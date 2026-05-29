import 'CuttinfType.dart';

class RollwiseModel implements BaseModel {
  final int srNo;
  final String rollNo;
  final String fabricWidth;
  final String fabricGsm;
  final double netWt;
  final double balance;
  final int cutPcs;

  RollwiseModel.fromJson(Map<String, dynamic> json)
      : srNo = int.tryParse(json["SRNO"].toString()) ?? 0,
        rollNo = json["ROLL_NO"] ?? "",
        fabricWidth = json["FABRIC_WIDTH"] ?? "",
        fabricGsm = json["FABRIC_GSM"] ?? "",
        netWt = double.tryParse(json["NET_WT"].toString()) ?? 0.0,
        balance = double.tryParse(json["BALANCE"].toString()) ?? 0,
        cutPcs = int.tryParse(json["CUT_PCS"].toString()) ?? 0;

  @override
  Map<String, dynamic> toJson() => {
    "SRNO": srNo,
    "ROLL_NO": rollNo,
    "FABRIC_WIDTH": fabricWidth,
    "FABRIC_GSM": fabricGsm,
    "NET_WT": netWt,
    "BALANCE": balance,
    "CUT_PCS": cutPcs,
  };
}
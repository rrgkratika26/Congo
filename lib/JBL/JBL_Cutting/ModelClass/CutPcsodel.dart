import 'CuttinfType.dart';

class CutPcsModel implements BaseModel {
  final int id;
  final String rollNo;
  final String fabricCode;
  final String date;
  final int netWt;
  final String cutLength;
  final String cutWidth;
  final String pcs;
  final double wastage;

  CutPcsModel.fromJson(Map<String, dynamic> json)
      : id = int.tryParse(json["id"].toString()) ?? 0,
        rollNo = json["ROLL_NO"] ?? "",
        fabricCode = json["FABRIC_CODE"] ?? "",
  date = json["DATE"] ?? "",
        netWt = int.tryParse(json["NET_WT"].toString()) ?? 0,
        cutLength = json["CUT_LENGTH"] ?? "",
        cutWidth = json["CUT_WIDTH"] ?? "",
        pcs = json["PCS"] ?? "",
        wastage = double.tryParse(json["WASTAGE"].toString()) ?? 0;

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "ROLL_NO": rollNo,
    "FABRIC_CODE": fabricCode,
    "DATE":date,
    "NET_WT": netWt,
    "CUT_LENGTH": cutLength,
    "CUT_WIDTH": cutWidth,
    "PCS": pcs,
    "WASTAGE": wastage,
  };
}
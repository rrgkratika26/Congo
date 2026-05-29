import 'CuttinfType.dart';

class CuttingInModel extends BaseModel {
  final int srNo;
  final int rollCode;
  final String barcode;
  final String loomType;
  final String loomNo;
  final String fabricCode;

  final double grossWeight;
  final double netWeight;
  final int rollLength;
  final double avgWeight;

  final String operatorName;
  final String loomOperator;
  final String supervisorName;

  final String date;
  final String time;

  final String partyName;
  final String workOrderNo;
  final String contNo;

  final double requiredQuantity;
  final double requiredQuantityMtr;

  final String tareWeight;
  final String department;
  final String issueToDept;
  final String status;

  final String entryIn;
  final String entryOut;

  final String mash;
  final String fabricType;
  final String fabricConstruction;
  final String color;

  final String fabricWidth;
  final String fabricGsm;
  final String laminationType;
  final String cutType;
  final String specialIdentification;

  final double gsmMtrGm;

  CuttingInModel.fromJson(Map<String, dynamic> json)
      : srNo = int.tryParse(json["SR_NO"].toString()) ?? 0,
        rollCode = int.tryParse(json["ROLL_CODE"].toString()) ?? 0,
        barcode = json["BARCODE"] ?? "",
        loomType = json["LOOM_TYPE"] ?? "",
        loomNo = json["LOOM_NO"] ?? "",
        fabricCode = json["FABRIC_CODE"] ?? "",

        grossWeight = double.tryParse(json["GROSS_WEIGHT"].toString()) ?? 0.0,
        netWeight = double.tryParse(json["NET_WEIGHT"].toString()) ?? 0.0,
        rollLength = int.tryParse(json["ROLL_LENGTH"].toString()) ?? 0,
        avgWeight = double.tryParse(json["AVG_WEIGHT"].toString()) ?? 0.0,

        operatorName = json["OPERATOR_NAME"] ?? "",
        loomOperator = json["LOOMOPARETOR1"] ?? "",
        supervisorName = json["SUPERVISOR_NAME"] ?? "",

        date = json["DATE"] ?? "",
        time = json["TIME"] ?? "",

        partyName = json["PARTYNAME"] ?? "",
        workOrderNo = json["WORK_ORDER_NO"] ?? "",
        contNo = json["CONT_NO"] ?? "",

        requiredQuantity =
            double.tryParse(json["REQUIRED_QUANTITY"].toString()) ?? 0.0,
        requiredQuantityMtr =
            double.tryParse(json["REQUIRED_QUANTITY_MTR"].toString()) ?? 0.0,

        tareWeight = json["TARE_WEIGHT"].toString(),
        department = json["DEPARTMENT"] ?? "",
        issueToDept = json["ISSUE_TO_DEPT"] ?? "",
        status = json["STATUS"] ?? "",

        entryIn = json["ENTRYIN"].toString(),
        entryOut = json["ENTRYOUT"] ?? "",

        mash = json["MASH"] ?? "",
        fabricType = json["FABRIC_TYPE"] ?? "",
        fabricConstruction = json["FABRIC_CONSTRUCTION"] ?? "",
        color = json["COLOR"] ?? "",

        fabricWidth = json["FABRIC_WIDTH"] ?? "",
        fabricGsm = json["FABRIC_GSM"] ?? "",
        laminationType = json["LAMINATION_TYPE"] ?? "",
        cutType = json["CUT_TYPE"] ?? "",
        specialIdentification = json["SPECIAL_IDENTIFICATION"] ?? "",

        gsmMtrGm = double.tryParse(json["GSM_MTR_GM"].toString()) ?? 0.0;

  Map<String, dynamic> toJson() => {
    "SR_NO": srNo,
    "ROLL_CODE": rollCode,
    "BARCODE": barcode,
    "LOOM_TYPE": loomType,
    "LOOM_NO": loomNo,
    "FABRIC_CODE": fabricCode,
    "GROSS_WEIGHT": grossWeight,
    "NET_WEIGHT": netWeight,
    "ROLL_LENGTH": rollLength,
    "AVG_WEIGHT": avgWeight,
    "OPERATOR_NAME": operatorName,
    "LOOMOPARETOR1": loomOperator,
    "SUPERVISOR_NAME": supervisorName,
    "DATE": date,
    "TIME": time,
    "PARTYNAME": partyName,
    "WORK_ORDER_NO": workOrderNo,
    "CONT_NO": contNo,
    "REQUIRED_QUANTITY": requiredQuantity,
    "REQUIRED_QUANTITY_MTR": requiredQuantityMtr,
    "TARE_WEIGHT": tareWeight,
    "DEPARTMENT": department,
    "ISSUE_TO_DEPT": issueToDept,
    "STATUS": status,
    "ENTRYIN": entryIn,
    "ENTRYOUT": entryOut,
    "MASH": mash,
    "FABRIC_TYPE": fabricType,
    "FABRIC_CONSTRUCTION": fabricConstruction,
    "COLOR": color,
    "FABRIC_WIDTH": fabricWidth,
    "FABRIC_GSM": fabricGsm,
    "LAMINATION_TYPE": laminationType,
    "CUT_TYPE": cutType,
    "SPECIAL_IDENTIFICATION": specialIdentification,
    "GSM_MTR_GM": gsmMtrGm,
  };
}
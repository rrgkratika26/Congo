import '../../JBL_Cutting/ModelClass/CuttinfType.dart';

class WebbingInModel extends BaseModel {
  final int srNo;
  final int rollCode;

  final String lotNo;
  final String fabricCode;
  final double rollWeightKg;
  final double rollLengthMtr;
  final String supervisorName;
  final String operatorName;
  // final String date;
  // final String time;
  // final String weekNo;
  // final String partyName;
  final String workOrderNo;
  // final String jobWork;
  final double requiredNewt;
  final double requiredQtyMtr;
  // final String machine;
  // final String modelNo;
  final String location;

  WebbingInModel.fromJson(Map<String, dynamic> json)
    : srNo = int.tryParse(json['Sr. No.']?.toString() ?? '0') ?? 0,
      rollCode = int.tryParse(json['ROLL CODE']?.toString() ?? '0') ?? 0,

      lotNo = json['LOT_NO']?.toString() ?? '', // ✅ LOT_NO
      fabricCode = json['FABRIC_CODE']?.toString() ?? '',
      rollWeightKg =
          double.tryParse(json['ROLL_WEIGHT(KG)']?.toString() ?? '0') ??
          0.0, // ✅
      rollLengthMtr =
          double.tryParse(json['ROLL LENGTH (Mtr)']?.toString() ?? '0') ??
          0.0, // ✅
      supervisorName = json['SUPERVISOR NAME']?.toString() ?? '', // ✅
      operatorName = json['OPERATOR NAME']?.toString() ?? '', // ✅
      // date           = json['DATE']?.toString() ?? '',              // ✅ DATE (all caps)
      // time           = json['TIME']?.toString() ?? '',              // ✅ TIME (all caps)
      // weekNo         = json['WEEKNO']?.toString() ?? '',
      // partyName      = json['PARTYNAME']?.toString() ?? '',
      workOrderNo = json['WORKORDERNO']?.toString() ?? '',
      // jobWork        = json['JOBWORK']?.toString() ?? '',
      requiredNewt =
          double.tryParse(json['REQUIREDNEWT']?.toString() ?? '0') ?? 0.0,
      requiredQtyMtr =
          double.tryParse(json['REQUIREDQTYMTR']?.toString() ?? '0') ?? 0.0,
      // machine        = json['MACHINE']?.toString() ?? '',
      // modelNo        = json['MODELNO']?.toString() ?? '',
      location = json['Location']?.toString() ?? '';

  @override
  Map<String, dynamic> toJson() => {
    'Sr No': srNo,
    'Roll Code': rollCode,

    'Lot No': lotNo,
    'Fabric Code': fabricCode,
    'Weight (KG)': rollWeightKg,
    'Length (Mtr)': rollLengthMtr,
    'Supervisor': supervisorName,
    'Operator': operatorName,
    // 'Date'         : date,
    // 'Time'         : time,
    // 'Week No'      : weekNo,
    // 'Party Name'   : partyName,
    'Work Order No': workOrderNo,
    // 'Job Work'     : jobWork,
    'Req Newt': requiredNewt,
    'Req Qty Mtr': requiredQtyMtr,
    // 'Machine'      : machine,
    // 'Model No'     : modelNo,
    'Location': location,
  };
}

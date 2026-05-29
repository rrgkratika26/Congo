class RollData {
  final int id;
  final int srno;
  final String machine;
  final String operator;
  final String supervisor;
  final String partyName;
  final String workOrderNo;
  final String fabricWidth;
  final String color;
  final String gsm;
  final String? machineno;
  final String cutType;
  final String sid;
  final String articleNo;
  final String grossWeight;
  final String tareWeight;
  final String? avgWeightGm;
  final String? mesh;
  final String generatedCode;
  final String specialId;
  final String fabricTypeOrUse;
  final String fabricBaffleType;
  final String lamination; // ✅ FIX
  final String modelno; // ✅ FIX

  final String rollWeightCalc;
  final String rollLengthCalc;
  final String tareWeightCalc;
  final String grossWeightCalc;
  final String avgWeight;
  final String purchsE_ORDER;
  // final String? requirednewt;
  // final String? modelno;

  final String requirednewt; // ✅ FIX
  final String requiredqtymtr; // ✅ FIX

  RollData.fromJson(Map<String, dynamic> json)
      : id = int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        srno = int.tryParse(json['srno']?.toString() ?? '0') ?? 0,
        machine = json['machine']?.toString() ?? '',
        operator = json['operator']?.toString() ?? '',
        supervisor = json['supervisor']?.toString() ?? '',
        partyName = json['partyName']?.toString() ?? '',
        workOrderNo = json['workOrderNo']?.toString() ?? '',
        fabricWidth = json['fabricWidth']?.toString() ?? '',
        color = json['color']?.toString() ?? '',
        gsm = json['gsm']?.toString() ?? '',
        machineno = json['machineno']?.toString() ?? '',
        cutType = json['cutType']?.toString() ?? '',
        sid = json['sid']?.toString() ?? '',
        articleNo = json['articleNo']?.toString() ?? '',
        grossWeight = json['grossWeight']?.toString() ?? '',
        tareWeight = json['tareWeight']?.toString() ?? '',
        avgWeightGm = json['avgWeightGm']?.toString(),
        mesh = json['mesh']?.toString() ?? '',
        generatedCode = json['generatedCode']?.toString() ?? '',
        specialId = json['specialId']?.toString() ?? '',
        fabricTypeOrUse = json['fabricTypeOrUse']?.toString() ?? '',
        fabricBaffleType = json['fabricBaffleType']?.toString() ?? '',
        lamination = json['lamination']?.toString() ?? '',
        modelno = json['modelno']?.toString() ?? '',
        rollWeightCalc = json['rollWeightCalc']?.toString() ?? '',
        rollLengthCalc = json['rollLengthCalc']?.toString() ?? '',
        tareWeightCalc = json['tareWeightCalc']?.toString() ?? '',
        grossWeightCalc = json['grossWeightCalc']?.toString() ?? '',
        avgWeight = json['avgWeight']?.toString() ?? '',
        requirednewt = json['requirednewt']?.toString() ?? '',
        purchsE_ORDER = json['purchsE_ORDER']?.toString() ?? '',
        requiredqtymtr = json['requiredqtymtr']?.toString() ?? '';

}




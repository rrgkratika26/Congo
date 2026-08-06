class DashboardSummary {
  final double planning;
  //
  final double cutKg;
  final double cutMtr;
  final double cutTotal;
  final double woCount;
  final double bomCount;
  final double inquiryCount;

  final double rmdNetWeight;
  final double rmdRollLength;
  final double rmdNoOfRoll;

  final double laminationNetWeight;
  final double laminationRollLength;
  final double laminationNoOfRoll;
  final double cutPieceKg;
  final double cutPieceTotal;

  final double totalBagProduction;
  final double totalNetWt;
  final double totalBagOut;

  final double inBagNwt;
  final double inCount;
  final double outBagNwt;
  final double outCount;

  final double tapeLineKg;
  final double loomNetWeight;
  final double loomRollLength;
  final double loomNoOfRoll;

  final double baleIn;
  final double baleout;
  final double baleNoOfRoll;



  DashboardSummary({
    required this.planning,
    //
    required this.cutKg,
    required this.cutMtr,
    required this.cutTotal,
    //
    required this.cutPieceKg,
    required this.cutPieceTotal,

    required this.totalBagProduction,
    required this.totalNetWt,
    required this.totalBagOut,

    required this.inBagNwt,
    required this.inCount,
    required this.outBagNwt,
    required this.outCount,
    //
    required this.tapeLineKg,

    required this.woCount,
    required this.bomCount,
    required this.inquiryCount,

    required this.rmdNetWeight,
    required this.rmdRollLength,
    required this.rmdNoOfRoll,

    required this.laminationNetWeight,
    required this.laminationRollLength,
    required this.laminationNoOfRoll,
    required this.loomNetWeight,
    required this.loomRollLength,
    required this.loomNoOfRoll,
    required this.baleIn,
    required this.baleout,
    required this.baleNoOfRoll,



  });

  static double toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is int) return value.toDouble();

    if (value is double) return value;

    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory DashboardSummary.fromJson({
    required Map<String, dynamic> planningJson,
    required Map<String, dynamic> cuttingJson,
    required Map<String, dynamic> cutPcsJson,
    required Map<String, dynamic> bagJson,
    required Map<String, dynamic> bailingJson,
    required Map<String, dynamic> tapeJson,

    required Map<String, dynamic> loomJson,

    required Map<String, dynamic> woJson,
    required Map<String, dynamic> rmdJson,
    required Map<String, dynamic> laminationJson,
    required Map<String, dynamic> bomJson,
    required Map<String, dynamic> inquiryJson,


  }) {
    return DashboardSummary(
      planning: toDouble(planningJson["planning"]),
      //
      cutKg: toDouble(cuttingJson["cutKg"]),
      cutMtr: toDouble(cuttingJson["cutMtr"]),
      cutTotal: toDouble(cuttingJson["cutTotal"]),

      cutPieceKg: toDouble(cutPcsJson["cutPieceKg"]),
      cutPieceTotal: toDouble(cutPcsJson["cutPieceTotal"]),

      totalBagProduction: toDouble(bagJson["totalBagProduction"]),
      totalNetWt: toDouble(bagJson["totalNetWt"]),
      totalBagOut: toDouble(bagJson["totalBagOut"]),

      inBagNwt: toDouble(bailingJson["inBagNwt"]),
      inCount: toDouble(bailingJson["inCount"]),
      outBagNwt: toDouble(bailingJson["outBagNwt"]),
      outCount: toDouble(bailingJson["outCount"]),

      tapeLineKg: toDouble(tapeJson["tapeLineKg"]),

      woCount: toDouble(woJson["totalInquiryCount"]),
      bomCount: toDouble(bomJson["totalInquiryCount"]),
      inquiryCount: toDouble(inquiryJson["totalInquiryCount"]),

      rmdNetWeight: toDouble(rmdJson["netWeight"]),
      rmdRollLength: toDouble(rmdJson["rollLength"]),
      rmdNoOfRoll: toDouble(rmdJson["noOfRoll"]),

      laminationNetWeight: toDouble(laminationJson["netWeight"]),
      laminationRollLength: toDouble(laminationJson["rollLength"]),
      laminationNoOfRoll: toDouble(laminationJson[""]),

      loomNetWeight: toDouble(loomJson["netWeight"]),
      loomRollLength: toDouble(loomJson["rollLength"]),
      loomNoOfRoll: toDouble(loomJson["noOfRoll"]),

        baleIn: toDouble(bailingJson["inBagNwt"]),
      baleout: toDouble(bailingJson["outBagNwt"]),
      baleNoOfRoll: toDouble(bailingJson["inCount"]),

    );
  }
}
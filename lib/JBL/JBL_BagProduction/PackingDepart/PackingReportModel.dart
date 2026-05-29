class PackingBagReportModel {

  final String partyname;
  final String workOrderNo;
  final String articleNo;
  final String bagtype;
  final String bagsize;
  final double baggwtgm;
  final int orderQty;
  final int totalManf;
  final int packedBags;
  final int balanceBag;

  PackingBagReportModel({
    required this.partyname,
    required this.workOrderNo,
    required this.articleNo,
    required this.bagtype,
    required this.bagsize,
    required this.baggwtgm,
    required this.orderQty,
    required this.totalManf,
    required this.packedBags,
    required this.balanceBag,
  });

  factory PackingBagReportModel.fromJson(Map<String, dynamic> json) {

    return PackingBagReportModel(

      partyname: json['partyname'] ?? '',

      workOrderNo: json['worK_ORDER_NO'] ?? '',

      articleNo: json['articaL_NO'] ?? '',

      bagtype: json['bagtype'] ?? '',

      bagsize: json['bagsize'] ?? '',

      baggwtgm: (json['baggwtgm'] as num?)?.toDouble() ?? 0.0,

      orderQty: (json['ordeR_QTY'] as num?)?.toInt() ?? 0,

      totalManf: (json['totaL_MANF'] as num?)?.toInt() ?? 0,

      packedBags: (json['packeD_BAGS'] as num?)?.toInt() ?? 0,

      balanceBag: (json['balancE_BAG'] as num?)?.toInt() ?? 0,
    );
  }
}
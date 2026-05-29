class BailingReportModel {
  final String barcode;
  final String srNo;
  final String date;
  final String time;
  final String partyName;
  final String printStatus;
  final String bomNo;
  final String articleNo;
  final String bagType;
  final String shift;
  final String baleNo;
  final String bagQty;
  final double netWt;     // ✅ double
  final double grossWt;   // ✅ double
  final String supervisor;
  final String checkedBy;
  final int baleAge;

  BailingReportModel({
    required this.barcode,
    required this.srNo,
    required this.date,
    required this.time,
    required this.partyName,
    required this.printStatus,
    required this.bomNo,
    required this.articleNo,
    required this.bagType,
    required this.shift,
    required this.baleNo,
    required this.bagQty,
    required this.netWt,
    required this.grossWt,
    required this.supervisor,
    required this.checkedBy,
    required this.baleAge,
  });

  /// ✅ Safe double parser
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory BailingReportModel.fromJson(Map<String, dynamic> json) {
    return BailingReportModel(
      barcode: json['barcode']?.toString() ?? '',
      srNo: json['sR_NO']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      partyName: json['partY_NAME']?.toString() ?? '',
      bomNo: json['boM_NO']?.toString() ?? '',
      articleNo: json['articlE_NO']?.toString() ?? '',
      bagType: json['baG_TYPE']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '',
      baleNo: json['balE_NO']?.toString() ?? '',
      bagQty: json['baG_QTY_IN_PCS']?.toString() ?? '',

      // ✅ ONLY double parsing (fixed)
      netWt: _toDouble(json['baG_NWT']),
      grossWt: _toDouble(json['grosS_WT']),

      supervisor: json['supervisor']?.toString() ?? '',
      checkedBy: json['checkeD_BY']?.toString() ?? '',
      printStatus: json['prinT_STATUS']?.toString() ?? '',

      baleAge: json['balE_AGE'] is int
          ? json['balE_AGE']
          : int.tryParse(json['balE_AGE']?.toString() ?? '0') ?? 0,
    );
  }
}
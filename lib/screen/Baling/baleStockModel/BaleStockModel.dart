import 'package:intl/intl.dart';

class BaleStockReportModel {
  final String barcode;
  final String srNo;
  final DateTime date;
  final String time;
  final String partyName;
  final String bomNo;
  final String articleNo;
  final String printStatus;
  final String bagType;
  final String shift;
  final String baleNo;
  final String bagQty;

  final double bagNwt;
  final double grossWt;
  final double bagWtGm;

  final String bagSize;
  final String palletSize;

  final String supervisor;
  final String remark;
  final String submittedBy;
  final String checkedBy;

  final int baleAge;

  BaleStockReportModel({
    required this.barcode,
    required this.srNo,
    required this.date,
    required this.time,
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.printStatus,
    required this.bagType,
    required this.shift,
    required this.baleNo,
    required this.bagQty,
    required this.bagNwt,
    required this.grossWt,
    required this.bagWtGm,
    required this.bagSize,
    required this.palletSize,
    required this.supervisor,
    required this.remark,
    required this.submittedBy,
    required this.checkedBy,
    required this.baleAge,
  });

  /// 📅 Date Display
  String get dateDisplay {
    return '${date.day.toString().padLeft(2, '0')} '
        '${const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month]} '
        '${date.year}';
  }

  /// 🔄 Safe double parser
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// 🔄 Factory
  factory BaleStockReportModel.fromJson(Map<String, dynamic> json) {
    return BaleStockReportModel(
      barcode: json['barcode'] ?? '',
      srNo: json['sR_NO'] ?? '',
      // date: DateFormat("M/d/yyyy hh:mm:ss a").parse(json['date']),
      date: DateFormat("M/d/yyyy")
          .parse(json['date'].toString()),
      time: json['time'] ?? '',
      partyName: json['partY_NAME'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      printStatus: json['prinT_STATUS'] ?? '',
      bagType: json['baG_TYPE'] ?? '',
      shift: json['shift'] ?? '',
      baleNo: json['balE_NO'] ?? '',
      bagQty: json['baG_QTY_IN_PCS'] ?? '',

      // ✅ numeric safe parsing
      bagNwt: _toDouble(json['baG_NWT']),
      grossWt: _toDouble(json['grosS_WT']),
      bagWtGm: _toDouble(json['baG_WT_GM']),

      bagSize: json['baG_SIZE'] ?? '',
      palletSize: json['palleT_SIZE'] ?? '',

      supervisor: json['supervisor'] ?? '',
      remark: json['remark'] ?? '',
      submittedBy: json['submitteD_BY'] ?? '',
      checkedBy: json['checkeD_BY'] ?? '',

      baleAge: json['balE_AGE'] ?? 0,
    );
  }
}
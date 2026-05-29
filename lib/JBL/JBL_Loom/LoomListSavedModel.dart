// class LoomListModel {
//   final int id;
//   final String barcode;
//   final String supervisor;
//   final String operator;
//   final String date;
//   final String time;
//   final String partyName;
//   final String workOrderNo;
//   final String machineNo;
//   final double netWt;
//   final int quantity;
//   final String? gsm;
//   final String? color;
//
//   LoomListModel({
//     required this.id,
//     required this.barcode,
//     required this.supervisor,
//     required this.operator,
//     required this.date,
//     required this.time,
//     required this.partyName,
//     required this.workOrderNo,
//     required this.machineNo,
//     required this.netWt,
//     required this.quantity, this.gsm, this.color,
//   });
//
//   factory LoomListModel.fromJson(Map<String, dynamic> json) {
//     return LoomListModel(
//       id: json['id'] ?? 0,
//       barcode: json['barcode'] ?? '',
//       supervisor: json['supervisor'] ?? '',
//       operator: json['operator'] ?? '',
//       date: json['date'] ?? '',
//       time: json['time'] ?? '',
//       partyName: json['partyname'] ?? '',
//       workOrderNo: json['workorderno'] ?? '',
//       machineNo: json['machineno'] ?? '',
//       netWt: (json['netWt'] ?? 0).toDouble(),
//       quantity: json['quantity'] ?? 0,
//       gsm: json['gsm']?.toString(),
//       color: json['color']?.toString(),
//     );
//   }
// }




class LoomListModel {
  final int id;
  final int srno;
  final String code;
  final String barcode;
  final String supervisor;
  final String operator;
  final DateTime? date;
  final String time;
  final String partyName;
  final String workOrderNo;
  final String machineNo;

  final double requiredNetWt;
  final int requiredQtyMtr;

  final String rmdSupervisor;
  final String buffle;
  final String typeUse;
  final String fabricWidth;
  final String color;
  final String lamination;
  final String gsm;
  final String sid;
  final String cutType;

  final double netWt;
  final int quantity;
  final String weekNo;
  final String machine;
  final String modelNo;
  final String department;

  LoomListModel({
    required this.id,
    required this.srno,
    required this.code,
    required this.barcode,
    required this.supervisor,
    required this.operator,
    required this.date,
    required this.time,
    required this.partyName,
    required this.workOrderNo,
    required this.machineNo,
    required this.requiredNetWt,
    required this.requiredQtyMtr,
    required this.rmdSupervisor,
    required this.buffle,
    required this.typeUse,
    required this.fabricWidth,
    required this.color,
    required this.lamination,
    required this.gsm,
    required this.sid,
    required this.cutType,
    required this.netWt,
    required this.quantity,
    required this.weekNo,
    required this.machine,
    required this.modelNo,
    required this.department,
  });

  factory LoomListModel.fromJson(Map<String, dynamic> json) {
    return LoomListModel(
      id: json['id'] ?? 0,
      srno: json['srno'] ?? 0,
      code: json['code'] ?? '',
      barcode: json['barcode'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: json['time'] ?? '',
      partyName: json['partyname'] ?? '',
      workOrderNo: json['workorderno'] ?? '',
      machineNo: json['machineno'] ?? '',

      /// ✅ SAFE conversions
      requiredNetWt: (json['requirednewt'] as num?)?.toDouble() ?? 0.0,
      requiredQtyMtr: (json['requiredqtymtr'] as num?)?.toInt() ?? 0,

      rmdSupervisor: json['rmdSupervisor'] ?? '',
      buffle: json['buffle'] ?? '',
      typeUse: json['typeUse'] ?? '',
      fabricWidth: json['fabricWidth'] ?? '',
      color: json['color'] ?? '',
      lamination: json['lamination'] ?? '',
      gsm: json['gsm'] ?? '',
      sid: json['sid'] ?? '',
      cutType: json['cutType'] ?? '',

      netWt: (json['netWt'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,

      weekNo: json['weekNo'] ?? '',
      machine: json['machine'] ?? '',
      modelNo: json['modelno'] ?? '',
      department: json['department'] ?? '',
    );
  }
}
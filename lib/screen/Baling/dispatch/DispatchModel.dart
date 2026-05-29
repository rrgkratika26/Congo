import 'package:intl/intl.dart';

import 'DispatchEntrymodel.dart';

class DispatchInitModel {
  final int srNo;
  final List<String> partyNames;
  final List<String> supervisors;
  final List<String> operators;
  final List<String> bomNumbers;
  final List<String> poNumbers;

  DispatchInitModel({
    required this.srNo,
    required this.partyNames,
    required this.supervisors,
    required this.operators,
    required this.bomNumbers,
    required this.poNumbers,
  });

  factory DispatchInitModel.fromJson(Map<String, dynamic> json) {
    return DispatchInitModel(
      srNo: int.tryParse(json['srNo'].toString()) ?? 0,

      partyNames: List<String>.from(json['partyNames'] ?? []),
      supervisors: List<String>.from(json['supervisors'] ?? []),
      operators: List<String>.from(json['operators'] ?? []),
      bomNumbers: List<String>.from(json['bomNumbers'] ?? []),
      poNumbers: List<String>.from(json['poNumbers'] ?? []),
    );
  }
}


class DispatchSaveRequest {
  final String flag;
  final int id;
  final String srNo;
  final String barcode;
  final String partyName;
  final String articleNo;
  final String supervisorName;
  final String operatorName;
  final String baleNo;
  final String bagType;

  final String laminationDate1;
  final String laminationToRoll1;
  final String laminationTime1;
  final String laminationOperator1;
  final String laminationRoll1;
  final String laminationLocation1;
  final String laminationSupervisor1;

  final String toRoll;
  final String forward;
  final String rmdSupervisor;
  final String rmdLocation;
  final String rmdOperator;
  final String rmdSupervisor1;
  final String rmdLocation1;
  final String rmdOperator1;
  final String toRoll1;
  final String forward1;
  final String statusRollType;
  final String rmStatus;
  final String rmdRemark;
  final String rmdSupervisorOut;
  final String fromRoll;
  final String machine;
  final List<DispatchEntry> entries;
  final int rmdTime;
  final String tableBaleNo;

  DispatchSaveRequest({
    required this.flag,
    required this.id,
    required this.srNo,
    required this.barcode,
    required this.partyName,
    required this.articleNo,
    required this.supervisorName,
    required this.operatorName,
    required this.baleNo,
    required this.bagType,
    required this.laminationDate1,
    required this.laminationToRoll1,
    required this.laminationTime1,
    required this.laminationOperator1,
    required this.laminationRoll1,
    required this.laminationLocation1,
    required this.laminationSupervisor1,
    required this.toRoll,
    required this.forward,
    required this.rmdSupervisor,
    required this.rmdLocation,
    required this.rmdOperator,
    required this.rmdSupervisor1,
    required this.rmdLocation1,
    required this.rmdOperator1,
    required this.toRoll1,
    required this.forward1,
    required this.statusRollType,
    required this.rmStatus,
    required this.rmdRemark,
    required this.rmdSupervisorOut,
    required this.fromRoll,
    required this.rmdTime,
    required this.tableBaleNo, required this.machine, required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      "flag": flag,
      "id": id,
      "srNo": srNo,
      "barcode": barcode,
      "partyName": partyName,
      "articleNo": articleNo,
      "supervisorName": supervisorName,
      "operatorName": operatorName,
      "baleNo": baleNo,
      "bagType": bagType,
      "laminationDate1": laminationDate1,
      "laminationToRoll1": laminationToRoll1,
      "laminationTime1": laminationTime1,
      "laminationOperator1": laminationOperator1,
      "laminationRoll1": laminationRoll1,
      "laminationLocation1": laminationLocation1,
      "laminationSupervisor1": laminationSupervisor1,
      "toRoll": toRoll,
      "forward": forward,
      "rmdSupervisor": rmdSupervisor,
      "rmdLocation": rmdLocation,
      "rmdOperator": rmdOperator,
      "rmdSupervisor1": rmdSupervisor1,
      "rmdLocation1": rmdLocation1,
      "rmdOperator1": rmdOperator1,
      "toRoll1": toRoll1,
      "forward1": forward1,
      "statusRollType": statusRollType,
      "rmStatus": rmStatus,
      "rmdRemark": rmdRemark,
      "rmdSupervisorOut": rmdSupervisorOut,
      "fromRoll": fromRoll,
      "rmdTime": rmdTime,
      "tableBaleNo": tableBaleNo,
    };
  }
}


class DispatchBailRecord {
  final String srNo;
  final int srno;
  final DateTime date;
  final String barcode;
  final String partyName;
  final String workOrder;
  final String articleNo;
  final String transportName;
  final String truckNo;
  final String driverContact;
  final String dispatchDepartment;
  final String dispatchPerson;
  final String supervisor;
  final String operator;
  final String remark;
  final String printStatus;
  final String bagType;
  final String shift;
  final String baleNo;
  final String entryout;
  final int bagQtyInPcs;
  final double palletNwt;
  final double palletGrossWt;
  final double palletWtGm;
  final String bagSize;
  final String palletSize;

  DispatchBailRecord({
    required this.srNo,
    required this.srno,
    required this.date,
    required this.barcode,
    required this.partyName,
    required this.workOrder,
    required this.articleNo,
    required this.transportName,
    required this.truckNo,
    required this.driverContact,
    required this.dispatchDepartment,
    required this.dispatchPerson,
    required this.supervisor,
    required this.operator,
    required this.remark,
    required this.printStatus,
    required this.bagType,
    required this.shift,
    required this.baleNo,
    required this.bagQtyInPcs,
    required this.palletNwt,
    required this.palletGrossWt,
    required this.palletWtGm,
    required this.bagSize,
    required this.palletSize,
    required this.entryout,
  });

  factory DispatchBailRecord.fromJson(Map<String, dynamic> json) {
    return DispatchBailRecord(
      srNo: json['sR_NO']?.toString() ?? '',
      // srno: json['sr_NUM']?.toString() ?? '',
      srno: int.tryParse(json['sr_NUM']?.toString() ?? '0') ?? 0,

      date: _parseDate(json['date']),
      barcode: json['barcode']?.toString() ?? '',
      partyName: json['partY_NAME'] ?? '',
      workOrder: json['worK_ORDER'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      transportName: json['transporT_NAME'] ?? '',
      truckNo: json['trucK_NO'] ?? '',
      driverContact: json['driveR_CONTACT'] ?? '',
      dispatchDepartment: json['dispatcH_DEPARTMENT'] ?? '',
      dispatchPerson: json['dispatcH_PERSON'] ?? '',
      supervisor: json['supervisor'] ?? '',
      operator: json['operator'] ?? '',
      remark: json['remark'] ?? '',
      printStatus: json['prinT_STATUS'] ?? '',
      bagType: json['baG_TYPE'] ?? '',
      shift: json['shift'] ?? '',
      baleNo: json['balE_NO']?.toString() ?? '',
      bagQtyInPcs: int.tryParse(json['baG_QTY_IN_PCS']?.toString() ?? '0') ?? 0,
      palletNwt: _toDouble(json['balE_PALLET_NWT']),
      palletGrossWt: _toDouble(json['balE_PALLET_GROSS_WT']),
      palletWtGm: _toDouble(json['balE_PALLET_WT_GM']),
      bagSize: json['baG_SIZE'] ?? '',
      palletSize: json['palleT_SIZE'] ?? '',
      entryout: '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateFormat('M/d/yyyy hh:mm:ss a').parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return '''
DispatchBailRecord(
  srNo: $srNo,
  srno: $srno,
  date: $date,
  barcode: $barcode,
  partyName: $partyName,
  workOrder: $workOrder,
  articleNo: $articleNo,
  supervisor: $supervisor,
  operator: $operator,
  bagType: $bagType,
  baleNo: $baleNo,
  entryout: $entryout,
  bagQtyInPcs: $bagQtyInPcs,
  palletNwt: $palletNwt,
  palletGrossWt: $palletGrossWt,
  palletWtGm: $palletWtGm,
  bagSize: $bagSize,
  palletSize: $palletSize
)
''';
  }
}

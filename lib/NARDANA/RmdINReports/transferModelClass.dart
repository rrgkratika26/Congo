class RmdTransferModel {
  final String srNo;
  final String rollCode;
  final String fabricCode;
  final String barcode;
  final String fromDept;
  final String toDept;
  final String entryIn;
  final String entryOut;
  final String firstStage;
  final String secondStage;
  final String currentDept;
  final String fromDept2;
  final String toDept2;

  RmdTransferModel.fromJson(Map<String, dynamic> json)
      : srNo = _safe(json['Sr. No.']),
        rollCode = _safe(json['ROLL_CODE']),
        fabricCode = _safe(json['FABRIC_CODE']),
        barcode = _safe(json['BARCODE']),
        fromDept = _safe(json['FROM_DEPARTMENT']),
        toDept = _safe(json['ISSUE_TO_DEPARTMENT']),
        entryIn = _safe(json['ENTRYIN']),
        entryOut = _safe(json['ENTRYOUT']),
        firstStage = _safe(json['FIRST_STAGE']),
        secondStage = _safe(json['SECOND_STAGE']),
        currentDept = _safe(json['CURRENT_DEPARTMENT']),
        fromDept2 = _safe(json['FROM_DEPARTMENT_2']),
        toDept2 = _safe(json['ISSUE_TO_DEPARTMENT_2']);

  static String _safe(dynamic v) => v == null ? '' : v.toString();
}
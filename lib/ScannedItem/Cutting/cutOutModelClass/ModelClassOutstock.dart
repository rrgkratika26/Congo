class CuttingOutstock {
  final String cuttingActive;
  final int id;
  final String srno;
  final String barcode;
  final String supervisor;
  final String operatorName;
  final DateTime laminationDate;
  final String laminationTime;
  final String weekno;
  final String partyname;
  final String workorderno;
  final String jobwork;
  final double requiredNetWeight;
  final double requiredQtyMtr;
  final String machine;
  final String modelno;
  final String typeuse;
  final String buffle;
  final String color;
  final String fabricwidth;
  final String gsm;
  final String lamination;
  final String cuttype;
  final String sid;
  final double netwt;
  final double quantity;
  final String remark;
  final String department;
  final String flattubegusset;
  final String toRoll;
  final String issueToDept;
  final String rmStatus;
  final String activein;
  final String laminationLocation;
  final String machineno;

  CuttingOutstock({
    required this.cuttingActive,
    required this.id,
    required this.srno,
    required this.barcode,
    required this.supervisor,
    required this.operatorName,
    required this.laminationDate,
    required this.laminationTime,
    required this.weekno,
    required this.partyname,
    required this.workorderno,
    required this.jobwork,
    required this.requiredNetWeight,
    required this.requiredQtyMtr,
    required this.machine,
    required this.modelno,
    required this.typeuse,
    required this.buffle,
    required this.color,
    required this.fabricwidth,
    required this.gsm,
    required this.lamination,
    required this.cuttype,
    required this.sid,
    required this.netwt,
    required this.quantity,
    required this.remark,
    required this.department,
    required this.flattubegusset,
    required this.toRoll,
    required this.issueToDept,
    required this.rmStatus,
    required this.activein,
    required this.laminationLocation,
    required this.machineno,
  });

  factory CuttingOutstock.fromJson(Map<String, dynamic> json) {
    return CuttingOutstock(
      cuttingActive: json['cuttinG_ACTIVE'] ?? '',
      id: json['id'] ?? 0,
      srno: json['srno'] ?? '',
      barcode: json['barcode'] ?? '',
      supervisor: json['laminatioN_SUPERVISOR1'] ?? '',
      operatorName: json['laminatioN_OPERATOR1'] ?? '',
      laminationDate: DateTime.parse(json['laminatioN_DATE1'] ?? DateTime.now().toString()),
      laminationTime: json['laminatioN_TIME1'] ?? '',
      weekno: json['weekno'] ?? '',
      partyname: json['partyname'] ?? '',
      workorderno: json['workorderno'] ?? '',
      jobwork: json['jobwork'] ?? '',
      requiredNetWeight: (json['requirednewt'] ?? 0).toDouble(),
      requiredQtyMtr: (json['requiredqtymtr'] ?? 0).toDouble(),
      machine: json['machine'] ?? '',
      modelno: json['modelno'] ?? '',
      typeuse: json['typeuse'] ?? '',
      buffle: json['buffle'] ?? '',
      color: json['color'] ?? '',
      fabricwidth: json['fabricwidth'] ?? '',
      gsm: json['gsm'] ?? '',
      lamination: json['lamination'] ?? '',
      cuttype: json['cuttype'] ?? '',
      sid: json['sid'] ?? '',
      netwt: (json['netwt'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      remark: json['remark'] ?? '',
      department: json['department'] ?? '',
      flattubegusset: json['flattubegusset'] ?? '',
      toRoll: json['to_ROLL'] ?? '',
      issueToDept: json['issuE_TO_DEPT'] ?? '',
      rmStatus: json['rM_STATUS'] ?? '',
      activein: json['activein'] ?? '',
      laminationLocation: json['laminatioN_LOCATION1'] ?? '',
      machineno: json['machineno'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cuttinG_ACTIVE': cuttingActive,
      'id': id,
      'srno': srno,
      'barcode': barcode,
      'laminatioN_SUPERVISOR1': supervisor,
      'laminatioN_OPERATOR1': operatorName,
      'laminatioN_DATE1': laminationDate.toIso8601String(),
      'laminatioN_TIME1': laminationTime,
      'weekno': weekno,
      'partyname': partyname,
      'workorderno': workorderno,
      'jobwork': jobwork,
      'requirednewt': requiredNetWeight,
      'requiredqtymtr': requiredQtyMtr,
      'machine': machine,
      'modelno': modelno,
      'typeuse': typeuse,
      'buffle': buffle,
      'color': color,
      'fabricwidth': fabricwidth,
      'gsm': gsm,
      'lamination': lamination,
      'cuttype': cuttype,
      'sid': sid,
      'netwt': netwt,
      'quantity': quantity,
      'remark': remark,
      'department': department,
      'flattubegusset': flattubegusset,
      'to_ROLL': toRoll,
      'issuE_TO_DEPT': issueToDept,
      'rM_STATUS': rmStatus,
      'activein': activein,
      'laminatioN_LOCATION1': laminationLocation,
      'machineno': machineno,
    };
  }
}

// ── Usage ──
// final response = await http.get(Uri.parse("{{visa_demo}}/Cutting/OutStockList?plant=FIBC"));
// final List<CuttingOutstock> rolls = (jsonDecode(response.body) as List)
//     .map((e) => CuttingOutstock.fromJson(e))
//     .toList();
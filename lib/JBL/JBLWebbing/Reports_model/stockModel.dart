class WebbingStock {
  // final int srNo;
  final String rollCode;
  final String barcode;
  final String lotNo;
  final String fabricCode;
  final double rollWeight;
  final double rollLength;
  final String supervisorName;
  final String operatorName;
  // final String date;
  // final String time;
  // final String weekNo;
  // final String partyName;
  final String workOrderNo;
  // final String orderType;
  final double requiredQtyKg;
  final double requiredQtyMtr;
  // final String machineNo;
  // final String machineType;
  // final String mesh;
  final String beltTypeFabricUse;
  final String beltConstruction;
  // final String color;
  final String beltWidth;
  final String beltGsm;
  // final String materialType;
  // final String colorIdentification;
  // final String department;
  final String mash;
  final String loomOperator1;
  final String loomOperator2;
  // final String remark;
  // final String hold;
  // final String holdRemark;
  final String location;

  WebbingStock({
    // required this.srNo,
    required this.rollCode,
    required this.barcode,
    required this.lotNo,
    required this.fabricCode,
    required this.rollWeight,
    required this.rollLength,
    required this.supervisorName,
    required this.operatorName,
    // required this.date,
    // required this.time,
    // required this.weekNo,
    // required this.partyName,
    required this.workOrderNo,
    // required this.orderType,
    required this.requiredQtyKg,
    required this.requiredQtyMtr,
    // required this.machineNo,
    // required this.machineType,
    // required this.mesh,
    required this.beltTypeFabricUse,
    required this.beltConstruction,
    // required this.color,
    required this.beltWidth,
    required this.beltGsm,
    // required this.materialType,
    // required this.colorIdentification,
    // required this.department,
    required this.mash,
    required this.loomOperator1,
    required this.loomOperator2,
    // required this.remark,
    // required this.hold,
    // required this.holdRemark,
    required this.location,
  });

  factory WebbingStock.fromJson(Map<String, dynamic> json) {
    return WebbingStock(
      // srNo:               int.tryParse(json['Sr. No.']?.toString() ?? '0') ?? 0,
      rollCode:           json['ROLL CODE']?.toString() ?? '',
      barcode:            json['BARCODE']?.toString() ?? '',
      lotNo:              json['LOT_NO']?.toString() ?? '',
      fabricCode:         json['FABRIC_CODE']?.toString() ?? '',
      rollWeight:         double.tryParse(json['ROLL_WEIGHT(KG)']?.toString() ?? '0') ?? 0.0,
      rollLength:         double.tryParse(json['ROLL LENGTH (Mtr)']?.toString() ?? '0') ?? 0.0,
      supervisorName:     json['SUPERVISOR NAME']?.toString() ?? '',
      operatorName:       json['OPERATOR NAME']?.toString() ?? '',
      // date:               json['DATE']?.toString() ?? '',           // ✅ String
      // time:               json['TIME']?.toString() ?? '',
      // weekNo:             json['WEEK NO.']?.toString() ?? '',
      // partyName:          json['PARTYNAME']?.toString() ?? '',
      workOrderNo:        json['WORK ORDER NO.']?.toString() ?? '',
      // orderType:          json['ORDER TYPE']?.toString() ?? '',
      requiredQtyKg:      double.tryParse(json['REQUIRED QUANTITY (Kg)']?.toString() ?? '0') ?? 0.0,
      requiredQtyMtr:     double.tryParse(json['REQUIRED QUANTITY MTR']?.toString() ?? '0') ?? 0.0,
      // machineNo:          json['MACHINE NO.']?.toString() ?? '',
      // machineType:        json['MACHINE TYPE']?.toString() ?? '',
      // mesh:               json['MESH']?.toString() ?? '',
      beltTypeFabricUse:  json['BELT TYPE/FABRIC USE']?.toString() ?? '',
      beltConstruction:   json['BELT CONSTRUCTION']?.toString() ?? '',
      // color:              json['COLOR']?.toString() ?? '',
      beltWidth:          json['BELT WIDTH(CM)']?.toString() ?? '',
      beltGsm:            json['BELT GSM']?.toString() ?? '',
      // materialType:       json['MATERIAL TYPE']?.toString() ?? '',
      // colorIdentification: json['COLOR IDENTIFICATION']?.toString() ?? '',
      // department:         json['Department']?.toString() ?? '',
      mash:               json['MASH']?.toString() ?? '',
      loomOperator1:      json['LOOMOPARETOR1']?.toString() ?? '',
      loomOperator2:      json['LOOMOPARETOR2']?.toString() ?? '',
      // remark:             json['REMARK']?.toString() ?? '',
      // hold:               json['HOLD']?.toString() ?? '',
      // holdRemark:         json['HOLD_REMARK']?.toString() ?? '',
      location:           json['Location']?.toString() ?? '',
    );
  }

  // ✅ toMap — screen table ke liye
  Map<String, dynamic> toMap() => {
    // 'Sr No':            srNo,
    'Roll Code':        rollCode,
    'Barcode':          barcode,
    'Lot No':           lotNo,
    'Fabric Code':      fabricCode,
    'Weight (KG)':      rollWeight,
    'Length (Mtr)':     rollLength,
    'Supervisor':       supervisorName,
    'Operator':         operatorName,
    // 'Date':             date,
    // 'Time':             time,
    // 'Week No':          weekNo,
    // 'Party':            partyName,
    'Work Order':       workOrderNo,
    // 'Order Type':       orderType,
    'Req KG':           requiredQtyKg,
    'Req Mtr':          requiredQtyMtr,
    // 'Machine No':       machineNo,
    // 'Machine Type':     machineType,
    // 'Color':            color,
    'Belt Width':       beltWidth,
    'Belt GSM':         beltGsm,
    // 'Material':         materialType,
    // 'Dept':             department,
    'Loom Op 1':        loomOperator1,
    'Loom Op 2':        loomOperator2,
    // 'Remark':           remark,
    // 'Hold':             hold,
    'Location':         location,
  };
}
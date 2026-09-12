class WastageEntryModel {
  final int id;
  final int code;
  final String? partyName;
  final String? po;
  final String? articleNo;
  final String? supervisor;
  final String? wastageType;
  final String? operator;
  final double weight;
  final double depositQty;
  final String? shift;
  final String? loomNo;
  final String? remark;
  final String date;
  final String status;

  WastageEntryModel({
    required this.id,
    required this.code,
    this.partyName,
    this.po,
    this.articleNo,
    this.supervisor,
    this.wastageType,
    this.operator,
    required this.weight,
    required this.depositQty,
    this.shift,
    this.loomNo,
    this.remark,
    required this.date,
    this.status = 'Saved',
  });

  WastageEntryModel copyWith({
    int? id,
    int? code,
    String? partyName,
    String? po,
    String? articleNo,
    String? supervisor,
    String? wastageType,
    String? operator,
    double? weight,
    double? depositQty,
    String? shift,
    String? loomNo,
    String? remark,
    String? date,
    String? status,
  }) {
    return WastageEntryModel(
      id: id ?? this.id,
      code: code ?? this.code,
      partyName: partyName ?? this.partyName,
      po: po ?? this.po,
      articleNo: articleNo ?? this.articleNo,
      supervisor: supervisor ?? this.supervisor,
      wastageType: wastageType ?? this.wastageType,
      operator: operator ?? this.operator,
      weight: weight ?? this.weight,
      depositQty: depositQty ?? this.depositQty,
      shift: shift ?? this.shift,
      loomNo: loomNo ?? this.loomNo,
      remark: remark ?? this.remark,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  factory WastageEntryModel.fromJson(Map<String, dynamic> json) {
    return WastageEntryModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      code: int.tryParse('${json['code'] ?? 0}') ?? 0,
      partyName: json['partyName']?.toString(),
      po: json['po']?.toString(),
      articleNo: json['articleNo']?.toString(),
      supervisor: json['supervisor']?.toString(),
      wastageType: json['wastageType']?.toString(),
      operator: json['operator']?.toString(),
      weight: double.tryParse('${json['weight'] ?? 0}') ?? 0,
      depositQty: double.tryParse('${json['depositQty'] ?? 0}') ?? 0,
      shift: json['shift']?.toString(),
      loomNo: json['loomNo']?.toString(),
      remark: json['remark']?.toString(),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Saved',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'partyName': partyName,
      'po': po,
      'articleNo': articleNo,
      'supervisor': supervisor,
      'wastageType': wastageType,
      'operator': operator,
      'weight': weight,
      'depositQty': depositQty,
      'shift': shift,
      'loomNo': loomNo,
      'remark': remark,
      'date': date,
      'status': status,
    };
  }
}
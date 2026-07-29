class TapeStockReportModel {
  final String date;
  final String party;
  final String po;
  final String articleNo;
  final String code;
  final String recipeType;
  final double totalQty;
  final double issueQty;
  final double balance;
  final int diner;
  final int widthMM;
  final String tapePlant;
  final String supervisor;

  TapeStockReportModel({
    required this.date,
    required this.party,
    required this.po,
    required this.articleNo,
    required this.code,
    required this.recipeType,
    required this.totalQty,
    required this.issueQty,
    required this.balance,
    required this.diner,
    required this.widthMM,
    required this.tapePlant,
    required this.supervisor,
  });

  factory TapeStockReportModel.fromJson(Map<String, dynamic> json) {
    return TapeStockReportModel(
      date: json['date'] ?? '',
      party: json['party'] ?? '',
      po: json['po'] ?? '',
      articleNo: json['articleNo'] ?? '',
      code: json['code'] ?? '',
      recipeType: json['recipeType'] ?? '',
      totalQty: (json['totalQty'] as num?)?.toDouble() ?? 0,
      issueQty: (json['issueQty'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      diner: (json['diner'] as num?)?.toInt() ?? 0,
      widthMM: (json['widthMM'] as num?)?.toInt() ?? 0,
      tapePlant: json['tapePlant'] ?? '',
      supervisor: json['supervisor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'party': party,
      'po': po,
      'articleNo': articleNo,
      'code': code,
      'recipeType': recipeType,
      'totalQty': totalQty,
      'issueQty': issueQty,
      'balance': balance,
      'diner': diner,
      'widthMM': widthMM,
      'tapePlant': tapePlant,
      'supervisor': supervisor,
    };
  }
}
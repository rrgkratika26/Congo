class BaleEntryModel {
  final int id;
  final String customerName;
  final String articleNo;
  final String poNumber;
  final int quantity;
  final int remaining;
  final int requiredBag;
  final String worK_ORDER_NO;

  BaleEntryModel({
    required this.id,
    required this.customerName,
    required this.articleNo,
    required this.poNumber,
    required this.quantity,
    required this.remaining,
    required this.worK_ORDER_NO,
    required this.requiredBag,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory BaleEntryModel.fromJson(
    Map<String, dynamic> json, {
    required int index, // 👈 used for ID
  }) {
    return BaleEntryModel(
      id: index + 1, // backend has no ID
      customerName: json['partY_NAME']?.toString() ?? '',
      articleNo: json['articlE_NO']?.toString() ?? '',
      poNumber: json['pO_NUM']?.toString() ?? '',
      quantity: 0, // not provided by API
      remaining: _toInt(
        json['remaininG_BAG'] ??
            json['remaining_bag'] ??
            json['remaining'] ??
            json['remainning'] ??
            json['REMAINING_BAG'],
      ),
      // work_ORDER_No: json['work_ORDER_NO']!.toString(),
      worK_ORDER_NO: json['worK_ORDER_NO']?.toString() ?? '',
      requiredBag: _toInt(json['requireD_BAG']),
    );
  }
}

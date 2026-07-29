class StoreIsssueModleClass {
  final String woNumber;
  final String customerName;
  final String type;
  final int quantity;
  final String date; // 👈 Add this

  StoreIsssueModleClass({
    required this.woNumber,
    required this.customerName,
    required this.type,
    required this.quantity,
    required this.date,
  });

  factory StoreIsssueModleClass.fromJson(Map<String, dynamic> json) {
    return StoreIsssueModleClass(
      woNumber: json['wO_NUMBER'] ?? '',
      customerName: json['customeR_NAME'] ?? '',
      type: json['typee'] ?? '',
      quantity: json['quantity'] ?? 0,
      date: json['date'] ?? '', // 👈 Map date from API
    );
  }
}

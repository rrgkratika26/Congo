
// Simple Stock Record Model
class StockRecord {
  final String id;
  final String itemName;
  final double netWeight;
  final double rollLength;
  final int numberOfRolls;
  final String location;
  final DateTime date;

  StockRecord({
    required this.id,
    required this.itemName,
    required this.netWeight,
    required this.rollLength,
    required this.numberOfRolls,
    required this.location,
    required this.date,
  });
}
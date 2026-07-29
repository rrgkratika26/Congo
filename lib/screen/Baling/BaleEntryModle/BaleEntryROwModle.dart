class BaleEntryRowModel {
  String baleNo;
  int baleQtyPcs;
  double baleNwt;
  double tareWt;
  double bagWt;
  int total;
  String bagSize;
  String typee;

  BaleEntryRowModel({
    required this.baleNo,
    required this.baleQtyPcs,
    required this.baleNwt,
    required this.tareWt,
    required this.bagWt,
    required this.total,
    required this.bagSize,
    required this.typee,
  });

  Map<String, dynamic> toJson() {
    return {
      "baleNo": baleNo,
      "baleQtyPcs": baleQtyPcs,
      "baleNwt": baleNwt,
      "tareWt": tareWt,
      "bagWt": bagWt,
      "total": total,
      "bagSize": bagSize,
      "typee": typee,
    };
  }
}
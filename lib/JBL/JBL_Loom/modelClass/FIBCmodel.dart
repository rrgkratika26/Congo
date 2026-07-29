import '../../../ScannedItem/Loom/LoomModelClass.dart';

class ProductionModel {
  final int orderNo;
  final String bomNo;
  final String partyName;
  final String fabricCode;

  final double actualRequiredKg;
  final double actualRequiredMtr;
  final double sumOutKg;
  final double sumOutMtr;
  final double balanceKg;
  final double balanceMtr;

  final String flatTubeGusset;

  // ✅ NEW FIELDS
  final String articleNo;
  final String poNumber;
  final String customerName;

  final double requiredKg;
  final double requiredMtr;

  final double productionKg;
  final double productionMtr;

  final double balanceKgInt;
  final double balanceMtrInt;

  final String woNo;
  final bool status;

  ProductionModel({
    required this.orderNo,
    required this.partyName,
    required this.fabricCode,
    required this.actualRequiredKg,
    required this.actualRequiredMtr,
    required this.sumOutKg,
    required this.sumOutMtr,
    required this.balanceKg,
    required this.balanceMtr,
    required this.flatTubeGusset,

    // ✅ new
    required this.articleNo,
    required this.poNumber,
    required this.customerName,
    required this.requiredKg,
    required this.requiredMtr,
    required this.productionKg,
    required this.productionMtr,
    required this.balanceKgInt,
    required this.balanceMtrInt,
    required this.woNo,
    required this.status, required this.bomNo,
  });

  factory ProductionModel.fromJson(Map<String, dynamic> json) {
    return ProductionModel(
      orderNo: json['orderNo'] ?? 0,
      bomNo: json['boM_NO'] ?? 0,
      partyName: json['partyName'] ?? '',
      fabricCode: json['fabricCode'] ?? '',

      actualRequiredKg: (json['actualRequiredKg'] ?? 0).toDouble(),
      actualRequiredMtr: (json['actualRequiredMtr'] ?? 0).toDouble(),
      sumOutKg: (json['sumOutKg'] ?? 0).toDouble(),
      sumOutMtr: (json['sumOutMtr'] ?? 0).toDouble(),
      balanceKg: (json['balanceKg'] ?? 0).toDouble(),
      balanceMtr: (json['balanceMtr'] ?? 0).toDouble(),

      flatTubeGusset: json['flatTubeGusset'] ?? "",

      // ✅ new
      articleNo: json['articleNo'] ?? "",
      poNumber: json['poNumber'] ?? "",
      customerName: json['customerName'] ?? "",

      requiredKg: json['requiredKg'] ?? 0,
      requiredMtr: json['requiredMtr'] ?? 0,

      productionKg: json['productionKg'] ?? 0,
      productionMtr: json['productionMtr'] ?? 0,

      balanceKgInt: json['balanceKg'] ?? 0,
      balanceMtrInt: json['balanceMtr'] ?? 0,

      woNo: json['woNo'] ?? "",
      status: json['status'] ?? '',
    );
  }
}




ProductionModel convertToProduction(LoomOrder order) {
  return ProductionModel(
    orderNo: int.tryParse(order.loomOrderNo) ?? 0,
    partyName: order.customerName,
    bomNo: order.bom,
    // fabricCode: order.requiredFabricCode,
    fabricCode: order.fabricCode.isNotEmpty
        ? order.fabricCode
        : order.requiredFabricCode,
    actualRequiredKg: order.requiredQuantityKg.toDouble(),
    actualRequiredMtr: order.requiredQuantityMtr.toDouble(),

    sumOutKg: order.productionKg.toDouble(),
    sumOutMtr: order.productionMtr.toDouble(),

    balanceKg: order.balanceKg.toDouble(),
    balanceMtr: order.balanceMtr.toDouble(),

    flatTubeGusset: "",

    // ✅ new mappings
    articleNo: order.articleNo.toString(), // not in API → keep empty or map if available
    poNumber:order.poNumber,  // same here
    customerName: order.customerName,

    requiredKg: order.requiredQuantityKg.toDouble(),
    requiredMtr: order.requiredQuantityMtr.toDouble(),

    productionKg: order.productionKg.toDouble(),
    productionMtr: order.productionMtr.toDouble(),

    balanceKgInt: order.balanceKg.toDouble(),
    balanceMtrInt: order.balanceMtr.toDouble(),

    woNo: order.woNo,
    status: order.status,

  );
}
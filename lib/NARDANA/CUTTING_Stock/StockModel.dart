
class CuttingFabricSummaryModel {
final String fabricCode;
final double totalNetWeightKg;
final double totalRollLengthMtr;
final double totalFabricWidthCm;
final int totalCount;

CuttingFabricSummaryModel({
required this.fabricCode,
required this.totalNetWeightKg,
required this.totalRollLengthMtr,
required this.totalFabricWidthCm,
required this.totalCount,
});

factory CuttingFabricSummaryModel.fromJson(
Map<String, dynamic> json,
) {
return CuttingFabricSummaryModel(
fabricCode: json['fabriC_CODE']?.toString() ?? '',
totalNetWeightKg:
double.tryParse(
json['totaL_NET_WEIGHT_KG']?.toString() ?? '0',
) ??
0.0,
totalRollLengthMtr:
double.tryParse(
json['totaL_ROLL_LENGTH_MTR']?.toString() ?? '0',
) ??
0.0,
totalFabricWidthCm:
double.tryParse(
json['totaL_FABRIC_WIDTH_CM']?.toString() ?? '0',
) ??
0.0,
totalCount:
int.tryParse(
json['totaL_COUNT']?.toString() ?? '0',
) ??
0,
);
}
}

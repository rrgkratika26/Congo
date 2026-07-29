/// ===============================================================
/// Cutting Fabric Summary API
/// URL:
/// /Cutting/GetFabricSummaryReport?pageNumber=1&pageSize=5
/// ===============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  factory CuttingFabricSummaryModel.fromJson(Map<String, dynamic> json) {
    return CuttingFabricSummaryModel(
      fabricCode: json["fabriC_CODE"] ?? "",
      totalNetWeightKg:
      (json["totaL_NET_WEIGHT_KG"] ?? 0).toDouble(),
      totalRollLengthMtr:
      (json["totaL_ROLL_LENGTH_MTR"] ?? 0).toDouble(),
      totalFabricWidthCm:
      (json["totaL_FABRIC_WIDTH_CM"] ?? 0).toDouble(),
      totalCount: json["totaL_COUNT"] ?? 0,
    );
  }
}
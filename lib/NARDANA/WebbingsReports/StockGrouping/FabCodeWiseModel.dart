import 'dart:convert';

/// ================= MODEL CLASS =================

class FabricCodeWiseResponse {
  final bool success;
  final String message;
  final FabricCodeWiseData data;

  FabricCodeWiseResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FabricCodeWiseResponse.fromJson(Map<String, dynamic> json) {
    return FabricCodeWiseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: FabricCodeWiseData.fromJson(json['data'] ?? {}),
    );
  }
}

class FabricCodeWiseData {
  final List<FabricCodeWiseItem> items;
  final int totalRecords;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  FabricCodeWiseData({
    required this.items,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory FabricCodeWiseData.fromJson(Map<String, dynamic> json) {
    return FabricCodeWiseData(
      items: (json['items'] as List? ?? [])
          .map((e) => FabricCodeWiseItem.fromJson(e))
          .toList(),
      totalRecords: json['totalRecords'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 50,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class FabricCodeWiseItem {
  final String fabricCode;
  final int id;
  final double totalRollWeightKg;
  final double totalRollLengthMtr;
  final int totalCount;

  FabricCodeWiseItem({
    required this.fabricCode,

    required this.totalRollWeightKg,
    required this.totalRollLengthMtr,
    required this.totalCount, required this.id,
  });

  factory FabricCodeWiseItem.fromJson(Map<String, dynamic> json) {
    return FabricCodeWiseItem(
      fabricCode: json['fabricCode'] ?? '',
      id: json['id']?? 0,
      totalRollWeightKg:
      (json['totalRollWeightKg'] ?? 0).toDouble(),
      totalRollLengthMtr:
      (json['totalRollLengthMtr'] ?? 0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
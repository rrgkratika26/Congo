class DispatchModel {
  final int dispatchNo;
  final String partyName;
  final String poNo;
  final String invoiceNo;
  final String date;
  final String transportName;
  final String vehicleNo;
  final int totalPcs;
  final int totalCount;
  final double totalGwt;
  final double totalNetWt;
  final double totalTwt;

  DispatchModel({
    required this.dispatchNo,
    required this.partyName,
    required this.poNo,
    required this.invoiceNo,
    required this.date,
    required this.transportName,
    required this.vehicleNo,
    required this.totalPcs,
    required this.totalCount,
    required this.totalGwt,
    required this.totalNetWt,
    required this.totalTwt,
  });

  factory DispatchModel.fromJson(Map<String, dynamic> json) {
    /// Convert all keys to lowercase
    final map = {for (var e in json.entries) e.key.toLowerCase(): e.value};

    return DispatchModel(
      dispatchNo: map["dispatch_no"] ?? 0,
      partyName: map["party_name"] ?? "",
      poNo: map["po_no"] ?? "",
      invoiceNo: map["invoice_no"] ?? "",
      date: map["date"] ?? "",
      transportName: map["transport_name"] ?? "",
      vehicleNo: map["vehicle_no"] ?? "",
      totalPcs: map["total_pcs"] ?? 0,
      totalCount: map["total_count"] ?? 0,
      totalGwt: (map["total_gwt"] ?? 0).toDouble(),
      totalNetWt: (map["total_netwt"] ?? 0).toDouble(),
      totalTwt: (map["total_twt"] ?? 0).toDouble(),
    );
  }
}

class DispatchDetailResponse {
  final Map<String, dynamic>? summary;
  final List<Map<String, dynamic>> lineItems;

  DispatchDetailResponse({required this.summary, required this.lineItems});

  factory DispatchDetailResponse.fromJson(dynamic json) {
    if (json is List) {
      final items = json.map((e) => Map<String, dynamic>.from(e)).toList();

      return DispatchDetailResponse(
        summary: items.isNotEmpty ? items.first : null,
        lineItems: items,
      );
    }

    if (json is Map<String, dynamic>) {
      final rows =
          json['data'] ?? json['items'] ?? json['rows'] ?? json['lineItems'];

      if (rows is List) {
        return DispatchDetailResponse(
          summary: json,
          lineItems: rows.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }

      return DispatchDetailResponse(
        summary: json,
        lineItems: [Map<String, dynamic>.from(json)],
      );
    }

    throw Exception("Unexpected response format for dispatch detail.");
  }
}

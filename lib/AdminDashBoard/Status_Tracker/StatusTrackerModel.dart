class OrderStatusItem {
  final String customerName;
  final String generatedInquiry;
  final String articleNo;
  final String wono;
  final String typee;
  final String sizeDisplay;
  final String quantity;
  final DateTime? todayDate;

  OrderStatusItem({
    required this.customerName,
    required this.generatedInquiry,
    required this.articleNo,
    required this.wono,
    required this.typee,
    required this.sizeDisplay,
    required this.quantity,
    this.todayDate,
  });

  factory OrderStatusItem.fromJson(Map<String, dynamic> json) {
    return OrderStatusItem(
      customerName: json['customerName']?.toString() ?? '',
      generatedInquiry: json['generatedInquiry']?.toString() ?? '',
      articleNo: json['articleNo']?.toString() ?? '',
      wono: json['wono']?.toString() ?? '',
      typee: json['typee']?.toString() ?? '',
      sizeDisplay: json['sizeDisplay']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      todayDate: json['todayDate'] != null
          ? DateTime.tryParse(json['todayDate'].toString())
          : null,
    );
  }
}

// ============================================================
// TRACKING RESPONSE
// ============================================================

class TrackingResponse {
  final bool success;
  final String message;
  final TrackingData data;

  TrackingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TrackingResponse.fromJson(Map<String, dynamic> json) {
    return TrackingResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: TrackingData.fromJson(json['data'] ?? {}),
    );
  }
}

// ============================================================
// TRACKING DATA
// ============================================================

class TrackingData {
  final TrackingHeader header;
  final String currentStage;
  final List<LifecycleStage> timeline;

  TrackingData({
    required this.header,
    required this.currentStage,
    required this.timeline,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    final timelineJson = json['timeline'];

    return TrackingData(
      header: TrackingHeader.fromJson(json['header'] ?? {}),
      currentStage: json['currentStage']?.toString() ?? '',
      timeline: timelineJson is List
          ? timelineJson
                .map((e) => LifecycleStage.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class TrackingHeader {
  final String generatedInquiry;
  final String customerName;
  final String typee;
  final String sizeDisplay;
  final String articleNo;
  final String quantity;
  final String inquiryDate;

  TrackingHeader({
    required this.generatedInquiry,
    required this.customerName,
    required this.typee,
    required this.sizeDisplay,
    required this.articleNo,
    required this.quantity,
    required this.inquiryDate,
  });

  factory TrackingHeader.fromJson(Map<String, dynamic> json) {
    return TrackingHeader(
      generatedInquiry: json['generatedInquiry']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      typee: json['typee']?.toString() ?? '',
      sizeDisplay: json['sizeDisplay']?.toString() ?? '',
      articleNo: json['articleNo']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      inquiryDate: json['inquiryDate']?.toString() ?? '',
    );
  }
}

// ============================================================
// LIFECYCLE STAGE
// ============================================================

class LifecycleStage {
  final String name; // ✅ display name getter is here
  final bool completed;
  final String? date;
  final String? value;
  final StageDetails? details;

  LifecycleStage({
    required this.name,
    required this.completed,
    this.date,
    this.value,
    this.details,
  });

  factory LifecycleStage.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];

    StageDetails? details;
    if (rawDetails is Map<String, dynamic>) {
      details = StageDetails.fromJson(rawDetails);
    }

    final completedAt = json['completedAt'];

    return LifecycleStage(
      name: _formatStageName(json['stage']?.toString() ?? ''),
      completed: json['completed'] == true,
      date: completedAt != null ? completedAt.toString() : null,
      value: details?.displayValue,
      details: details,
    );
  }

  static String _formatStageName(String value) {
    if (value.trim().isEmpty) return '';

    return value
        .trim()
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0]}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

// ============================================================
// STAGE DETAILS
// ============================================================

class StatusTrackerResponse {
  final List<OrderStatusItem> data;
  final int totalRecords;
  final int totalPages;

  StatusTrackerResponse({
    required this.data,
    required this.totalRecords,
    required this.totalPages,
  });
}


class StageDetails {
  final double? kg;
  final double? mtr;
  final int? rolls;

  StageDetails({this.kg, this.mtr, this.rolls});

  factory StageDetails.fromJson(Map<String, dynamic> json) {
    return StageDetails(
      kg: _toDouble(json['kg']),
      mtr: _toDouble(json['mtr']),
      rolls: _toInt(json['rolls']),
    );
  }

  // ✅ displayValue getter is here
  String get displayValue {
    final parts = <String>[];

    if (kg != null) parts.add('${_formatNumber(kg!)} KG');
    if (mtr != null) parts.add('${_formatNumber(mtr!)} MTR');
    if (rolls != null) parts.add('$rolls Roll${rolls == 1 ? '' : 's'}');

    return parts.join(' • ');
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

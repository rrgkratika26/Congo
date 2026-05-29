// ─────────────────────────────────────────────────────────────
//  File: lib/JBL/JBLWebbing/model/webbing_out_response.dart
// ─────────────────────────────────────────────────────────────

class WebbingOutResponse {
  final bool   success;
  final String message;
  final dynamic data;

  WebbingOutResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory WebbingOutResponse.fromJson(Map<String, dynamic> json) {
    return WebbingOutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data   : json['data'],
    );
  }
}
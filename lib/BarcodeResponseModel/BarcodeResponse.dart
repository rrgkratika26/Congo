class BarcodeResponse {
  final String status;
  final String message;

  BarcodeResponse({required this.status, required this.message});

  factory BarcodeResponse.fromJson(Map<String, dynamic> json) {
    return BarcodeResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}

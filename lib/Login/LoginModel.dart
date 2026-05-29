class LoginModel {
  final String status;
  final String message;
  final String user;
  final String department;
  final String userType;
  final String unit;
  final String token;
  final String redirect;

  LoginModel({
    required this.status,
    required this.message,
    required this.user,
    required this.department,
    required this.userType,
    required this.unit,
    required this.token,
    required this.redirect,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      user: json['user'] ?? '',
      department: json['department'] ?? '',
      userType: json['userType'] ?? '',
      unit: json['unit'] ?? '',
      token: json['token'] ?? '',
      redirect: json['redirect'] ?? '',
    );
  }
}

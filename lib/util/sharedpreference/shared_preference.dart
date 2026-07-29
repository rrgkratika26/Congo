
import 'package:shared_preferences/shared_preferences.dart';
import '../userRole.dart';

class AppSession {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static String? unit;

  // ─────────────────────────────────────────────────────────────────────────────
//  ADD / REPLACE this method inside your existing AppSession class.
//  It saves every field from LoginModel in one call.
// ─────────────────────────────────────────────────────────────────────────────

  static Future<void> saveLogin({
    required String user,
    required String department,
    required String userType,
    required String unit,
    required String token,
    required String redirect,
    required String password,   // needed for auto-login on next launch
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username',   user);
    await prefs.setString('password',   password);
    await prefs.setString('unit',       unit);
    await prefs.setString('department', department);
    await prefs.setString('userType',   userType);
    await prefs.setString('token',      token);
    await prefs.setString('redirect',   redirect);
    await prefs.setBool('isLoggedIn',   true);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

// ── Getters (add any that are missing) ───────────────────────────────────────
  static Future<String?> getUsername()   async => (await SharedPreferences.getInstance()).getString('username');
  static Future<String?> getUnit()       async => (await SharedPreferences.getInstance()).getString('unit');
  static Future<String?> getDepartment() async => (await SharedPreferences.getInstance()).getString('department');
  static Future<String?> getUserType()   async => (await SharedPreferences.getInstance()).getString('userType');
  static Future<String?> getToken()      async => (await SharedPreferences.getInstance()).getString('token');
}
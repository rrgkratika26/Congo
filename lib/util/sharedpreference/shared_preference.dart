// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../DEPARTMENT/departmentiUtils.dart';
// import '../userRole.dart';
//
// class AppSession {
//
//   static Future<void> saveLogin({
//     required String user,
//     required String department,
//     required String userType,
//     required String unit,
//     required String token,
//     required String redirect,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     // final normalizedDept = normalizeDepartment(department);
//     await prefs.setBool('isLoggedIn', true);
//
//
//     await prefs.setString('user', user);
//     await prefs.setString('department', department);
//     await prefs.setString('userType', userType);
//     await prefs.setString('unit', unit);
//     // await prefs.setString('token', token);
//     await prefs.setString(_tokenKey, token);
//     await prefs.setString('redirect', redirect);
//     await prefs.setBool('isLoggedIn', true);
//   }
//
//   static const _tokenKey = 'auth_token';
//
//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }
//
//   static Future<String?> getUser() async =>
//       (await SharedPreferences.getInstance()).getString('user');
//
//   static Future<String?> getDepartment() async =>
//       (await SharedPreferences.getInstance()).getString('department');
//
//   static Future<String?> getUserType() async =>
//       (await SharedPreferences.getInstance()).getString('userType');
//
//
//
//   static Future<String?> getRedirect() async =>
//       (await SharedPreferences.getInstance()).getString('redirect');
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   static Future<void> clear() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
//
//   static Future<String?> getUnit() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('unit');
//   }
//
//   static Future<String?> getUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user');
//   }
//
//   static Future<String?> getPlant() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('unit');
//   }
//
//   static const _roleKey = 'user_role';
//
//   static Future<void> setUserRole(UserRole role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_roleKey, role.name);
//   }
//
//   static Future<UserRole> getUserRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString(_roleKey);
//
//     switch (role) {
//       case 'padmin':
//         return UserRole.padmin;
//       case 'rmd':
//         return UserRole.rmd;
//       case 'lamination':
//         return UserRole.lamination;
//       case 'cutting':
//         return UserRole.cutting;
//       case 'bagProduction':
//         return UserRole.bagProduction;
//       case 'bailing':
//         return UserRole.bailing;
//       default:
//         return UserRole.unknown;
//     }
//   }
// }







import 'package:shared_preferences/shared_preferences.dart';
import '../userRole.dart';

class AppSession {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static String? unit;

  static Future<void> saveLogin({
    required String user,
    required String password, // ✅ ADD THIS
    required String department,
    required String userType,
    required String unit,
    required String token,
    required String redirect,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);

    // ✅ CONSISTENT KEYS
    await prefs.setString('username', user);
    await prefs.setString('password', password); // ✅ REQUIRED for auto login

    await prefs.setString('department', department);
    await prefs.setString('userType', userType);
    await prefs.setString('unit', unit);

    await prefs.setString(_tokenKey, token);
    await prefs.setString('redirect', redirect);
  }

  // ================= TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  // ================= GETTERS =================
  static Future<String?> getUsername() async =>
      (await SharedPreferences.getInstance()).getString('username');

  static Future<String?> getPassword() async =>
      (await SharedPreferences.getInstance()).getString('password');

  static Future<String?> getDepartment() async =>
      (await SharedPreferences.getInstance()).getString('department');

  static Future<String?> getUserType() async =>
      (await SharedPreferences.getInstance()).getString('userType');

  static Future<String?> getUnit() async =>
      (await SharedPreferences.getInstance()).getString('unit');

  static Future<String?> getRedirect() async =>
      (await SharedPreferences.getInstance()).getString('redirect');

  static Future<bool> isLoggedIn() async =>
      (await SharedPreferences.getInstance()).getBool('isLoggedIn') ?? false;

  // ================= ROLE =================
  static Future<void> setUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
  }

  static Future<String?> getPlant() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('unit');
  }


  static Future<UserRole> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_roleKey);

    switch (role) {
      case 'padmin':
        return UserRole.padmin;
      case 'rmd':
        return UserRole.rmd;
      case 'lamination':
        return UserRole.lamination;
      case 'cutting':
        return UserRole.cutting;
      case 'bagProduction':
        return UserRole.bagProduction;
      case 'bailing':
        return UserRole.bailing;
      default:
        return UserRole.unknown;
    }
  }

  // ================= LOGOUT =================
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('department');
    await prefs.remove('userType');
    await prefs.remove('unit');
    await prefs.remove('redirect');
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  static const String logoutUrl =
      // 'http://190.92.175.47:80/JblAPI/api/Login/logout';
      // "http://190.92.175.47:80/Innoweave/api/Login/logout";
      //      'http://fibcsoftware.in:4430/api/api/Login/logout';
      // 'http://190.92.175.47:80/JblAPI/api/Login/logout';
      // 'http://190.92.175.47:80/JBL_DEMO/api/Login/logout';
        'http://190.92.175.47:80/Nardana/api';
  // 'http://192.168.29.125:7165/api';

  // 'http://190.92.175.47:80/ASIA_API/api';
  // 'http://190.92.175.47:80/API/api';
 // ' http://fibcsoftware.in:4430/api/api';
      // 'http://190.92.175.47:80/Visa/api';
  //   // static const String _baseUrl = 'http://fibcsoftware.in:4430/Visa/api';

  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(logoutUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Logout Status: ${response.statusCode}");
        print("Logout Response: ${response.body}");
      }

      // ✅ Always clear local session
      await prefs.clear();
      return true;
    } catch (e) {
      print("Logout error: $e");

      // ✅ Even on error, clear local
      await prefs.clear();
      return false;
    }
  }
}

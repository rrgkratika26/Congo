import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CurrentUnitService {
  static const String baseUrl =
      // 'http://190.92.175.47/CONGO_API';
      'https://192.168.29.39:44349';

  static Future<String?> getCurrentUnit() async {
    try {
      final uri = Uri.parse('$baseUrl/api/Login/current-unit');

      debugPrint('CURRENT UNIT API: $uri');

      // IMPORTANT:
      // No Authorization token/header is required.
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      debugPrint('CURRENT UNIT STATUS: ${response.statusCode}');

      debugPrint('CURRENT UNIT RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> &&
          data['status']?.toString().toLowerCase() == 'ok') {
        final unit = data['unit']?.toString().trim();

        if (unit != null && unit.isNotEmpty) {
          return unit;
        }
      }

      return null;
    } catch (e) {
      debugPrint('CURRENT UNIT API ERROR: $e');

      return null;
    }
  }
}

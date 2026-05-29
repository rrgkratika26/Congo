import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../../NARDANA/StockLedger/Web_StockModelClass.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../auth_exception.dart';

class LedgerApiService {
  static const String _baseUrl =
      'https://190.92.175.47:80/Nardana/api';
  // static const String _baseUrl ='http://192.168.128.237:7165/api';


  // ================= AUTH CHECK =================
  static void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw AuthException("SESSION_EXPIRED");
    }
  }

  // ================= LOG =================
  static void _logApi({
    required String method,
    required Uri url,
    required http.Response response,
  }) {
    // debugPrint("==========================================");
    // debugPrint("🌐 $method => $url");
    // debugPrint("📡 Status Code => ${response.statusCode}");
    // debugPrint("📦 Response => ${response.body}");
    // debugPrint("==========================================");
  }

  // ================= HEADERS =================
  static Future<Map<String, String>> authHeaders() async {
    final token = await AppSession.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ================= API =================
  Future<List<StockLedgerModel>> fetchStockLedger(
      String fromDate,
      String toDate,
      int page,
      int pageSize,
      ) async {
    final url = Uri.parse(
      "$_baseUrl/Ledger/ledger"
          "?fromDate=$fromDate"
          "&toDate=$toDate"
          "&pageNumber=$page"
          "&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await authHeaders(),
    );

    _logApi(method: "GET Ledger", url: url, response: response);
    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List list =
      jsonData is Map ? (jsonData['data'] ?? []) : jsonData;

      return list.map((e) => StockLedgerModel.fromJson(e)).toList();
    } else {
      throw Exception("Ledger API failed: ${response.statusCode}");
    }
  }
}
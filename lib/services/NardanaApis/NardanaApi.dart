import 'dart:convert';
import 'dart:developer';
import 'package:IMS/NARDANA/RmdINReports/StockReportsModel.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../InquiryScreen/Marketing/MarketingModel.dart';
import '../../NARDANA/BaleNardana/BaleModel.dart';
import '../../NARDANA/CUTTING_Stock/StockModel.dart';
import '../../NARDANA/LaminationReports/LamOutModelClass.dart';
import '../../NARDANA/LaminationReports/LaminationReports.dart';
import '../../NARDANA/LaminationReports/NaradanaModelLami.dart';
import '../../NARDANA/LoomReprts/LoomReportModelClass.dart';
import '../../NARDANA/Marketing/InquiryReportModel.dart';
import '../../NARDANA/Planning/ModelClass/CombineToLoomModel.dart';
import '../../NARDANA/Planning/ModelClass/DropdownModel_GenCode.dart';
import '../../NARDANA/Planning/ModelClass/ForwardListModel.dart';
import '../../NARDANA/Planning/ModelClass/OrderCompositionModel.dart';
import '../../NARDANA/Planning/ModelClass/OrderPlanningModel.dart';
import '../../NARDANA/Planning/ModelClass/PartyNameModel.dart';
import '../../NARDANA/Planning/ModelClass/PlanningModel.dart';
import '../../NARDANA/RmdINReports/RmdInReportsModel.dart';
import '../../NARDANA/RmdINReports/RmdOutReportModel.dart';
import '../../NARDANA/StockLedger/StockLedger_detailsModelClass.dart';
import '../../NARDANA/WebbingsReports/OutModelClass.dart';
import '../../NARDANA/WebbingsReports/StockGrouping/FabCodeWiseModel.dart';
import '../../NARDANA/WebbingsReports/WebInReportModel.dart';
import '../../ScannedItem/Cutting/NardanaCutting/modelclass/CuttingOutStockNardana.dart';
import '../../ScannedItem/Cutting/NardanaCutting/modelclass/RemaingWtModel.dart';
import '../../ScannedItem/Cutting/cutOutModelClass/RemainingWeightModelClass.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/laminationOut_model.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/RollData.dart';
import '../../ScannedItem/Webbing/ReportmodelClass/ReportModelClass.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../auth_exception.dart';

class NaradanaApiService {
  // static const String _baseUrl = 'http://192.168.29.125:7165/api';
  // static const String _baseUrl = 'http://fibcsoftware.in:4430/api/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/JblAPI/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/JBL_DEMO/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/Visa/api';
  static const String _baseUrl = 'http://190.92.175.47:80/Nardana/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/ASIA_API/api';
  // static const String _baseUrl ='http://190.92.175.47:80/API/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/Nardana';
  // static const String _baseUrl = 'http://fibcsoftware.in:4430/Visa/api';
  // static const String _baseUrl = 'http://190.92.175.47:80/Innoweave/api';

  static void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw AuthException("SESSION_EXPIRED");
    }
  }

  static void _logApi({
    required String method,
    required Uri url,
    required http.Response response,
  }) {
    debugPrint("==========================================");
    debugPrint("🌐 $method => $url");
    // debugPrint("📡 Status Code => ${response.statusCode}");
    // debugPrint("📦 Response => ${response.body}");
    // debugPrint("==========================================");
  }

  // COMMON HEADERS
  static Future<Map<String, String>> _jsonHeaders({
    bool withAuth = true,
  }) async {
    final token = await AppSession.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (withAuth && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await AppSession.getToken();
    // debugPrint("Authatoken::::$token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> formHeaders() async {
    final token = await AppSession.getToken();

    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ======== DROPDOWN DATA =================

  Future<List<LoomReport>> fetchLoomData({
    required DateTime? from,
    required DateTime? to,
  }) async {
    try {
      final fromDate = from != null
          ? DateFormat('yyyy-MM-dd').format(from)
          : '';
      final toDate = to != null ? DateFormat('yyyy-MM-dd').format(to) : '';

      final uri = Uri.parse('$_baseUrl/Loom/GetLoomData').replace(
        queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
          'pageNumber': '1',
          'pageSize': '500',
        },
      );

      final response = await http.get(uri, headers: await authHeaders());
      debugPrint("URL: $uri");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("LOOM API RESPONSE: $uri");
      _checkUnauthorized(response);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint("LOOM API RESPONSE: $data");

        return data.map((e) => LoomReport.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch loom data");
      }
    } catch (e) {
      debugPrint("LOOM API ERROR: $e");
      rethrow;
    }
  }

  Future<List<RmdInReport>> fetchRmdInReport({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      // ✅ Safe date handling
      final fromDate = from != null
          ? DateFormat('yyyy-MM-dd').format(from)
          : DateFormat(
        'yyyy-MM-dd',
            ).format(DateTime.now().subtract(const Duration(days: 1)));

      final toDate = to != null
          ? DateFormat('yyyy-MM-dd').format(to)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final uri = Uri.parse('$_baseUrl/Rmd/Rmd/GetRmdInReport').replace(
        queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
          'pageNumber': '1',
          'pageSize': '50',
        },
      );

      final response = await http.get(uri, headers: await authHeaders());

      _logApi(method: "GET", url: uri, response: response);
      _checkUnauthorized(response);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // ✅ Handle both response types
        final List data = decoded is List ? decoded : decoded['data'] ?? [];

        return data.map((e) => RmdInReport.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to load RMD In Report (${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("RMD ERROR: $e");
      rethrow;
    }
  }

  Future<List<RmdOutReport>> fetchRmdOutReport({
    required DateTime from,
    required DateTime to,

    int pageNumber = 1,
    int pageSize = 500000,
  }) async {
    // final url =
    //     "$_baseUrl/Rmd/Rmd/GetRmdOutReport"
    //     "?fromDate=${DateFormat('yyyy-MM-dd').format(from)}"
    //     "&toDate=${DateFormat('yyyy-MM-dd').format(to)}"
    //     "&pageNumber=pageNumber"&pageSize=$pageSize";
    final url =
        "$_baseUrl/Rmd/Rmd/GetRmdOutReport"
        "?fromDate=${DateFormat('yyyy-MM-dd').format(from)}"
        "&toDate=${DateFormat('yyyy-MM-dd').format(to)}"
        "&pageNumber=$pageNumber"
        "&pageSize=$pageSize";

    final res = await http.get(Uri.parse(url), headers: await authHeaders());

    debugPrint("RMD IN URL: $url");
    debugPrint("STATUS: ${res.statusCode}");
    if (res.statusCode == 200) {
      _logApi(method: "GET", url: Uri.parse(url), response: res);
      final List data = jsonDecode(res.body);

      return data.map((e) => RmdOutReport.fromJson(e)).toList();
    } else {
      throw Exception("API Failed");
    }
  }
  // api/Lamination/GetLaminationInReport?fromDate=2026-04-20&toDate=2026-04-21&pageNumber=1&pageSize=250
  // Lamination in report

  Future<List<LaminationReportModel>> fetchLaminationReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/Lamination/GetLaminationInReport'
        "?fromDate=${DateFormat('yyyy-MM-dd').format(from)}"
        "&toDate=${DateFormat('yyyy-MM-dd').format(to)}"
        "&pageNumber=1&pageSize=10",
      );

      final response = await http.get(
        uri,
        headers: await InStockService.authHeaders(),
      );
      _logApi(method: "GET", url: uri, response: response);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        debugPrint("Response adata: $jsonList");
        return jsonList
            .map((json) => LaminationReportModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load lamination report: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching lamination report: $e');
    }
  }

  Future<List<LamNardanaOutModel>> fetchLamOut({
    required DateTime from,
    required DateTime to,
  }) async {
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(to);

    final url =
        "$_baseUrl/Lamination/GetLaminationOutReport?fromDate=$f&toDate=$t&pageNumber=1&pageSize=5000";

    final res = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );

    if (res.statusCode == 200) {
      print('Lam in Report $url');
      final body = jsonDecode(res.body);
      final List list = body is List ? body : (body["data"] ?? []);
      return list.map((e) => LamNardanaOutModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed API");
    }
  }

  Future<List<WeBNardanaReportModel>> fetchReport(
    String from,
    String to, {
    int pageNumber = 1,
    int pageSize = 50000,
  }) async {
    final uri = Uri.parse("$_baseUrl/Webbing/webbing-in-report").replace(
      queryParameters: {
        'dateFrom': from,
        'dateTo': to,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final res = await http.get(uri, headers: await authHeaders());

    debugPrint("URL: $uri");
    debugPrint("STATUS: ${res.statusCode}");
    debugPrint("BODY: ${res.body}");

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);

      if (jsonData['success'] == true) {
        return (jsonData['data'] as List)
            .map((e) => WeBNardanaReportModel.fromJson(e))
            .toList();
      } else {
        throw Exception(jsonData['message'] ?? "Unknown error");
      }
    } else {
      throw Exception("API Failed: ${res.statusCode}");
    }
  }

  Future<List<WebOutReportModel>> fetchWebbingOutReport(
    String fromDate,
    String toDate,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/Webbing/webbing-out-report?dateFrom=$fromDate&dateTo=$toDate&pageNumber=1&pageSize=250',
    );

    final response = await http.get(url, headers: await authHeaders());

    if (response.statusCode == 200) {
      print("📡 Status Code => ${response.statusCode}");

      print("URL=> ${url}");

      print("📦 webbing Response Body => ${response.body}");
      final decoded = json.decode(response.body);

      if (decoded['success'] == true) {
        final List data = decoded['data'];

        return data.map((e) => WebOutReportModel.fromJson(e)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to fetch data');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<List<WebOutReportModel>> fetchWebbingStock(int page, int size) async {
    final url =
        "$_baseUrl/Webbing/webbing-stock?pageNumber=$page&pageSize=$size";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);

      final List list = jsonData['data'];

      return list.map((e) => WebOutReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Webbing Stock");
    }
  }

  Future<List<RmdStockReportModel>> fetchRmdStock(int page, int size) async {
    final url = "$_baseUrl/Rmd/Rmd/GetRmdStock?pageNumber=$page&pageSize=$size";

    // print("🌐 GET => $url");

    final res = await http.get(Uri.parse(url), headers: await authHeaders());

    // ✅ PRINT STATUS CODE
    // print("📡 Status Code => ${res.statusCode}");

    // Optional: print full response for debugging
    // print("📦 Response Body => ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final List list = body is List ? body : body["data"];

      return list.map((e) => RmdStockReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed: ${res.statusCode} | ${res.body}");
    }
  }

  /// ===============================================================
  /// FILE 1 : fabric_code_wise_api.dart
  /// API SERVICE (SEPARATE FILE)
  /// ===============================================================

  /// =====================================================
  /// 1. FABRIC CODE SUMMARY REPORT
  /// =====================================================
  static Future<FabricCodeWiseResponse> getFabricCodeWise({
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Webbing/fabriccodewise?pageNumber=$page&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    // print("🌐 GET => $url");
    // print("📌 Status Code => ${response.statusCode}");
    _logApi(method: "GET", url: url, response: response);

    /// ✅ Full Raw Response Body
    // print("📦 Response Body => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      /// ✅ Pretty Print JSON
      // print("✅ Decoded Response => $jsonData");

      return FabricCodeWiseResponse.fromJson(jsonData);
    } else {
      print("❌ Error Response => ${response.body}");
      throw Exception("Failed to load fabric code wise report");
    }
  }

  /// =====================================================
  /// 2. FABRIC CODE STOCK DETAIL
  /// =====================================================
  static Future<Map<String, dynamic>> getWebStockFabric({
    required String fabricCode,
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Webbing/stockfabric"
      "?fabricCode=$fabricCode&pageNumber=$page&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    // print("🌐 GET => $url");
    // print("Fabric WebStock Grouping Report => $response");
    _logApi(method: "GET", url: url, response: response);
    if (response.statusCode == 200) {
      // print("📦 Response Body => ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load stock fabric data");
    }
  }

  /// ===============================================================
  /// API SERVICE METHOD
  /// ===============================================================

  static Future<List<CuttingFabricSummaryModel>> getCuttingFabricSummary({
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Cutting/GetFabricSummaryReport?pageNumber=$page&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    _logApi(method: "GET", url: url, response: response);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print("Fabric WebStock Grouping Report => $data.");

      return data.map((e) => CuttingFabricSummaryModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Cutting Fabric Summary");
    }
  }

  static Future<List<dynamic>> getFabricCodeWiseReport({
    required String fabricCode,
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Cutting/GetFabricCodeWiseReport"
      "?fabricCode=$fabricCode"
      "&pageNumber=$page"
      "&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    // print("==================================");
    // print("🌐 API URL => $url");
    // print("📡 Status Code => ${response.statusCode}");
    // print("📦 Raw Response => ${response.body}");
    // print("==================================");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      _logApi(method: "GET", url: url, response: response);
      if (decoded is List) {
        // print("✅ Total Records => ${decoded.length}");

        for (int i = 0; i < decoded.length; i++) {
          // print("📌 Item $i => ${decoded[i]}");
        }

        return decoded;
      } else {
        print("⚠ Response is not List");
        return [];
      }
    } else {
      print("❌ API Failed");
      throw Exception("Failed to load Fabric Code Wise Report");
    }
  }

  //
  //
  // static Future<List<dynamic>> getFabricWiseDetail({
  //   required String fabricCode,
  //   required int id,
  // }) async {
  //   final url = Uri.parse(
  //     "$_baseUrl/api/Cutting/FabricWiseDetail"
  //         "?fabricCode=$fabricCode&id=$id",
  //   );
  //
  //   final response = await http.get(
  //     url,
  //     headers: await InStockService.authHeaders(),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final decoded = jsonDecode(response.body);
  //
  //     if (decoded is List) {
  //       return decoded;
  //     } else if (decoded is Map &&
  //         decoded["data"] is List) {
  //       return decoded["data"];
  //     } else {
  //       return [];
  //     }
  //   } else {
  //     throw Exception(
  //       "Failed to load Fabric Wise Detail",
  //     );
  //   }
  // }

  //////////////////////////////////////////////////////
  static Future<List<dynamic>> getFabricWiseDetail({
    required String fabricCode,
    required int? id,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Webbing/FabricWiseDetail"
      "?fabricCode=${Uri.encodeComponent(fabricCode)}"
      "&id=$id",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      _logApi(method: "GET", url: url, response: response);

      return jsonDecode(response.body);
    } else {
      throw Exception("FabricWiseDetail Failed : ${response.statusCode}");
    }
  }
  // api/Cutting/FabricWiseDetail?fabricCode=099-F00-A-130%2B17-SL-WH-H-000&id=2

  static Future<List<dynamic>> getCutFabricWiseDetail({
    required String fabricCode,
    required int? id,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Cutting/FabricWiseDetail"
      "?fabricCode=${Uri.encodeComponent(fabricCode)}"
      "&id=$id",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      _logApi(method: "GET", url: url, response: response);

      return jsonDecode(response.body);
    } else {
      throw Exception("FabricWiseDetail Failed : ${response.statusCode}");
    }
  }

  // =======================================================
  // Add in NaradanaApiService.dart
  // =======================================================

  static Future<List<BaleStockModel>> getBailingStock({
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/BaleDepartment/BailingStock?pageNumber=$page&pageSize=$pageSize",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    // print("======================================");
    // print("🌐 GET => $url");
    // print("📡 Status => ${response.statusCode}");
    // print("📦 Response => ${response.body}");
    // print("======================================");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BaleStockModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Bale Stock");
    }
  }

  static Future<List<CuttingOutstockNaradana>> fetchOutStockListNaradana({
    required String plant,
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Cutting/cutting-out-list?plant=$plant&page=$page&pageSize=$pageSize",
    );

    final res = await http.get(url, headers: await authHeaders());
    print("🌐 GET => $url");
    // print("📡 Status => ${res.statusCode}");
    debugPrint("📦 Response => ${res.body}", wrapWidth: 50);
    print("======================================");
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);

      // assuming API returns: List directly OR inside "data"
      final List list = jsonData is List ? jsonData : jsonData['data'] ?? [];

      return list.map((e) => CuttingOutstockNaradana.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load cutting out list");
    }
  }

  static Future<Map<String, dynamic>?> getArticleNo(int id) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/Cutting/GetArticleNo?id=$id"),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      print("$response");

      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getBomAndComponents({
    required String po,
    required String article,
  }) async {
    final url = "$_baseUrl/Cutting/GetBomAndComponents?po=$po&article=$article";

    final response = await http.get(
      Uri.parse(url),
      headers: await authHeaders(),
    );
    debugPrint("Response Bom and Component Body: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, List<String>>> getLaminationAndBaffle() async {
    try {
      final response = await http.get(
        Uri.parse("${_baseUrl}/Cutting/GetLaminationAndBuffle"),
        headers: await authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        return {
          "laminations": List<String>.from(data["laminations"] ?? []),
          "buffles": List<String>.from(data["buffles"] ?? []),
        };
      } else {
        throw Exception("API Failed");
      }
    } catch (e) {
      debugPrint("Lamination API Error: $e");
      return {"laminations": [], "buffles": []};
    }
  }

  static Future<String> saveCutting(Map<String, dynamic> body) async {
    try {
      final url = "${_baseUrl}/Cutting/SaveCutting";
      final headers = await authHeaders();
      final encodedBody = jsonEncode(body);

      // 🔥 PRINT EVERYTHING
      debugPrint("📡 API CALL → POST");
      debugPrint("🔗 URL → $url");
      debugPrint("📨 Headers → $headers");
      debugPrint("📦 Body → $encodedBody");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedBody,
      );

      // 🔥 PRINT RESPONSE
      debugPrint("📥 Status Code → ${response.statusCode}");
      debugPrint("📥 Response Body → ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return response.body;
        // return res["message"] ?? "SUCCESS";
      } else {
        return "Error ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("❌ Exception → $e");
      return "Exception: $e";
    }
  }

  static Future<RemainingWeightNardanaModel?> getRemainingWeight({
    required int code,
    required double rollWeight,
  }) async {
    try {
      if (code == 0 || rollWeight <= 0) {
        print("❌ Invalid input → code: $code, rollWeight: $rollWeight");
        return null;
      }

      final url =
          "${_baseUrl}/Cutting/GetRemainingWeight?code=$code&rollWeight=$rollWeight";

      // print("🌐 API URL 👉 $url");

      final response = await http.get(
        Uri.parse(url),
        headers: await InStockService.authHeaders(),
      );

      // print("📡 Status Code 👉 ${response.statusCode}");
      // print("📦 Response Body 👉 ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RemainingWeightNardanaModel.fromJson(data);
      } else {
        print("❌ API Failed");
        return null;
      }
    } catch (e) {
      print("❌ Error in getRemainingWeight 👉 $e");
      return null;
    }
  }

  static Future<LaminationOutModel> getLaminationOutstock(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/Lamination/lamination-outstock?id=$id');
      print("🌐 API URL 👉 $url");

      final response = await http.get(url, headers: await authHeaders());

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        print("📡 Status Code 👉 ${response.statusCode}");
        print("📦 Response Body 👉 ${response.body}");
        return LaminationOutModel.fromJson(
          jsonData['data'], // ✅ FULL DATA
        );
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  static Future<List<NewBarcodeNardanaModel>> getLaminationSavedRolls({
    required String date,
  }) async {
    try {
      final headers = await authHeaders();

      final response = await http.get(
        Uri.parse("$_baseUrl/Lamination/savedroll?date=$date"),
        headers: headers,
      );

      // debugPrint("📥 Status Code => ${response.statusCode}");
      // debugPrint("📥 Response => ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => NewBarcodeNardanaModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load lamination rolls");
      }
    } catch (e) {
      debugPrint("❌ API ERROR => $e");
      rethrow;
    }
  }

  static Future<bool> printBarcode({
    required String barcode,
    required String forwardDepartment,
    required String hold,
    required String id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Lamination/print-barcode'),
        headers: await authHeaders(),
        body: jsonEncode({
          "barcode": barcode,
          "forwardDepartment": forwardDepartment,
          "hold": hold,
          "id": id,
        }),
      );

      // debugPrint("PRINT API STATUS : ${response.statusCode}");
      // debugPrint("PRINT API BODY : ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint("PRINT API ERROR : $e");
      return false;
    }
  }

  Future<List<OpenQtyDetailsModel>> fetchOpenQty({
    required String fabricCode,
    required String date,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/Ledger/openqty"
        "?fabricCode=${Uri.encodeComponent(fabricCode)}"
        "&date=$date"
        "&pageNumber=$pageNumber"
        "&pageSize=$pageSize",
      ),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // debugPrint("PRINT API STATUS : ${response.statusCode}");
      // debugPrint("PRINT API BODY : ${response.body}");
      return data.map((e) => OpenQtyDetailsModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<List<dynamic>> fetchInQty({
    required String fabricCode,
    required String fromDate,
    required String toDate,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final uri = Uri.parse("$_baseUrl/Ledger/inqty").replace(
      queryParameters: {
        "fabricCode": fabricCode,
        "fromDate": fromDate,
        "toDate": toDate,
        "pageNumber": pageNumber.toString(),
        "pageSize": pageSize.toString(),
      },
    );

    final response = await http.get(uri, headers: await authHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return List<dynamic>.from(body);
    } else {
      throw Exception(
        "Failed to load InQty Data : "
        "${response.statusCode}",
      );
    }
  }

  /// ───────────────── API SERVICE ─────────────────

  Future<List<Map<String, dynamic>>> fetchInquiryReport({
    required String fromDate,
    required String toDate,
    int pageNumber = 1,
    int pageSize = 50000,
  }) async {
    final url =
        "$_baseUrl/Marketing/InquiryReport?"
        "fromDate=$fromDate"
        "&toDate=$toDate"
        "&pageNumber=$pageNumber"
        "&pageSize=$pageSize";

    final response = await http.get(
      Uri.parse(url),
      headers: await authHeaders(),
    );
    debugPrint("PRINT API STATUS : ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("PRINT API STATUS : ${response.statusCode}");
      debugPrint("PRINT API BODY : ${response.body}");

      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load Inquiry Report");
    }
  }

  Future<List<String>> fetchCustomerNames() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/Marketing/CustomerName"),
        headers: await authHeaders(),
      );
      debugPrint("PRINT API STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        // debugPrint("PRINT API STATUS : ${response.statusCode}");
        // debugPrint("PRINT API BODY : ${response.body}");
        return data
            .map<String>((e) => e["customeR_NAME"].toString().trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      }

      return [];
    } catch (e) {
      print("Customer API Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBomInquiryReport({
    required String unitName,
    int pageNumber = 1,
    int pageSize = 500,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/Marketing/BomInquiryReport"
          "?extra37=$unitName"
          "&pageNumber=$pageNumber"
          "&pageSize=$pageSize",
        ),
        headers: await authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return List<Map<String, dynamic>>.from(data);
      }

      return [];
    } catch (e) {
      print("BOM API Error: $e");
      return [];
    }
  }

  Future<List<String>> fetchPartyNames() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/Marketing/CustomerName"),
        headers: await authHeaders(),
      );

      // print("PartyName STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final partyNames =
            data
                .map<String>((e) => e["customeR_NAME"].toString().trim())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        print("Party List => $partyNames");

        return partyNames;
      }

      return [];
    } catch (e) {
      print("Party API Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBomList({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/Marketing/BomList?pageNumber=$pageNumber&pageSize=$pageSize",
        ),
        headers: await authHeaders(),
      );

      print("BOM LIST STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return List<Map<String, dynamic>>.from(data);
      }

      return [];
    } catch (e) {
      print("BOM LIST ERROR : $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchIssueToQuality({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/Marketing/IssueToQuality?pageNumber=$pageNumber&pageSize=$pageSize",
      ),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load Issue To Quality");
    }
  }

  Future<List<OrderPlanningModel>> fetchOrderPlanning({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Uri url = Uri.parse("$_baseUrl/Planning/OrderCompList").replace(
        queryParameters: {
          "pageNumber": pageNumber.toString(),
          "pageSize": pageSize.toString(),
        },
      );

      final response = await http.get(url, headers: await authHeaders());

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => OrderPlanningModel.fromJson(e)).toList();
      }

      throw Exception("Status Code: ${response.statusCode}");
    } catch (e) {
      throw Exception("Failed: $e");
    }
  }

  //   {{baseUrl_Nardana}}/Planning/Planning?inquiryNo=%2321
  Future<List<PlanningModel>> fetchPlanningData({
    required String inquiryNo,
  }) async {
    try {
      final Uri url = Uri.parse(
        "$_baseUrl/Planning/Planning",
      ).replace(queryParameters: {"inquiryNo": inquiryNo});
      final response = await http.get(url, headers: await authHeaders());

      if (response.statusCode == 200) {
        debugPrint("PRINT API STATUS : ${response.statusCode}");
        debugPrint("PRINT BODY : ${response.body}");

        final List data = jsonDecode(response.body);

        return data.map((e) => PlanningModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      throw Exception("Planning API Error : $e");
    }
  }

  Future savePlanning({
    required String woNumber,
    required String quantity,
    required String poNum,
    required String articleNum,
    required String unit,
    required List<PlanningModel> items,
  }) async {
    final body = {
      "wo_number": woNumber,
      "quantity": quantity,
      "po_num": poNum,
      "article_num": articleNum,

      "items": items
          .map(
            (e) => {
              "row_list": e.rowList,
              "hemming_fs_ds": e.fabricCode,
              "fabric_gsm": e.fabricGsm,
              "lamination": e.lamination,
              "fabric_size": e.fabricSize,
              "cut_size": e.cutSize,

              "extra12": e.reqMtr,
              "extra35": e.reqKg,
              "value_1": e.reqPcs,

              "department": e.department,
              "wastage": e.wastage.isEmpty ? "0" : e.wastage,

              "actual_required_mtr": e.reqMtr,
              "actual_required_kg": e.reqKg,
              "actual_required_pcs": e.reqPcs,

              "available_mtr": "",
              "available_kg": "",
              "available_pcs": "",

              "stock": "",

              "order_required_mtr":
                  ((double.tryParse(e.reqMtr) ?? 0) +
                          ((double.tryParse(e.reqMtr) ?? 0) *
                              (double.tryParse(e.wastage) ?? 0) /
                              100))
                      .round()
                      .toString(),
              "order_required_kg":(
                  (double.tryParse(e.reqKg) ?? 0) +
                      ((double.tryParse(e.reqKg) ?? 0) *
                          (double.tryParse(e.wastage) ?? 0) / 100)
              ).round().toString(),
              "order_required_pcs": (
                  (double.tryParse(e.quantity) ?? 0) +
                      (double.tryParse(e.wastage) ?? 0)
              ).round().toString(),

              "combined_column": e.combinedColumn,
            },
          )
          .toList(),
    };

    // Add unit in URL
    final url = Uri.parse("$_baseUrl/Planning/save?unit=UNIT-$unit");

    debugPrint("URL => $url");
    debugPrint("BODY => ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {...await authHeaders(), "Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    debugPrint("Response Status => ${response.statusCode}");

    debugPrint("Response Body => ${response.body}");

    return response;
  }

  Future<List<OrderCompositionModel>> fetchOrderComposition() async {
    final response = await http.get(
      Uri.parse("$_baseUrl/Planning/ordercomp_list"),
      headers: await authHeaders(),
    );

    debugPrint("Order Composition Status => ${response.statusCode}");

    debugPrint("Order Composition Body => ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => OrderCompositionModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load order composition");
  }

  Future singleSave(List<OrderCompositionModel> items) async {
    final body = {
      "items": items
          .map(
            (e) => {
              "boM_NO": e.woNumber,
              "component": e.component,
              "fabriC_CODE": e.fabricCode,
              "mtr": e.orderRequiredMtr,
              "kg": e.orderRequiredKg,
              "iD_WO": e.idForWo,
              "pO_NUM": e.poNum,
              "articlE_NUM": e.articleNum,
            },
          )
          .toList(),
    };

    final url = "$_baseUrl/Planning/SingleSave";

    debugPrint("URL => $url");
    debugPrint("Single Body => ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(url),

      headers: {"Content-Type": "application/json", ...await authHeaders()},

      body: jsonEncode(body),
    );

    debugPrint("Status => ${response.statusCode}");

    debugPrint("Response => ${response.body}");

    return response;
  }

  Future clubSave(List<OrderCompositionModel> items) async {
    final body = {
      "items": items
          .map(
            (e) => {
              "boM_NO": e.woNumber,
              "component": e.component,
              "fabriC_CODE": e.fabricCode,
              "mtr": e.orderRequiredMtr,
              "kg": e.orderRequiredKg,
              "iD_WO": e.idForWo,
              "pO_NUM": e.poNum,
              "articlE_NUM": e.articleNum,
            },
          )
          .toList(),
    };

    final url = "$_baseUrl/Planning/ClubSave";

    debugPrint("========== CLUB REQUEST ==========");

    debugPrint("URL => $url");

    debugPrint("Club Body => ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(url),

      headers: {"Content-Type": "application/json", ...await authHeaders()},

      body: jsonEncode(body),
    );

    debugPrint("Status Code => ${response.statusCode}");

    debugPrint("Headers => ${response.headers}");

    debugPrint("Response Body => ${response.body}");

    debugPrint("==================================");

    return response;
  }

  Future<List<CombineToLoomModel>> getCombineToLoomList(String? unit) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/Planning/CombineToLoomList?unit=$unit"),
        headers: await authHeaders(),
      );
      debugPrint("Response Body => ${response.body}");

      debugPrint("==================================");
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((e) => CombineToLoomModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<FabricCategoryModel>> getFabricDropdowns(String? unit) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/Planning/AllFabricDropdowns?unit=$unit"),
        headers: await authHeaders(),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        debugPrint(
          "Status Code /Planning/AllFabricDropdowns?unit=$unit => ${response.statusCode}",
        );

        debugPrint("Headers => ${response.headers}");

        debugPrint("Response Body => ${response.body}");

        debugPrint("==================================");

        debugPrint("Response Body => ${response.body}");

        debugPrint("==================================");
        return data.map((e) => FabricCategoryModel.fromJson(e)).toList();
      }

      throw Exception("Failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> forwardToLoom({
    required String? unit,

    required int orderNo,
    required String fabricCode,
    required String requiredMtr,
    required String requiredKg,
    required String extraMtr,
    required String extraKg,
    required String actualRequiredMtr,
    required String actualRequiredKg,
    required String customerName,
    required String poNum,
    required String articleNum,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/Planning/ForwardToLoom?unit=$unit');

      final body = {
        "ordeR_NO": orderNo,
        "fabriC_CODE": fabricCode,
        "requireD_MTR": requiredMtr,
        "requireD_KG": requiredKg,
        "extrA_MTR": extraMtr,
        "extrA_KG": extraKg,
        "actuaL_REQUIRED_MTR": actualRequiredMtr,
        "actuaL_REQUIRED_KG": actualRequiredKg,
        "customeR_NAME": customerName,
        "pO_NUM": poNum,
        "articlE_NUM": articleNum,
      };

      final response = await http.post(
        url,
        headers: await authHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ForwardListModel>> getForwardList({
    required String unit,
    required String orderNo,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/Planning/ForwardList"
        "?unit=$unit&orderNo=$orderNo",
      ),
      headers: await authHeaders(),
    );

    debugPrint("ForwardList Status : ${response.statusCode}");

    debugPrint("ForwardList Response : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data as List).map((e) => ForwardListModel.fromJson(e)).toList();
    }

    return [];
  }

  Future<PartyNameModel?> getPartyDetails({
    required String unit,
    required String bomNo,
  }) async {
    final url = Uri.parse(
      "$_baseUrl/Planning/PartyName"
      "?unit=${Uri.encodeComponent(unit)}"
      "&bomNo=${Uri.encodeComponent(bomNo.trim())}",
    );

    debugPrint("Party API URL : $url");

    final response = await http.get(url, headers: await authHeaders());

    debugPrint("Party API Status : ${response.statusCode}");

    debugPrint("Party API Response : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return PartyNameModel.fromJson(data[0]);
    }

    return null;
  }

  Future<bool> forwardPlanningToLoom({
    required String unit,
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = "$_baseUrl/Planning/ForwardToLoom?unit=$unit";

      debugPrint("Forward URL => $url");

      debugPrint("Request => $body");

      final response = await http.post(
        Uri.parse(url),
        headers: await authHeaders(),
        body: jsonEncode(body),
      );

      debugPrint("Status => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Forward Error => $e");
      return false;
    }
  }

  static Future<MarketingCountModel?> getMarketingCount({
    required String unit,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final url =
        "$_baseUrl/Dashboard/MarketingCount"
        "?unit=$unit"
        "&type=$type"
        "&fromDate=${DateFormat('dd-MM-yyyy').format(fromDate)}"
        "&toDate=${DateFormat('dd-MM-yyyy').format(toDate)}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await authHeaders(),
      );

      debugPrint("=================================");
      debugPrint("URL => $url");
      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");
      debugPrint("=================================");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        debugPrint("Total Inquiry => ${json['totalInquiryCount']}");
        debugPrint("Net Weight => ${json['netWeight']}");
        debugPrint("Roll Length => ${json['rollLength']}");
        debugPrint("No Of Roll => ${json['noOfRoll']}");

        return MarketingCountModel.fromJson(json);
      }
    } catch (e, s) {
      debugPrint("MarketingCount Error => $e");
      debugPrint("$s");
    }

    return null;
  }
}

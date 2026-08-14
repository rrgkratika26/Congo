import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../AdminDashBoard/Dashboard Summary.dart';
import '../InquiryScreen/Marketing/MarketingModel.dart';
import '../JBL/JBLWebbing/Reports_model/outReportModel.dart';
import '../ScannedItem/Webbing/ReportmodelClass/BomDetailModel.dart';
import '../ScannedItem/Webbing/ReportmodelClass/ReportModelClass.dart';
import '../ScannedItem/Webbing/ReportmodelClass/SaveWebbingEntry.dart';
import '../ScannedItem/Webbing/ReportmodelClass/WebOutDetailsclass.dart';
import '../ScannedItem/Webbing/ReportmodelClass/WebbingEntryModel.dart';
import '../ScannedItem/Webbing/ReportmodelClass/webSaveEntriesList.dart';
import '../util/sharedpreference/shared_preference.dart';

class DashboardService {
  double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<DashboardSummary> getDashboard({
    required String unit,
    required String fromDate,
    required String toDate,
  }) async {
    Future<Map<String, dynamic>> get(String unit,String api) async {
      final url = Uri.parse(
        "${InStockService.baseUrl}/Dashboard/$api"
        "?unit=$unit&fromDate=$fromDate&toDate=$toDate",
      );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      print("========== API ==========");
      print("URL : $url");
      print("STATUS : ${response.statusCode}");
      print("RESPONSE : ${response.body}");
      print("=========================");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(response.body);
    }

    Future<Map<String, dynamic>> getMarketing(String unit,String type) async {
      final url = Uri.parse(
        "${InStockService.baseUrl}/Dashboard/MarketingCount"
        "?unit=$unit&type=$type&fromDate=$fromDate&toDate=$toDate",
      );

      print("========== MARKETING API ==========");
      print("TYPE : $type");
      print("URL : $url");

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      print("STATUS : ${response.statusCode}");
      print("TYPE : $type");
      print("BODY : ${response.body}");
      print("===============================");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception("Marketing $type : ${response.body}");
    }

    final result = await Future.wait([
      get(unit,"planning"), // 0
      get(unit,"cutting"), // 1
      get(unit,"cutpcs"), // 2
      get(unit,"totalbagproduction"), // 3
      get(unit,"bailing"), // 4
      get(unit,"tapeline"), //5

      getMarketing(unit,"WO"), // 6
      getMarketing(unit,"RMD"), // 7
      getMarketing(unit,"LAMINATION"), // 8
      getMarketing(unit,"BOM"), // 9
      getMarketing(unit,"INQUIRY"), // 10
      get(unit,"GetLoomData"), // 6
    ]);

    final dashboard = DashboardSummary.fromJson(
      planningJson: result[0],
      cuttingJson: result[1],
      cutPcsJson: result[2],
      bagJson: result[3],
      bailingJson: result[4],
      tapeJson: result[5],
      woJson: result[6],
      rmdJson: result[7],
      laminationJson: result[8],
      bomJson: result[9],
      inquiryJson: result[10],
      loomJson: result[11],
    );

    print("Inquiry Count = ${dashboard.inquiryCount}");

    print("Inquiry Count = ${dashboard.bomCount}");

    return dashboard;
  }

  static Future<WebbingMasterDropdownModel> fetchWebbingMasterDropdown() async {
    final response = await http.get(
      Uri.parse('${InStockService.baseUrl}/Webbing/master-dropdown'),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      print("RESPONSE master dropdown : ${response.body}");
      return WebbingMasterDropdownModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load dropdown');
  }

  static Future<List<String>> fetchBomList() async {
    final response = await http.get(
      Uri.parse('${InStockService.baseUrl}/Webbing/bom'),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      print("RESPONSE Bom List : ${response.body}");

      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic> data = json["data"] ?? [];

      return data.map((e) => e.toString()).toList();
    }

    throw Exception("Failed to load BOM");
  }

  static Future<WebbingBomDetailsModel> fetchBomDetails(String bom) async {
    final response = await http.get(
      Uri.parse(
        '${InStockService.baseUrl}/Webbing/all-dropdown?bom=${Uri.encodeComponent(bom)}',
      ),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      print("RESPONSE Bom  Details//////////List : ${response.body}");

      return WebbingBomDetailsModel.fromJson(jsonDecode(response.body));
    }

    throw Exception("Unable to load BOM Details");
  }

  static Future<double> fetchProductionWeight(String bomNo) async {
    final response = await http.get(
      Uri.parse(
        "${InStockService.baseUrl}/Webbing/production-weight?bomNo=${Uri.encodeComponent(bomNo)}",
      ),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      print("RESPONSE Production wt Details//////////List : ${response.body}");
      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        return (json["productionWeight"] as num).toDouble();
      }
    }

    return 0;
  }

  static Future<WebbingSaveResponse> saveWebbingEntry(
    WebbingSaveRequest request,
  ) async {
    final response = await http.post(
      Uri.parse('${InStockService.baseUrl}/Webbing/save'),
      headers: await InStockService.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    debugPrint("SAVE REQUEST : ${jsonEncode(request.toJson())}");
    debugPrint("SAVE RESPONSE : ${response.body}");

    if (response.statusCode == 200) {
      return WebbingSaveResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception("Unable to save entry");
  }

  static Future<int> fetchWebbingId() async {
    try {
      final response = await http.get(
        Uri.parse("${InStockService.baseUrl}/Webbing/id"),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as int;
        }
      }
      throw Exception("Failed to fetch Webbing ID");
    } catch (e) {
      print("fetchWebbingId error: $e");
      rethrow;
    }
  }

  static Future<List<WebbingSavedEntry>> fetchSavedWebbingEntries(
    String plant,
  ) async {
    final response = await http.get(
      Uri.parse("${InStockService.baseUrl}/Webbing/saved-list?plant=$plant"),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return WebbingSavedEntryResponse.fromJson(jsonData).data;
    }

    throw Exception("Unable to load entries");
  }

  static Future<Map<String, dynamic>> printWebbingBarcode({
    required String barcode,
    required String department,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${InStockService.baseUrl}/Webbing/print-barcode"),
        headers: await InStockService.authHeaders(),
        body: jsonEncode({"barcode": barcode, "department": department}),
      );

      debugPrint("Print Status : ${response.statusCode}");
      debugPrint("Print Response : ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<MarketingCountModel> getMarketingCount({
    required String unit,
    required String type,
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse(
      "${InStockService.baseUrl}/Dashboard/MarketingCount"
      "?unit=$unit"
      "&type=$type"
      "&fromDate=$fromDate"
      "&toDate=$toDate",
    );

    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      debugPrint("Print//////// URL : $uri");
      debugPrint("TYPE : $type");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");

      return MarketingCountModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  Future<List<dynamic>> getCuttingScannedItems(String date) async {
    final url =
        '${InStockService.baseUrl}/Cutting/CuttingInScannedItem?date=$date';

    print("URL : $url");

    final response = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Status: ${response.statusCode}\nResponse: ${response.body}',
      );
    }
  }

  Future<int> getCutScannedItemsCount(String date) async {
    final items = await getCuttingScannedItems(date);
    return items.length;
  }

  static Future<WebbingOutDetailsModel?> fetchWebbingScannedOutItems(
    String date,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${InStockService.baseUrl}/Webbing/WebbingOutScanned?date=$date',
        ),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return WebbingOutDetailsModel.fromJson(jsonData);
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<int> fetchWebbingScannedOutItemsCount(String date) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${InStockService.baseUrl}/Webbing/WebbingOutScanned?date=$date',
        ),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.length;
      }

      return 0;
    } catch (e) {
      debugPrint("Count Error: $e");
      return 0;
    }
  }
}

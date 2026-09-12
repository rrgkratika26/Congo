import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../NARDANA/CUTTING_Stock/Reports/RollCuttingReport/ModelComponentWise/ComponentDetailModel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/RollCuttingReport/ModelComponentWise/ComponentdateWiseModel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/RollCuttingReport/ModelComponentWise/RollCuttingModel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/RollCuttingReport/ModelComponentWise/RollwisecuttingStockmodel.dart';
import '../../NARDANA/RmdINReports/RmdRollModelclass/ArtcleBomModel.dart';
import '../../NARDANA/RmdINReports/RmdRollModelclass/MasterRmdModel.dart';
import '../../NARDANA/RmdINReports/RmdRollModelclass/PonOmodel.dart';

import '../../NARDANA/RmdINReports/RmdRollModelclass/RmdRollEntrysavedListModel.dart';
import '../../util/sharedpreference/shared_preference.dart';

class RmdService {
  static Future<Map<String, String>> authHeaders() async {
    final token = await AppSession.getToken();
    // debugPrint("Authatoken::::$token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// MASTER DATA
  static Future<RmdMasterModel?> getMasterData({required String unit}) async {
    final url = Uri.parse(
      "${InStockService.baseUrl}/Rmd/Rmd/GetMasterData?unit=$unit",
    );

    try {
      print("========================================");
      print("GET : $url");

      final response = await http.get(
        url,
        headers: await RmdService.authHeaders(),
      );

      print("STATUS : ${response.statusCode}");
      print("RESPONSE : ${response.body}");
      print("========================================");

      if (response.statusCode == 200) {
        return RmdMasterModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("MASTER DATA ERROR : $e");
    }

    return null;
  }

  /// PO NUMBER
  static Future<PoNumberModel?> getPoNumbers(String customerName) async {
    final url = Uri.parse(
      "${InStockService.baseUrl}/Rmd/Rmd/GetPoNumbers?customerName=${Uri.encodeComponent(customerName)}",
    );

    try {
      print("========================================");
      print("GET : $url");

      final response = await http.get(
        url,
        headers: await RmdService.authHeaders(),
      );

      print("STATUS : ${response.statusCode}");
      print("RESPONSE : ${response.body}");
      print("========================================");

      if (response.statusCode == 200) {
        return PoNumberModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("PO API ERROR : $e");
    }
  }

  /// ARTICLE + BOM
  static Future<ArticleBomModel?> getArticleBom({
    required String customerName,
    required String poNumber,
  }) async {
    final url = Uri.parse(
      "${InStockService.baseUrl}/Rmd/Rmd/GetArticleAndBom"
      "?customerName=${Uri.encodeComponent(customerName)}"
      "&poNumber=${Uri.encodeComponent(poNumber)}",
    );

    try {
      print("========================================");
      print("GET : $url");

      final response = await http.get(
        url,
        headers: await RmdService.authHeaders(),
      );

      print("STATUS : ${response.statusCode}");
      print("RESPONSE : ${response.body}");
      print("========================================");

      if (response.statusCode == 200) {
        return ArticleBomModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("ARTICLE API ERROR : $e");
    }

    return null;
  }

  static Future<bool> saveRollEntry({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse("${InStockService.baseUrl}/Rmd/SaveRollEntry");

      final jsonBody = jsonEncode(body);

      // debugPrint("=================================");
      debugPrint("SAVE URL : $url");
      // debugPrint("SAVE JSON : $jsonBody");
      // debugPrint("=================================");

      final response = await http.post(
        url,
        headers: {
          ...await InStockService.authHeaders(),
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      debugPrint("SAVE STATUS : ${response.statusCode}");
      debugPrint("SAVE RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        return response.body.toLowerCase().contains("data saved successfully");
      }

      return false;
    } catch (e) {
      debugPrint("SAVE ERROR : $e");
      return false;
    }
  }

  static Future<List<RmdRollEntrySavedListModel>> fetchSavedRollEntry({
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      "${InStockService.baseUrl}/Rmd/SavedRollEntryList?fromDate=$fromDate&toDate=$toDate",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    print("Status code => ${url}");
    print("Status code => ${response}");

    if (response.statusCode == 200) {
      print("REQUEST => ${response.body}");
      final List data = jsonDecode(response.body);

      return data.map((e) => RmdRollEntrySavedListModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Saved Roll Entry");
    }
  }

  Future<Map<String, dynamic>> printBarcode({
    required int id,
    required String rollEntry,
    required String barcode,
    required String plant,
    required String location,
    required String operator,
    required String supervisor,
  }) async {
    final url = Uri.parse("${InStockService.baseUrl}/Rmd/PrintBarcode");

    final response = await http.post(
      url,
      headers: await InStockService.authHeaders(),
      body: jsonEncode({
        "id": id,
        "rollEntry": rollEntry,
        "barcode": barcode,
        "plant": plant,
        "location": location,
        "operator": operator,
        "supervisor": supervisor,
      }),
    );
    print("REQUEST => ${response.body}");

    if (response.statusCode == 200) {
      print("STATUS => ${response.statusCode}");
      print("RESPONSE => ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception("Print API Failed : ${response.body}");
    }
  }

  Future<List<RollCuttingReportModel>> fetchRollCuttingReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final String fromDate =
        '${from.year.toString().padLeft(4, '0')}/'
        '${from.month.toString().padLeft(2, '0')}/'
        '${from.day.toString().padLeft(2, '0')}';

    final String toDate =
        '${to.year.toString().padLeft(4, '0')}/'
        '${to.month.toString().padLeft(2, '0')}/'
        '${to.day.toString().padLeft(2, '0')}';

    final Uri url = Uri.parse(
      '${InStockService.baseUrl}/Cutting/roll-cutting-report',
    ).replace(queryParameters: {'fromDate': fromDate, 'toDate': toDate});

    // debugPrint('');
    // debugPrint('====================================================');
    // debugPrint('ROLL CUTTING REPORT API');
    debugPrint('URL: $url');
    // debugPrint('FROM DATE: $fromDate');
    // debugPrint('TO DATE: $toDate');
    // debugPrint('====================================================');

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      debugPrint('STATUS CODE: ${response.statusCode}');

      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }

      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid API response. Expected a List.');
      }

      final List<RollCuttingReportModel> result = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => RollCuttingReportModel.fromJson(json))
          .toList();

      // Sort oldest -> newest
      result.sort((a, b) => a.todayDate.compareTo(b.todayDate));

      debugPrint('PARSED RECORDS: ${result.length}');

      for (final item in result) {
        debugPrint(
          '${item.formattedDate} | '
          'Weight: ${item.totalWeight} | '
          'Wastage: ${item.totalWastage}',
        );
      }

      debugPrint('====================================================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('ROLL CUTTING API ERROR: $e');

      debugPrint('STACK TRACE: $stackTrace');

      rethrow;
    }
  }

  Future<List<ComponentDatewiseModel>> fetchComponentDatewise({
    required DateTime date,
  }) async {
    final String createdDate =
        '${date.year.toString().padLeft(4, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';

    final Uri url = Uri.parse(
      '${InStockService.baseUrl}/Cutting/component-datewise',
    ).replace(queryParameters: {'createdDate': createdDate});

    // debugPrint('');
    // debugPrint('====================================================');
    // debugPrint('COMPONENT DATEWISE REPORT API');
    debugPrint('URL: $url');
    // debugPrint('CREATED DATE: $createdDate');
    // debugPrint('====================================================');

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      debugPrint('STATUS CODE: ${response.statusCode}');

      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'API Error ${response.statusCode}: '
          '${response.body}',
        );
      }

      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid API response. Expected a List.');
      }

      final List<ComponentDatewiseModel> result = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => ComponentDatewiseModel.fromJson(json))
          .toList();

      // Sort component alphabetically
      result.sort((a, b) => a.component.compareTo(b.component));

      debugPrint(
        'PARSED COMPONENT RECORDS: '
        '${result.length}',
      );

      for (final item in result) {
        debugPrint(
          '${item.component} | '
          'PCS: ${item.pcs} | '
          'Weight: ${item.weight} | '
          'Wastage: ${item.wastage}',
        );
      }

      debugPrint('====================================================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('COMPONENT DATEWISE API ERROR: $e');

      debugPrint('STACK TRACE: $stackTrace');

      rethrow;
    }
  }

  Future<List<ComponentDetailModel>> fetchCuttingDetailDatewise({
    required DateTime date,
    required String component,
  }) async {
    final dateString = DateFormat('yyyy/MM/dd').format(date);

    final uri = Uri.parse(
      '${InStockService.baseUrl}/Cutting/cutting-detail-datewise'
      '?createdDate=${Uri.encodeQueryComponent(dateString)}'
      '&component=${Uri.encodeQueryComponent(component)}',
    );

    // debugPrint('');
    // debugPrint('==============================================');
    // debugPrint('CUTTING DETAIL DATEWISE API');
    // debugPrint('==============================================');
    // debugPrint('Date      : $dateString');
    // debugPrint('Component : $component');
    debugPrint('URL       : $uri');

    try {
      final response = await http.get(
        uri,
        headers: await InStockService.authHeaders(),
      );

      debugPrint('Status Code : ${response.statusCode}');
      debugPrint('Response    : ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load cutting detail. '
          'Status Code: ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid response format from API.');
      }

      final List<ComponentDetailModel> result = decoded
          .whereType<Map<String, dynamic>>()
          .map(ComponentDetailModel.fromJson)
          .toList();

      debugPrint('Records Found : ${result.length}');
      debugPrint('==============================================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ CUTTING DETAIL API ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('==============================================');

      rethrow;
    }
  }

  Future<List<RollWiseCuttingStockModel>> fetchCuttingStockReport({
    required int pageNumber,
    required int pageSize,
  }) async {
    final uri = Uri.parse(
      '${InStockService.baseUrl}/Cutting/cutting-stock-report'
      '?pageNumber=$pageNumber'
      '&pageSize=$pageSize',
    );

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('CUTTING STOCK REPORT API');
    debugPrint('==============================================');
    debugPrint('Page Number : $pageNumber');
    debugPrint('Page Size   : $pageSize');
    debugPrint('URL         : $uri');

    try {
      final response = await http.get(uri,headers: await InStockService.authHeaders());

      debugPrint('Status Code : ${response.statusCode}');
      debugPrint('Response    : ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load cutting stock report. '
          'Status Code: ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid response format from cutting stock API.');
      }

      final List<RollWiseCuttingStockModel> result = [];

      for (final item in decoded) {
        if (item is Map) {
          result.add(
            RollWiseCuttingStockModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }

      debugPrint('Parsed Records: ${result.length}');

      debugPrint('==============================================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==============================================');
      debugPrint('CUTTING STOCK REPORT API ERROR');
      debugPrint('==============================================');
      debugPrint('Error      : $e');
      debugPrint('StackTrace : $stackTrace');
      debugPrint('==============================================');

      rethrow;
    }
  }
}

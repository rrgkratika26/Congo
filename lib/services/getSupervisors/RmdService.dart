import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

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
      final response = await http.post(
        Uri.parse("${InStockService.baseUrl}/Rmd/SaveRollEntry"),
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      debugPrint("SAVE STATUS : ${response.statusCode}");
      debugPrint("SAVE Roll EntryRESPONSE : ${response.body}");

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
}

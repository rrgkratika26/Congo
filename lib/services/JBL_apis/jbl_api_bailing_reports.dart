import 'dart:convert';
import 'dart:developer';
import 'package:IMS/JBL/JBLBailing/modleclass/StockReports.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../JBL/JBLBailing/modleclass/Bailing_summary_model.dart';
import '../../JBL/JBLBailing/modleclass/OverallModel.dart';
import '../../JBL/JBLDispatch/JblDispatchModel.dart';
import '../../JBL/JBLWebbing/Reports_model/OUTmodel.dart';
import '../../JBL/JBLWebbing/Reports_model/outReportModel.dart';
import '../../JBL/JBLWebbing/Reports_model/report_model.dart';
import '../../JBL/JBLWebbing/Reports_model/stockModel.dart';
import '../../JBL/JBLWebbing/model/WebbForwardResponse.dart';
import '../../JBL/JBLWebbing/model/WebbingListModel.dart';
import '../../JBL/JBLWebbing/model/webbingfilterModel.dart';
import '../../JBL/JBL_BagProduction/ComponentModel.dart';
import '../../JBL/JBL_BagProduction/JBLBagProductionEntry.dart';
import '../../JBL/JBL_BagProduction/PackingDepart/PackingReportModel.dart';
import '../../JBL/JBL_BagProduction/ProductDetailModleclass.dart';
import '../../JBL/JBL_BagProduction/ReportModel/bagReportModel.dart';
import '../../JBL/JBL_BagProduction/ReportModel/baseModel.dart';
import '../../JBL/JBL_BagProduction/ReportModel/packingReportModel.dart';
import '../../JBL/JBL_BagProduction/StoeIssueModleClass.dart';
import '../../JBL/JBL_BailingReport/Bailing_model.dart';
import '../../JBL/JBL_BailingReport/Reports/BalemodelClass.dart';
import '../../JBL/JBL_BailingReport/Reports/BalingDetailModel.dart';
import '../../JBL/JBL_Cutting/ModelClass/CutPcsodel.dart';
import '../../JBL/JBL_Cutting/ModelClass/CuttinfType.dart';
import '../../JBL/JBL_Cutting/ModelClass/ReportModel.dart';
import '../../JBL/JBL_Cutting/ModelClass/rollwiseModel.dart';
import '../../JBL/JBL_Loom/modelClass/FIBCmodel.dart';
import '../../ScannedItem/Cutting/CutPcsModel.dart';
import '../../ScannedItem/Cutting/CuttinIN/Cutt_pieces_issueModel.dart';
import '../../ScannedItem/Cutting/recutPcsIssue/recutModleClass.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../getSupervisors/getSupervisors.dart';

class JblApiService {
  // static const String baseUrlJBL = 'http://190.92.175.47:80/api/api';
  // static const String baseUrlJBL = 'http://192.168.29.125:7165/api';
  static const String baseUrlJBL = 'http://190.92.175.47/VISA_S/api';


  // static const String baseUrlJBL = 'http://190.92.175.47/Qualipack/api';
// static const String baseUrlJBL = 'http://190.92.175.47/CONGO_API/api';

  // static const String baseUrlJBL = 'http://190.92.175.47/ShriShakti/api';

  // static const String baseUrlJBL ='http://192.168.29.39:44349/api/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/JblAPI/api';
  // static const String baseUrlJBL = 'http://fibcsoftware.in:4430/api/api';
  // static String baseUrlJBL = 'http://190.92.175.47:80/JBL_DEMO/api';
  // static String baseUrlJBL = 'http://190.92.175.47:80/ASIA_API/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/Visa/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/Nardana/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/ASIA_API/api';

  // static const String baseUrlJBL ='http://190.92.175.47:80/API/api';  // for others database

  // static const String baseUrlJBL = 'http://190.92.175.47:80/Innoweave/api';

  Future<List<JBLBalingReportModel>> getBalingReport() async {
    final url = Uri.parse("${baseUrlJBL}/BaleDepartment/bailing-report");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(), // ✅ PASS TOKEN
    );

    // print("STATUS CODE: ${response.statusCode}");
    // print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      if (jsonBody["success"] == true) {
        List data = jsonBody["data"];
        return data.map((e) => JBLBalingReportModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception("API Failed ${response.statusCode}");
    }
  }

  Future<List<BalingDetailsModel>> getBalingDetails({
    required String bomNo,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrlJBL/BaleDepartment/bailing-report-details"
        "?bomNo=$bomNo&fromDate=$fromDate&toDate=$toDate",
      ),
      headers: await InStockService.authHeaders(),
    );
    // print("STATUS CODE: ${response.statusCode}");
    // print("BODY: ${response.body}");
    final data = jsonDecode(response.body);

    return (data as List).map((e) => BalingDetailsModel.fromJson(e)).toList();
  }

  Future<List<BailingSummaryModel>> getBailingSummary({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrlJBL/BaleDepartment/bailing-summary"
        "?fromDate=$fromDate&toDate=$toDate",
      );

      // print("URL: $url");

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      // print("STATUS: ${response.statusCode}");
      // print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("API Failed: ${response.statusCode}");
      }

      final List data = jsonDecode(response.body);

      return data.map((e) => BailingSummaryModel.fromJson(e)).toList();
    } catch (e) {
      print("ERROR: $e");
      rethrow;
    }
  }

  Future<List<DispatchModel>> getDispatchReport() async {
    final url = Uri.parse("${baseUrlJBL}/BaleDepartment/dispatch-search");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    // print("Dispatch STATUS: ${response.statusCode}");
    // print("Dispatch BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      // ✅ CASE 1: Direct List Response
      if (jsonBody is List) {
        return jsonBody.map((e) => DispatchModel.fromJson(e)).toList();
      }

      // ✅ CASE 2: Wrapped Response { success: true, data: [] }
      if (jsonBody is Map &&
          jsonBody["success"] == true &&
          jsonBody["data"] is List) {
        return (jsonBody["data"] as List)
            .map((e) => DispatchModel.fromJson(e))
            .toList();
      }

      return [];
    } else {
      throw Exception("Dispatch API Failed ${response.statusCode}");
    }
  }

  // ── Dispatch Detail ────────────────────────────────────────────────────────

  Future<DispatchDetailResponse> getDispatchDetail(int dispatchNo) async {
    final url = Uri.parse(
      "$baseUrlJBL/BaleDepartment/double-click-dispatch?dispatchNo=$dispatchNo",
    );

    final response = await http
        .get(url, headers: await InStockService.authHeaders())
        .timeout(const Duration(seconds: 30));

    // print("Dispatch Detail STATUS: ${response.statusCode}");
    // print("Dispatch Detail BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return DispatchDetailResponse.fromJson(jsonBody);
    } else {
      throw Exception("Dispatch Detail API Failed ${response.statusCode}");
    }
  }

  static Future<List<CuttingApprovalModel>> getCuttingApprovalList() async {
    final url = Uri.parse("$baseUrlJBL/Cutting/CuttingApprovalList");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    // print("API URL: $url");
    // print("Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return CuttingApprovalModel.fromList(data);
    } else {
      throw Exception("Failed to load Cutting Approval List");
    }
  }

  static Future<List<CutPieceIssuedModel>> fetchCutPieceIssuedList() async {
    final url = Uri.parse("$baseUrlJBL/Cutting/CutPieceIssuedList");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);

      return jsonData.map((e) => CutPieceIssuedModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Cut Piece Issued List");
    }
  }

  static Future<bool> issueCutPiece({
    required int id,
    required String woNumber,
    required String component,
    required double issuePcs,
    required double issueKg,
  }) async {
    final url = Uri.parse("${baseUrlJBL}/Cutting/IssueCutPiece");

    try {
      final body = {
        "iid": id,
        "issuE_TO_WORK_ORDER": woNumber,
        "issuE_TO_COMPONENT": component,
        "nO_OF_PCS": issuePcs.toInt(),
        "kg": issueKg,
      };

      print("Issue API Body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          ...(await InStockService.authHeaders()),
          // "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Issue API Success: ${response.body}");
        return true;
      } else {
        print("Issue API Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Issue API Exception: $e");
      return false;
    }
  }

  static Future<List<ReIssueCutPcsModel>> getReIssueCutPcsList() async {
    final url = Uri.parse("$baseUrlJBL/Cutting/GetReIssueCutPcs");

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      // print("ReIssueCutPcs STATUS: ${response.statusCode}");
      // print("ReIssueCutPcs BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);
        return ReIssueCutPcsModel.fromList(jsonData);
      } else {
        throw Exception(
          "Failed to load ReIssueCutPcs (${response.statusCode})",
        );
      }
    } catch (e) {
      print("ReIssueCutPcs Exception: $e");
      return [];
    }
  }

  static Future<int?> getNextRollEntryId() async {
    try {
      final url = Uri.parse('${baseUrlJBL}/Cutting/GetNextRollEntryId');

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        /// API returns single value like: 11482
        final int id = jsonDecode(response.body);
        return id;
      } else {
        throw Exception('Failed to load Roll Entry ID');
      }
    } catch (e) {
      throw Exception('Error fetching Roll Entry ID: $e');
    }
  }

  static Future<int?> getNextBagEntryId() async {
    try {
      final url = Uri.parse('${baseUrlJBL}/BagProduction/GetNextBagEntryId');

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("API Response: $data");

        // ✅ extract from JSON object
        if (data['status'] == 'ok') {
          return data['nextBagEntryId'];
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load Bag Entry ID');
      }
    } catch (e) {
      throw Exception('Error fetching Bag Entry ID: $e');
    }
  }

  static Future<List<String>> getWorkOrders() async {
    try {
      final url = Uri.parse('${baseUrlJBL}/Cutting/GetWorkOrders');

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        /// Extract only WO numbers
        List<String> workOrders = data
            .map<String>((e) => e['wO_NUMBER'].toString())
            .toList();

        return workOrders;
      } else {
        throw Exception('Failed to load Work Orders');
      }
    } catch (e) {
      throw Exception('Error fetching Work Orders: $e');
    }
  }

  static Future<Map<String, dynamic>> getFabricCutSize({
    required String woNumber,
    required String component,
  }) async {
    try {
      final url = Uri.parse('${baseUrlJBL}/Cutting/GetFabricCutSize').replace(
        queryParameters: {'woNumber': woNumber, 'component': component},
      );
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      // print("FINAL URL: $url");
      // print("👉 Raw Response: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // print("Response facit cut issue $response");

        /// Example response:
        /// {
        ///   "fabricsize_addqty": 190,
        ///   "cutsize_addwt": 131
        /// }
        return data;
      } else {
        throw Exception('Failed to load Fabric Cut Size');
      }
    } catch (e) {
      throw Exception('Error fetching Fabric Cut Size: $e');
    }
  }

  /// Save Cut Piece Issue
  static Future<bool> addRecutPcsIssue({
    required int iid,
    required String woNumber,
    required String component,
    required double cutWidth,
    required double cutLength,
    required double cutSizeQty,
    required double netWt,
  }) async {
    try {
      final url = Uri.parse("${baseUrlJBL}/Cutting/SaveCutPieceIssue");

      final headers = await InStockService.authHeaders();
      headers["Content-Type"] = "application/json";

      final body = jsonEncode({
        "iid": iid,
        "issuE_TO_WORK_ORDER": woNumber,
        "issuE_TO_COMPONENT": component,
        "nO_OF_PCS": cutSizeQty.toInt(),
        "kg": netWt,
        "cuT_WIDTH": cutWidth.toString(), // ← String
        "cuT_LENGTH": cutLength.toString(),
        "isChecked": true,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Save API Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Save Exception: $e");
      return false;
    }
  }

  /// Fetch FIBC Store Entry List
  static Future<List<StoreIsssueModleClass>> getFibcStoreEntries() async {
    final url = Uri.parse('${baseUrlJBL}/BagProduction/fibc-store-entry');

    final headers = await InStockService.authHeaders();
    final response = await http.get(url, headers: headers);

    // // Print raw response
    // print("Status Code: ${response.statusCode}");
    // print("Raw Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Print decoded JSON
      // print("Decoded JSON: $json");

      if (json['success'] == true) {
        final List data = json['data'] as List;

        // Print data list
        // print("Data List: $data");

        return data.map((e) => StoreIsssueModleClass.fromJson(e)).toList();
      }

      throw Exception(json['message'] ?? 'Failed to fetch store entries');
    }

    throw Exception('HTTP ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getFibcComponents(
    String wo, {
    String? inquiry,
  }) async {
    String url = "${baseUrlJBL}/BagProduction/fibc-components?woNumber=$wo";

    if (inquiry != null) {
      url += "&inquiryNo=$inquiry"; // 🔥 add param
    }

    final headers = await InStockService.authHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print("Selected Inquiry: $inquiry");
      // print("Components Count: ${jsonData.length}");
      // log("Response : ${jsonData}");
      final components = jsonData["data"]["components"] as List;
      final inquiryRaw = jsonData["data"]["inquiryList"] as List;

      return {
        "components": components
            .map((e) => FibcComponentModel.fromJson(e))
            .toList(),
        "inquiries": inquiryRaw.map((e) => e["inquirY_NO"].toString()).toList(),
      };
    } else {
      throw Exception("Failed to load data");
    }
  }

  static Future<bool> saveFibcStoreEntry({
    required String wo,
    required List<Map<String, dynamic>> components,
  }) async {
    final url = "${baseUrlJBL}/BagProduction/save-fibc-store-entry";

    final body = jsonEncode({"wo": wo, "components": components});

    print("SAVE BODY: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
      body: body,
    );

    print("SAVE RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to save store entry");
    }
  }

  static Future<List<PackingBagReportModel>> getPackingBagReport() async {
    final url = Uri.parse('${baseUrlJBL}/BagProduction/packing-bag-report');

    final headers = await InStockService.authHeaders();
    final response = await http.get(url, headers: headers);

    // print("Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];

        return data.map((e) => PackingBagReportModel.fromJson(e)).toList();
      } else {
        throw Exception(jsonResponse['message']);
      }
    } else {
      throw Exception("Failed to load Packing Bag Report");
    }
  }

  /// Packing Entry Count API
  static Future<int?> getPackingEntryCount(String bomNo) async {
    try {
      final url = Uri.parse(
        "$baseUrlJBL/BagProduction/packing-entry-count?bomNo=$bomNo",
      );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          return data["data"]; // this will return 12
        }
      }
    } catch (e) {
      print("Packing Count Error: $e");
    }

    return null;
  }

  /// SAVE PACKING ENTRY
  static Future<bool> savePackingEntry({
    required String partyName,
    required String bomNo,
    required String articleNo,
    required double perBagWt,
    required String bagSize,
    required DateTime dateTime,
    required int readyPackedBunches,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse("$baseUrlJBL/BagProduction/save-packing-entry");

    final body = {
      "partyName": partyName,
      "bomNo": bomNo,
      "articleNo": articleNo,
      "perBagWt": perBagWt,
      "bagSize": bagSize,
      "dateTime": dateTime.toIso8601String(),
      "readyPackedBunches": readyPackedBunches,
      "items": items,
    };

    try {
      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      // print("Packing Entry Request: ${jsonEncode(body)}");
      // print("Response Status: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Packing Entry API Error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> jblWebbcheckBarcode({
    required String barcode,
    required String plant,
    required String supervisor,
    required String operator,
    required String location,
    required String status,
  }) async {
    try {
      final url = Uri.parse("${baseUrlJBL}/Webbing/check-barcode");

      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode({
          "barcode": barcode,
          "plant": plant,
          "supervisor": supervisor,
          "operator": operator,
          "location": location,
          "status": status,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("Barcode Response: $data");
        return data;
      } else {
        // print("Barcode API Error: ${response.statusCode}");
        // print(response.body);
        return null;
      }
    } catch (e) {
      print("Barcode API Exception: $e");
      return null;
    }
  }

  static Future<List<String>> fetchWebbingLocations({
    required String plant,
  }) async {
    final plant = await AppSession.getUnit();
    final url = "${baseUrlJBL}/Webbing/location-dropdown?plant=$plant";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["success"] == true) {
          List data = jsonData["data"];

          return data.map<String>((e) => e["location"].toString()).toList();
        } else {
          throw Exception(jsonData["message"]);
        }
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      throw Exception("Location API Error: $e");
    }
  }

  static Future<List<WebbingListModel>> getWebbingList() async {
    try {
      final url = Uri.parse("${baseUrlJBL}/Webbing/webbing-list");

      final response = await http.post(
        url,

        // headers: {"Content-Type": "application/json"},
        headers: await InStockService.authHeaders(),
        body: jsonEncode({
          "plant": "JBL",
          "movement": "OUT-OUT",
          "date": DateTime.now().toIso8601String(),
          "fromDate": "2025-03-10T11:22:12.428Z",
          "toDate": "2026-03-10T11:22:12.428Z",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          List list = data["data"];

          return list.map((e) => WebbingListModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      print("Webbing List Error: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getWebbingInStock({
    required String date,
    required String unit,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/Webbing/GetWebbingInStock?date=$date&unit=$unit",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    print("URL: $url");
    print("🔵 RAW RESPONSE → ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ CASE 1: API returns direct LIST
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((e) => Map<String, dynamic>.from(e)),
        );
      }

      // ✅ CASE 2: API returns {success, data}
      if (decoded is Map && decoded["success"] == true) {
        var rawData = decoded["data"];

        // if string → decode
        if (rawData is String) {
          rawData = jsonDecode(rawData);
        }

        // if single object → convert to list
        if (rawData is Map) {
          rawData = [rawData];
        }

        return List<Map<String, dynamic>>.from(
          rawData.map((e) => Map<String, dynamic>.from(e)),
        );
      }

      throw Exception("Invalid API format");
    } else {
      throw Exception("Failed to load stock data");
    }
  }

  /// Filter Webbing API
  static Future<List<WebbingFilterModel>> filterWebbing({
    String plant = "JBL",
    String fabricCodes = "",
    String lotNo = "",
  }) async {
    final url = Uri.parse("$baseUrlJBL/Webbing/filter-webbing");
    final headers = await InStockService.authHeaders();
    headers["Content-Type"] = "application/json";
    final response = await http.post(
      url,
      // headers: {"Content-Type": "application/json"},
      headers: await InStockService.authHeaders(),
      body: jsonEncode({
        "plant": plant,
        "fabricCodes": fabricCodes,
        "lotNo": lotNo,
      }),
    );
    print("URL: $url");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        List list = data["data"];

        return list.map((e) => WebbingFilterModel.fromJson(e)).toList();
      } else {
        throw Exception(data["message"]);
      }
    } else {
      throw Exception("Failed to load webbing data");
    }
  }

  // ───────────────────────────────────────────────────────────

  static Future<WebbingOutResponse> webbingOutSave({
    required String plant,
    required String location,
    required String barcode,
    required String operator,
    required String supervisor,
    required String machine,
    String workOrderNo = "",
  }) async {
    final url = Uri.parse("${baseUrlJBL}/Webbing/webbing-out-save");
    debugPrint("API URL: $url");
    final response = await http.post(
      url,
      headers: await InStockService.authHeaders(),
      body: jsonEncode({
        "plant": plant,
        "location": location,
        "barcode": barcode,
        "workOrderNo": workOrderNo,
        "operator": operator,
        "supervisor": supervisor,
        "machine": machine,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WebbingOutResponse.fromJson(data);
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  JBL API SERVICE — Cutting / Approve Cutting
  // ─────────────────────────────────────────────────────────────

  /// Fetches the cutting approval list and maps it to [CutPcsItem] list.
  static Future<List<CutPcsItem>> fetchCuttingItems() async {
    final apiData = await JblApiService.getCuttingApprovalList();

    return apiData.map((e) {
      return CutPcsItem(
        id: (e.id ?? 0).toInt(),
        date: DateFormat("dd-MMM-yyyy").format(e.date ?? DateTime.now()),
        orderNo: e.orderNo ?? "",
        component: e.component ?? "",
        netWt: double.tryParse(e.netWt ?? "0") ?? 0,
        wastage: double.tryParse(e.wastage ?? "0") ?? 0,
        pcs: int.tryParse(e.pcs ?? "0") ?? 0,
        width: double.tryParse(e.width ?? "0") ?? 0,
        cutLength: double.tryParse(e.cutLength ?? "0") ?? 0,
        perPcsWt: double.tryParse(e.perPcsWt ?? "0") ?? 0,
        poNo: "",
        articleNo: "",
        bom: "",
        customerName: "",
      );
    }).toList();
  }

  /// Sends approve request for the given list of [CutPcsItem].
  /// Returns true on success, false on failure.
  static Future<bool> approveCuttingItems(
    List<CutPcsItem> selectedItems,
  ) async {
    final body = selectedItems.map((e) {
      return {
        "id": e.id,
        "col2": e.date,
        "col3": e.orderNo,
        "col4": e.component,
        "col5": e.netWt.toString(),
        "col6": e.wastage.toString(),
        "col7": e.pcs.toString(),
        "col8": e.width.toString(),
        "col9": e.cutLength.toString(),
        "col10": e.perPcsWt.toString(),
      };
    }).toList();

    final response = await http.post(
      Uri.parse("$baseUrlJBL/Cutting/ApproveCutting"),
      headers: await InStockService.authHeaders(),
      body: jsonEncode(body),
    );
    // debugPrint("API URL: $response");
    // print("STATUS CODE: ${response.statusCode}");
    // print("RESPONSE BODY: ${response.body}");
    return response.statusCode == 200;
  }

  Future<List<String>> get_jblRmdOperators() async {
    final url = Uri.parse('$baseUrlJBL/Rmd/GetOperators');
    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    // debugPrint("API URL RMD: $url");
    // debugPrint("GET OPERATORS STATUS: ${response.statusCode}");
    // debugPrint("GET OPERATORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load operators');
  }

  Future<List<String>> get_jblRmdSupervisors() async {
    final url = Uri.parse('$baseUrlJBL/Rmd/GetSupervisors');
    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    // debugPrint("API URLRMD: $url");
    // debugPrint("GET SUPERVISORS STATUS: ${response.statusCode}");
    // debugPrint("GET SUPERVISORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load supervisors');
  }

  // Future<List<String>> get_jblRmdLocations() async {
  //   final url = Uri.parse('$baseUrlJBL/Rmd/GetLocations');
  //   final response = await http.get(
  //     url,
  //     headers: await InStockService.authHeaders(),
  //   );
  //   debugPrint("API URL: $url");
  //   debugPrint("GET LOCATIONS STATUS: ${response.statusCode}");
  //   debugPrint("GET LOCATIONS RESPONSE: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final List data = jsonDecode(response.body);
  //     return data.map((e) => e['label'].toString()).toList();
  //   }
  //   throw Exception('Failed to load locations');
  // }

  Future<Map<String, dynamic>?> jbl_checkBarcodeIn({
    required String barcode,
    required String roll_entry,
    required String storage,
    required String operatorName,
    required String supervisor,
    required String department,
    required String unit,
  }) async {
    final url = Uri.parse('$baseUrlJBL/Rmd/checkBarcodeIn');

    try {
      var request = http.MultipartRequest('POST', url);
      debugPrint("FIELDS:");
      debugPrint("barcode: $barcode");
      debugPrint("roll_entry: $roll_entry");
      debugPrint("storage: $storage");
      debugPrint("operator: $operatorName");
      debugPrint("supervisor: $supervisor");
      debugPrint("department: $department");
      debugPrint("unit: $unit");
      // ✅ headers
      request.headers.addAll(await InStockService.authHeaders());
      debugPrint("JBL API URL: $url");
      // ✅ form-data fields
      request.fields['barcode'] = barcode;
      request.fields['roll_entry'] = roll_entry;
      request.fields['storage'] = storage;
      request.fields['operatorName'] = operatorName;
      request.fields['supervisor'] = supervisor;
      request.fields['department'] = department;
      request.fields['unit'] = unit;

      // ✅ send request
      var streamedResponse = await request.send();

      // convert to normal response
      var response = await http.Response.fromStream(streamedResponse);
      // debugPrint("JBL API URL: $url");
      // debugPrint("STATUS: ${response.statusCode}");
      // debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }

    return null;
  }

  Future<List<dynamic>> get_jblScannedItems(String date, String unit) async {
    final url = Uri.parse(
      '$baseUrlJBL/Rmd/GetScannedItems?date=$date&unit=$unit',
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    debugPrint("RMD IN URL: $url");
    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load scanned items');
    }
  }

  Future<List<dynamic>> get_jblRmdInScannedItems(
    String date,
    String unit,
  ) async {
    final url = Uri.parse(
      '$baseUrlJBL/Rmd/GetScannedItems?date=$date&unit=$unit',
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    // debugPrint("API URL: $url");
    // debugPrint("GET SCANNED ITEMS STATUS: ${response.statusCode}");
    // debugPrint("GET SCANNED ITEMS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load scanned items');
    }
  }

  Future<int> get_jblInScannedItemsCount(String date, String unit) async {
    final items = await get_jblRmdInScannedItems(date, unit); // ← use OUT API
    return items.length;
  }

  Future<int> get_jbloutScannedItemsCount(String date, String unit) async {
    final items = await get_jblOut_ScannedItems(date, unit); // ← use OUT API
    return items.length;
  }

  Future<List<dynamic>> get_jblOut_ScannedItems(
    String date,
    String unit,
  ) async {
    final url = Uri.parse(
      '$baseUrlJBL/Rmd/Rmd/GetOutScannedItems?date=$date&unit=$unit',
    );

    debugPrint("FINAL API URL: $url");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    //
    // debugPrint("STATUS: ${response.statusCode}");
    // debugPrint("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load scanned items');
    }
  }

  // Future<int> get_jbloutScannedItemsCount(String date, String unit) async {
  //   final items = await get_jblScannedItems(date, unit);
  //   return items.length;
  // }

  Future<Map<String, dynamic>?> jbl_checkBarcodeOut({
    required String barcode,
    required String roll_entry,
    required String storage,
    required String operatorName,
    required String supervisor,
    required String department,
    required String unit,
  }) async {
    final url = Uri.parse('$baseUrlJBL/Rmd/checkBarcodeOut');
    debugPrint("API URL RMD OUT SCAN : $url");

    try {
      // ✅ authHeaders lo, phir content-type override karo
      final headers = await InStockService.authHeaders();
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      // ✅ Verify karo ki values null nahi hain
      debugPrint(
        "PARAMS → barcode: $barcode | storage: $storage | operator: $operatorName | supervisor: $supervisor | dept: $department | unit: $unit",
      );

      final response = await http.post(
        url,
        headers: headers,
        body: {
          "barcode": barcode,
          "roll_entry": roll_entry,
          "storage": storage,
          "operatorName": operatorName,
          "supervisor": supervisor,
          "department": department,
          "unit": unit,
        },
      );

      // debugPrint("CHECK OUT STATUS: ${response.statusCode}");
      // debugPrint("CHECK OUT BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("CHECK OUT ERROR: $e");
    }
    return null;
  }

  // ================= OPERATORS =================
  Future<List<String>> getJblCuttingOperators() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlJBL/Cutting/GetOperators'),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("API RESPONSE Cutting: ${response.body}");

        List list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'];
        }

        // ✅ HANDLE BOTH STRING & MAP RESPONSE
        return list.map<String>((e) {
          if (e is Map) {
            return e['label']?.toString() ?? e['value']?.toString() ?? '';
          } else {
            return e.toString();
          }
        }).toList();
      } else {
        throw Exception('Failed to load operators');
      }
    } catch (e) {
      print("Operator API Error: $e");
      return [];
    }
  }

  // ================= SUPERVISORS =================
  // ================= SUPERVISORS =================
  Future<List<String>> getJblCuttingSupervisors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlJBL/Cutting/GetSupervisors'),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List list = [];
        print("API RESPONSE cutting : ${response.body}");
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'];
        }

        return list.map<String>((e) {
          if (e is Map) {
            return e['label']?.toString() ?? e['value']?.toString() ?? '';
          } else {
            return e.toString();
          }
        }).toList();
      } else {
        throw Exception('Failed to load supervisors');
      }
    } catch (e) {
      print("Supervisor API Error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> jbl_CuttingcheckBarcode({
    required String barcode,
    required String supervisor,
    required String operator,
    required String location,
    required String department,
    required String plant,
  }) async {
    final url = Uri.parse("$baseUrlJBL/Cutting/Cutting/CheckBarcodeInCutting");

    final response = await http.post(
      url,
      headers: await InStockService.authHeaders(),
      body: jsonEncode({
        "barcode": barcode,
        "supervisor": supervisor,
        "operator": operator,
        "location": location,
        "department": department,
        "plant": plant,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<dynamic> getCuttingScannedRepo({
    required String supervisor,
    required String operator,
    required String location,
    required String department,
    required String plant,
  }) async {
    final url = Uri.parse("$baseUrlJBL/Cutting/Cutting/CuttingScannedReport");

    final body = {
      "department": department,
      "plant": plant,
      "date": getApiDate(), // ✅ IMPORTANT
    };

    final response = await http.post(
      url,
      headers: await InStockService.authHeaders(),
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  // ================= SUPERVISORS =================
  Future<List<String>> getLaminationSupervisors() async {
    try {
      final url = Uri.parse(
        "$baseUrlJBL/Lamination/GetLaminationSupervisors?supervisorType=LAMINATION",
      );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(), // ✅ FIX
      );
      // print("uRL//////:$url");
      // print("STATUS: ${response.statusCode}");
      // print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'];
        }

        return list.map<String>((e) {
          if (e is Map) {
            return e['label']?.toString() ?? '';
          } else {
            return e.toString();
          }
        }).toList();
      } else {
        throw Exception("Failed to load supervisors");
      }
    } catch (e) {
      print("❌ Supervisor API Error: $e");
      return [];
    }
  }

  // ================= OPERATORS =================
  Future<List<String>> getLaminationOperators() async {
    try {
      final url = Uri.parse(
        "$baseUrlJBL/Lamination/GetLaminationOperators?operatorType=LAMINATION",
      );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      print("API RESPONSE lamination: ${response.body}");
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        // ✅ Extract label
        return data.map((e) => e['label'].toString()).toList();
      } else {
        throw Exception("Failed to load operators");
      }
    } catch (e) {
      print("❌ Operator API Error: $e");
      return [];
    }
  }

  //   api/Lamination/GetLaminationScannedItems?date=2026-03-24&plant=JB
  Future<int> get_jblLaminationScannedItemsCount(
    String date,
    String plant,
  ) async {
    // debugPrint("📅 DATE: $date");
    // debugPrint("🏭 PLANT: $plant");
    final items = await get_jblLaminationScannedItems(date, plant);
    // debugPrint("📦 FULL API RESPONSE: $items");
    // debugPrint("🔢 TOTAL COUNT: ${items.length}");
    return items.length;
  }

  Future<List<dynamic>> get_jblLaminationScannedItems(
    String date,
    String plant,
  ) async {
    final url = Uri.parse(
      '$baseUrlJBL/Lamination/GetLaminationScannedItems?date=$date&plant=$plant',
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  static String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  Future<List<dynamic>> getDynamicReport({
    required String endpoint,
    required Map<String, String> params,
  }) async {
    final uri = Uri.parse(
      "$baseUrlJBL/$endpoint",
    ).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );
    // debugPrint("RMD REPORT URL: $uri");
    // debugPrint("STATUS: ${response.statusCode}");
    // debugPrint("BODY: ${response.body}");
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ IMPORTANT FIX
      return decoded["data"] ?? [];
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<List<dynamic>> getRmdData({
    required String plant,
    required String type, // IN / OUT
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse("$baseUrlJBL/Rmd/GetRmdData").replace(
      queryParameters: {
        "plant": plant,
        "type": type,
        "fromDate": fromDate,
        "toDate": toDate,
      },
    );

    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );

    // debugPrint("RMD REPORT URL: $uri");
    // debugPrint("STATUS: ${response.statusCode}");
    // debugPrint("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ CASE 1: Direct List
      if (decoded is List) {
        return decoded;
      }

      // ✅ CASE 2: Wrapped response
      if (decoded is Map && decoded["data"] != null) {
        return decoded["data"];
      }

      return [];
    } else {
      throw Exception("Failed to load RMD Report");
    }
  }

  Future<List<dynamic>> getRmdStock({
    required String plant,
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/Rmd/RmdStock?plant=$plant&fromDate=$fromDate&toDate=$toDate",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      print("FULL RESPONSE: $decoded"); // 👈 DEBUG

      if (decoded["status"] == true) {
        return decoded["data"] ?? [];
      } else {
        return [];
      }
    } else {
      throw Exception("API Failed");
    }
  }

  Future<List<dynamic>> getLaminationReports({
    required String type, // IN or OUT
    required String fromDate,
    required String toDate,
    required String plant,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/Lamination/LaminationReports"
      "?type=$type&fromDate=$fromDate&toDate=$toDate&plant=$plant",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    print("URL//////$url");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint("Response $json");
      if (json["status"] == true) {
        return json["data"] ?? [];
      } else {
        throw Exception(json["message"]);
      }
    } else {
      throw Exception("API Failed (${response.statusCode})");
    }
  }

  // Future<List<dynamic>> getCuttingReports({
  //   required CuttingType type,
  //   required String fromDate,
  //   required String toDate,
  //   required String plant,
  // }) async {
  //   final url = Uri.parse(
  //     "$baseUrlJBL/Cutting/CuttingReports"
  //     "?type=${getTypeValue(type)}&fromDate=$fromDate&toDate=$toDate&plant=$plant",
  //   );
  //
  //   final response = await http.get(url);
  //
  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //
  //     if (json["status"] == true) {
  //       final List data = json["data"];
  //
  //       switch (type) {
  //         case CuttingType.rollwise:
  //           return data.map((e) => RollwiseModel.fromJson(e)).toList();
  //
  //         case CuttingType.inwards:
  //           return data.map((e) => CuttingReportModel.fromJson(e)).toList();
  //
  //         case CuttingType.cutpcs:
  //           return data.map((e) => CutPcsModel.fromJson(e)).toList();
  //       }
  //     } else {
  //       throw Exception(json["message"]);
  //     }
  //   } else {
  //     throw Exception("API Failed (${response.statusCode})");
  //   }

  // }

  Future<List<BaseModel>> getCuttingReports({
    required String type,
    required String fromDate,
    required String toDate,
    required String plant,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/Cutting/CuttingReports"
      "?type=$type&fromDate=$fromDate&toDate=$toDate&plant=$plant",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json["status"] == true) {
        final List data = json["data"];
        // debugPrint("Response $data");

        switch (type) {
          case "ROLLWISE":
            return data
                .map<BaseModel>((e) => RollwiseModel.fromJson(e))
                .toList();
          case "IN":
            return data
                .map<BaseModel>((e) => CuttingInModel.fromJson(e))
                .toList();
          case "CUTPCS":
            return data.map<BaseModel>((e) => CutPcsModel.fromJson(e)).toList();
          default:
            return [];
        }
      } else {
        throw Exception(json["message"]);
      }
    } else {
      throw Exception("API Failed (${response.statusCode})");
    }
  }

  static Future<List<BaseModel>> getWebbingReport({
    required String type,
    required String fromDate,
    required String toDate,
    required String plant,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/Webbing/WebbingReport"
      "?type=$type&fromDate=$fromDate&toDate=$toDate&plant=$plant",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json["status"] == true) {
        final List data = json["data"];
        const encoder = JsonEncoder.withIndent('  ');
        print("url webbing///$url");
        // debugPrint("FORMATTED RESPONSE:\n${encoder.convert(json)}");
        switch (type.toUpperCase()) {
          case "IN":
            return data.map((e) => WebbingInModel.fromJson(e)).toList();

          case "OUT":
            return data.map((e) => WebbingOutModel.fromJson(e)).toList();

          case "OUTREPORT":
            return data.map((e) => WebbingOutReportModel.fromJson(e)).toList();

          default:
            return [];
        }
      } else {
        throw Exception(json["message"]);
      }
    } else {
      throw Exception("API Failed (${response.statusCode})");
    }
  }

  Future<List<WebbingStock>> fetchStock({
    required String fromDate,
    required String toDate,
    required String plant,
  }) async {
    final uri = Uri.parse(
      '$baseUrlJBL/Webbing/StockReport?fromDate=$fromDate&toDate=$toDate&plant=$plant',
    );
    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == true) {
        List<WebbingStock> stockList = [];
        for (var item in jsonData['data']) {
          stockList.add(WebbingStock.fromJson(item));
        }
        return stockList;
      } else {
        throw Exception('API returned false status');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<dynamic>> getBagReport({
    required String type, // BAGREPORT or PACKAGING
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      "$baseUrlJBL/BagProduction/GetReports?type=$type&fromDate=$fromDate&toDate=$toDate",
    );

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["status"] == true) {
        final List data = jsonResponse["data"];
        debugPrint("Bag Report ?????$data");
        switch (type.toUpperCase()) {
          case "BAGREPORT":
            return data.map((e) => BagReportModel.fromJson(e)).toList();

          case "PACKAGING":
            return data.map((e) => PackagingReportModel.fromJson(e)).toList();

          default:
            return [];
        }
      } else {
        throw Exception(jsonResponse["message"]);
      }
    } else {
      throw Exception("API Failed (${response.statusCode})");
    }
  }

  static Future<List<BaseReportModel>> getBaleReport({
    required String type,
    required String fromDate,
    required String toDate,
  }) async {
    final url =
        "$baseUrlJBL/BaleDepartment/GetBaleReports?type=$type&fromDate=$fromDate&toDate=$toDate";
    debugPrint("API URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["status"] == true) {
        final List data = jsonResponse["data"];
        debugPrint("API response : $data");

        switch (type.toUpperCase()) {
          case "STOCK":
            return data.map((e) => BaleStockReportModel.fromJson(e)).toList();

          case "OVERALL":
            return data.map((e) => OverallModel.fromJson(e)).toList();

          default:
            return [];
        }
      } else {
        throw Exception(jsonResponse["message"]);
      }
    } else {
      throw Exception("API Failed (${response.statusCode})");
    }
  }

  static Future<List<JBLBagEntryModel>> getjblBagEntryData() async {
    final url = Uri.parse("$baseUrlJBL/BagProduction/GetBagEntryData");

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded.containsKey("data")) {
          list = decoded["data"];
        }

        /// 🔥 CONVERT TO MODEL HERE
        return list.map((e) => JBLBagEntryModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }

  Future<ProductDetails?> getProductDetails({
    required String partyName,
    required String articleNo,
  }) async {
    try {
      final url = Uri.parse("$baseUrlJBL/BagProduction/GetProductDetails")
          .replace(
            queryParameters: {"partyName": partyName, "articleNo": articleNo},
          );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductDetails.fromJson(data);
      } else {
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>> saveBagProductionEntry({
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse("$baseUrlJBL/BagProduction/SaveBagProductionEntry");

    final res = await http.post(
      url,
      headers: await InStockService.authHeaders(),
      body: jsonEncode(body),
    );

    return {"statusCode": res.statusCode, "data": jsonDecode(res.body)};
  }

  // 🔥 GET Production Report
  static Future<List<ProductionModel>> getProductionReport() async {
    try {
      final url = Uri.parse(
        "$baseUrlJBL/Loom/GetForwardToLoom",
      ); // 👈 change endpoint

      print("🌐 API URL: $url");

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      // print("📥 STATUS: ${response.statusCode}");
      // print("📥 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["status"] == true) {
          final List data = jsonData["data"];

          return data.map((e) => ProductionModel.fromJson(e)).toList();
        } else {
          throw Exception(jsonData["message"]);
        }
      } else {
        throw Exception("Failed with status ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ API ERROR: $e");
      print("📍 STACK: $stack");
      rethrow;
    }
  }
}

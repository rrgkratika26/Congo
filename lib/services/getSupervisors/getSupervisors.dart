import 'dart:convert';
import 'dart:developer';
import 'package:IMS/ScannedItem/TAPELINE/modelClass/tapeListFIBC.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../JBL/JBL_Loom/LoomListSavedModel.dart';
import '../../Login/LoginModel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/ComponentReportmodel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/CuttingReport_Model.dart';
import '../../NARDANA/CUTTING_Stock/Reports/InReportModel.dart';
import '../../NARDANA/CUTTING_Stock/Reports/RollWiseReportModel.dart';
import '../../NARDANA/LoomReprts/ManualPlanningModel.dart';
import '../../ScannedItem/Cutting/NardanaCutting/modelclass/CuttingAprrovalModelNardana.dart';
import '../../ScannedItem/Cutting/NardanaCutting/modelclass/CutPcsItemNardana.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/laminationOut_model.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import '../../ScannedItem/Loom/LoomModelClass.dart';
import '../../ScannedItem/Loom/LoomSuperiosrData.dart';
import '../../ScannedItem/TAPELINE/modelClass/InReportmodel.dart';
import '../../ScannedItem/TAPELINE/modelClass/TapeOutModel.dart';
import '../../ScannedItem/TAPELINE/modelClass/tapeStockModel.dart';
import '../../ScannedItem/Webbing/ReportmodelClass/ReportModelClass.dart';
import '../../ScannedItem/Webbing/ReportmodelClass/WebbingDropdownModel.dart';
import '../../screen/BagProduction/BagProduction/BadProductionModel.dart';
import '../../screen/BagProduction/modelClass/BagReportModelClass.dart';
import '../../screen/Baling/BaleModel.dart';
import '../../screen/Baling/baleStockModel/BaleReportModel.dart';
import '../../screen/Baling/baleStockModel/BaleStockModel.dart';
import '../../screen/Baling/dispatch/BarcCodeModel.dart';
import '../../screen/Baling/dispatch/DispatchModel.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../auth_exception.dart';

class InStockService {
  // static const String baseUrl = 'http://192.168.29.125:7165/api';
  static const String baseUrl = 'http://190.92.175.47/VISA_S/api';
  // static const String baseUrl = 'http://190.92.175.47/Qualipack/api';
  // http://190.92.175.47/CONGO_API/
  // static const String baseUrl = 'http://190.92.175.47/CONGO_API/api';

  // static const String baseUrl = 'http://190.92.175.47:80/api/api';
  // static const String baseUrl = 'http://190.92.175.47/ShriShakti/api';
  // static const String baseUrl = 'http://190.92.175.47:80/JblAPI/api';
  // static const String baseUrl = 'http://190.92.175.47:80/JBL_DEMO/api';
  // static const String baseUrl = 'http://190.92.175.47:80/Visa/api';
  // static const String baseUrl = 'http://190.92.175.47:80/Nardana/api';
  // static const String baseUrl = 'http://190.92.175.47:80/ASIA_API/api';
  // static const String baseUrl ='http://190.92.175.47:80/API/api';
  // static const String baseUrl = 'http://190.92.175.47:80/Nardana';
  // static const String baseUrl = 'http://fibcsoftware.in:4430/Visa/api';
  // static const String baseUrl = 'http://190.92.175.47:80/Innoweave/api';

  static void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw AuthException("SESSION_EXPIRED");
    }
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

  Future<List<String>> getOperators() async {
    final url = Uri.parse('$baseUrl/Rmd/GetOperators');
    final response = await http.get(url, headers: await authHeaders());
    // debugPrint("API URL: $url");
    // debugPrint("GET OPERATORS STATUS: ${response.statusCode}");
    // debugPrint("GET OPERATORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load operators');
  }

  static Future<List<Roll>> getRollList({required String unit}) async {
    try {
      final url = Uri.parse('${baseUrl}/Lamination/roll-list?unit=$unit');

      // final url = Uri.parse('${baseUrl}/Lamination/roll-list?unit=UNIT-SILVASSA');

      final response = await http.get(url, headers: await authHeaders());

      InStockService._checkUnauthorized(response);
      // debugPrint("GET SUPERVISORS STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('data:::::$jsonData');
        // debugPrint("API URL: $url");
        // debugPrint("GET SUPERVISORS STATUS: ${response.statusCode}");
        // debugPrint("GET SUPERVISORS RESPONSE: ${response.body}");

        if (jsonData['success'] == true) {
          List list = jsonData['data'];
          return list.map((e) => Roll.fromJson(e)).toList();
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception("Failed to load roll list: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Roll List API Error: $e");
    }
  }

  Future<List<String>> getSupervisors() async {
    final url = Uri.parse('$baseUrl/Rmd/GetSupervisors');
    final response = await http.get(url, headers: await authHeaders());
    // debugPrint("API URL: $url");
    // debugPrint("GET SUPERVISORS STATUS: ${response.statusCode}");
    // debugPrint("GET SUPERVISORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load supervisors');
  }

  Future<List<String>> getLocations() async {
    final url = Uri.parse('$baseUrl/Rmd/GetLocations');
    debugPrint(" /////API URL: $url");
    final response = await http.get(url, headers: await authHeaders());
    // debugPrint("API URL: $url");
    // debugPrint("GET LOCATIONS STATUS: ${response.statusCode}");
    // debugPrint("GET LOCATIONS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load locations');
  }

  Future<List<dynamic>> getScannedItems(String date) async {
    final url = Uri.parse('$baseUrl/Rmd/GetScannedItems?date=$date');
    final response = await http.get(url, headers: await authHeaders());
    debugPrint("API URL: $url");
    debugPrint("GET SCANNED ITEMS STATUS: ${response.statusCode}");
    debugPrint("GET SCANNED ITEMS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load scanned items');
    }
  }

  Future<int> getRMDScannedItemsCount(String date) async {
    final items = await getScannedItems(date);
    return items.length;
  }

  Future<List<String>> fetchList(String url) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return List<String>.from(data.map((e) => e['name'].toString()));
    } else {
      throw Exception("Failed to load data");
    }
  }

  // FOLDING SCANNED ITEMS SCANNER
  Future<Map<String, dynamic>?> checkFoldingBarcodeOut({
    required String barcode,
    required String roll_entry,
    required String storage,
    required String operatorName,
    required String supervisor,
    required String department,
    required String unit, // ✅ NEW PARAM
  }) async {
    final url = Uri.parse('$baseUrl/Folding/CheckBarcodeOut'); // ✅ FIXED

    try {
      final response = await http.post(
        url,
        headers: await formHeaders(),
        body: {
          "barcode": barcode,
          "roll_entry": roll_entry, // FOLDING
          "operatorName": operatorName,
          "supervisor": supervisor,
          "department": department, // FOLDING
          "storage": storage,
          "unit": unit, // ✅ REQUIRED (from your screenshot)
        },
      );

      // debugPrint("FOLDING CHECK OUT STATUS: ${response.statusCode}");
      // debugPrint("FOLDING CHECK OUT BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("API FAILED: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("FOLDING CHECK OUT ERROR: $e");
    }

    return null;
  }

  // {{baseUrl}}Rmd/Rmd/GetOutScannedItems?date=2026-01-31
  // Add this method to your InStockService class
  Future<List<Map<String, dynamic>>> getOutScannedItems(String date) async {
    final url = Uri.parse('$baseUrl/Rmd/Rmd/GetOutScannedItems?date=$date');

    try {
      final response = await http.get(url, headers: await authHeaders());
      // debugPrint("API URL: $url");
      // debugPrint("GET OUT SCANNED ITEMS STATUS: ${response.statusCode}");
      // debugPrint("GET OUT SCANNED ITEMS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // ✅ API RETURNS A LIST DIRECTLY
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
      return [];
    } catch (e) {
      debugPrint('GetOutScannedItems error: $e');
      return [];
    }
  }

  // Your existing method can now use this:
  Future<int> getOutScannedItemsCount(String date) async {
    try {
      final items = await getOutScannedItems(date);
      debugPrint('GET OUT SCANNED ITEMS : ${items.length}');
      return items.length;
    } catch (e) {
      debugPrint('GetOutScannedItemsCount error: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> checkBarcodeIn({
    required String barcode,
    required String roll_entry,
    required String storage,
    required String operatorName,
    required String supervisor,
    required String department,
  }) async {
    final url = Uri.parse('$baseUrl/Rmd/checkBarcodeIn');

    try {
      final response = await http.post(
        url,
        headers: await formHeaders(), // 👈 use form headers
        body: {
          "barcode": barcode,
          "roll_entry": roll_entry,
          "storage": storage,
          "operatorName": operatorName,
          "supervisor": supervisor,
          "department": department,
        },
      );
      debugPrint("API URL: $url");
      debugPrint("CHECK BARCODE STATUS: ${response.statusCode}");
      debugPrint("CHECK BARCODE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("CHECK BARCODE ERROR: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkBarcodeOut({
    required String barcode,
    required String roll_entry,
    required String storage,
    required String operatorName,
    required String supervisor,
    required String department,
  }) async {
    final url = Uri.parse('$baseUrl/Rmd/checkBarcodeOut');

    try {
      final response = await http.post(
        url,
        headers: await formHeaders(),
        body: {
          "barcode": barcode,
          "roll_entry": roll_entry,
          "storage": storage,
          "operatorName": operatorName,
          "supervisor": supervisor,
          "department": department,
        },
      );
      debugPrint("Barcode : $barcode");
      debugPrint("Storage : $storage");
      debugPrint("Operator : $operatorName");
      debugPrint("Supervisor : $supervisor");
      debugPrint("Department : $department");
      debugPrint("Roll Entry : $roll_entry");
      debugPrint("CHECK OUT STATUS: ${response.statusCode}");
      debugPrint("CHECK OUT BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("CHECK OUT ERROR: $e");
    }
    return null;
  }

  Future<LoginModel> adminLogin({
    required String username,
    required String password,
    required String unit,
  }) async {
    final url = Uri.parse('$baseUrl/Login/login');

    final response = await http.post(
      url,
      headers: await _jsonHeaders(withAuth: false),
      body: jsonEncode({
        'username': username,
        'password': password,
        'unit': unit,
      }),
    );
    print(
      "REQUEST BODY: ${jsonEncode({"username": username, "password": password, "unit": unit})}",
    );

    print("RESPONSE CODE: $url");
    print("RESPONSE BODY: ${response.body}");
    debugPrint('LOGIN STATUS: ${response.statusCode}');
    debugPrint('LOGIN RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final loginResponse = LoginModel.fromJson(decoded);

      if (loginResponse.status == 'ok') {
        await AppSession.getToken();
        return loginResponse;
      } else {
        throw Exception(loginResponse.message);
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<Map<String, List<String>>> getBomPartyList() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/Planning/GeneratedInquiry"),
        headers: await authHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        return {
          "generatedInquiry": List<String>.from(json["generatedInquiry"] ?? []),
          "customerNames": List<String>.from(json["customerNames"] ?? []),
        };
      }

      return {"generatedInquiry": [], "customerNames": []};
    } catch (e) {
      debugPrint("getBomList Error: $e");

      return {"generatedInquiry": [], "customerNames": []};
    }
  }

  Future<List<String>> getLaminationOperators() async {
    final url = Uri.parse(
      '$baseUrl/Lamination/GetLaminationOperators?operatorType=LAMINATION',
    );

    final response = await http.get(url, headers: await authHeaders());
    debugPrint("LAMINATION OPERATORS: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load lamination operators');
  }

  // 🔹 Supervisors
  Future<List<String>> getLaminationSupervisors() async {
    final url = Uri.parse(
      '$baseUrl/Lamination/GetLaminationSupervisors?supervisorType=LAMINATION',
    );

    final response = await http.get(url, headers: await authHeaders());
    debugPrint("LAMINATION SUPERVISORS: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    throw Exception('Failed to load lamination supervisors');
  }

  // 🔹 Locations
  Future<List<String>> getLaminationLocations() async {
    final url = Uri.parse('$baseUrl/Lamination/GetLaminationLocations');
    final response = await http.get(url, headers: await authHeaders());

    debugPrint("LAMINATION LOCATIONS: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load lamination locations');
  }

  //   Lamination/SubmitBarcode

  Future<Map<String, dynamic>?> laminationBarcode({
    required String barcode,
    // required String rollEntry,
    required String operator,
    required String supervisor,
    required String location,
    // required String plant,
    required String department,
    required String rollEntry,
  }) async {
    final url = Uri.parse('$baseUrl/Lamination/SubmitBarcode');

    try {
      final body = {
        "barcode": barcode,
        "rollEntry": rollEntry, // ✅ camelCase
        "operator": operator,
        "supervisor": supervisor,
        "location": location,
        "department": department,
        // "plant": plant,
      };

      final response = await http
          .post(
            url,
            headers: await authHeaders(),
            body: jsonEncode(body), // ✅ JSON ENCODE
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("LAMINATION BARCODE ERROR: $e");
    }

    return null;
  }

  // Lamination/GetLaminationScannedItems?date=2026-01-28&plant=UNIT-1
  Future<List<Map<String, dynamic>>> getLaminationScannedItems({
    required String date,
    required String plant,
  }) async {
    final url = Uri.parse(
      '$baseUrl/Lamination/GetLaminationScannedItems?date=$date&plant=$plant',
    );

    try {
      final response = await http.get(url, headers: await authHeaders());

      debugPrint('LAMINATION STATUS: ${response.statusCode}');
      debugPrint('LAMINATION RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // ✅ API RETURNS LIST DIRECTLY
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
      return [];
    } catch (e) {
      debugPrint('GetLaminationScannedItems error: $e');
      return [];
    }
  }

  Future<int> getLaminationScannedItemsCount(String date, String plant) async {
    try {
      final items = await getLaminationScannedItems(date: date, plant: plant);
      return items.length;
    } catch (e) {
      debugPrint('GetLaminationScannedItemsCount error: $e');
      return 0;
    }
  }

  Future<List<String>> getCuttingOperators() async {
    final url = Uri.parse('$baseUrl/Cutting/GetOperators');
    final response = await http.get(url, headers: await authHeaders());

    debugPrint("GET Cutting OPERATORS STATUS: ${response.statusCode}");
    debugPrint("GET OPERATORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    throw Exception('Failed to load operators');
  }

  Future<List<String>> getCuttingSupervisors() async {
    final url = Uri.parse('$baseUrl/Cutting/GetSupervisors');
    final response = await http.get(url, headers: await authHeaders());

    debugPrint("GET Cutting SUPERVISORS STATUS: ${response.statusCode}");
    debugPrint("GET SUPERVISORS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    throw Exception('Failed to load supervisors');
  }

  Future<List<String>> getCuttingLocations() async {
    final url = Uri.parse('$baseUrl/Cutting/GetLocations');
    final response = await http.get(url, headers: await authHeaders());

    debugPrint("GET  Cutting LOCATIONS STATUS: ${response.statusCode}");
    debugPrint("GET LOCATIONS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['label'].toString()).toList();
    }
    throw Exception('Failed to load locations');
  }

  // Cutting/Cutting/CheckBarcodeInCutting
  Future<Map<String, dynamic>?> cuttingBarcode({
    required String barcode,
    required String operatorName,
    required String supervisor,
    required String location,
    required String department,
    required String cuttingRecParty,
    required String workOrderCutting,
  }) async {
    final url = Uri.parse('$baseUrl/Cutting/Cutting/CheckBarcodeInCutting');

    try {
      final body = {
        "Barcode": barcode,
        "Operator": operatorName,
        "Supervisor": supervisor,
        "Location": location,
        "Department": department,
        "CuttingRecParty": cuttingRecParty,
        "WorkOrderCutting": workOrderCutting,
      };

      final response = await http
          .post(url, headers: await authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      debugPrint('URL => $url');
      debugPrint('BODY => ${jsonEncode(body)}');
      debugPrint("Cutting scan STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Cutting BARCODE ERROR: $e");
    }

    return null;
  }

  //   {{baseUrl}}BagProduction/GetBagEntryData
  //   Bag Production
  Future<List<BagEntryModel>> getBagEntryData() async {
    final url = Uri.parse('$baseUrl/BagProduction/GetBagEntryData');
    debugPrint('URL: ${url}');

    try {
      final response = await http.get(url, headers: await authHeaders());

      debugPrint('URL: ${url}');

      debugPrint('BAG ENTRY STATUS://////////// ${response.statusCode}');
      log(response.body, name: '///////////////////BAG ENTRY RESPONSE');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        log(response.body, name: 'BAG ENTRY RESPONSE');
        if (decoded['status'] == 'ok') {
          final List list = decoded['data'];
          return list.map((e) => BagEntryModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('BAG ENTRY ERROR: $e');
    }

    return [];
  }

  Future<String?> getNextBagEntryId() async {
    final url = Uri.parse('$baseUrl/BagProduction/GetNextBagEntryId');

    try {
      final response = await http.get(url, headers: await authHeaders());
      debugPrint('URL: ${url}');
      debugPrint('Next Bag Entry ID STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nextId = data['nextBagEntryId']; // 👈 extract value
        debugPrint("NEXT BAG ENTRY ID (SERVICE): $nextId"); // ✅ PRINT HERE
        // Example response: { "nextId": 7 }
        return nextId?.toString();
      }
    } catch (e) {
      debugPrint('GetNextBagEntryId ERROR: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getProductDetails({
    required String partyName,
    required String articleNo,
    required String generatedInquiry,
  }) async {
    final uri = Uri.parse("${baseUrl}/BagProduction/GetProductDetails").replace(
      queryParameters: {
        "partyName": partyName,
        "articleNo": articleNo,
        "generatedInquiry": generatedInquiry,
      },
    );

    try {
      final response = await http.get(uri, headers: await authHeaders());
      debugPrint('URL: ${uri}');
      // debugPrint('PRODUCT DETAILS STATUS: ${response.statusCode}');
      debugPrint('PRODUCT DETAILS BODY: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('BAG ENTRY STATUS: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('GetProductDetails ERROR: $e');
    }
    return null;
  }

  Future<List<String>> getSupervisorsList() async {
    final url = Uri.parse('$baseUrl/BagProduction/GetSupervisorsList');

    try {
      final response = await http.get(url, headers: await authHeaders());
      debugPrint('SUPERVISOR STATUS: $url');
      debugPrint('SUPERVISOR BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['supervisors']);
        }
      }
    } catch (e) {
      debugPrint('GetSupervisors ERROR: $e');
    }
    return [];
  }

  // api/BaleDepartment/GetSupervisorsList

  Future<List<String>> getBaleSupervisorsList() async {
    final url = Uri.parse('$baseUrl/BaleDepartment/GetSupervisorsList');

    try {
      final response = await http.get(url, headers: await authHeaders());
      debugPrint('Bale SUPERVISOR STATUS: $url');
      debugPrint('SUPERVISOR BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['supervisors']);
        }
      }
    } catch (e) {
      debugPrint('GetSupervisors ERROR: $e');
    }
    return [];
  }

  Future<List<String>> getBaleProCheckedByList() async {
    final url = Uri.parse('$baseUrl/BaleDepartment/GetCheckedBy');

    try {
      final response = await http.get(url, headers: await authHeaders());
      // debugPrint('BAG PRODUCT Checked By STATUS: ${response.statusCode}');
      // debugPrint('Checked BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return List<String>.from(data.map((e) => e["checkedBy"].toString()));
      }
    } catch (e) {
      debugPrint('GetSupervisors ERROR: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> saveBagProductionEntry({
    required int srNo,
    required DateTime date,
    required String partyName,
    required String bomNo,
    required String articleNo,
    required String poNumber,
    required String printStatus,
    required String bagSize,
    required String bagType,
    required int bagWeight,

    // 🔹 NEW: list of items
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$baseUrl/BagProduction/SaveBagProductionEntry');

    final body = {
      "srNo": srNo,
      "date": date.toIso8601String().split('T')[0], // ✅ "2026-05-06"
      "partyName": partyName,
      "bomNo": bomNo,
      "articleNo": articleNo,
      "poNumber": poNumber,
      "printStatus": printStatus,
      "bagSize": bagSize,
      "bagType": bagType,
      "bagWeight": bagWeight,
      "items": items, // ✅ important
    };

    debugPrint("SAVE REQUEST: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode(body),
    );

    debugPrint("SAVE STATUS: ${response.statusCode}");
    debugPrint("SAVE RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<BagProductionReport>> getBagProductionReport({
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      "$baseUrl/BagProduction/report?fromDate=$fromDate&toDate=$toDate",
    );

    final response = await http.get(url, headers: await authHeaders());

    // debugPrint("STATUS CODE: ${response.statusCode}");
    // debugPrint("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List list = jsonData['data'];
      for (var item in list) {
        // debugPrint("API Required Bag: ${item['requireD_BAG']}");
      }
      return list.map((e) => BagProductionReport.fromJson(e)).toList();
      // return list.map((e) => BagProductionReport.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load report");
    }
  }

  //   Baling Sections
  // {{baseUrl}}BaleDepartment/bale-in-report
  Future<List<BaleEntryModel>> fetchBaleInReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/BaleDepartment/bale-in-report'),
      headers: await authHeaders(),
    );
    // debugPrint("URL: $response");
    // debugPrint(" Bale reports RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      final List list = json['data'];
      // debugPrint(list.toString());

      return List<BaleEntryModel>.generate(
        list.length,
        (index) => BaleEntryModel.fromJson(list[index], index: index),
      );
    } else {
      throw Exception('Failed to load bale reports');
    }
  }

  // {{baseUrl}}BaleDepartment/GetBaleNextSerialNumber
  Future<int> fetchNextBaleSerialNumber() async {
    final response = await http.get(
      Uri.parse('$baseUrl/BaleDepartment/GetBaleNextSerialNumber'),
      headers: await authHeaders(),
    );
    // debugPrint("STATUS CODE: ${response.statusCode}");
    // debugPrint("RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['success'] == true) {
        return int.tryParse(json['srNo'].toString()) ?? 0;
      } else {
        throw Exception('API returned success = false');
      }
    } else {
      throw Exception('Failed to fetch next serial number');
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails({
    required String partyName,
    required String articleNo,
    required String generatedInquiry,
  }) async {
    final uri = Uri.parse('$baseUrl/BaleDepartment/GetProductDetails').replace(
      queryParameters: {
        'partyName': partyName,
        'articleNo': articleNo,
        'generatedInquiry': generatedInquiry,
      },
    );
    _logApi(method: "GET", url: uri);
    final response = await http.get(uri, headers: await authHeaders());
    // _checkUnauthorized(response);
    // debugPrint("STATUS CODE: ${response.statusCode}");
    // debugPrint("RESPONSE BALE PRODUCT DETAILS: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['success'] == true) {
        return json;
      } else {
        throw Exception('Product details not found');
      }
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<Map<String, dynamic>?> saveBaleEntry(
    Map<String, dynamic> payload,
  ) async {
    final url = "$baseUrl/BaleDepartment/SaveBaleEntry";

    // debugPrint("🌐 API URL: $url");
    // debugPrint("📤 REQUEST BODY:");
    // debugPrint(jsonEncode(payload));

    final response = await http.post(
      Uri.parse(url),
      headers: await authHeaders(),
      body: jsonEncode(payload),
    );

    // debugPrint("📥 STATUS CODE: ${response.statusCode}");
    // debugPrint("📥 RESPONSE BODY:");
    // debugPrint(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<List<BaleStockReportModel>> fetchStockReport({
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      '$baseUrl/BaleDepartment/stock-report?fromDate=$fromDate&toDate=$toDate',
    );
    _logApi(method: "GET", url: url);
    final response = await http.get(url, headers: await authHeaders());
    // _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RESPONSE BALE STOCK REPORT DETAILS: ${response.body}");
      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => BaleStockReportModel.fromJson(e))
            .toList();
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load report');
    }
  }

  Future<List<BailingReportModel>> fetchBailingReport({
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      '$baseUrl/BaleDepartment/bailing-report?fromDate=$fromDate&toDate=$toDate',
    );
    // _logApi(method: "GET", url: url);
    final response = await http.get(url, headers: await authHeaders());
    // _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // debugPrint("STATUS CODE: ${response.statusCode}");
      // log("RESPONSE BALE REPORT DETAILS: ${response.body}");
      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => BailingReportModel.fromJson(e))
            .toList();
      } else {
        throw Exception('No records found');
      }
    } else {
      throw Exception('Failed to load bailing report');
    }
  }

  static DispatchInitModel? cachedDispatchInit;

  static Future<DispatchInitModel> fetchDispatchInit() async {
    final response = await http.get(
      Uri.parse("$baseUrl/BaleDepartment/dispatch-init"),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      debugPrint('Response dispatch all :::::$response');

      final data = json.decode(response.body);
      debugPrint('Response dispatch supervisor operator:::::$data');
      _checkUnauthorized(response);
      cachedDispatchInit = DispatchInitModel.fromJson(data);
      return cachedDispatchInit!;
    } else {
      throw Exception("Failed to load dispatch init");
    }
  }

  static Future<List<String>> fetchBomNumbers(String partyName) async {
    final response = await http.get(
      Uri.parse("$baseUrl/BaleDepartment/bom-numbers?partyName=$partyName"),
      headers: await authHeaders(),
    );
    // _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 👇 API returns List directly
      return List<String>.from(data);
    } else {
      throw Exception("Failed to load BOM numbers");
    }
  }

  static Future<String?> fetchArticleNumber({
    required String partyName,
    required String bomNumber,
  }) async {
    final uri = Uri.parse("$baseUrl/BaleDepartment/article-number").replace(
      queryParameters: {"customerName": partyName, "bomNumber": bomNumber},
    );

    // debugPrint("Article API URL: $uri");

    final response = await http.get(uri, headers: await authHeaders());
    // _checkUnauthorized(response);
    // debugPrint("Article status: ${response.statusCode}");
    // debugPrint("Article body: ${response.body}");

    if (response.statusCode == 200) {
      // 🔥 DIRECT RETURN — NO json.decode
      return response.body.trim();
    } else {
      throw Exception(
        "Failed to fetch article number (${response.statusCode})",
      );
    }
  }

  //   {{baseurl}}/BaleDepartment/po-numbers?partyName=BGT

  static Future<List<String>> fetchPONumbers({
    required String partyName,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/BaleDepartment/po-numbers?partyName",
    ).replace(queryParameters: {"partyName": partyName});

    // debugPrint("PO API URL: $uri");

    final response = await http.get(uri, headers: await authHeaders());
    // _checkUnauthorized(response);
    // debugPrint("PO status: ${response.statusCode}");
    // debugPrint("PO body: ${response.body}");

    if (response.statusCode == 200) {
      final body = response.body.trim();

      // ✅ If API returns JSON array
      if (body.startsWith("[")) {
        final List data = json.decode(body);
        return data.map((e) => e.toString()).toList();
      }

      // ✅ If API returns single PO as string
      return body.isEmpty ? [] : [body];
    } else {
      throw Exception("Failed to fetch PO numbers (${response.statusCode})");
    }
  }

  static Future<BarcodeResponseModel> fetchBarcodeBySrNo({
    required int srNo,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/BaleDepartment/barcode",
    ).replace(queryParameters: {"srno": srNo.toString()});

    // debugPrint("BARCODE API URL: $uri");

    final response = await http.get(uri, headers: await authHeaders());
    // _checkUnauthorized(response);
    // debugPrint("Barcode status: ${response.statusCode}");
    // debugPrint("Barcode body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BarcodeResponseModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch barcode (${response.statusCode})");
    }
  }

  // static Future<bool> saveDispatch(DispatchSaveRequest request) async {
  static Future<bool> saveDispatch(Map<String, dynamic> body) async {
    // final uri = Uri.parse("$baseUrl/BaleDepartment/save-dispatch");
    final uri = Uri.parse("$baseUrl/BaleDepartment/save-dispatch-multiple");

    // debugPrint("Save Dispatch URL: $uri");
    // debugPrint("Payload: ${jsonEncode(body)}");

    final response = await http.post(
      uri,
      headers: await authHeaders(),
      body: jsonEncode(body),
    );
    // _checkUnauthorized(response);
    debugPrint("Save status: ${response.statusCode}");
    debugPrint("Save body: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return true;

      final data = jsonDecode(response.body);
      // _checkUnauthorized(response);
      // Try multiple possible keys
      return data["success"] == true ||
          data["found"] == true ||
          data["status"] == 1;
    } else {
      return false;
    }
  }

  // static Future<bool> saveDispatch(DispatchSaveRequest request) async {
  static Future<List<DispatchBailRecord>> fetchDispatchReport({
    required String fromDate,
    required String toDate,
  }) async {
    final url = Uri.parse(
      '$baseUrl/BaleDepartment/dispatch-report?fromDate=$fromDate&toDate=$toDate',
    );

    debugPrint("DISPATCH REPORT URL: $url");

    try {
      final response = await http.get(url, headers: await authHeaders());
      // _checkUnauthorized(response);
      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RAW RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);

        return list.map((e) => DispatchBailRecord.fromJson(e)).toList();
      } else {
        debugPrint('Dispatch Report Failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Dispatch Report Error: $e');
      return [];
    }
  }

  //Webbing DEpartment
  static Future<WebbingDropdownModel?> webbFetchDropdowns() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/Webbing/dropdowns"),
        headers: await authHeaders(),
      );
      // _checkUnauthorized(response);
      // print("STATUS: ${response.statusCode}");
      // print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print("DECODED DATA: $data");

        return WebbingDropdownModel.fromJson(data["data"]);
      } else {
        print("Dropdown API failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Dropdown API error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> checkWebbBarcode({
    required String barcode,
    required String plant,
    required String rollEntry,
    required String supervisor,
    required String operator,
    required String department,
    required String location,
  }) async {
    final url = Uri.parse("$baseUrl/Webbing/check-barcode");

    final payload = {
      "barcode": barcode,
      // "plant": 'UNIT-SILVASSA',
      // "plant": 'UNIT-NARDANA',
      "Plant": plant,

      // "plant": 'UNIT-1',
      "location": location,

      "department": department,
      "supervisor": supervisor,
      "operator": operator,
      "rollEntry": rollEntry,
    };

    debugPrint("CHECK BARCODE PAYLOAD 👉 ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode(payload),
    );
    // _checkUnauthorized(response);
    debugPrint("webb url 👉 $url");
    debugPrint("CHECK BARCODE RESPONSE 👉 ${response.body}");

    return jsonDecode(response.body);
  }

  static Future<WebbingReportModel?> fetchWebbingScannedItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Webbing/webbing-report'),
        headers: await authHeaders(),
      );
      // _checkUnauthorized(response);

      if (response.statusCode == 200) {
        // print("STATUS: ${response.statusCode}");
        // print("Webbing Reports: ${response.body}");
        final jsonData = jsonDecode(response.body);
        return WebbingReportModel.fromJson(jsonData);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  static Future<WebbingReportModel?> fetchWebbingScannedOutItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Webbing/WebbingOutScanned'),
        headers: await authHeaders(),
      );
      // _checkUnauthorized(response);

      if (response.statusCode == 200) {
        // print("STATUS: ${response.statusCode}");
        // print("Webbing Reports: ${response.body}");
        final jsonData = jsonDecode(response.body);
        return WebbingReportModel.fromJson(jsonData);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
  // {{baseUrl}}/Webbing/lookup-data

  static Future<WebbingDropdownModel?> fetchWebbingOutLookup() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/Webbing/lookup-data"),
        headers: await authHeaders(),
      );
      // _checkUnauthorized(response);
      print("URL: $baseUrl/Webbing/lookup-data");

      // print("STATUS: ${response.statusCode}");
      // print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          // return WebbingDropdownModel.fromJson(jsonData["data"]);
          // return WebbingDropdownModel.fromJson(data["data"]);
          return WebbingDropdownModel.fromJson(data);

          // If NOT nested, use:
          // return WebbingOutLookupModel.fromJson(jsonData);
        }
      }

      return null;
    } catch (e) {
      print("Lookup API error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> processOutBarcode({
    required String barcode,
    required String supervisor,
    required String operator,
    required String issueType,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Webbing/process-out-barcode"),
        headers: {"Content-Type": "application/json", ...await authHeaders()},
        body: jsonEncode({
          "barcode": barcode,
          "supervisor": supervisor,
          "operator": operator,
          "issueType": issueType,
          "location": location,
        }),
      );
      // _checkUnauthorized(response);
      // print("PROCESS OUT STATUS: ${response.statusCode}");
      // print("PROCESS OUT BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Process Out API error: $e");
      return {"status": "error", "message": "Something went wrong"};
    }
  }

  Future<List<WebbingInReportModel>> getWebbingInReport({
    required String dateFrom,
    required String dateTo,
  }) async {
    final url = Uri.parse(
      "$baseUrl/Webbing/webbing-in-report?dateFrom=$dateFrom&dateTo=$dateTo",
    );

    try {
      final response = await http.get(url);
      // _checkUnauthorized(response);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List data = jsonData['data'];

          return data.map((e) => WebbingInReportModel.fromJson(e)).toList();
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception("Failed to fetch report");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // LOOOM DEPARTMENt
  static Future<LoomOrderResponse> fetchLoomOrders({
    required String viewType,
    required String unit,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/LoomForward/get').replace(
      queryParameters: {
        'viewType': viewType,
        'unit': unit,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final response = await http.get(uri, headers: await authHeaders());
    debugPrint("Loom LOist Resposne Body ::::::${uri}");
    // debugPrint("STATUS LOOM dropdown CODE: ${response.statusCode}");
    // debugPrint("Loom LOist Resposne Body ::::::${response.body}");
    // print("Status Code: ${response.statusCode}");
    // print("Headers: ${response.headers}");
    // print("Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("API Error ${response.statusCode}: ${response.body}");
    }

    if (response.statusCode == 200) {
      // debugPrint("Loom LOist Resposne Body ::::::${response.body}");
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        final List dataList = jsonData['data'] ?? [];

        return LoomOrderResponse(
          orders: dataList.map((e) => LoomOrder.fromJson(e)).toList(),
          totalCount: jsonData['count'] ?? 0,
          status: '',
        );
      } else {
        throw Exception("API returned failure");
      }
    } else {
      throw Exception("Failed to load Loom Orders");
    }
  }

  static Future<LoomDropdownData> fetchDropdowns({
    required String unit,
    required String fabricCode,
  }) async {
    final url = Uri.parse(
      "$baseUrl/LoomForward/dropdowns?unit=$unit&fabricCode=$fabricCode",
    );

    final response = await http.get(url, headers: await authHeaders());
    // _checkUnauthorized(response);
    // debugPrint("STATUS LOOM dropdown CODE: ${response.statusCode}");

    // debugPrint("DropDown Resposne Body ::::::${response.body}");
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'success') {
        return LoomDropdownData.fromJson(jsonData['data']);
      } else {
        throw Exception("API returned failure status");
      }
    } else {
      throw Exception("Failed to load dropdowns");
    }
  }

  static Future<List<CuttingApprovalModelNardan>>
  getCuttingApprovalList() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/Cutting/CuttingApprovalList"),
        headers: await authHeaders(),
      );

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data
            .map((e) => CuttingApprovalModelNardan.fromJson(e))
            .toList(); // ✅
      }

      return [];
    } catch (e) {
      debugPrint("API Error: $e");
      return [];
    }
  }

  static Future<bool> approveCutting(
    List<CuttingApprovalModelNardan> items,
  ) async {
    try {
      final body = jsonEncode({
        "items": items
            .map(
              (e) => {
                "col1": e.id.toString(),
                "col2": e.date,
                "col3": e.orderNo,
                "col4": e.component,
                "col5": e.netWt.toString(),
                "col6": e.wastage.toString(),
                "col7": e.pcs.toString(),
                "col8": e.width.toString(),
                "col9": e.cutLength.toString(),
                "col10": e.perPcsWt.toString(),
              },
            )
            .toList(),
      });

      // debugPrint("APPROVE BODY: $body");

      final response = await http.post(
        Uri.parse("$baseUrl/Cutting/Approve"),
        headers: await authHeaders(),
        body: body,
      );

      // debugPrint("STATUS: ${response.statusCode}");
      // debugPrint("RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Approve API Error: $e");
      return false;
    }
  }

  static Future<List<CutPcsItemNardana>> getCuttingIssuedList(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final f = DateFormat("yyyy-MM-dd").format(fromDate);
      final t = DateFormat("yyyy-MM-dd").format(toDate);

      final url = "$baseUrl/Cutting/CuttingIssuedList?fromDate=$f&toDate=$t";

      debugPrint("ISSUED API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: await authHeaders(),
      );

      // debugPrint("STATUS: ${response.statusCode}");
      // debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((e) => CutPcsItemNardana.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("ERROR: $e");
      return [];
    }
  }

  static Future<List<String>> getComponentsInCuttingIssued(
    String woNumber,
  ) async {
    try {
      final url = Uri.parse(
        "$baseUrl/Cutting/ComponentInCuttingIssued?woNumber=${Uri.encodeComponent(woNumber)}",
      );

      debugPrint("COMPONENTS API: $url");

      final response = await http.get(url, headers: await authHeaders());

      // debugPrint("STATUS: ${response.statusCode}");
      // debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((e) => e['component'].toString())
            .toList(); // ✅ ["BODY", "SIDE"]
      }

      return [];
    } catch (e) {
      debugPrint("getComponentsInCuttingIssued Error: $e");
      return [];
    }
  }

  static Future<String> saveCuttingIssue({
    required int iid,
    required String issueToWorkOrder,
    required String issueToComponent,
    required int noOfPcs,
    required double kg,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/Cutting/SaveCuttingIssue");

      final body = {
        "iid": iid,
        "issueToWorkOrder": issueToWorkOrder,
        "issueToComponent": issueToComponent,
        "noOfPcs": noOfPcs,
        "kg": kg,
      };

      final response = await http.post(
        url,
        headers: await authHeaders(),
        body: jsonEncode(body),
      );

      print("REQUEST SaveCuttingIssue URL: $url");
      // print("STATUS CODE: ${response.statusCode}");
      // print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return "Data Saved Successfully";
      } else {
        throw Exception("Failed to save data");
      }
    } catch (e) {
      print("ERROR: $e");
      throw Exception("Error saving cutting issue");
    }
  }

  static void _logApi({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    debugPrint("🌐 [$method] URL => $url");

    if (headers != null) {
      debugPrint("🧾 Headers => $headers");
    }

    if (body != null) {
      try {
        debugPrint("📦 Body => ${body is String ? body : jsonEncode(body)}");
      } catch (e) {
        debugPrint("📦 Body => $body");
      }
    }
  }

  static Future<LaminationOutModel> getLaminationDetails(int id) async {
    final url = Uri.parse('${baseUrl}/Lamination/lamination-outstock?id=$id');

    final headers = await InStockService._jsonHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      debugPrint("OuTSTOCK id fetch data ::::::$jsonData");

      if (jsonData['success'] == true) {
        return LaminationOutModel.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception("Failed to load lamination details");
    }
  }

  //TaPELINE APIS
  // PARTYNAME

  // 1. Get dropdown data
  Future<Map<String, dynamic>> fetchDropdownData() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/Tapeline/dropdown-data'),
        headers: await authHeaders(),
      );

      // debugPrint("STATUS: ${response.statusCode}");
      // debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 🔥 IMPORTANT: ensure Map
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception("Invalid API format");
        }
      } else {
        throw Exception('Failed to load dropdown');
      }
    } catch (e) {
      debugPrint("API ERROR: $e");
      rethrow;
    }
  }

  // 2. Get PO Numbers
  Future<List<dynamic>> getPoNumbers(String customerName) async {
    final res = await http.get(
      Uri.parse("$baseUrl/Tapeline/po-numbers?customerName=$customerName"),
      headers: await InStockService.authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // 3. Get Article Numbers
  Future<List<dynamic>> getArticleNumbers(
    String customerName,
    String poNum,
  ) async {
    final res = await http.get(
      Uri.parse(
        "${baseUrl}/Tapeline/article-numbers?customerName=$customerName&poNum=$poNum",
      ),
      headers: await InStockService.authHeaders(),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> saveTapeLineEntry(
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/Tapeline/save"),
      headers: await authHeaders(), // ✅ correct
      body: jsonEncode(body),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to save data");
    }
  }

  Future<List<dynamic>> getRecentSavedList() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Tapeline/saved-list"),
      headers: await InStockService.authHeaders(), // ✅ correct
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print("OutList URL: ${response}");

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      // if API returns list directly
      if (decoded is List) {
        return decoded;
      }

      // if single object → convert to list
      return [decoded];
    } else {
      throw Exception("Failed to load saved list");
    }
  }

  Future<List<dynamic>> getTapelineOutList() async {
    final response = await http.get(
      Uri.parse("${baseUrl}/Tapeline/outstock-list"),
      headers: await InStockService.authHeaders(),
    );

    // ✅ PRINT STATUS & BODY
    print("OutList URL: ${response}");

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // if API returns list
      if (decoded is List) {
        return decoded;
      }

      // if single object
      return [decoded];
    } else {
      throw Exception("Failed to load OutStock list");
    }
  }

  Future<List<dynamic>> getOutStockById(String id) async {
    final response = await http.get(
      Uri.parse("${baseUrl}/Tapeline/outstock_issueqty?id=$id"),
      headers: await InStockService.authHeaders(),
    );

    print("URL: ${baseUrl}/Tapeline/outstock_issueqty?id=$id");
    // print("STATUS CODE: ${response.statusCode}");
    // print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch barcode data");
    }
  }

  //
  // Future<Map<String, dynamic>> getOperatorSupervisor() async {
  //   final response = await http.get(
  //     Uri.parse("baseUrl$baseUrl/Tapeline/op-name"),headers: await InStockService.authHeaders()
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //
  //     print("OP API: $jsonData");
  //
  //     return {
  //       "supervisors": List<String>.from(jsonData['supervisor'] ?? []),
  //       "operators": List<String>.from(jsonData['operator'] ?? []),
  //     };
  //   } else {
  //     throw Exception("Failed to load operator/supervisor");
  //   }
  // }

  // ✅ Supervisor + Operator
  Future<Map<String, dynamic>> getOperatorSupervisor() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Tapeline/op-name"),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // ✅ HANDLE LIST RESPONSE
      if (jsonData is List) {
        final supervisors = jsonData
            .map((e) => e['supervisor'].toString())
            .toList();

        return {
          "supervisors": supervisors,
          "operators": supervisors, // ⚠️ same API (no operator field)
        };
      }

      throw Exception("Invalid response format");
    } else {
      throw Exception("Failed to load operator/supervisor");
    }
  }

  // ✅ Barcode Details
  Future<Map<String, dynamic>> getBarcodeDetails(String code) async {
    final response = await http.get(
      Uri.parse("$baseUrl/Tapeline/outstock_issueqty?id=$code"),
      headers: await authHeaders(),
    );
    // print("====== FINAL FETCH BARCODE ======");

    // print("STATUS: ${response.statusCode}");
    // print("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // ✅ HANDLE LIST RESPONSE
      if (jsonData is List && jsonData.isNotEmpty) {
        return jsonData.first; // 🔥 IMPORTANT
      }

      throw Exception("No data found");
    } else {
      throw Exception("Failed to fetch barcode");
    }
  }

  Future<Map<String, dynamic>> saveOutstock({
    required String date,
    required String time,
    required String supervisor,
    required String operator,
    required String dept,
    required Map<String, dynamic> item,
  }) async {
    final url = Uri.parse("$baseUrl/Tapeline/saveoutstock");

    final body = {
      "date": date,
      "time": time,
      "computeR_OPERATOR_NAME": supervisor,
      "operatoR_NAME": operator,
      "issuE_DEPARTMENT": dept,
      "items": [
        {
          "id": item["id"],
          "balanceQty": item["balanceQty"],
          "issueQty": item["issueQty"],
          "existingIssueQty": item["existingIssueQty"],
          "statuS_ISSUE": item["statuS_ISSUE"] ?? "True",
        },
      ],
    };

    final response = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode(body),
    );

    print("====== FINAL MATCH POSTMAN ======");
    print("BODY: ${jsonEncode(body)}");
    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return json.decode(response.body);
  }

  static Future<List<String>> getWoNumbers() async {
    final url = Uri.parse("${baseUrl}/Cutting/wo-numbers");

    print("URL: $url");

    final response = await http.get(url, headers: await authHeaders());

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // print("Bom No Response: $data");

      List<String> woList = data.map((e) => e["wO_NUMBER"].toString()).toList();

      /// ✅ SORT PROPERLY (handles #, SM# etc.)
      woList.sort((a, b) {
        int extractNumber(String val) {
          return int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        }

        return extractNumber(a).compareTo(extractNumber(b));
      });

      return woList;
    } else {
      print("❌ API FAILED");
      return [];
    }
  }

  Future<List<CuttingInReportModel>> getCuttingInReport({
    required String dateFrom,
    required String dateTo,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final url = Uri.parse(
      "$baseUrl/Cutting/cuttinginreport"
      "?fromDate=$dateFrom"
      "&toDate=$dateTo"
      "&pageNumber=$pageNumber"
      "&pageSize=$pageSize",
    );

    /// 🔹 PRINT URL
    debugPrint("REQUEST URL: $url");

    final response = await http.get(url, headers: await authHeaders());

    /// 🔹 PRINT STATUS + RESPONSE
    // debugPrint("STATUS CODE: ${response.statusCode}");
    // debugPrint("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded; // direct list

      return data.map((e) => CuttingInReportModel.fromJson(e)).toList();
    } else {
      /// 🔹 PRINT ERROR RESPONSE
      debugPrint("API ERROR RESPONSE: ${response.body}");

      throw Exception("Failed To Load Cutting In Report");
    }
  }
  //
  // Future<List<RollWiseReportModel>> getRollWiseReport({
  //   String? fromDate,
  //   String? toDate,
  //   required int pageNumber,
  //   required int pageSize,
  // }) async {
  //   try {
  //     String url;
  //
  //     /// 🔥 API SWITCHING
  //     if (fromDate != null && toDate != null) {
  //       url =
  //       "$baseUrl/Cutting/RollWiseReport?fromDate=$fromDate&toDate=$toDate&pageNumber=$pageNumber&pageSize=$pageSize";
  //
  //           // "$baseUrl/Cutting/cutting-balance-report?fromDate=$fromDate&toDate=$toDate&pageNumber=$pageNumber&pageSize=$pageSize";
  //     } else {
  //       url =
  //       "$baseUrl/Cutting/RollWiseReport?fromDate=$fromDate&toDate=$toDate&pageNumber=$pageNumber&pageSize=$pageSize";
  //
  //       // "$baseUrl/Cutting/cutting-balance-report?pageNumber=$pageNumber&pageSize=$pageSize";
  //     }
  //     print("👉 API URL: $url");
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: await authHeaders(),
  //     );
  //     print("👉 Response Body Cutting Balance report: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       /// 🔥 PRINT STATUS CODE
  //       print("👉 Status Code: ${response.statusCode}");
  //
  //       /// 🔥 PRINT RAW RESPONSE
  //       print("👉 Response Body Cutting Balance report: ${response.body}");
  //       return (data as List)
  //           .map((e) => RollWiseReportModel.fromJson(e))
  //           .toList();
  //     } else {
  //       throw Exception("Failed to load report: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("API Error: $e");
  //   }
  // }

  Future<List<RollWiseReportModel>> getRollWiseReport({
    String? fromDate,
    String? toDate,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Map<String, String> params = {
        "pageNumber": pageNumber.toString(),
        "pageSize": pageSize.toString(),
      };

      if (fromDate != null && toDate != null) {
        params["fromDate"] = fromDate;
        params["toDate"] = toDate;
      }

      final uri = Uri.parse(
        "$baseUrl/Cutting/RollWiseReport",
      ).replace(queryParameters: params);

      print("URL => $uri");

      final response = await http.get(uri, headers: await authHeaders());

      print("Status => ${response.statusCode}");
      print("Response => ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        return jsonData.map((e) => RollWiseReportModel.fromJson(e)).toList();
      }

      throw Exception("Status: ${response.statusCode}\nBody: ${response.body}");
    } catch (e) {
      throw Exception("RollWiseReport Error: $e");
    }
  }

  Future<List<Comp_NardanaReportModel>> getComponentReport({
    String? fromDate,
    String? toDate,
    required int pageNumber,
    required int pageSize,
  }) async {
    final uri = Uri.parse("$baseUrl/Cutting/cutting-Component-report").replace(
      queryParameters: {
        "fromDate": fromDate ?? "",
        "toDate": toDate ?? "",
        "pageNumber": pageNumber.toString(),
        "pageSize": pageSize.toString(),
      },
    );

    print("👉 API URL: $uri");

    final response = await http.get(uri, headers: await authHeaders());

    // print("👉 Status Code: ${response.statusCode}");
    // print("👉 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      // print("👉 Total Records: ${data.length}");

      return data.map((e) => Comp_NardanaReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Component Report");
    }
  }

  Future<List<CuttingReportModel>> getCuttingReport({
    String? fromDate,
    String? toDate,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final url =
        "$baseUrl/Cutting/cutting-report?fromDate=$fromDate&toDate=$toDate&pageNumber=$pageNumber&pageSize=$pageSize";

    final response = await http.get(
      Uri.parse(url),
      headers: await authHeaders(),
    );

    /// 🔥 PRINT STATUS CODE
    print("👉 Cutting url: ${url}");

    /// 🔥 PRINT RAW RESPONSE
    // print("👉 Response Body Cutting Report: ${response.body}");
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // print(json);

      /// 🔥 PRINT PARSED LENGTH
      // print("👉 Total Records: ${data.length}");
      return data.map((e) => CuttingReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Cutting Report");
    }
  }

  static Future<LoomSupervisorData> fetchSuperDropdownData({
    String? machine,
    String? unit,
  }) async {
    final url = Uri.parse(
      // "$baseUrl/LoomForward/supervisor?unit=UNIT-NARDANA&machine=${machine ?? "All"}",
      "$baseUrl/LoomForward/supervisor?unit=$unit&machine=${machine ?? "All"}",
    );

    print("👉 API URL: $url"); // ✅ PRINT URL

    final response = await http.get(url, headers: await authHeaders());

    print("👉 STATUS CODE: ${response.statusCode}"); // ✅ STATUS
    print("👉 RESPONSE BODY: ${response.body}"); // ✅ FULL RESPONSE

    if (response.statusCode == 200) {
      return LoomSupervisorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load dropdown data");
    }
  }

  Future<List<LoomListModel>> fetchLoomList() async {
    final url = Uri.parse("${baseUrl}/LoomForward/GetLoomList");

    final res = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );
    print("👉 Loom List Response: ${url}");

    print("👉 Loom List Response: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      List list = data['data'];

      return list.map((e) => LoomListModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<Map<String, dynamic>> printBarcode({
    required int id,
    required String barcode,
  }) async {
    final response = await http.post(
      Uri.parse("${baseUrl}/LoomForward/PrintBarcode"),
      headers: await authHeaders(),
      body: jsonEncode({"id": id, "barcode": barcode}),
    );

    if (response.statusCode == 200) {
      print("👉 Loom List Response: ${response.body}");

      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to print barcode");
    }
  }

  static Future<List> fetchByRoll(String roll) async {
    final url = Uri.parse(
      "$baseUrl/Rmd/Rmd/RMDTRANSFERbyRollCode?rollCode=$roll",
    );

    final res = await http.get(url, headers: await authHeaders());

    // print("STATUS: ${res.statusCode}");
    // print("RESPONSE BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // print("DECODED TYPE: ${decoded.runtimeType}");

      // ✅ IMPORTANT FIX HERE
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        return decoded['data'];
      } else {
        return [];
      }
    } else {
      throw Exception("Server error (${res.statusCode})");
    }
  }

  static Future<List> fetchByBarcode(String barcode) async {
    final url = Uri.parse(
      "$baseUrl/Rmd/Rmd/RMDTRANSFERByBarcode?barcode=$barcode",
    );

    final res = await http.get(url, headers: await authHeaders());

    // print("STATUS: ${res.statusCode}");
    // print("RESPONSE BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        return decoded['data'];
      } else {
        return [];
      }
    } else {
      throw Exception("Server error (${res.statusCode})");
    }
  }

  static Future<Map<String, dynamic>> receiveRoll(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl/Rmd/Rmd/ReceiveRoll");

    final res = await http.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Transfer failed");
    }
  }

  Future<List<ManualPlanningModel>> fetchManualPlanning({
    DateTime? from,
    DateTime? to,
    String? unit,
  }) async {
    final formatter = DateFormat("yyyy-MM-dd");

    final url = Uri.parse(
      "$baseUrl/LoomForward/manualplanning"
      "?fromDate=${formatter.format(from!)}"
      "&toDate=${formatter.format(to!)}"
      "&unit=$unit",
    );
    print("URL: $url");

    final response = await http.get(url, headers: await authHeaders());
    // print("STATUS: ${response.statusCode}");
    // print("RESPONSE BODY: ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return (jsonData["data"] as List)
          .map((e) => ManualPlanningModel.fromJson(e))
          .toList();
    }

    throw Exception("Failed");
  }

  Future<List<String>> fetchPartyNames() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Tapeline/partname"),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      print("API Records = ${data.length}");

      final parties = data
          .map<String>((e) => (e["customeR_NAME"] ?? "").toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();

      print("After Filter = ${parties.length}");
      print(parties);

      return parties;
    }

    throw Exception("Unable to load Party List");
  }

  Future<List<TapeFIBCModel>> fetchFibc(String customerName) async {
    final response = await http.get(
      Uri.parse("$baseUrl/Tapeline/required-fibc?customerName=$customerName"),
      headers: await authHeaders(),
    );
    print("STATUS TAPELINE LIST////: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => TapeFIBCModel.fromJson(e)).toList();
    } else {
      throw Exception("Unable to load data");
    }
  }

  Future<List<TapelineInReportModel>> fetchTapelineInReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final formatter = DateFormat("yyyy-MM-dd");

    final url = Uri.parse(
      "$baseUrl/Tapeline/tapeline-report"
      "?fromDate=${formatter.format(from!)}"
      "&toDate=${formatter.format(to!)}",
    );

    print(url);

    final response = await http.get(url, headers: await authHeaders());
    print(url);
    print("RESPONSE Tapeline Report BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => TapelineInReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Tapeline Report");
    }
  }

  Future<List<TapelineOutReportModel>> fetchTapelineOutReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final formatter = DateFormat("yyyy-MM-dd");

    final url = Uri.parse(
      "$baseUrl/Tapeline/tapeline-out-report"
      "?fromDate=${formatter.format(from!)}"
      "&toDate=${formatter.format(to!)}",
    );

    print(url);

    final response = await http.get(url, headers: await authHeaders());

    if (response.statusCode == 200) {
      print("RESPONSE Tape out Report BODY: ${response.body}");
      final List data = jsonDecode(response.body);

      return data.map((e) => TapelineOutReportModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Tapeline Report");
    }
  }

  static Future<List<TapeStockReportModel>> fetchTapeStock({
    required int page,
    required int pageSize,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/Tapeline/tapeline-stock?page=$page&pageSize=$pageSize',
      ),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // print(url);
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      return data.map((e) => TapeStockReportModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load Tape Stock");
  }

  static Future<Map<String, dynamic>> updateLocation({
    required String barcode,
    required String location,
    required String plant,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/Rmd/UpdateLocation");

      final body = {"barcode": barcode, "location": location, "plant": plant};

      final response = await http.post(
        url,
        headers: await authHeaders(),
        body: jsonEncode(body),
      );

      print(url);
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Server Error (${response.statusCode})",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}

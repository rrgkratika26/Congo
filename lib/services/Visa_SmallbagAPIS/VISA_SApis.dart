import 'dart:convert';

import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ScannedItem/Cutting/cutOutModelClass/ModelClassOutstock.dart';
import '../../ScannedItem/Cutting/cutOutModelClass/RemainingWeightModelClass.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/NewBarcode.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import '../../Visa/Loom/modelClass/FIBCmodel.dart';
import '../../Visa/Loom/modelClass/LoomMasterModel.dart';
import '../../Visa/Loom/modelClass/LoomSavedListModel.dart';
import '../../Visa/Loom/modelClass/LoomTypeModel.dart';
import '../../screen/Printing/ModelClass/InReportModelClass.dart';
import '../../screen/Printing/ModelClass/PrintOutReport.dart';
import '../../screen/Printing/ModelClass/PrintOutsaveListModel.dart';
import '../../screen/Printing/ModelClass/Printmodel.dart';

import '../../screen/Printing/ModelClass/scanReportModel.dart';
import '../getSupervisors/getSupervisors.dart';

class VisaSmallBagApiService {
  // static const String baseUrlJBL = 'http://190.92.175.47:80/JblAPI/api';
  // static String baseUrlJBL = 'http://190.92.175.47:80/Visa/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/Innoweave/api';
  // static const String baseUrlJBL ='http://190.92.175.47:80/api/api';
  // static const String baseUrlJBL ='http://190.92.175.47/Qualipack/api';
  // static const String baseUrlJBL ='http://190.92.175.47/CONGO_API/api';
  // static const String baseUrl = 'http://192.168.29.125:7165/api';
  static const String baseUrl = 'http://190.92.175.47/VISA_S/api';

  // static const String baseUrlJBL = 'http://190.92.175.47/ShriShakti/api';

  // static const String baseUrlJBL ='http://192.168.29.39:44349/api/api';

  // static const String baseUrl = 'http://190.92.175.47:80/Nardana/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/ASIA_API/api';

  Future<List<String>> getPrintingLocations() async {
    final url = Uri.parse('$baseUrl/Lamination/GetLaminationLocations');

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    debugPrint("Printing LOCATIONS: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((e) => e['label'].toString()).toList();
    }

    throw Exception('Failed to load lamination locations');
  }

  Future<Map<String, dynamic>?> printingScanIn({
    required String barcode,
    required String location,
    required String operator,
    required String supervisor,
    required String department,
    required String plant,
  }) async {
    final url = Uri.parse('$baseUrl/Printing/ScanBarcode');

    final body = {
      "barcode": barcode,
      "location": location,
      "operator": operator,
      "supervisor": supervisor,
      "department": department,
      "plant": plant,
    };

    debugPrint("URL : $url");
    debugPrint("BODY : ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        ...await InStockService.authHeaders(),
      },
      body: jsonEncode(body),
    );

    debugPrint("Status : ${response.statusCode}");
    // debugPrint("Response : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {"status": "error", "message": response.body};
  }

  Future<Map<String, dynamic>?> slittingIn({
    required String barcode,
    required String operator,
    required String location,
    required String plant,
    required String roll,
    String party = "",
    String workOrderNo = "",
    required String supervisor,
  }) async {
    final url = Uri.parse('$baseUrl/Slitting/SlittingIn');

    final body = {
      "barcode": barcode,
      "roll": roll,
      "operator": operator,
      "supervisor": supervisor,
      "location": location,
      "party": party,
      "workOrderNo": workOrderNo,
      "plant": plant,
    };

    debugPrint("URL : $url");
    debugPrint("BODY : ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        ...await InStockService.authHeaders(),
      },
      body: jsonEncode(body),
    );

    debugPrint("Status : ${response.statusCode}");
    debugPrint("Response : ${response.body}");

    // Parse response for both success and error
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPrintingSpAndOpName() async {
    final url = Uri.parse('$baseUrl/Printing/SpAndOpName');

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    debugPrint("SP & OP Status : ${response.statusCode}");
    // debugPrint("SP & OP Response : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load Operators & Supervisors");
  }

  Future<List<PrintingReportModel>> getPrintingReport(String date) async {
    final url = Uri.parse('$baseUrl/Printing/ScannedItemList?date=$date');

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    debugPrint(url.toString());
    // debugPrint(response.body);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => PrintingReportModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load report");
  }

  static Future<List<PrintingOutModel>> getPrintingOutList() async {
    final url = Uri.parse("$baseUrl/Printing/PrintingOutList");

    final response = await http.get(
      url,
      headers: await InStockService.authHeaders(),
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => PrintingOutModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load Printing Out List");
  }

  static Future<bool> savePrintOutstock(Map<String, dynamic> data) async {
    final url = Uri.parse('${baseUrl}/Printing/SavePrinting');

    try {
      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(data),
      );
      print("URL = $url");
      print("BODY = ${jsonEncode(data)}");
      print("STATUS Save Print: ${response.statusCode}");
      print("Save Print RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("API ERROR: $e");
      return false;
    }
  }

  static Future<List<PrintingSavedListModel>> getPrintingSavedList() async {
    final response = await http.get(
      Uri.parse("$baseUrl/Printing/SavedList"),
      headers: {
        "Content-Type": "application/json",
        ...await InStockService.authHeaders(),
      },
    );

    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return (jsonData["data"] as List)
          .map((e) => PrintingSavedListModel.fromJson(e))
          .toList();
    }

    throw Exception(response.body);
  }

  Future<Map<String, dynamic>?> getSlittingScannedItems({
    required String barcode,
    required String location,
    required String operator,
    required String supervisor,
    required String roll,
    required String plant,
    required String party,
    required String workorder,
  }) async {
    final url = Uri.parse('$baseUrl/Slitting/SlittingIn');

    final body = {
      "barcode": barcode,
      "location": location,
      "operator": operator,
      "supervisor": supervisor,
      "roll": roll,
      "plant": plant,
      "party": "",
      "workOrderNo": '',
    };

    debugPrint("URL : $url");
    debugPrint("BODY : ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        ...await InStockService.authHeaders(),
      },
      body: jsonEncode(body),
    );

    debugPrint("Status : ${response.statusCode}");
    debugPrint("Response : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {"status": "error", "message": response.body};
  }

  Future<List<dynamic>> SlittingScannedItemsDetails(String date) async {
    final url = '${InStockService.baseUrl}/Slitting/ScannedItems?date=$date';

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

  Future<int> getSlittingItemsCount(String date) async {
    final items = await SlittingScannedItemsDetails(date);
    return items.length;
  }

  Future<List<PrintingOutReportItem>> fetchPrintingOutReport({
    required DateTime fromDate,
    required DateTime toDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/Printing/Printoutreport').replace(
      queryParameters: {
        'fromDate': DateFormat('yyyy-MM-dd').format(fromDate),
        'toDate': DateFormat('yyyy-MM-dd').format(toDate),
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );
    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final model = PrintingOutReportModel.fromJson(jsonData);
      return model.data;
    } else {
      throw Exception(
        'Failed to load Printing Out Report: ${response.statusCode}\n${response.body}',
      );
    }
  }

  //   PrintINReport

  Future<PrintingInReportModel> fetchPrintingInReport({
    required String unit,
    required DateTime fromDate,
    required DateTime toDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/Printing/PrintINReport',
    ).replace(
      queryParameters: {
        'unit': unit,
        'fromDate': DateFormat('yyyy-MM-dd').format(fromDate),
        'toDate': DateFormat('yyyy-MM-dd').format(toDate),
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
    );


    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );
    print("Status Code : $uri}");

    print("Status Code : ${response.statusCode}");
    print("Printing In Report : ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final json = jsonDecode(response.body);

      return PrintingInReportModel.fromJson(json);
    } else {
      throw Exception(
        'Failed to load Printing Out Report: ${response.statusCode}\n${response.body}',
      );
    }
  }
}

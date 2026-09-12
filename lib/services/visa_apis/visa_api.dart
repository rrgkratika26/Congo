import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ScannedItem/Cutting/cutOutModelClass/ModelClassOutstock.dart';
import '../../ScannedItem/Cutting/cutOutModelClass/RemainingWeightModelClass.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/NewBarcode.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import '../../Visa/Loom/modelClass/FIBCmodel.dart';
import '../../Visa/Loom/modelClass/LoomMasterModel.dart';
import '../../Visa/Loom/modelClass/LoomSavedListModel.dart';
import '../../Visa/Loom/modelClass/LoomTypeModel.dart';
import '../getSupervisors/getSupervisors.dart';

class VisaApiService {
  // static const String baseUrlJBL = 'http://190.92.175.47:80/JblAPI/api';
  // static String baseUrlJBL = 'http://190.92.175.47:80/Visa/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/Innoweave/api';
  // static const String baseUrlJBL ='http://190.92.175.47:80/api/api';
  // static const String baseUrlJBL ='http://190.92.175.47/Qualipack/api';
  // static const String baseUrlJBL ='http://190.92.175.47/CONGO_API/api';
  static const String baseUrlJBL = 'http://192.168.29.123:7165/api';
  // static const String baseUrlJBL = 'http://190.92.175.47/VISA_S/api';


  // static const String baseUrlJBL = 'http://190.92.175.47/ShriShakti/api';

  // static const String baseUrlJBL ='http://192.168.29.39:44349/api/api';

  // static const String baseUrlJBL = 'http://190.92.175.47:80/Nardana/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/ASIA_API/api';

  static Future<List<LoomProcessModel>> getLoomProcess() async {
    try {
      final url = Uri.parse(
        '${baseUrlJBL}/Loom/GetLoomProcess',
      ); // replace base url

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      print('VISA URL....$url');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('VISA URL....$url');
        print('VISA URL....$data');
        return data.map((e) => LoomProcessModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load Loom Process");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  static Future<List<LoomTypeModel>> getLoomTypes() async {
    try {
      final url = Uri.parse('${baseUrlJBL}/Loom/GetLoomType/LoomNo?type=LOOM');

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => LoomTypeModel.fromJson(e)).toList();
      } else {
        // ✅ Return empty list instead of nothing
        return [];
      }
    } catch (e) {
      print("❌ API Error: $e");

      // ✅ Always return something
      return [];
    }
  }

  static Future<List<String>> getLoomNumbers({
    required String type,
    required String machine,
  }) async {
    final url =
        "${baseUrlJBL}/Loom/GetLoomType/LoomNo?type=$type&machine=$machine";

    final response = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e['value'].toString()).toList();
    } else {
      throw Exception("Failed to load loom numbers");
    }
  }

  static Future<Map<String, dynamic>> getLoomReading({
    required int loom,
    required String loomType,
  }) async {
    final url = "${baseUrlJBL}/Loom/GetReading?loom=$loom&loomType=$loomType";

    final response = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("RAW Reading API: $data"); // 👈 DEBUG

      return data; // ✅ RETURN MAP
    } else {
      throw Exception("Failed to load reading");
    }
  }

  static Future<List<LoomMasterModel>> getLoomMaster(String type) async {
    try {
      final url = Uri.parse('${baseUrlJBL}/Loom/GetLoomMaster?type=$type');

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print("RAW GetLoomMaster data///: $data"); // 👈 DEBUG

        return data.map((e) => LoomMasterModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ LoomMaster Error: $e");
      return [];
    }
  }

  static Future<String> saveLoomEntry(Map<String, dynamic> data) async {
    final url = Uri.parse('${baseUrlJBL}/Loom/SaveLoomEntry');

    try {
      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("RAW SaveLoomEntry data///: $res"); // 👈 DEBUG

        return res["message"] ?? "Success";
      } else {
        throw Exception("Failed to save data");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  static Future<String?> generateBatchNo({
    required String partyName,
    required String date,
    required String loomType,
    required String shift,
  }) async {
    final url = Uri.parse('${baseUrlJBL}/Loom/generateBatchNo');

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(await InStockService.authHeaders());
      print("STATUS batch url: $url");

      request.fields['partyName'] = partyName;
      request.fields['date'] = date;
      request.fields['loomType'] = loomType;
      request.fields['shift'] = shift;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      print("BODY: $resBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        return data['batchNo'];
      } else {
        throw Exception("API Error: $resBody");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> saveOutstock(Map<String, dynamic> data) async {
    final url = Uri.parse('${baseUrlJBL}/Lamination/save-outstock');

    try {
      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(data),
      );

      debugPrint("════════════════════════════════════");
      debugPrint("SAVE OUTSTOCK STATUS: ${response.statusCode}");
      debugPrint("SAVE OUTSTOCK RESPONSE:");
      debugPrint(response.body);
      debugPrint("════════════════════════════════════");

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

  static Future<List<LoomSavedModel>> getLoomSavedList() async {
    final url = Uri.parse('${baseUrlJBL}/Loom/loom-saved-list');

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List data = jsonData['data'];
          debugPrint('$data');
          return data.map((e) => LoomSavedModel.fromJson(e)).toList();
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  static Future<List<NewBarcodeModel>> getNewBarcodeList() async {
    final url = Uri.parse(
      '${baseUrlJBL}/Lamination/NewBarcodeList?department=LAMINATION',
    );

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      print("API New barcode: $url");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("API New barcode data: $data");
        if (data['status'] == "SUCCESS") {
          List list = data['data'];

          return list.map((e) => NewBarcodeModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("API Error: $e");
    }

    return [];
  }

  static Future<bool> issueBarcode({
    required String barcode,
    required String type, // LOOM / LAMINATION
  }) async {
    final endpoint = type == "LAMINATION"
        ? "/Lamination/issue"
        : "/Loom/IssueBarcode";

    final url = Uri.parse("$baseUrlJBL$endpoint");
    print('VISA URL....$url');
    try {
      final res = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode({
          "barcode": barcode,
          "issueToDept": "RMD",
          "plant": "FIBC",
        }),
      );

      final decoded = jsonDecode(res.body);
      print('New Barcode ....$decoded');
      if (decoded is Map<String, dynamic>) {
        return decoded["success"] == true;
      } else if (decoded is String) {
        return decoded.contains("Successfully");
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Issue API error: $e");
      return false;
    }
  }

  static Future<bool> lamination_issueBarcode({
    required String barcode,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrlJBL}/Lamination/issue"),
        headers: await InStockService.authHeaders(),
        body: jsonEncode({
          "barcode": barcode,
          "issueToDept": "RMD",
          "plant": "FIBC",
        }),
      );
      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);

        print("API RESPONSE: $resBody");

        // 🔥 CASE 1: response is String
        if (resBody is String) {
          return resBody.toLowerCase().contains("success");
        }

        // 🔥 CASE 2: response is Map
        if (resBody is Map) {
          return resBody["message"]?.toString().toLowerCase().contains(
                "success",
              ) ??
              true;
        }

        return true;
      } else {
        print("API ERROR: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Issue API error: $e");
      return false;
    }
  }

  static Future<List<CuttingOutstock>> fetchOutStockList({
    required String plant,
    int page = 1,
    int pageSize = 50,
  }) async {
    final uri = Uri.parse(
      "$baseUrlJBL/Cutting/OutStockList?plant=$plant&page=$page&pageSize=$pageSize",
    );

    print("👉 API CALL: $uri");

    final response = await http.get(
      uri,
      headers: await InStockService.authHeaders(),
    );

    print("👉 STATUS: ${response.statusCode}");
    print("👉 BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);

      return jsonList.map((e) => CuttingOutstock.fromJson(e)).toList();
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }

  /// Fetch BOM numbers and components for Cutting
  static Future<Map<String, List<String>>> getBomAndComponents({
    required String po,
    required String article,
  }) async {
    final uri = Uri.parse(
      "$baseUrlJBL/Cutting/GetBomAndComponents?po=$po&article=$article",
    );

    try {
      final response = await http.get(
        uri,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Get Bom and component $uri");
        print('$data');
        // Extract boprint mNumbers and components as List<String>
        final List<String> bomNumbers = (data['bomNumbers'] as List)
            .map((e) => e.toString())
            .toList();

        final List<String> components = (data['components'] as List)
            .map((e) => e.toString())
            .toList();

        return {"bomNumbers": bomNumbers, "components": components};
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[API ERROR] $e");
      rethrow;
    }
  }

  Future<String?> getArticleNo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrlJBL}/Cutting/GetArticleNo?id=$id'),
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('$data');
        return data['articleNo']; // ✅ fetch article number
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCutSize({
    required String woNumber,
    required String component,
  }) async {
    try {
      final uri = Uri.parse("${baseUrlJBL}/Cutting/GetCutSize").replace(
        queryParameters: {
          "woNumber": woNumber, // ✅ auto encode करेगा (# → %23)
          "component": component,
        },
      );

      print("API URL 👉 $uri");

      final response = await http.get(
        uri,
        headers: await InStockService.authHeaders(),
      );

      debugPrint("✅ CutSize Status: ${response.statusCode}");
      debugPrint("✅ CutSize Body: ${response.body}"); // ← YE DEKHO

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error in getCutSize: $e");
      return null;
    }
  }

  static Future<List<String>> getGsmOrFabricWidth({
    required String type,
  }) async {
    try {
      final url = "${baseUrlJBL}/Cutting/GetGsmOrFabricWidth?type=$type";

      print("API URL 👉 $url"); // ✅ print URL

      final response = await http.get(
        Uri.parse(url),
        headers: await InStockService.authHeaders(),
      );

      // print("Status Code 👉 ${response.statusCode}");
      // print("Response Body 👉 ${response.body}"); // ✅ print response

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error in getGsmOrFabricWidth 👉 $e");
      return [];
    }
  }

  static Future<RemainingWeightModel?> getRemainingWeight({
    required dynamic code,
    required int rollWeight,
  }) async {
    try {
      // ✅ FORCE INT
      final int parsedCode = int.tryParse(code.toString()) ?? 0;

      final url =
          "${baseUrlJBL}/Cutting/GetRemainingWeight?code=$code&rollWeight=$rollWeight";

      print("API URL 👉 $url");

      final response = await http.get(
        Uri.parse(url),
        headers: await InStockService.authHeaders(), // ✅ same as your first API
      );

      print("Status Code 👉 ${response.statusCode}");
      print("Response Body 👉 ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // ✅ FIX
        return RemainingWeightModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Error in getRemainingWeight 👉 $e");
      return null;
    }
  }

  static Future<String> saveOutStock(Map<String, dynamic> payload) async {
    try {
      final url = "${baseUrlJBL}/Cutting/SaveOutStock";

      print("POST URL 👉 $url");
      print("PAYLOAD 👉 $payload");

      final response = await http.post(
        Uri.parse(url),
        headers: await InStockService.authHeaders(),
        body: jsonEncode(payload),
      );

      print("STATUS 👉 ${response.statusCode}");
      print("BODY 👉 ${response.body}");

      if (response.statusCode == 200) {
        return "SUCCESS";
      } else {
        return "FAILED: ${response.body}";
      }
    } catch (e) {
      return "ERROR: $e";
    }
  }
  static Future<String> finishLamination(List rolls) async {
    try {
      final url = "$baseUrlJBL/Lamination/RollFinish";

      final roll = rolls.first;

      final body = {
        "rollId": roll.id,
        "rollCode": roll.rollCode,
      };

      print("POST URL => $url");
      print("BODY => ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(url),
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      print("STATUS => ${response.statusCode}");
      print("RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res is String) {
          return res; // Roll Finished Successfully
        }

        if (res is Map<String, dynamic>) {
          return res["message"]?.toString() ?? "SUCCESS";
        }

        return "SUCCESS";
      }

      return "FAILED: ${response.body}";
    } catch (e) {
      return "ERROR: $e";
    }
  }
  // static Future<String> finishLamination(List<String> ids) async {
  //   try {
  //     final url = "$baseUrlJBL/Lamination/RollFinish";
  //
  //     // Build array body with isChecked + id
  //     final body = ids.map((id) => {"isChecked": false, "id": id}).toList();
  //
  //     print("POST URL 👉 $url");
  //     print("BODY 👉 $body");
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: await InStockService.authHeaders(),
  //         // ..addAll({"Content-Type": "application/json"}), // ensure JSON header
  //       body: jsonEncode(body),
  //     );
  //
  //     print("STATUS 👉 ${response.statusCode}");
  //     print("RESPONSE 👉 ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final res = jsonDecode(response.body);
  //       return res['message'] ?? "SUCCESS";
  //     } else {
  //       return "FAILED: ${response.body}";
  //     }
  //   } catch (e) {
  //     return "ERROR: $e";
  //   }
  // }

  static Future<List<CuttingOutstock>> fetchOutStockListPaged({
    required String plant,
    required int page,
    required int pageSize,
  }) async {
    final url =
        "$baseUrlJBL/Cutting/OutStockList?plant=$plant&page=$page&pageSize=$pageSize";
    final response = await http.get(
      Uri.parse(url),
      headers: await InStockService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CuttingOutstock.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load OutStock list");
    }
  }



}

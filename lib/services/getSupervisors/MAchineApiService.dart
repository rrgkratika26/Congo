import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../screen/MachineDepartment/ModelClass.dart';

class MachineApiService {
  static const String baseUrl =
      "https://fibcsoftware.in:4430/api/api/Machine/machines";

  static Future<List<MachineModel>> fetchMachines() async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri);

      // debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // debugPrint("Status Response: ${response.body}");

        final List dataList = decoded["data"];

        // 🔥 Convert to Model List HERE
        return dataList.map((json) => MachineModel.fromJson(json)).toList();
      } else {
        debugPrint("Error: ${response.reasonPhrase}");
        return [];
      }
    } catch (e) {
      debugPrint("API Exception: $e");
      return [];
    }
  }


  static Future<Map<String, dynamic>?> fetchMachineById(
      String machineId) async {
    final url =
    Uri.parse("$baseUrl/Machine/machineById?machineId=$machineId");

    print("MachineById URL: $url");

    final response = await http.get(url);

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getMachineRepairs(int machineId) async {
    final url = Uri.parse(
      "https://fibcsoftware.in:4430/api/api/Machine/repairs?machineId=$machineId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint("Machine Repair List::::::$response");
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load repairs");
    }
  }


  static Future<Map<String, dynamic>> insertFault({
    required String machineId,
    required int faultId,
    required String referenceNo,
    required String status,
    required int createdBy,
    required int updatedBy,
    required String createdDate,
    required String updatedDate,
    required int quantity,
    required String description,
    required String imagePath,
  }) async {
    try {
      final url = Uri.parse(
        "https://fibcsoftware.in:4430/api/api/Machine/InsertFaults",
      ); // 🔥 confirm endpoint

      final body = {
        "machineId": machineId,
        "faultId": faultId,
        "referenceNo": referenceNo,
        "status": status,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdDate": createdDate,
        "updatedDate": updatedDate,
        "quantity": quantity,
        "description": description,
        "imagePath": imagePath,
      };

      debugPrint("Insert Fault Payload: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("Insert Fault Status Code: ${response.statusCode}");
      debugPrint("Insert Fault Response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Insert Fault Exception: $e");
      return {"success": false, "message": "Something went wrong"};
    }
  }
}

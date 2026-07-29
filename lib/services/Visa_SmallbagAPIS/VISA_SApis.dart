import 'dart:convert';

import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
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

class VisaSmallBagApiService {
  // static const String baseUrlJBL = 'http://190.92.175.47:80/JblAPI/api';
  // static String baseUrlJBL = 'http://190.92.175.47:80/Visa/api';
  // static const String baseUrlJBL = 'http://190.92.175.47:80/Innoweave/api';
  // static const String baseUrlJBL ='http://190.92.175.47:80/api/api';
  // static const String baseUrlJBL ='http://190.92.175.47/Qualipack/api';
  // static const String baseUrlJBL ='http://190.92.175.47/CONGO_API/api';
  // static const String baseUrlJBL = 'http://192.168.29.125:7165/api';
  static const String baseUrl = 'http://190.92.175.47/VISA_S/api';

  // static const String baseUrlJBL = 'http://190.92.175.47/ShriShakti/api';

  // static const String baseUrlJBL ='http://192.168.29.39:44349/api/api';

  // static const String baseUrlJBL = 'http://190.92.175.47:80/Nardana/api';
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
    final url = Uri.parse(
        "$baseUrl/Printing/ScanBarcode");

    final body = {
      "barcode": barcode,
      "location": location,
      "operator": operator,
      "supervisor": supervisor,
      "department": department,
      "plant": plant,
    };

    debugPrint(url.toString());
    debugPrint(jsonEncode(body));

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        ...await InStockService.authHeaders(),
      },
      body: jsonEncode(body),
    );

    debugPrint("Status : ${response.statusCode}");
    debugPrint(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      "status": "error",
      "message": response.body,
    };
  }


  Future<List<dynamic>> getPrintScannedItems() async {
    final url = Uri.parse('$baseUrl/Printing/ScanBarcode');

    final response = await http.get(url, headers: await InStockService.authHeaders(),);
    debugPrint("API URL: $url");
    debugPrint("Print Status ${response.statusCode}");
    debugPrint("GET SCANNED Print RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load scanned items');
    }
  }

  Future<int> getPrintScannedItemsCount() async {
    final items = await getPrintScannedItems();
    return items.length;
  }


}

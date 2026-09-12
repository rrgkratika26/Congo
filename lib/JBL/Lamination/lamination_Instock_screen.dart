import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../JBL_RMD/screens/JBL_ReportDetailScreen.dart';
import 'jbl_LaminationQrScann.dart';
import 'LaminationJbl_controller.dart';

class LaminationInStockScreen extends StatefulWidget {
  const LaminationInStockScreen({Key? key}) : super(key: key);

  @override
  State<LaminationInStockScreen> createState() =>
      _LaminationInStockScreenState();
}

class _LaminationInStockScreenState extends State<LaminationInStockScreen> {
  final controller = JBl_laminationController();

  String department = 'LAMINATION';
  String unitTitle = '';
  int totalScanned = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.loadInitialData().then((_) {
      setState(() {});
      _loadScannedData(); // ✅ ADD THIS
    });
    _loadUnit().then((_) {
      _loadScannedData(); // ✅ ALSO HERE (important for plant)
    });
  }

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  Future<void> _loadScannedData() async {
    if (!controller.isFormValid()) return;

    setState(() => isLoading = true);

    // final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final date = JblApiService.getApiDate();
    final plant = unitTitle;

    debugPrint("📅 DATE: $date");
    debugPrint("🏭 PLANT: $plant");

    final items = await JblApiService().get_jblLaminationScannedItems(
      date,
      plant,
    );

    debugPrint("📦 FULL API RESPONSE: $items");
    debugPrint("🔢 TOTAL COUNT: ${items.length}");

    setState(() {
      totalScanned = items.length;
      isLoading = false;
    });
  }

  // ===================== API CALL =====================
  Future<void> submitBarcode({
    required String barcode,
    required String operator,
    required String supervisor,
    required String location,
    required String department,
  }) async {
    try {
      final cleanBarcode = barcode.trim();

      if (cleanBarcode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Barcode cannot be empty"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint("================================");
      debugPrint("📦 BARCODE: [$cleanBarcode]");
      debugPrint("👤 OPERATOR: $operator");
      debugPrint("👨‍💼 SUPERVISOR: $supervisor");
      debugPrint("📍 LOCATION: $location");
      debugPrint("🏭 PLANT: $location");
      debugPrint("🏢 DEPARTMENT: $department");
      debugPrint("================================");

      final url = Uri.parse(
        "${JblApiService.baseUrlJBL}/Lamination/SubmitBarcode",
      );

      final body = {
        "barcode": cleanBarcode,
        "rollEntry": "LAMINATION",
        "operator": operator,
        "supervisor": supervisor,
        "department": department,
        "location": location,
        "plant": location,
      };

      debugPrint("📡 URL: $url");
      debugPrint("📡 REQUEST: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      debugPrint("📡 STATUS CODE: ${response.statusCode}");
      debugPrint("📡 RESPONSE BODY: ${response.body}");

      dynamic res;

      try {
        res = jsonDecode(response.body);
      } catch (e) {
        debugPrint("❌ JSON ERROR: $e");

        res = {
          "status": false,
          "message": "Invalid server response",
        };
      }

      final bool isSuccess =
          response.statusCode == 200 &&
              (res["status"] == true ||
                  res["status"] == "ok");

      final String message =
          res["message"]?.toString() ??
              "No message from server";

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess
              ? Colors.green
              : Colors.red,
        ),
      );

      if (isSuccess) {
        await _loadScannedData();
      }
    } catch (e, stackTrace) {
      debugPrint("❌ API ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ===================== OPEN SCANNER =====================
  Future<void> _openScanner() async {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JBl_laminationQrScanScreen(
          operator: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: 'L-1',
          department: department,
          plant: unitTitle,
          onSubmitBarcode: (barcode) async {
            await submitBarcode(
              barcode: barcode,
              operator: controller.selectedOperator!,
              supervisor: controller.selectedSupervisor!,
              location: unitTitle,
              department: department,
            );
          },
        ),
      ),
    );

    await _loadScannedData();
  }

  // ===================== MANUAL ENTRY =====================
  void _manualEntry() {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Manual Entry"),
        content: TextField(
          textCapitalization: TextCapitalization.characters,
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Enter Barcode"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final barcode = ctrl.text.trim();
              Navigator.pop(context);

              if (barcode.isEmpty) return;

              await submitBarcode(
                barcode: barcode,
                operator: controller.selectedOperator!,
                supervisor: controller.selectedSupervisor!,
                location: unitTitle,
                department: department,
              );

              await _loadScannedData();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showValidationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            children: [
              _dropdown(
                "Select Supervisor",
                controller.supervisors,
                controller.selectedSupervisor,
                (v) {
                  setState(() => controller.selectedSupervisor = v);
                  _loadScannedData();
                },
                Icons.supervisor_account,
              ),
              const SizedBox(height: 12),
              _dropdown(
                "Select Operator",
                controller.operators,
                controller.selectedOperator,
                (v) {
                  setState(() => controller.selectedOperator = v);
                  _loadScannedData();
                },
                Icons.person,
              ),
              const SizedBox(height: 12),
              _locationBox(),
              const SizedBox(height: 12),
              _departmentBox(),
              const SizedBox(height: 20),
              _scanCard(),
              const SizedBox(height: 20),
              _buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(icon, color: C.warning),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label),
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationBox() => Container(
    decoration: _box(),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.location_on, color: C.warning),
        const SizedBox(width: 10),
        Text('L-1', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _departmentBox() => Container(
    decoration: _box(),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.business, color: C.warning),
        const SizedBox(width: 10),
        Text(department, style: const TextStyle(color:C.textMid,fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _scanCard() => InkWell(
    onTap: _openReportDetail, // ✅ new function
    child: Container(
      decoration: _box(),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Text("Total Items Scanned", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,)),
          const SizedBox(height: 8),
          // isLoading
          // ? const CircularProgressIndicator()
          // :
          Text(
            "$totalScanned",
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(DateTime.now().toString().split(' ')[0]),
        ],
      ),
    ),
  );

  Widget _buttons() => Row(
    children: [
      Expanded(
        child: _btn(
          "Scan QR",
          Icons.qr_code_scanner,
          Colors.blue,
          _openScanner,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _btn("Manual Entry", Icons.edit, Colors.green, _manualEntry),
      ),
    ],
  );

  Future<void> _openReportDetail() async {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    setState(() => isLoading = true);

    try {
      // final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final date = JblApiService.getApiDate();
      final plant = unitTitle;

      debugPrint("📅 REPORT DATE: $date");
      debugPrint("🏭 REPORT PLANT: $plant");

      final scannedItems = await JblApiService().get_jblLaminationScannedItems(
        date,
        plant,
      );

      debugPrint("📊 REPORT DATA: $scannedItems");
      setState(() => isLoading = false);
      // ✅ ALWAYS navigate (even if empty)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Jbl_ReportDetailScreen(
            title: "Lamination InStock",
            date: date,
            data: scannedItems,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ REPORT ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch report"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _btn(String title, IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: _box(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
    ],
  );
}

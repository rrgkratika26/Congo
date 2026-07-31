import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../ScannedItem/Webbing/ReportmodelClass/ReportModelClass.dart';
import '../../ScannedItem/Webbing/WebbingController.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../app_colors.dart';
import 'QRScanScreen.dart';
import 'WebbingStockListScreen.dart';

class JblWebbingStockIn extends StatefulWidget {
  final String screenType;
  const JblWebbingStockIn({Key? key, required this.screenType})
    : super(key: key);

  @override
  State<JblWebbingStockIn> createState() => _JblWebbingStockInState();
}

class _JblWebbingStockInState extends State<JblWebbingStockIn> {
  late InStockWebController controller;
  late Future<void> _dropdownFuture;
  String? loginUnit;

  List<Map<String, dynamic>> stockList = [];
  bool isStockLoading = false;
  String department = "WEBBING_STOCK_IN";

  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();

    controller = InStockWebController();

    _dropdownFuture = _initData();


  }


  Future<void> _initData() async {
    await controller.loadWebInitialData();

    loginUnit = await AppSession.getUnit();
    controller.selectedLocation = loginUnit;

    await loadStockData(); // ✅ only call once
  }

  Future<void> loadStockData() async {
    setState(() => isStockLoading = true);

    try {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final result = await JblApiService.getWebbingInStock(
        date: today,
        unit: controller.selectedLocation ?? "JBL",
      );

      print("🟢 COUNT → ${result.length}");
      print("🟢 DATA → $result");

      if (!mounted) return;

      setState(() {
        stockList = result;
        isStockLoading = false;
      });
    } catch (e, stackTrace) {
      print("❌ ERROR → $e");
      print("📍 TRACE → $stackTrace");

      if (!mounted) return;

      setState(() => isStockLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Future<void> _checkBarcodeApi(String barcode) async {
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Barcode cannot be empty")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: C.appBar3,)),
    );

    try {
      final response = await JblApiService.jblWebbcheckBarcode(
        barcode: barcode,
        plant: controller.selectedLocation ?? "",

        supervisor: controller.selectedSupervisor ?? "",
        operator: controller.selectedOperator ?? "",

        location: controller.selectedLocation ?? "",
        status: 'OUT-IN',
      );

      if (mounted) Navigator.pop(context);

      if (response != null && response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Stock In Successful ✅"),
            backgroundColor: Colors.green,
          ),
        );

        await loadStockData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?["message"] ?? "Invalid barcode"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Webbing InStock",
          style: TextStyle(color: C.bg),
        ),
        iconTheme: IconThemeData(color: C.bg),
        centerTitle: true,
        backgroundColor: C.primaryColor, // Light Blue
      ),

      body: FutureBuilder(
        future: _dropdownFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: C.appBar3,));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDropdown(
                  label: "Choose Supervisor",
                  value: controller.selectedSupervisor,
                  items: controller.supervisors,
                  icon: Icons.supervisor_account,
                  onChanged: (val) =>
                      setState(() => controller.selectedSupervisor = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: "Choose Operator",
                  value: controller.selectedOperator,
                  items: controller.operators,
                  icon: Icons.person,
                  onChanged: (val) =>
                      setState(() => controller.selectedOperator = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: "Storage Location",
                  value: controller.selectedLocation,
                  items: loginUnit != null ? [loginUnit!] : [],
                  icon: Icons.location_on,
                  onChanged: null, // disables dropdown
                ),

                const SizedBox(height: 20),
                _buildButtons(),
                const SizedBox(height: 20),
                _buildTotalCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.qr_code_scanner,
            label: "Scan QR",
            color: Colors.blue,
            onTap: _openScanner,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.edit,
            label: "Manual Entry",
            color: Colors.green,
            onTap: _manualEntry,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,

    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
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

  Widget _buildTotalCard() {
    return InkWell(
      onTap: () {
        if (stockList.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebbingStockListScreen(data: stockList),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _boxDecoration(borderRadius: 20),
        child: isStockLoading
            ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
            : Column(
          children: [
            const Text(
              "Total Stock In Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${stockList.isNotEmpty ? stockList.length : 0}",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              getCurrentDate(),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: _boxDecoration(borderRadius: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  void _openScanner() async {
    if (!controller.isFormValid()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QRWebbingScanScreen(
          operatorName: controller.selectedOperator ?? "",
          supervisor: controller.selectedSupervisor ?? "",
          location: controller.selectedLocation ?? "",
          department: department,
        ),
      ),
    );

    if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
      _checkBarcodeApi(scannedBarcode);
    }
  }

  void _manualEntry() {
    if (!controller.isFormValid()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Barcode"),
        content: TextField(
          controller: barcodeController,
          textCapitalization: TextCapitalization.characters,

          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter barcode number"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              final barcode = barcodeController.text.trim();

              Navigator.pop(context);

              if (barcode.isNotEmpty) {
                _checkBarcodeApi(barcode);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ================= STYLING =================

  BoxDecoration _boxDecoration({double borderRadius = 12}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF64B5F6).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF42A5F5)),
    );
  }
}

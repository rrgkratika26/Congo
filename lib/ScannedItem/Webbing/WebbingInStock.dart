import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../screen/inStock/ReportScreen.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'ReportmodelClass/ReportModelClass.dart';
import 'StockDetailsScreen.dart';
import 'WebbingBarcode.dart';
import 'WebbingController.dart';

class WebbingInStock extends StatefulWidget {
  const WebbingInStock({Key? key}) : super(key: key);

  @override
  State<WebbingInStock> createState() => _WebbingInStockState();
}

class _WebbingInStockState extends State<WebbingInStock> {
  // final controller = InStockWebController();
  late InStockWebController controller;
  late Future<void> _dropdownFuture;
  String _unitTitle = '';
  String department = 'WEBBING';
  int totalScanned = 0;
  Future<WebbingReportModel?>? _reportFuture;
  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    controller = InStockWebController();
    _dropdownFuture = controller.loadWebInitialData();
    _reportFuture = InStockService.fetchWebbingScannedItems();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  Future<void> _checkBarcodeApi(String barcode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Debug print parameters
      print("======= CHECK BARCODE API PARAMS =======");
      print("barcode: $barcode");
      print("plant:${AppSession.unit} ");
      print("department: $department");
      print("supervisor: ${controller.selectedSupervisor}");
      print("operator: ${controller.selectedOperator}");
      print("rollEntry: ROLL_ENTRY_1");
      print("location: ${controller.selectedLocation}");
      print("========================================");
      final response = await InStockService().checkWebbBarcode(
        barcode: barcode,
        plant: AppGlobals.unit,
        department: department,
        supervisor: controller.selectedSupervisor!,
        operator: controller.selectedOperator!,
        rollEntry: "ROLL_ENTRY_1",
        location: controller.selectedLocation!,
      );

      Navigator.pop(context); // remove loader

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: C.success,
            content: Text(response["message"]),
          ),
        );

        setState(() {
          totalScanned++;
          _reportFuture = InStockService.fetchWebbingScannedItems();
        });
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${_unitTitle.isNotEmpty ? _unitTitle : 'Unit'} WEBBING",
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder(
        future: _dropdownFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                  label: "Choose Supervisor",
                  value: controller.selectedSupervisor,
                  items: controller.supervisors,
                  icon: Icons.supervisor_account,
                  onChanged: (val) =>
                      setState(() => controller.selectedSupervisor = val),
                ),

                const SizedBox(height: 12),

                _buildDropdown(
                  label: "Choose Storage Location",
                  value: controller.locations.contains(controller.selectedLocation)
                      ? controller.selectedLocation
                      : null,
                  items: controller.locations.toSet().toList(),
                  icon: Icons.location_on,
                  onChanged: (val) {
                    setState(() {
                      controller.selectedLocation = val;
                    });
                  },
                ),
                const SizedBox(height: 12),

                _buildDepartmentCard(),
                const SizedBox(height: 24),

                _buildTotalCard(),
                const SizedBox(height: 20),

                _buildButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

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

  // ================= UI Widgets =================

  Widget _buildDropdown({
    required String label,
    // required String value,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _iconBox(icon),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _labelStyle()),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value, // null initially
                      hint: Text(
                        'Select an option',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      isExpanded: true,
                      items: items
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          _iconBox(Icons.business),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DEPARTMENT",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              Text(
                department,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebbingInStockDetailScreen(date: getApiDate()),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _boxDecoration(borderRadius: 20),
        child: FutureBuilder<WebbingReportModel?>(
          // future: InStockService.fetchWebbingScannedItems(),
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [
                  Text(
                    "Total Webbing Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "...",
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Column(
                children: [
                  Text(
                    "Total Webbing Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "0",
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }

            final count = snapshot.data!.data.length;

            return Column(
              children: [
                const Text(
                  "Total Webbing Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getCurrentDate(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            );
          },
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
    print("Operator: ${controller.selectedOperator}");
    print("Supervisor: ${controller.selectedSupervisor}");
    print("Location: ${controller.selectedLocation}");

    if (!controller.isFormValid()) {
      print("Form not valid triggered");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    print("Form valid — opening scanner");

    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => WebbingScanScreen(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: controller.selectedLocation!,
          department: department,
          scanType: ScanType.inStock,
        ),
      ),
    );

    if (scannedBarcode == null) return;

    _checkBarcodeApi(scannedBarcode);
  }

  void _manualEntry() {
    if (!controller.isFormValid()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final TextEditingController barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Barcode"),
        content: TextField(
          controller: barcodeController,
          textCapitalization: TextCapitalization.characters,

          decoration: const InputDecoration(hintText: "Enter barcode number"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkBarcodeApi(barcodeController.text.trim());
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
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.orange),
    );
  }

  TextStyle _labelStyle() {
    return TextStyle(
      fontSize: 10,
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }
}

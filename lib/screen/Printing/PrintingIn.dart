import 'dart:convert';

import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../screen/inStock/ReportScreen.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/Visa_SmallbagAPIS/VISA_SApis.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'PrintScanQr.dart';
import 'PrintingInStockDetail.dart';

class PrintingInStockScreen extends StatefulWidget {
  const PrintingInStockScreen({Key? key}) : super(key: key);

  @override
  State<PrintingInStockScreen> createState() => _PrintingInStockScreenState();
}

class _PrintingInStockScreenState extends State<PrintingInStockScreen> {
  String? selectedOperator;
  String? selectedSupervisor;
  final controller = InStockController();
  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String? selectedLocation;
  String department = 'PRINTING';
  int totalScanned = 0;
  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  final List<String> operators = [];
  List<String> supervisors = [];
  bool isLoadingSupervisors = false;
  String unitName = '';
  final List<String> locations = [];

  // ================= VALIDATION =================

  void _showValidationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all required fields before scanning QR'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    unitName = prefs.getString('unit') ?? 'UNIT';

    try {
      final api = VisaSmallBagApiService();

      /// Locations
      controller.locations.clear();
      controller.locations.addAll(await api.getPrintingLocations());

      /// Operators & Supervisors
      final data = await api.getPrintingSpAndOpName();

      controller.operators.clear();
      controller.supervisors.clear();

      controller.operators.addAll(List<String>.from(data["operators"] ?? []));

      controller.supervisors.addAll(
        List<String>.from(data["supervisors"] ?? []),
      );
      setState(() {});

      await _loadTotalScanned();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: C.primaryblue, // or Colors.blue
        foregroundColor: Colors.white,
        title: const Text('Printing In', style: TextStyle(fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 12 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Choose an Operator',
                  value: controller.selectedOperator,
                  items: controller.operators,
                  icon: Icons.person,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedOperator = value;
                    });
                  },
                  isTablet: isTablet,
                  isSmallScreen: isSmallScreen,
                ),

                SizedBox(height: isTablet ? 12 : 10),

                _buildDropdown(
                  label: 'Choose a Supervisor',
                  value: controller.selectedSupervisor,
                  items: controller.supervisors,
                  icon: Icons.supervisor_account,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedSupervisor = value;
                    });
                  },
                  isTablet: isTablet,
                  isSmallScreen: isSmallScreen,
                ),

                SizedBox(height: isTablet ? 12 : 10),

                _buildDropdown(
                  label: 'Choose Storage Location',
                  value: controller.selectedLocation,
                  items: controller.locations,
                  icon: Icons.location_on,
                  isTablet: isTablet,
                  isSmallScreen: isSmallScreen,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedLocation = value;
                    });
                  },
                ),

                SizedBox(height: isTablet ? 16 : 12),

                _buildDepartmentField(isTablet, isSmallScreen),

                SizedBox(height: isTablet ? 20 : 18),

                _buildScanningCard(isTablet, isSmallScreen),

                SizedBox(height: isTablet ? 20 : 18),

                _buildActionButtons(isTablet, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _buildDropdown({
    required String label,
    // required String value,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 12,
          vertical: isSmallScreen ? 5 : 8,
        ),
        child: Row(
          children: [
            _iconBox(icon),
            SizedBox(width: isSmallScreen ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _labelStyle(isTablet, isSmallScreen)),
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

  Widget _buildDepartmentField(bool isTablet, bool isSmallScreen) {
    return Container(
      decoration: _boxDecoration(),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 16,
        vertical: isSmallScreen ? 10 : 16,
      ),
      child: Row(
        children: [
          _iconBox(Icons.business),
          SizedBox(width: isSmallScreen ? 5 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DEPARTMENT', style: _labelStyle(isTablet, isSmallScreen)),
              const SizedBox(height: 2),
              Text(
                department,
                style: TextStyle(
                  fontSize: isTablet ? 16 : (isSmallScreen ? 13 : 15),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanningCard(bool isTablet, bool isSmallScreen) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PrintingInDetailScreen(date: getApiDate(), plant: unitName),
            ),
          );
        },
        child: Container(
          decoration: _boxDecoration(borderRadius: 20),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                "Total Items Scanned",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "$totalScanned",
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
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            color: C.purple,
            onTap: _openScanner,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_note,
            label: 'Manual Entry',
            color: Colors.green,
            onTap: () => _showWithoutScanDialog(isSmallScreen),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
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

  // Future<void> _openScanner() async {
  //   if (controller.isFormValid()) {
  //     _showValidationSnackBar();
  //     return;
  //   }
  //
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => QRPrintingScanInScreen(
  //         operatorName: controller.selectedOperator!,
  //         supervisor: controller.selectedSupervisor!,
  //         location: controller.selectedLocation!,
  //         department: department,
  //         plant: unitName,
  //       ),
  //     ),
  //   );
  //
  //   if (result != null) {
  //     setState(() {
  //       totalScanned++;
  //     });
  //   }
  // }
  Future _openScanner() async {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRPrintingScanInScreen(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: controller.selectedLocation!,
          department: department,
          plant: unitName,
        ),
      ),
    );

    print("Returned Result: $result");

    if (result != null) {
      await Future.delayed(const Duration(seconds: 1));
      await _loadTotalScanned();
    }
  }
  Future<void> _loadTotalScanned() async {
    try {
      final data =
      await VisaSmallBagApiService().getPrintingReport(getApiDate());

      if (!mounted) return;

      setState(() {
        totalScanned = data.length;
      });
    } catch (e) {
      debugPrint("Count Error: $e");
    }
  }
  void _showWithoutScanDialog(bool isSmallScreen) {
    final barcodeController = TextEditingController();

    if (controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manual Entry'),
        content: TextField(
          controller: barcodeController,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(labelText: 'Enter Barcode'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            child: const Text('Submit', style: TextStyle(color: Colors.green)),
            onPressed: () async {
              final barcode = barcodeController.text.trim().toUpperCase();

              if (barcode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter barcode"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context); // Close dialog

              final result = await VisaSmallBagApiService().printingScanIn(
                barcode: barcode,
                location: controller.selectedLocation!,
                operator: controller.selectedOperator!,
                supervisor: controller.selectedSupervisor!,
                department: department,
                plant: unitName,
              );

              if (result == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Server not responding"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final status = (result["status"] ?? "").toString().toLowerCase();
              final message = result["message"] ?? "";

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: status == "ok" ? Colors.green : Colors.red,
                ),
              );

              if (status == "ok") {


                if (!mounted) return;

                await Future.delayed(const Duration(seconds: 1));
                await _loadTotalScanned();
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: C.primaryblue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: C.primaryLight),
    );
  }

  TextStyle _labelStyle(bool isTablet, bool isSmallScreen) {
    return TextStyle(
      fontSize: isTablet ? 12 : (isSmallScreen ? 8 : 11),
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }
}

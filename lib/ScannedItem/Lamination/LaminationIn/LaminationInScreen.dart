import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../Color/Colorclass.dart';
import '../../../QRScan/QrScanScreen.dart';
import '../../../screen/inStock/ReportScreen.dart';
import '../../../screen/inStock/inStockController.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/sharedpreference/shared_preference.dart';
import 'LainationQrScan.dart';
import 'LaminationController.dart';
import 'LaminationDetailReportScreen.dart';

class LaminationInStockScreen extends StatefulWidget {
  const LaminationInStockScreen({Key? key}) : super(key: key);

  @override
  State<LaminationInStockScreen> createState() =>
      _LaminationInStockScreenState();
}

class _LaminationInStockScreenState extends State<LaminationInStockScreen> {
  String? selectedOperator;
  String? selectedSupervisor;
  final controller = Laminationcontroller();
  // String plant= "INNOWEAVE";
  String? plant;
  int totalScanned = 0;
  bool isLoadingCount = true;
  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String? selectedLocation;
  String department = 'LAMINATION';

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";
  }

  final List<String> operators = [];
  List<String> supervisors = [];
  bool isLoadingSupervisors = false;

  final List<String> locations = [];

  // ================= VALIDATION =================

  bool _isFormValid() {
    return selectedOperator!.isNotEmpty &&
        selectedSupervisor!.isNotEmpty &&
        selectedLocation!.isNotEmpty;
  }

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
    _loadPlant();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshCount();
  }
  Future<void> _loadPlant() async {
    plant = await AppSession.getUnit();

    if (plant == null) {
      debugPrint("Plant not found in session");
      return;
    }

    await refreshCount();

    setState(() {});
  }

  Future<void> _loadData() async {
    await controller.loadInitialData();
    setState(() {});
  }

  Future<void> refreshCount() async {
    if (plant == null) return;

    setState(() {
      isLoadingCount = true;
    });

    try {
      final apiCount = await InStockService().getLaminationScannedItemsCount(
        getApiDate(),
        plant!,
      );

      setState(() {
        totalScanned = apiCount;
        isLoadingCount = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCount = false;
      });

      debugPrint("Refresh Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallScreen = size.width < 360;

    return SingleChildScrollView(
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
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              onChanged: (value) =>
                  setState(() => controller.selectedOperator = value),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            _buildDropdown(
              label: 'Choose a Supervisor',
              value: controller.selectedSupervisor,
              items: controller.supervisors,
              icon: Icons.supervisor_account,
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              onChanged: (value) =>
                  setState(() => controller.selectedSupervisor = value),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            _buildDropdown(
              label: 'Choose Location',
              value: controller.selectedLocation,

              items: controller.locations,

              icon: Icons.location_on,
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              onChanged: (value) =>
                  setState(() => controller.selectedLocation = value!),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            _buildDepartmentField(isTablet, isSmallScreen),
            SizedBox(height: isTablet ? 32 : 24),

            _buildScanningCard(isTablet, isSmallScreen),
            SizedBox(height: isTablet ? 24 : 20),

            _buildActionButtons(isTablet, isSmallScreen),
          ],
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
          horizontal: isSmallScreen ? 12 : 12,
          vertical: isSmallScreen ? 8 : 8,
        ),
        child: Row(
          children: [
            _iconBox(icon),
            SizedBox(width: isSmallScreen ? 12 : 16),
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
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 12 : 16,
      ),
      child: Row(
        children: [
          _iconBox(Icons.business),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DEPARTMENT', style: _labelStyle(isTablet, isSmallScreen)),
              const SizedBox(height: 4),
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => ReportDetailScreen(date: getApiDate())),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LaminationDetailScreen(
              date: getApiDate(),
              plant: plant!,
              // plant: 'INNOWEAVE',
            ),
          ),
        );
      },
      child: Center(
        child: Container(
          decoration: _boxDecoration(borderRadius: 20),
          padding: const EdgeInsets.all(24),
          child:Column(
            children: [
              const Text(
                'Total Items Scanned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              isLoadingCount
                  ? const CircularProgressIndicator(
                color: C.appBar4,
              )
                  : Text(
                '$totalScanned',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                getCurrentDate(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
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
  //       builder: (_) => LaminationQRScanScreen(
  //         operator: controller.selectedOperator!,
  //         supervisor: controller.selectedSupervisor!,
  //         location: controller.selectedLocation!,
  //         department: department,
  //         // plant: 'PLANT1',
  //         // scanType: null,
  //       ),
  //     ),
  //   );
  //
  //   if (result != null) {
  //     await refreshCount();
  //   }
  // }

  Future<void> _openScanner() async {
    if (controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaminationQRScanScreen(
          operator: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: controller.selectedLocation!,
          department: department,
        ),
      ),
    );

    if (result == true) {
      await refreshCount();
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
              final barcode = barcodeController.text.trim();

              if (barcode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid barcode'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              Navigator.pop(context); // close dialog

              // 🔄 Call SAME API as QR scan
              final result = await InStockService().laminationBarcode(
                barcode: barcode,
                rollEntry: 'LAMINATION',
                location: controller.selectedLocation!,
                operator: controller.selectedOperator!,
                supervisor: controller.selectedSupervisor!,
                department: department,
                // plant: 'PLANT-1',
              );

              if (result == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Server not responding'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              final status = result['status'];
              final message = result['message'] ?? 'Unknown response';

              // ✅ SAME RESPONSE AS QR
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: status == 'ok' ? Colors.green : Colors.green,
                ),
              );

              // 🔁 Refresh count only on success
              if (status == 'ok') {
                try {
                  await refreshCount();
                } catch (e) {
                  debugPrint('Refresh count error: $e');
                }
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.blue),
    );
  }

  TextStyle _labelStyle(bool isTablet, bool isSmallScreen) {
    return TextStyle(
      fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  // Future<void> refreshCount() async {
  //   try {
  //     final apiCount = await InStockService()
  //         .getLaminationScannedItemsCount(
  //       getApiDate(),
  //       plant!,
  //     );
  //
  //     setState(() {
  //       totalScanned = apiCount;
  //     });
  //   } catch (e) {
  //     debugPrint("Refresh Error : $e");
  //   }
  // }
}

import 'package:IMS/ScannedItem/Webbing/WebbingController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'WebbingBarcode.dart';
import 'WebbingReports/OutReports.dart';

class WebOutStock extends StatefulWidget {
  const WebOutStock({Key? key}) : super(key: key);

  @override
  State<WebOutStock> createState() => _WebOutStockState();
}

class _WebOutStockState extends State<WebOutStock> {
  // final controller = InStockWebController();
  late InStockWebController controller;
  late Future<void> _dropdownFuture;

  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // String getCurrentDate() {
  //   final now = DateTime.now();
  //   return "${now.day.toString().padLeft(2, '0')}-"
  //       "${now.month.toString().padLeft(2, '0')}-"
  //       "${now.year}";
  // }
  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  // ---------------- STATIC ISSUE TO ----------------
  // ---------------- STATIC ISSUE TO ----------------
  final List<String> issueToList = ['LAMINATION', 'CUTTING', 'OTHERS'];

  String? selectedIssueTo; // Local state for IssueTo
  String department = 'WEBBING';
  int totalScanned = 0;

  // ================= VALIDATION =================

  bool _isFormValid() {
    return controller.selectedOperator != null &&
        controller.selectedOperator!.isNotEmpty &&
        controller.selectedSupervisor != null &&
        controller.selectedSupervisor!.isNotEmpty &&
        selectedIssueTo != null &&
        selectedIssueTo!.isNotEmpty;
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
    controller = InStockWebController();
    _dropdownFuture = controller.loadLookupData();
  }

  // Future<void> _loadData() async {
  //   await controller.loadWebInitialData();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallScreen = size.width < 360;

    return FutureBuilder<void>(
      future: _dropdownFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: C.appBar3,));
        }
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
                  label: 'Issue To',
                  value: selectedIssueTo,
                  items: issueToList,
                  icon: Icons.account_tree,
                  isTablet: isTablet,
                  isSmallScreen: isSmallScreen,
                  onChanged: (value) => setState(() => selectedIssueTo = value),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                _buildDepartmentField(isTablet, isSmallScreen),
                SizedBox(height: isTablet ? 32 : 24),

                // _buildScanningCard(isTablet, isSmallScreen),
                // SizedBox(height: isTablet ? 24 : 20),
                _buildActionButtons(isTablet, isSmallScreen),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= COMPONENTS =================

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    final uniqueItems = items.toSet().toList(); // ✅ remove duplicates

    return Container(
      decoration: _boxDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      value: uniqueItems.contains(value)
                          ? value
                          : null, // ✅ safe value
                      hint: Text(
                        'Select an option',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      isExpanded: true,
                      items: uniqueItems.map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
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
        //   MaterialPageRoute(
        //     builder: (_) => WebbOutReportDetailsScreen(),
        //   ),
        // );
      },
      child: Container(
        decoration: _boxDecoration(borderRadius: 20),
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<int>(
          future: InStockService().getOutScannedItemsCount(getApiDate()),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return Column(
              children: [
                const Text(
                  'Total Items Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  snapshot.connectionState == ConnectionState.waiting
                      ? '...'
                      : '$count',
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
            );
          },
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
            color: Colors.blue,
            onTap: _openScanner,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_note,
            label: 'Manual Entry',
            color: Colors.green,
            onTap: () => _showManualDialog(isSmallScreen),
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
  Future<void> _processOutBarcode(String barcode) async {
    try {
      final result = await InStockService.processOutBarcode(
        barcode: barcode,
        supervisor: controller.selectedSupervisor!,
        operator: controller.selectedOperator!,
        issueType: selectedIssueTo!,
        location: department,
      );

      if (!mounted) return;

      if (result == null) {
        _showSnack("Server not responding", Colors.redAccent);
        return;
      }

      final status = result['status'] ?? result['success'];
      final message = result['message'] ?? "Unknown response";

      final isSuccess = status == 'ok' || status == true;

      _showSnack(message, isSuccess ? Colors.green : Colors.orange);

      if (isSuccess) {
        await _refreshCount();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack("Error: $e", Colors.redAccent);
    }
  }

  Future<void> _refreshCount() async {
    try {
      final apiCount = await InStockService().getOutScannedItemsCount(
        getApiDate(),
      );

      setState(() {
        totalScanned = apiCount;
      });
    } catch (e) {
      debugPrint('Refresh count error: $e');
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _openScanner() async {
    if (!_isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => WebbingScanScreen(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: department,
          department: department,
          scanType: ScanType.inStock,
        ),
      ),
    );

    if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
      await _processOutBarcode(scannedBarcode);
    }
  }

  void _showManualDialog(bool isSmallScreen) {
    final barcodeController = TextEditingController();

    if (!_isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manual Entry'),
        content: TextField(
          controller: barcodeController,
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
                _showSnack('Please enter a valid barcode', Colors.redAccent);
                return;
              }

              Navigator.pop(context);
              await _processOutBarcode(barcode);
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
}

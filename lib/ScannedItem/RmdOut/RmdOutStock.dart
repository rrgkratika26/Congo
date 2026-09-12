import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/GlobalLoader/GLobalLoader.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'OutReportDetailScreen.dart';
import 'ScanRMDOutBarcode.dart';

class OutReportScreen extends StatefulWidget {
  const OutReportScreen({Key? key}) : super(key: key);

  @override
  State<OutReportScreen> createState() => _OutReportScreenState();
}

class _OutReportScreenState extends State<OutReportScreen> {
  final controller = InStockController();
  final loader = Get.find<LoaderController>();
  int _refreshKey = 0;
  String? unit = AppSession.unit;
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
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // ---------------- STATIC ISSUE TO ----------------
  final List<String> issueToList = ['LAMINATION', 'CUTTING', 'FOLDING','OTHERS'];
  // final List<String> issueToList = [
  //   'LAMINATION',
  //   'CUTTING',
  //   'PRINTING',
  //   'SLITTING',
  //   'OTHERS',
  // ];

  String? selectedIssueTo; // Local state for IssueTo
  String department = 'RMD';
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
    _loadUnit();
    loadTodayCount();
    _loadData();
  }

  Future<void> _loadData() async {
    loader.show();

    try {
      await controller.loadInitialData();

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loader.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallScreen = size.width < 360;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 10 : 16)),
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
                      value: value,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutReportDetailsScreen(date: getApiDate()),
          ),
        );
      },
      child: Center(
        child: Container(
          decoration: _boxDecoration(borderRadius: 20),
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<int>(
            key: ValueKey(_refreshKey), // 👈 force rebuild trigger
            future: InStockService().getOutScannedItemsCount(getApiDate()),
            builder: (context, snapshot) {
              final count = snapshot.data ?? totalScanned;
              return Column(
                children: [
                  const Text(
                    'Total Items Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$count',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getCurrentDate(),
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
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
            onTap: _openRMDOutScanner,
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
            Icon(icon, color: color, size: 38),
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
  //   if (!_isFormValid()) {
  //     _showValidationSnackBar();
  //     return;
  //   }
  //
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => QRRMDScanScreen(
  //         operatorName: controller.selectedOperator!,
  //         supervisor: controller.selectedSupervisor!,
  //         location: selectedIssueTo!, // Using IssueTo instead of Location
  //         department: department,
  //         scanType: ScanType.outStock,
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
  //
  // Future<void> _openRMDOutScanner() async {
  //   if (!_isFormValid()) {
  //     _showValidationSnackBar();
  //     return;
  //   }
  //
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => QROutRmdScanScreen(
  //         operatorName: controller.selectedOperator!,
  //         supervisor: controller.selectedSupervisor!,
  //         location: selectedIssueTo!,
  //         department: department,
  //       ),
  //     ),
  //   );
  //
  //   // result is the scanned barcode string returned from QRRMDScanScreen
  //   // if (result != null && result is String && result.isNotEmpty) {
  //   //   final apiResult = await InStockService().checkBarcodeOut(
  //   //     barcode: result,
  //   //     roll_entry: 'ROLL-${DateTime.now()}',
  //   //     storage: selectedIssueTo!,
  //   //     operatorName: controller.selectedOperator!,
  //   //     supervisor: controller.selectedSupervisor!,
  //   //     department: controller.selectedSupervisor!,
  //   //   );
  //   //
  //   //   if (apiResult == null) {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       const SnackBar(
  //   //         content: Text('Server not responding'),
  //   //         backgroundColor: Colors.redAccent,
  //   //       ),
  //   //     );
  //   //     return;
  //   //   }
  //   //
  //   //   final status = apiResult['status'];
  //   //   final message = apiResult['message'] ?? 'Unknown response';
  //   //
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     SnackBar(
  //   //       content: Text(message),
  //   //       backgroundColor: status == 'ok' ? Colors.green : Colors.orange,
  //   //     ),
  //   //   );
  //   //
  //   //   if (status == 'ok') {
  //   //     try {
  //   //       final apiCount = await InStockService().getOutScannedItemsCount(getApiDate());
  //   //       setState(() {
  //   //         totalScanned = apiCount;
  //   //       });
  //   //     } catch (e) {
  //   //       debugPrint('Refresh count error: $e');
  //   //     }
  //   //   }
  //   // }
  // }

  Future<void> _openRMDOutScanner() async {
    if (!_isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QROutRmdScanScreen(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: selectedIssueTo!,
          department: department,
        ),
      ),
    );

    if (result != null && result is String) {
      // Remove spaces/new lines
      String barcode = result.trim();

      // Optional: remove hidden characters
      barcode = barcode.replaceAll(RegExp(r'[\n\r\t]'), '');

      debugPrint("Scanned barcode: [$barcode]");

      loader.show();

      try {
        final apiResult = await InStockService().checkBarcodeOut(
          barcode: barcode,
          roll_entry: 'R-1',
          storage: selectedIssueTo!,
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          department: department,
        );

        // debugPrint("API Response: $apiResult");

        if (apiResult == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Server not responding"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResult['message']),
            backgroundColor: apiResult['status'] == 'ok'
                ? Colors.green
                : Colors.orange,
          ),
        );

        if (apiResult['status'] == 'ok') {
          setState(() => _refreshKey++);
        }
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        loader.hide();
      }
    }
  }

  Future<void> loadTodayCount() async {
    try {
      final count = await InStockService().getOutScannedItemsCount(
        getApiDate(),
      );

      setState(() {
        totalScanned = count;
      });
    } catch (e) {
      debugPrint(e.toString());
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

              loader.show();

              try {
                final result = await InStockService().checkBarcodeOut(
                  barcode: barcode,
                  roll_entry: 'R-1',
                  storage: selectedIssueTo!,
                  operatorName: controller.selectedOperator!,
                  supervisor: controller.selectedSupervisor!,
                  department: department,
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

                // ✅ Show response
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: status == 'ok'
                        ? Colors.green
                        : Colors.orange,
                  ),
                );

                // 🔁 Refresh count only on success
                // if (status == 'ok') {
                //   try {
                //     final apiCount = await InStockService()
                //         .getOutScannedItemsCount(getApiDate());
                //
                //     setState(() {
                //       totalScanned = apiCount;
                //     });
                //   } catch (e) {
                //     debugPrint('Refresh count error: $e');
                //   }
                // }
                if (status == 'ok') {
                  setState(() => _refreshKey++);
                }
              } catch (e) {
                debugPrint(e.toString());
              } finally {
                loader.hide();
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
        color: C.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: C.appBar1),
    );
  }

  TextStyle _labelStyle(bool isTablet, bool isSmallScreen) {
    return TextStyle(
      fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  Future<void> _loadUnit() async {
    final savedUnit = await AppSession.getUnit();

    setState(() {
      unit = savedUnit ?? "";
    });
  }
}

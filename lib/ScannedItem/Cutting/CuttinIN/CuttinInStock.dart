import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../QRScan/QrScanScreen.dart';
import '../../../screen/inStock/ReportScreen.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../CuttingController/CuttingController.dart';
import 'CuttingQR.dart';
import 'QRCuttingScan.dart' hide ScanType;

class CuttingInScreen extends StatefulWidget {
  const CuttingInScreen({Key? key}) : super(key: key);

  @override
  State<CuttingInScreen> createState() => _CuttingInScreenState();
}

class _CuttingInScreenState extends State<CuttingInScreen> {
  final controller = CuttingController();

  /// 🔹 IMPORTANT
  String department = 'CUTTING';

  int totalScanned = 0;

  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await controller.loadInitialData();
    setState(() {});
  }

  // ================= VALIDATION =================

  void _showValidationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Please fill all required fields before scanning'),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            isDesktop ? 24 : (isTablet ? 20 : (isSmallScreen ? 12 : 16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Fields
              _buildFormSection(isTablet, isDesktop, isSmallScreen),

              SizedBox(height: isTablet ? 24 : 20),

              _buildDepartmentField(isTablet, isSmallScreen),
              SizedBox(height: isTablet ? 32 : 24),

              // _buildScanningCard(isTablet, isDesktop),
              SizedBox(height: isTablet ? 24 : 20),

              // Action Buttons
              _buildActionButtons(isTablet, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FORM SECTION =================

  Widget _buildFormSection(bool isTablet, bool isDesktop, bool isSmallScreen) {
    return Column(
      children: [
        _buildDropdown(
          label: 'Choose an Operator',
          value: controller.selectedOperator,
          items: controller.operators,
          icon: Icons.person_rounded,
          color: const Color(0xFF42A5F5),
          isTablet: isTablet,
          isDesktop: isDesktop,
          isSmallScreen: isSmallScreen,
          onChanged: (value) =>
              setState(() => controller.selectedOperator = value),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        _buildDropdown(
          label: 'Choose a Supervisor',
          value: controller.selectedSupervisor,
          items: controller.supervisors,
          icon: Icons.supervisor_account_rounded,
          color: const Color(0xFF42A5F5),
          isTablet: isTablet,
          isDesktop: isDesktop,
          isSmallScreen: isSmallScreen,
          onChanged: (value) =>
              setState(() => controller.selectedSupervisor = value),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        _buildDropdown(
          label: 'Choose Storage Location',
          value: controller.selectedLocation,
          items: controller.locations,
          icon: Icons.location_on_rounded,
          color: const Color(0xFF42A5F5),
          isTablet: isTablet,
          isDesktop: isDesktop,
          isSmallScreen: isSmallScreen,
          onChanged: (value) =>
              setState(() => controller.selectedLocation = value),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
    required bool isTablet,
    required bool isDesktop,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isDesktop ? 16 : (isTablet ? 14 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 18 : (isTablet ? 16 : 14)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : (isTablet ? 11 : 10)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 24 : (isTablet ? 22 : 20),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    // SizedBox(height: isTablet ? 6 : 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        hint: Text(
                          'Select an option',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                          ),
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: color,
                        ),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                          fontWeight: FontWeight.w500,
                        ),
                        items: items
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
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
      ),
    );
  }

  // ================= SCANNING CARD =================

  // Widget _buildScanningCard(bool isTablet, bool isDesktop) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(isDesktop ? 24 : (isTablet ? 20 : 16)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF42A5F5).withOpacity(0.1),
  //           blurRadius: 20,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
  //     child: Column(
  //       children: [
  //         // Icon
  //         Container(
  //           padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
  //           decoration: BoxDecoration(
  //             gradient: const LinearGradient(
  //               colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
  //             ),
  //             shape: BoxShape.circle,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color(0xFF42A5F5).withOpacity(0.3),
  //                 blurRadius: 15,
  //                 offset: const Offset(0, 8),
  //               ),
  //             ],
  //           ),
  //           child: Icon(
  //             Icons.qr_code_2_rounded,
  //             color: Colors.white,
  //             size: isDesktop ? 40 : (isTablet ? 36 : 32),
  //           ),
  //         ),
  //
  //         SizedBox(height: isDesktop ? 20 : (isTablet ? 18 : 16)),
  //
  //         Text(
  //           'Total Items Scanned',
  //           style: TextStyle(
  //             fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
  //             fontWeight: FontWeight.w600,
  //             color: Colors.grey[700],
  //             letterSpacing: 0.3,
  //           ),
  //         ),
  //
  //         SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
  //
  //         Text(
  //           '$totalScanned',
  //           style: TextStyle(
  //             fontSize: isDesktop ? 56 : (isTablet ? 52 : 48),
  //             fontWeight: FontWeight.bold,
  //             color: const Color(0xFF42A5F5),
  //             height: 1,
  //           ),
  //         ),
  //
  //         SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
  //
  //         Container(
  //           padding: EdgeInsets.symmetric(
  //             horizontal: isDesktop ? 16 : (isTablet ? 14 : 12),
  //             vertical: isDesktop ? 8 : (isTablet ? 7 : 6),
  //           ),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF42A5F5).withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(
  //                 Icons.calendar_today_rounded,
  //                 size: isDesktop ? 16 : 14,
  //                 color: const Color(0xFF42A5F5),
  //               ),
  //               SizedBox(width: isTablet ? 8 : 6),
  //               Text(
  //                 getCurrentDate(),
  //                 style: TextStyle(
  //                   color: const Color(0xFF42A5F5),
  //                   fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildScanningCard(bool isTablet, bool isDesktop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(date: getApiDate()),
          ),
        );
      },
      borderRadius: BorderRadius.circular(
        isDesktop ? 24 : (isTablet ? 20 : 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            isDesktop ? 24 : (isTablet ? 20 : 16),
          ),
        ),
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
        child: Column(
          children: [
            // Icon
            Text(
              'Total Items Scanned',
              style: TextStyle(
                fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),

            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),

            Text(
              '$totalScanned',
              style: TextStyle(
                fontSize: isDesktop ? 56 : (isTablet ? 52 : 48),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1,
              ),
            ),

            SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : (isTablet ? 14 : 12),
                vertical: isDesktop ? 8 : (isTablet ? 7 : 6),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: isDesktop ? 16 : 14,
                    color: Colors.grey,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    getCurrentDate(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                      fontWeight: FontWeight.w600,
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
  // ================= ACTION BUTTONS =================
  //
  //   Widget _buildActionButtons(bool isTablet, bool isDesktop) {
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: _actionButton(
  //             icon: Icons.qr_code_scanner_rounded,
  //             label: 'Scan QR',
  //             gradient: const [Color(0xFFFFA726), Color(0xFFFF8F00)],
  //             onTap: _openScanner,
  //             isTablet: isTablet,
  //             isDesktop: isDesktop,
  //           ),
  //         ),
  //         SizedBox(width: isTablet ? 16 : 12),
  //         Expanded(
  //           child: _actionButton(
  //             icon: Icons.edit_note_rounded,
  //             label: 'Manual Entry',
  //             gradient: const [Color(0xFF66BB6A), Color(0xFF4CAF50)],
  //             onTap: _showManualEntryDialog,
  //             isTablet: isTablet,
  //             isDesktop: isDesktop,
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //
  //   Widget _actionButton({
  //     required IconData icon,
  //     required String label,
  //     required List<Color> gradient,
  //     required VoidCallback onTap,
  //     required bool isTablet,
  //     required bool isDesktop,
  //   }) {
  //     return InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(
  //         isDesktop ? 20 : (isTablet ? 18 : 16),
  //       ),
  //       child: Container(
  //         // height: isDesktop ? 140 : (isTablet ? 130 : 120),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: gradient,
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //           borderRadius: BorderRadius.circular(
  //             isDesktop ? 20 : (isTablet ? 18 : 16),
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: gradient[0].withOpacity(0.3),
  //               blurRadius: 15,
  //               offset: const Offset(0, 8),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               icon,
  //               color: Colors.white,
  //               size: isDesktop ? 40 : (isTablet ? 36 : 32),
  //             ),
  //             SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: isDesktop ? 17 : (isTablet ? 16 : 15),
  //                 letterSpacing: 0.5,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // ================= ACTIONS =================
  //
  //   Future<void> _openScanner() async {
  //     if (!controller.isFormValid()) {
  //       _showValidationSnackBar();
  //       return;
  //     }
  //
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => CuttingQRScanScreen(
  //           operator: controller.selectedOperator!,
  //           supervisor: controller.selectedSupervisor!,
  //           location: controller.selectedLocation!,
  //           department: department,
  //           plant: 'PLANT1',
  //         ),
  //       ),
  //     );
  //
  //     if (result != null) {
  //       setState(() => totalScanned++);
  //     }
  //   }
  //
  //   void _showManualEntryDialog() {
  //     if (!controller.isFormValid()) {
  //       _showValidationSnackBar();
  //       return;
  //     }
  //     // Add manual entry dialog implementation here
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Row(
  //           children: [
  //             Icon(Icons.info_outline, color: Colors.white),
  //             SizedBox(width: 12),
  //             Text('Manual entry feature coming soon'),
  //           ],
  //         ),
  //         backgroundColor: const Color(0xFF42A5F5),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   }
  // }

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
            onTap: () => _showWithoutScanDialog(isSmallScreen),
          ),
        ),
      ],
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

  Future<void> _openScanner() async {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRCuttingScanScreen(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: controller.selectedLocation!,
          department: department,
          scanType: ScanType.inStock,
        ),
      ),
    );
    setState(() {
      totalScanned++;
    });
  }

  void _showWithoutScanDialog(bool isSmallScreen) {
    final barcodeController = TextEditingController();

    if (!controller.isFormValid()) {
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
              final result = await InStockService().cuttingBarcode(
                barcode: barcode,
                location: controller.selectedLocation!,
                operatorName: controller.selectedOperator!,
                supervisor: controller.selectedSupervisor!,
                department: "CUTTING",

                cuttingRecParty: '',
                workOrderCutting: '',
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
                  backgroundColor: status == 'ok'
                      ? Colors.green
                      : Colors.orange,
                ),
              );

              // 🔁 Refresh count only on success
              if (status == 'ok') {
                try {
                  final apiCount = await InStockService().getScannedItemsCount(
                    getApiDate(),
                  );

                  setState(() {
                    totalScanned = apiCount;
                  });
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
}

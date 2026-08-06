import 'dart:convert';
import 'package:IMS/services/DashboardApiServices.dart';
import 'package:IMS/services/Visa_SmallbagAPIS/VISA_SApis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Color/Colorclass.dart';
import '../../../QRScan/QrScanScreen.dart';
import '../../../screen/inStock/ReportScreen.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../ScannedItem/Cutting/CuttinIN/CutDetailInScreen.dart';
import '../../ScannedItem/Cutting/CuttingController/CuttingController.dart';
import 'SlittingInStockDetails.dart';
import 'SlittingScanIn.dart';

class SlittingInScreen extends StatefulWidget {
  const SlittingInScreen({Key? key}) : super(key: key);

  @override
  State<SlittingInScreen> createState() => _SlittingInScreenState();
}

class _SlittingInScreenState extends State<SlittingInScreen> {
  final controller = CuttingController();

  /// 🔹 IMPORTANT
  String department = 'SLITTING';

  int totalScanned = 0;
  String unitName = '';
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
    loadTodayCount();
  }

  Future<void> _loadData() async {
    await controller.loadInitialData();
    final prefs = await SharedPreferences.getInstance();

    unitName = prefs.getString('unit') ?? 'UNIT';
    setState(() {});
  }

  Future<void> loadTodayCount() async {
    try {
      final apiCount = await VisaSmallBagApiService().getSlittingItemsCount(
        getApiDate(),
      );

      setState(() {
        totalScanned = apiCount;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: C.primaryblue, // or Colors.blue
        foregroundColor: Colors.white,
        title: const Text('Slitting In', style: TextStyle(fontSize: 20)),
      ),
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

              _buildScanningCard(isTablet, isDesktop),
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
          color: C.primaryblue,
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
          color: C.primaryblue,
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
          color: C.primaryblue,
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
          isDesktop ? 16 : (isTablet ? 14 : 10),
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

  Widget _buildScanningCard(bool isTablet, bool isDesktop) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SlittingInStockDetail(date: getApiDate()),
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

  // Future<void> _openScanner() async {
  //   if (!controller.isFormValid()) {
  //     _showValidationSnackBar();
  //     return;
  //   }
  //
  //   final barcode = await Navigator.push<String>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => QrSlittingScanInScree(
  //         // operatorName: controller.selectedOperator!,
  //         // supervisor: controller.selectedSupervisor!,
  //         // location: controller.selectedLocation!,
  //         // roll: department,
  //         // plant: unitName,
  //         operatorName: controller.selectedOperator!,
  //         supervisor: controller.selectedSupervisor!,
  //         location: controller.selectedLocation!,
  //         roll: department,
  //         plant: unitName,
  //         party: '',
  //         workorder: '',
  //       ),
  //     ),
  //   );
  //
  //   if (barcode == null || barcode.isEmpty) return;
  //
  //   final result = await VisaSmallBagApiService().slittingIn(
  //     barcode: barcode.toUpperCase(),
  //     operator: controller.selectedOperator!,
  //     location: controller.selectedLocation!,
  //     plant: unitName,
  //     supervisor: controller.selectedSupervisor!,
  //     roll: '',
  //     party: '',
  //   );
  //
  //   // if (result == null) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     const SnackBar(
  //   //       content: Text("Server not responding"),
  //   //       backgroundColor: Colors.red,
  //   //     ),
  //   //   );
  //   //   return;
  //   // }
  //   //
  //   // final status = result["status"];
  //   // final message = result["message"] ?? "";
  //   //
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   SnackBar(
  //   //     content: Text(message),
  //   //     backgroundColor: status == "ok" ? Colors.green : Colors.orange,
  //   //   ),
  //   // );
  //
  //   // if (status == "ok") {
  //   //   await loadTodayCount();
  //   // }
  // }


  Future<void> _openScanner() async {
    if (!controller.isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QrSlittingScanInScree(
          operatorName: controller.selectedOperator!,
          supervisor: controller.selectedSupervisor!,
          location: controller.selectedLocation!,
          roll: department,
          plant: unitName,
          party: '',
          workorder: '',
        ),
      ),
    );

    if (success == true) {
      await loadTodayCount();
    }


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
                    content: Text('Please enter a valid barcode'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              Navigator.pop(context); // close dialog

              // 🔄 Call SAME API as QR scan
              final result = await VisaSmallBagApiService()
                  .getSlittingScannedItems(
                    barcode: barcode,

                    operator: controller.selectedOperator!,
                    location: controller.selectedLocation!,
                    plant: unitName,
                    supervisor: controller.selectedSupervisor!,
                    roll: department,
                    party: '',
                    workorder: '',
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
                      ? Colors.orange
                      : Colors.green,
                ),
              );

              if (status == 'ok') {
                await loadTodayCount();
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

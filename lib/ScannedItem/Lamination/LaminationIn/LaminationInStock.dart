// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../QRScan/QrScanScreen.dart';
// import '../../../screen/inStock/ReportScreen.dart';
// import '../../../screen/inStock/laminationController.dart';
// import 'LaminationController.dart';
//
// class LaminationInStockScreen extends StatefulWidget {
//   const LaminationInStockScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LaminationInStockScreen> createState() =>
//       _LaminationInStockScreenState();
// }
//
// class _LaminationInStockScreenState extends State<LaminationInStockScreen> {
//   final controller = Laminationcontroller();
//
//   /// 🔹 IMPORTANT
//   String department = 'LAMINATION';
//
//   int totalScanned = 0;
//
//   String getApiDate() {
//     final now = DateTime.now();
//     return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//   }
//
//   String getCurrentDate() {
//     final now = DateTime.now();
//     return "${now.day.toString().padLeft(2, '0')}-"
//         "${now.month.toString().padLeft(2, '0')}-"
//         "${now.year}";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     await controller.loadInitialData();
//     setState(() {});
//   }
//
//   // ================= VALIDATION =================
//
//   void _showValidationSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.warning_rounded, color: Colors.white),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text('Please fill all required fields before scanning'),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.red[700],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width >= 600 && size.width < 1024;
//     final isDesktop = size.width >= 1024;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(
//             isDesktop ? 24 : (isTablet ? 20 : (isSmallScreen ? 12 : 16)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Form Fields
//               _buildFormSection(isTablet, isDesktop, isSmallScreen),
//
//               SizedBox(height: isTablet ? 24 : 20),
//
//               // Total Scanned Card
//               _buildScanningCard(isTablet, isDesktop),
//
//               SizedBox(height: isTablet ? 24 : 20),
//
//               // Action Buttons
//               // _buildActionButtons(isTablet, isDesktop),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= FORM SECTION =================
//
//   Widget _buildFormSection(bool isTablet, bool isDesktop, bool isSmallScreen) {
//     return Column(
//       children: [
//         _buildDropdown(
//           label: 'Choose an Operator',
//           value: controller.selectedOperator,
//           items: controller.operators,
//           icon: Icons.person_rounded,
//           color: const Color(0xFFFFA726),
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//           isSmallScreen: isSmallScreen,
//           onChanged: (value) =>
//               setState(() => controller.selectedOperator = value),
//         ),
//         SizedBox(height: isTablet ? 16 : 12),
//         _buildDropdown(
//           label: 'Choose a Supervisor',
//           value: controller.selectedSupervisor,
//           items: controller.supervisors,
//           icon: Icons.supervisor_account_rounded,
//           color: const Color(0xFFFFA726),
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//           isSmallScreen: isSmallScreen,
//           onChanged: (value) =>
//               setState(() => controller.selectedSupervisor = value),
//         ),
//         SizedBox(height: isTablet ? 16 : 12),
//         _buildDropdown(
//           label: 'Choose Storage Location',
//           value: controller.selectedLocation,
//           items: controller.locations,
//           icon: Icons.location_on_rounded,
//           color: const Color(0xFFFFA726),
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//           isSmallScreen: isSmallScreen,
//           onChanged: (value) =>
//               setState(() => controller.selectedLocation = value),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required IconData icon,
//     required Color color,
//     required ValueChanged<String?> onChanged,
//     required bool isTablet,
//     required bool isDesktop,
//     required bool isSmallScreen,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(
//           isDesktop ? 16 : (isTablet ? 14 : 12),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: Padding(
//           padding: EdgeInsets.all(isDesktop ? 18 : (isTablet ? 16 : 14)),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(isDesktop ? 12 : (isTablet ? 11 : 10)),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: isDesktop ? 24 : (isTablet ? 22 : 20),
//                 ),
//               ),
//               SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     SizedBox(height: isTablet ? 6 : 4),
//                     DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: value,
//                         hint: Text(
//                           'Select an option',
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
//                           ),
//                         ),
//                         isExpanded: true,
//                         icon: Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: color,
//                         ),
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         items: items
//                             .map(
//                               (e) => DropdownMenuItem(value: e, child: Text(e)),
//                             )
//                             .toList(),
//                         onChanged: onChanged,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= SCANNING CARD =================
//
//   Widget _buildScanningCard(bool isTablet, bool isDesktop) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => ReportScreen(date: getApiDate())),
//         );
//       },
//       borderRadius: BorderRadius.circular(
//         isDesktop ? 24 : (isTablet ? 20 : 16),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(
//             isDesktop ? 24 : (isTablet ? 20 : 16),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFFFFA726).withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
//         child: Column(
//           children: [
//             // Icon
//
//             Text(
//               'Total Items Scanned',
//               style: TextStyle(
//                 fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//                 letterSpacing: 0.3,
//               ),
//             ),
//
//             SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
//
//             Text(
//               '$totalScanned',
//               style: TextStyle(
//                 fontSize: isDesktop ? 56 : (isTablet ? 52 : 48),
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFFFFA726),
//                 height: 1,
//               ),
//             ),
//
//             SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= ACTION BUTTONS =================
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
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QRScanScreen(
//           operatorName: controller.selectedOperator!,
//           supervisor: controller.selectedSupervisor!,
//           location: controller.selectedLocation!,
//           department: department,
//           scanType: ScanType.inStock,
//         ),
//       ),
//     );
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
//         backgroundColor: const Color(0xFFFFA726),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }

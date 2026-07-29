// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../QRScan/QrScanScreen.dart';
// import '../../../screen/inStock/ReportScreen.dart';
// import '../../../screen/inStock/inStockController.dart';
// import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'JBL_ReportDetailScreen.dart';
// import 'Jbl_ScanBarcode.dart';
//
// class JBLRmdIn extends StatefulWidget {
//   final String screenType; // "IN" or "OUT"
//   const JBLRmdIn({Key? key, required this.screenType}) : super(key: key);
//
//   @override
//   State<JBLRmdIn> createState() => _JBLRmdInState();
// }
//
// class _JBLRmdInState extends State<JBLRmdIn> {
//   String department = 'RMD';
//   int totalScanned = 0;
//   String? unit;
//   String _unitTitle = '';
//
//   final controller = InStockController();
//   String getCurrentDate() {
//     return DateFormat('dd-MM-yyyy').format(DateTime.now());
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _loadUnit();
//   }
//
//   Future<void> _loadUnit() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       unit = prefs.getString('unit');
//     });
//   }
//
//   Future<void> _loadData() async {
//     await controller.load_JBl_InitialData();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       // ✅ FIX: Scaffold provides Material ancestor
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade100,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//
//         leadingWidth: 110, // important
//         leading: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
//               onPressed: () => Navigator.pop(context),
//             ),
//             // Image.asset(
//             //   'assets/images/logo-1.png',
//             //   height: 28,
//             //   fit: BoxFit.contain,
//             // ),
//           ],
//         ),
//
//         title: Row(
//           children: [
//             Text(
//               _unitTitle.isNotEmpty ? _unitTitle : 'JBL',
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontSize: isTablet ? 20 : 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(width: 5),
//             Text(
//               'RMD ${widget.screenType}',
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontSize: isTablet ? 20 : 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 12 : 16)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDropdown(
//                 label: 'Choose an Operator',
//                 value: controller.selectedOperator,
//                 items: controller.jbloperators,
//                 icon: Icons.person,
//                 isTablet: isTablet,
//                 isSmallScreen: isSmallScreen,
//                 onChanged: (value) =>
//                     setState(() => controller.selectedOperator = value),
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 label: 'Choose a Supervisor',
//                 value: controller.selectedSupervisor,
//                 items: controller.jblsupervisors,
//                 icon: Icons.supervisor_account,
//                 isTablet: isTablet,
//                 isSmallScreen: isSmallScreen,
//                 onChanged: (value) =>
//                     setState(() => controller.selectedSupervisor = value),
//               ),
//               const SizedBox(height: 15),
//               _buildUnitField(isTablet, isSmallScreen),
//               const SizedBox(height: 15),
//               _buildDepartmentField(isTablet, isSmallScreen),
//               const SizedBox(height: 15),
//               _buildScanningCard(isTablet, isSmallScreen),
//               const SizedBox(height: 15),
//               _buildActionButtons(isTablet, isSmallScreen),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= ACTIONS =================
//
//   Future<void> _openScanner() async {
//     if (!_isFormValid()) {
//       // ✅ FIX: check NOT valid
//       _showValidationSnackBar();
//       return;
//     }
//
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Jbl_ScanBarcode(
//           operatorName: controller.selectedOperator!,
//           supervisor: controller.selectedSupervisor!,
//           storage: unit!,
//           department: department,
//           scanType: ScanJBLType.inRmd,
//           unit: unit!,
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         totalScanned++;
//       });
//     }
//   }
//
//   void _showWithoutScanDialog(bool isSmallScreen) {
//     final barcodeController = TextEditingController();
//
//     if (!_isFormValid()) {
//       // ✅ FIX: check NOT valid
//       _showValidationSnackBar();
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Manual Entry'),
//         content: TextField(
//           controller: barcodeController,
//           decoration: const InputDecoration(labelText: 'Enter Barcode'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             child: const Text('Submit'),
//             onPressed: () async {
//               final barcode = barcodeController.text.trim();
//               if (barcode.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Please enter a valid barcode'),
//                     backgroundColor: Colors.redAccent,
//                   ),
//                 );
//                 return;
//               }
//
//               Navigator.pop(context);
//
//               final result = await JblApiService().jbl_checkBarcodeIn(
//                 barcode: barcode,
//                 roll_entry: 'RMD',
//                 storage: unit!,
//                 operatorName: controller.selectedOperator!,
//                 supervisor: controller.selectedSupervisor!,
//                 department: department,
//                 unit: unit!,
//               );
//
//               if (result == null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Server not responding'),
//                     backgroundColor: Colors.redAccent,
//                   ),
//                 );
//                 return;
//               }
//
//               final status = result['status'];
//               final message = result['message'] ?? 'Unknown response';
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(message),
//                   backgroundColor: status == 'ok'
//                       ? Colors.green
//                       : Colors.orange,
//                 ),
//               );
//
//               if (status == 'ok') {
//                 final apiCount = await JblApiService()
//                     .get_jbloutScannedItemsCount(getApiDate(), unit!);
//                 setState(() => totalScanned = apiCount);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= VALIDATION =================
//   bool _isFormValid() {
//     return controller.selectedOperator != null &&
//         controller.selectedSupervisor != null &&
//         unit != null;
//   }
//
//   void _showValidationSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please fill all required fields before scanning QR'),
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }
//
//   Widget _buildDropdown({
//     required String label,
//     // required String value,
//     required String? value,
//     required List<String> items,
//     required IconData icon,
//     required ValueChanged<String?> onChanged,
//     required bool isTablet,
//     required bool isSmallScreen,
//   }) {
//     return Container(
//       decoration: _boxDecoration(),
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: isSmallScreen ? 12 : 12,
//           vertical: isSmallScreen ? 8 : 8,
//         ),
//         child: Row(
//           children: [
//             _iconBox(icon),
//             SizedBox(width: isSmallScreen ? 12 : 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label, style: _labelStyle(isTablet, isSmallScreen)),
//                   DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: value, // null initially
//                       hint: Text(
//                         'Select an option',
//                         style: TextStyle(color: Colors.grey.shade400),
//                       ),
//                       isExpanded: true,
//                       items: items
//                           .map(
//                             (e) => DropdownMenuItem(
//                               value: e,
//                               child: Text(
//                                 e,
//                                 style: const TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: onChanged,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   TextStyle _labelStyle(bool isTablet, bool isSmallScreen) {
//     return TextStyle(
//       fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
//       color: Colors.grey[600],
//       fontWeight: FontWeight.w500,
//     );
//   }
//
//   BoxDecoration _boxDecoration({double borderRadius = 12}) {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(borderRadius),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     );
//   }
//
//   Widget _iconBox(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(icon, color: Colors.blue),
//     );
//   }
//
//   // String getApiDate() {
//   //   final now = DateTime.now();
//   //   return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//   // }
//   String getApiDate() {
//     return DateFormat('dd-MMM-yyyy').format(DateTime.now());
//   }
//
//   Widget _buildDepartmentField(bool isTablet, bool isSmallScreen) {
//     return Container(
//       decoration: _boxDecoration(),
//       padding: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 12 : 16,
//         vertical: isSmallScreen ? 12 : 16,
//       ),
//       child: Row(
//         children: [
//           _iconBox(Icons.business),
//           SizedBox(width: isSmallScreen ? 12 : 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('DEPARTMENT', style: _labelStyle(isTablet, isSmallScreen)),
//               const SizedBox(height: 4),
//               Text(
//                 department,
//                 style: TextStyle(
//                   fontSize: isTablet ? 16 : (isSmallScreen ? 13 : 15),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScanningCard(bool isTablet, bool isSmallScreen) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () async {
//         if (unit == null) return;
//
//         final items = await JblApiService().get_jblScannedItems(
//           getApiDate(),
//           unit!,
//         );
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => Jbl_ReportDetailScreen(
//               title: "$department ${widget.screenType}",
//               date: getApiDate(),
//               data: items,
//             ),
//           ),
//         );
//       },
//       child: Center(
//         child: Container(
//           decoration: _boxDecoration(borderRadius: 20),
//           padding: const EdgeInsets.all(24),
//           child: FutureBuilder<int>(
//             future: unit == null
//                 ? Future.value(0)
//                 : JblApiService().get_jblInScannedItemsCount(
//                     getApiDate(),
//                     unit!,
//                   ),
//             builder: (context, snapshot) {
//               final count = snapshot.data ?? 0;
//
//               return Column(
//                 children: [
//                   const Text(
//                     'Total Items Scanned',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     // snapshot.connectionState == ConnectionState.waiting
//                     //     ? '...'
//                     //     :
//                     '$count',
//                     style: const TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     getCurrentDate(),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(bool isTablet, bool isSmallScreen) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildActionButton(
//             icon: Icons.qr_code_scanner,
//             label: 'Scan QR',
//             color: Colors.blue,
//             onTap: _openScanner,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildActionButton(
//             icon: Icons.edit_note,
//             label: 'Manual Entry',
//             color: Colors.green,
//             onTap: () => _showWithoutScanDialog(isSmallScreen),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 120,
//         decoration: _boxDecoration(borderRadius: 16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(color: color, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUnitField(bool isTablet, bool isSmallScreen) {
//     return Container(
//       decoration: _boxDecoration(),
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           _iconBox(Icons.location_on),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('UNIT', style: _labelStyle(isTablet, isSmallScreen)),
//               const SizedBox(height: 4),
//               Text(
//                 unit ?? 'Loading...',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

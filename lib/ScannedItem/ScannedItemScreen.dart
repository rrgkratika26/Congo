// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../QRScan/QrScanScreen.dart';
//
// class ScannedItemScreen extends StatefulWidget {
//   const ScannedItemScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ScannedItemScreen> createState() => _ScannedItemScreenState();
// }
//
// class _ScannedItemScreenState extends State<ScannedItemScreen> {
//   String selectedOperator = '';
//   String selectedSupervisor = '';
//   String selectedLocation = '';
//
//   String department = 'RMD';
//   int totalScanned = 0;
//   String currentDate = '21-01-2026';
//
//   final List<String> operators = ['RAM'];
//   final List<String> supervisors = ['HARISH PATIL'];
//   final List<String> locations = [];
//
//   // ================= VALIDATION =================
//
//   bool _isFormValid() {
//     return selectedOperator != null &&
//         selectedSupervisor != null &&
//         selectedLocation != null &&
//         selectedOperator!.isNotEmpty &&
//         selectedSupervisor!.isNotEmpty &&
//         selectedLocation!.isNotEmpty;
//   }
//
//   void _showValidationSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please fill all required fields before scanning QR'),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.all(16),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   // ================= API CALL =================
//
//   Future<Map<String, dynamic>?> checkBarcodeIn({
//     required String barcode,
//     required String rollEntry,
//   }) async {
//     final url = Uri.parse('http://192.168.29.76:7165/api/Rmd/checkBarcodeIn');
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "barcode": barcode,
//           "roll_entry": rollEntry,
//           "storage": selectedLocation,
//           "operatorName": selectedOperator,
//           "supervisor": selectedSupervisor,
//           "department": department,
//         }),
//       );
//
//       debugPrint("STATUS: ${response.statusCode}");
//       debugPrint("BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       debugPrint('Exception: $e');
//     }
//     return null;
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'INNOWEAVE - [ IN Report ]',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildDropdown(
//               'Choose Operator',
//               selectedOperator,
//               operators,
//               (v) => setState(() => selectedOperator = v ?? ''),
//             ),
//
//             const SizedBox(height: 16),
//             _buildDropdown(
//               'Choose Supervisor',
//               selectedSupervisor,
//               supervisors,
//               (v) => setState(() => selectedSupervisor = v!),
//             ),
//             const SizedBox(height: 16),
//             _buildDropdown(
//               'Choose Location',
//               selectedLocation,
//               locations,
//               (v) => setState(() => selectedLocation = v!),
//             ),
//             const SizedBox(height: 16),
//             _buildDepartment(),
//             const SizedBox(height: 30),
//             _buildScanCountCard(),
//             const SizedBox(height: 30),
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown(
//     String label,
//     String value,
//     List<String> items,
//     ValueChanged<String?> onChanged,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               isExpanded: true,
//               items: items
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDepartment() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: const [
//           Text('Department', style: TextStyle(color: Colors.grey)),
//           Text(
//             'RMD',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScanCountCard() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'Total Items Scanned',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             '$totalScanned',
//             style: const TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(currentDate),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.qr_code_scanner),
//             label: const Text('Scan'),
//             onPressed: _openScanner,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.edit),
//             label: const Text('W/o Scan'),
//             onPressed: () => _showWithoutScanDialog(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ================= ACTIONS =================
//
//   Future<void> _openScanner() async {
//     if (_isFormValid()) {
//       _showValidationSnackBar();
//       return;
//     }
//
//     final scannedBarcode = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QRScanScreen(
//           operatorName: selectedOperator,
//           supervisor: selectedSupervisor,
//           location: selectedLocation,
//           department: 'RMD',
//           scanType: ScanType.inStock,
//         ),
//       ),
//     );
//
//     if (scannedBarcode == null) return;
//
//     final result = await checkBarcodeIn(
//       barcode: scannedBarcode,
//       rollEntry: 'R1',
//     );
//
//     if (result != null && result['status'] == 'ok') {
//       setState(() => totalScanned++);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(result['message']),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Barcode scan failed'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _showWithoutScanDialog() {
//     final controller = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add Without Scan'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: 'Enter Barcode'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final qty = int.tryParse(controller.text) ?? 0;
//               if (qty > 0) {
//                 setState(() => totalScanned += qty);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
// }

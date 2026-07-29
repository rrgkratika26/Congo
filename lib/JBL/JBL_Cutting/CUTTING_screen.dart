// import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Color/Colorclass.dart';
// import '../JBL_RMD/screens/JBL_ReportDetailScreen.dart';
// import 'JBL_cutting_controller.dart';
// import 'JblQrCuttingScan.dart';
//
// class JblCuttingScreen extends StatefulWidget {
//   const JblCuttingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<JblCuttingScreen> createState() => _JblCuttingScreenState();
// }
//
// class _JblCuttingScreenState extends State<JblCuttingScreen> {
//   final controller = JblCuttingController(); // ✅ FIXED
//   bool isLoading = false;
//   List scannedList = [];
//   String department = 'CUTTING';
//   int totalScanned = 0;
//   String unitTitle = '';
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
//     controller.loadInitialData().then((_) {
//       setState(() {});
//       _loadScannedData(); // ✅ ADD THIS
//     });
//     _loadUnit();
//   }
//
//   Future<void> _loadUnit() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     unitTitle = prefs.getString('unit') ?? 'UNIT';
//
//     setState(() {});
//
//     // ✅ CALL AFTER UNIT IS READY
//     await _loadScannedData();
//   }
//   void _showValidationSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please fill all required fields'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade100,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: Text(
//           " ${unitTitle.isNotEmpty ? unitTitle : 'Unit Name'} Cutting IN Stock ",
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: isTablet ? 20 : 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       _dropdown(
//                         "Select a Supervisor",
//                         controller.supervisors,
//                         controller.selectedSupervisor,
//                         (v) {
//                           setState(() => controller.selectedSupervisor = v);
//                           _loadScannedData();
//                         },
//                         Icons.supervisor_account,
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       _dropdown(
//                         "Select an Operator",
//                         controller.operators,
//                         controller.selectedOperator,
//                         (v) {
//                           setState(() => controller.selectedOperator = v);
//                           _loadScannedData();
//                         },
//                         Icons.person,
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       _locationBox(),
//
//                       const SizedBox(height: 16),
//
//                       _departmentBox(),
//
//                       const SizedBox(height: 20),
//
//                       _scanCard(),
//
//                       const SizedBox(height: 20),
//
//                       _buttons(),
//
//                       const SizedBox(
//                         height: 20,
//                       ), // 👈 extra space for small screens
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // ================= DROPDOWN =================
//   Widget _dropdown(
//     String label, // ✅ NEW
//     List<String> items,
//     String? value,
//     ValueChanged<String?> onChanged,
//     IconData icon,
//   ) {
//     return Container(
//       decoration: _box(),
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label, // ✅ Label text
//             style: const TextStyle(fontSize: 12, color: Colors.grey),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Icon(icon, color: Colors.blue),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: value,
//                     hint: Text(label), // ✅ Hint same as label
//                     isExpanded: true,
//                     items: items
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: onChanged,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= LOCATION BOX =================
//   Widget _locationBox() {
//     return Container(
//       decoration: _box(),
//       padding: const EdgeInsets.all(14),
//       child: Row(
//         children: [
//           const Icon(Icons.location_on, color: Colors.blue),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "LOCATION",
//                 style: TextStyle(fontSize: 11, color: Colors.grey),
//               ),
//               Text(
//                 unitTitle.isNotEmpty ? unitTitle : "UNIT",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= DEPARTMENT =================
//   Widget _departmentBox() {
//     return Container(
//       decoration: _box(),
//       padding: const EdgeInsets.all(14),
//       child: Row(
//         children: [
//           const Icon(Icons.business, color: Colors.blue),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "DEPARTMENT",
//                 style: TextStyle(fontSize: 11, color: Colors.grey),
//               ),
//               Text(
//                 department,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _openReportScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Jbl_ReportDetailScreen(
//           title: "Cutting Report",
//           date: getCurrentDate(),
//           data: scannedList, // ✅ full API data
//         ),
//       ),
//     );
//   }
//
//   // ================= SCAN CARD =================
//   Widget _scanCard() {
//     return InkWell(
//       onTap: _openReportScreen, // ✅ FIXED
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         decoration: _box(),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text(
//               "Total Items Scanned",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//
//             isLoading
//                 ? const CircularProgressIndicator(color: C.appBar3,)
//                 : Text(
//                     "$totalScanned",
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//             const SizedBox(height: 6),
//             Text(getCurrentDate(), style: const TextStyle(color: Colors.grey)),
//
//             const SizedBox(height: 10),
//             const Text(
//               "Tap to view details",
//               style: TextStyle(color: Colors.blue, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= BUTTONS =================
//   Widget _buttons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _bigButton(
//             title: "Scan QR",
//             icon: Icons.qr_code_scanner,
//             color: Colors.blue,
//             onTap: _openScanner,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _bigButton(
//             title: "Manual Entry",
//             icon: Icons.edit_note,
//             color: Colors.green,
//             onTap: _manualEntry,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _bigButton({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         height: 130,
//         decoration: BoxDecoration(
//           color: Colors.white, // ✅ white card
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08), // ✅ soft elevation
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: Border.all(
//             color: color.withOpacity(0.15), // ✅ subtle color border
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1), // ✅ icon bg
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: color, // ✅ colored icon
//                 size: 30,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: color, // ✅ colored text
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   BoxDecoration _box() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
//       ],
//     );
//   }
//
//   // ================= ACTIONS =================
//
//   Future<void> _openScanner() async {
//     // if (!controller.isFormValid()) {
//     //   _showValidationSnackBar();
//     //   return;
//     // }
//
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => JblQRCuttingScanScreen(
//           operatorName: controller.selectedOperator!,
//           supervisor: controller.selectedSupervisor!,
//           location: unitTitle,
//           department: department,
//           plant: unitTitle,
//         ),
//       ),
//     );
//
// // ✅ CALL API AGAIN
//     await _loadScannedData();
//
//     // setState(() => totalScanned++);
//   }
//   String getApiDate() {
//     final now = DateTime.now();
//     return "${now.year}-"
//         "${now.month.toString().padLeft(2, '0')}-"
//         "${now.day.toString().padLeft(2, '0')}";
//   }
//   Future<void> _loadScannedData() async {
//     // if (!controller.isFormValid()) return;
//
//     setState(() => isLoading = true);
//
//     final res = await JblApiService.getCuttingScannedRepo(
//       supervisor: controller.selectedSupervisor!,
//       operator: controller.selectedOperator!,
//       location: unitTitle,
//       department: department,
//       plant: unitTitle,
//     );
//
//     debugPrint("📡 API RESPONSE: $res");
//
//     if (res != null && res['status'] == 'ok') {
//
//       // ✅ DATA
//       scannedList = res['data'] ?? [];
//
//       // ✅ COUNT (API se directly lo)
//       totalScanned = res['count'] ?? scannedList.length;
//
//       debugPrint("📦 DATA LIST: $scannedList");
//       debugPrint("🔢 TOTAL COUNT: $totalScanned");
//
//     } else {
//       scannedList = [];
//       totalScanned = 0;
//     }
//
//     setState(() => isLoading = false);
//   }
//   void _manualEntry() {
//     // if (!controller.isFormValid()) {
//     //   _showValidationSnackBar();
//     //   return;
//     // }
//
//     final ctrl = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Manual Entry"),
//         content: TextField(
//           controller: ctrl,
//           decoration: const InputDecoration(
//             hintText: "Enter Barcode",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final barcode = ctrl.text.trim();
//
//               if (barcode.isEmpty) return;
//
//               Navigator.pop(context);
//
//               // 🔥 API CALL
//               final result = await JblApiService.jbl_CuttingcheckBarcode(
//                 barcode: barcode,
//                 supervisor: controller.selectedSupervisor!,
//                 operator: controller.selectedOperator!,
//                 location: unitTitle,
//                 department: department,
//                 plant: unitTitle,
//               );
//
//               final status = (result['status'] ?? '').toString().toLowerCase();
//               final message = result['message'] ?? 'Something went wrong';
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(message),
//                   backgroundColor: status == 'ok' ? Colors.green : Colors.red,
//                 ),
//               );
//
//               if (status == 'ok' || status == 'exists') {
//                 await _loadScannedData();
//               }
//             },
//             child: const Text("Submit"),
//           ),
//         ],
//       ),
//     );
//   }
// }

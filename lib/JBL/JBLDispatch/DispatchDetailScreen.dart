// import 'package:IMS/Color/Colorclass.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../app_colors.dart';
// import 'JblDispatchModel.dart';
//
// class DispatchDetailScreen extends StatefulWidget {
//   final int dispatchNo;
//   const DispatchDetailScreen({super.key, required this.dispatchNo});
//
//   @override
//   State<DispatchDetailScreen> createState() => _DispatchDetailScreenState();
// }
//
// class _DispatchDetailScreenState extends State<DispatchDetailScreen> {
//   final JblApiService _apiService = JblApiService();
//
//   bool _isLoading = true;
//   String? _errorMessage;
//   DispatchDetailResponse? _response;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDispatchDetails();
//   }
//
//   Future<void> _fetchDispatchDetails() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final result = await _apiService.getDispatchDetail(widget.dispatchNo);
//       setState(() {
//         _response = result;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   String _formatDate(String? apiDate) {
//     if (apiDate == null || apiDate.isEmpty) return '-';
//     try {
//       return DateFormat("dd-MMM-yyyy").format(DateTime.parse(apiDate));
//     } catch (_) {
//       return apiDate;
//     }
//   }
//
//   String _safe(dynamic value) => value?.toString() ?? '-';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgColor,
//       appBar: AppBar(
//         title: Text(
//           "Dispatch #${widget.dispatchNo}",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: _fetchDispatchDetails,
//             tooltip: 'Refresh',
//           ),
//         ],
//         iconTheme: IconThemeData(
//           color: Colors.white,
//         ),
//       ),
//       body: _buildBody(),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: C.appBar3,),
//             SizedBox(height: 16),
//             Text('Loading dispatch details...'),
//           ],
//         ),
//       );
//     }
//
//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 48),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _fetchDispatchDetails,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Retry'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Dispatch Items',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           _buildDetailTable(_response?.lineItems ?? []),
//         ],
//       ),
//     );
//   }
//
//   // Widget _summaryRow(String label, String value) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 6),
//   //     child: Row(
//   //       children: [
//   //         SizedBox(
//   //           width: 160,
//   //           child: Text(
//   //             label,
//   //             style: const TextStyle(
//   //               fontWeight: FontWeight.w500,
//   //               color: Colors.grey,
//   //             ),
//   //           ),
//   //         ),
//   //         Expanded(
//   //           child: Text(
//   //             value,
//   //             style: const TextStyle(fontWeight: FontWeight.bold),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // ── Detail Table ───────────────────────────────────────────────────────────
//   Widget _buildDetailTable(List<Map<String, dynamic>> rows) {
//     if (rows.isEmpty) {
//       return const Card(
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Center(child: Text('No line items found.')),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: rows.length,
//       itemBuilder: (context, index) {
//         final row = rows[index];
//
//         return Card(
//           elevation: 5,
//           color: C.brand200,
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: row.entries.map((entry) {
//                 final raw = entry.value;
//
//                 final display =
//                     (raw is String && raw.contains('T') && raw.length >= 10)
//                     ? _formatDate(raw)
//                     : _safe(raw);
//
//                 return _detailRow(_formatHeader(entry.key), display);
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 4,
//             child: Text(
//               label.toUpperCase(),
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//                 color: C.text,
//               ),
//             ),
//           ),
//           const Text(" : "),
//           Expanded(
//             flex: 6,
//             child: Text(value, style: const TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatHeader(String key) {
//     if (key.isEmpty) return key;
//
//     // Add space before capital letters
//     String result = key.replaceAllMapped(
//       RegExp(r'([a-z])([A-Z])'),
//           (match) => '${match.group(1)} ${match.group(2)}',
//     );
//
//     // Capitalize first letter
//     result = result[0].toUpperCase() + result.substring(1);
//
//     return result;
//   }
// }

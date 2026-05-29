// import 'package:flutter/material.dart';
// import '../../Color/Colorclass.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../JBLBailing/modleclass/Bailing_summary_model.dart';
// import 'Bailing_model.dart';
// import 'BalingDetailScreen.dart';
// import 'header.dart';
//
// class JBLBalingReportScreen extends StatefulWidget {
//   const JBLBalingReportScreen({Key? key}) : super(key: key);
//
//   @override
//   State<JBLBalingReportScreen> createState() => _JBLBalingReportScreenState();
// }
//
// class _JBLBalingReportScreenState extends State<JBLBalingReportScreen> {
//   final JblApiService apiService = JblApiService();
//
//   // List<JBLBalingReportModel> originalList = [];
//   // List<JBLBalingReportModel> filteredList = [];
//
//   bool isLoading = false;
//   String _search = "";
//
//
//   DateTime? fromDate;
//   DateTime? toDate;
//   List<BailingSummaryModel> dispatchList = [];
//   List<BailingSummaryModel> filtered_List = [];
//
//   /// Pagination
//   int currentPage = 0;
//   int rowsPerPage = 10;
//   String _formatApiDate(DateTime d) {
//     return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // fetchData();
//     loadDispatchData();
//   }
//
//
//
//   Future<void> loadDispatchData() async {
//     try {
//       setState(() => isLoading = true);
//
//       final data = await JblApiService().getBailingSummary(
//         fromDate: _formatApiDate(
//           fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
//         ),
//         toDate: _formatApiDate(toDate ?? DateTime.now()),
//       );
//
//       setState(() {
//         dispatchList = data;
//         filtered_List = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("ERROR: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   /// 🔥 Apply All Filters
//   void applyFilters() {
//     if (_search.isEmpty) {
//       filtered_List = dispatchList;
//     } else {
//       final query = _search.toLowerCase();
//
//       filtered_List = dispatchList.where((item) {
//         return item.toJson().values
//             .join(' ')
//             .toLowerCase()
//             .contains(query);
//       }).toList();
//     }
//
//     currentPage = 0;
//     setState(() {});
//   }
//
//   /// Pagination Data
//   List<BailingSummaryModel> get paginatedList {
//     final start = currentPage * rowsPerPage;
//     final end = start + rowsPerPage;
//     return filtered_List.sublist(
//       start,
//       end > filtered_List.length ? filtered_List.length : end,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final totalItems = filtered_List.length;
//     final totalPages = (totalItems / rowsPerPage).ceil();
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             color: C.headerTop,
//
//           ),
//         ),
//         elevation: 0,
//         title: const Text(
//           "Baling Report",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.date_range),
//             onPressed: openDateFilter,
//           ),
//         ],
//       ),
//
//       body: Column(
//         children: [
//           /// FILTER SECTION
//           Container(
//             margin: const EdgeInsets.all(12),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: C.cardBg,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: C.brandOp10,
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search anything...",
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: C.brand50,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (v) {
//                 _search = v;
//                 applyFilters();
//               },
//             ),
//           ),
//
//           /// COUNT
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Text("Total Items: $totalItems"),
//             ),
//           ),
//
//           /// TABLE
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
//                 : filtered_List.isEmpty
//                 ? const Center(child: Text("No Data Found"))
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(12),
//                     child: PaginatedDataTable(
//                       columnSpacing: 24,
//                       horizontalMargin: 16,
//                       rowsPerPage: rowsPerPage,
//                       onRowsPerPageChanged: (value) {
//                         setState(() {
//                           rowsPerPage = value ?? 10;
//                         });
//                       },
//                       columns: const [
//                         DataColumn(label: Text("Sr No")),
//                         DataColumn(label: Text("Party Name")),
//                         DataColumn(label: Text("BOM No")),
//                         DataColumn(label: Text("Article No")),
//                         DataColumn(label: Text("Total Qty")),
//                         DataColumn(label: Text("Bag Production")),
//                         DataColumn(label: Text("Bail Qty")),
//                         DataColumn(label: Text("Dispatch Qty")),
//                       ],
//                       source: BalingTableSource(
//                         filtered_List,
//                         onBomTap: (bomNo) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => BalingDetailsScreen(
//                                 bomNo: bomNo,
//                                 fromDate: fromDate,
//                                 toDate: toDate,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//           ),
//
//           /// PAGINATION CONTROLS
//           if (totalPages > 1)
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: currentPage > 0
//                         ? () => setState(() => currentPage--)
//                         : null,
//                     icon: const Icon(Icons.arrow_back),
//                   ),
//
//                   Text("Page ${currentPage + 1} of $totalPages"),
//
//                   IconButton(
//                     onPressed: currentPage < totalPages - 1
//                         ? () => setState(() => currentPage++)
//                         : null,
//                     icon: const Icon(Icons.arrow_forward),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// DATE FILTER
//   void openDateFilter() async {
//     final DateTimeRange? pickedRange = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//       initialDateRange: fromDate != null && toDate != null
//           ? DateTimeRange(start: fromDate!, end: toDate!)
//           : null,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: C.brand700,
//               onPrimary: Colors.white,
//               surface: C.cardBg,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (pickedRange != null) {
//       setState(() {
//         fromDate = pickedRange.start;
//         toDate = pickedRange.end;
//       });
//
//       // applyFilters();
//       await loadDispatchData(); // ✅ API CALL AGAIN
//     }
//   }
//
//   Future<void> pickDate(bool isFrom) async {
//     final date = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//       initialDate: DateTime.now(),
//     );
//
//     if (date != null) {
//       setState(() {
//         if (isFrom) {
//           fromDate = date;
//         } else {
//           toDate = date;
//         }
//       });
//     }
//   }
//
//   Widget _buildTextField(String label, Function(String) onChanged) {
//     return TextField(
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: C.brand50,
//         labelStyle: const TextStyle(color: C.textMid),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: C.borderLight),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: C.brand600, width: 1.5),
//         ),
//       ),
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _buildDateField(String label, DateTime? date, bool isFrom) {
//     return InkWell(
//       onTap: () => pickDate(isFrom),
//       child: InputDecorator(
//         decoration: InputDecoration(labelText: label),
//         child: Text(
//           date == null
//               ? "Select Date"
//               : "${date.day}-${date.month}-${date.year}",
//         ),
//       ),
//     );
//   }
// }

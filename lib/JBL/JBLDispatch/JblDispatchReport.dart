// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../Color/Colorclass.dart';
// import '../../routes/app_routes.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../app_colors.dart';
// import 'JblDispatchModel.dart';
//
// class JblDispatchReportScreen extends StatefulWidget {
//   const JblDispatchReportScreen({super.key});
//
//   @override
//   State<JblDispatchReportScreen> createState() =>
//       _JblDispatchReportScreenState();
// }
//
// class _JblDispatchReportScreenState extends State<JblDispatchReportScreen> {
//   bool isLoading = true;
//   List<DispatchModel> dispatchList = [];
//   late final sw = MediaQuery.of(context).size.width;
//
//   List<DispatchModel> filteredList = [];
//   late final isSmall = sw < 400;
//   TextEditingController searchController = TextEditingController();
//   int currentPage = 1;
//   int rowsPerPage = 10;
//   DateTime _fromDate = DateTime.now().subtract(
//     const Duration(days: 30),
//   ); // ← add this
//   DateTime _toDate = DateTime.now();
//   @override
//   void initState() {
//     super.initState();
//     loadDispatchData();
//   }
//
//   Future<void> loadDispatchData() async {
//     try {
//       final data = await JblApiService().getDispatchReport();
//
//       setState(() {
//         dispatchList = data;
//         filteredList = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void filterDispatch(String query) {
//     final lowerQuery = query.toLowerCase();
//
//     setState(() {
//       filteredList = dispatchList.where((item) {
//         return item.dispatchNo.toString().contains(lowerQuery) ||
//             item.partyName.toLowerCase().contains(lowerQuery);
//       }).toList();
//
//       currentPage = 1;
//     });
//   }
//
//   List<DispatchModel> get paginatedList {
//     final start = (currentPage - 1) * rowsPerPage;
//     final end = start + rowsPerPage;
//
//     return filteredList.sublist(
//       start,
//       end > filteredList.length ? filteredList.length : end,
//     );
//   }
//
//   int get totalPages => (filteredList.length / rowsPerPage).ceil();
//
//   String formatDate(String apiDate) {
//     DateTime dt = DateTime.parse(apiDate);
//     return DateFormat("dd-MMM-yyyy").format(dt);
//   }
//   Future<void> _pickDateRange() async {
//     final range = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: DateTimeRange(
//         start: _fromDate,
//         end: _toDate,
//       ),
//     );
//
//     if (range != null) {
//       setState(() {
//         _fromDate = range.start;
//         _toDate = range.end;
//         isLoading = true;
//       });
//
//       await loadDispatchData(); // ✅ reload data with new dates
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgColor,
//       appBar: AppBar(
//         backgroundColor: C.primaryBlue,
//         title: const Text(
//           "Dispatch Reports",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: GestureDetector(
//               onTap: _pickDateRange, // ✅ CLICK ENABLED
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.calendar_today_rounded,
//                     color: Colors.white,
//                     size: 22,
//                   ),
//
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
//           : dispatchList.isEmpty
//           ? const Center(child: Text("No Data Found"))
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.15),
//                           blurRadius: 8,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: searchController,
//                       onChanged: filterDispatch,
//                       style: const TextStyle(fontSize: 14),
//                       decoration: InputDecoration(
//                         hintText: "Search Dispatch No or Party Name",
//                         hintStyle: TextStyle(color: Colors.grey.shade500),
//
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: AppColors.primaryColor,
//                         ),
//
//                         suffixIcon: searchController.text.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(Icons.close),
//                                 onPressed: () {
//                                   searchController.clear();
//                                   filterDispatch("");
//                                   setState(() {});
//                                 },
//                               )
//                             : null,
//
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 10,
//                         ),
//
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 /// LIST
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: paginatedList.length,
//                     itemBuilder: (context, index) {
//                       final item = paginatedList[index];
//                       return _dispatchCard(item);
//                     },
//                   ),
//                 ),
//
//                 /// PAGINATION
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         onPressed: currentPage > 1
//                             ? () {
//                                 setState(() {
//                                   currentPage--;
//                                 });
//                               }
//                             : null,
//                         icon: const Icon(Icons.arrow_back),
//                       ),
//                       Text(
//                         "Page $currentPage of $totalPages",
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       IconButton(
//                         onPressed: currentPage < totalPages
//                             ? () {
//                                 setState(() {
//                                   currentPage++;
//                                 });
//                               }
//                             : null,
//                         icon: const Icon(Icons.arrow_forward),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
//
//   /// DISPATCH CARD UI
//   Widget _dispatchCard(DispatchModel item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(.15),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// DISPATCH NO + DATE
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "DIS.NO : ${item.dispatchNo}",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               Text(
//                 formatDate(item.date),
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 6),
//
//           /// PARTY
//           Text(
//             item.partyName,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//           ),
//
//           const SizedBox(height: 10),
//
//           /// PO + INVOICE
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "PO : ${item.poNo}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   "INV : ${item.invoiceNo}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 8),
//
//           /// TRANSPORT + VEHICLE
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "Transport : ${item.transportName}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   "Vehicle : ${item.vehicleNo}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 8),
//
//           /// PCS + COUNT
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "PCS : ${item.totalPcs}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   "COUNT : ${item.totalCount}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 6),
//
//           /// WEIGHT
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "GWT : ${item.totalGwt}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   "NET WT : ${item.totalNetWt}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//
//           /// DETAIL BUTTON
//           Align(
//             alignment: Alignment.centerRight,
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.primaryColor,
//               ),
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   AppRoutes.jblDispatchDetail,
//                   arguments: item.dispatchNo,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

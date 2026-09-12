// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../Color/Colorclass.dart';
// import '../../../services/getSupervisors/getSupervisors.dart';
// import 'RecutPOPupNardana.dart';
// import 'modelclass/CutPcsItemNardana.dart';
//
// class CutPieceIssuedScreenNardana extends StatefulWidget {
//   const CutPieceIssuedScreenNardana({super.key});
//
//   @override
//   State<CutPieceIssuedScreenNardana> createState() =>
//       _CutPieceIssuedScreenNardanaState();
// }
//
// class _CutPieceIssuedScreenNardanaState
//     extends State<CutPieceIssuedScreenNardana> {
//   List<CutPcsItemNardana> data = [];
//   bool loading = true;
//   DateTime? fromDate;
//   DateTime? toDate;
//   int? selectedIndex;
//   int _currentPage = 1;
//   int _rowsPerPage = 10;
//   String searchQuery = "";
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   // ───────── LOAD DATA ─────────
//   Future<void> loadData() async {
//     setState(() => loading = true);
//     try {
//       final result = await InStockService.getCuttingIssuedList(
//         fromDate ?? DateTime(2026, 1, 1),
//         toDate ?? DateTime.now(),
//       );
//       setState(() {
//         data = result;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//     }
//   }
//
//   // ───────── DATE FILTER ─────────
//   // List<CutPcsItemNardana> get _filtered {
//   //   if (fromDate == null || toDate == null) return data;
//   //   return data.where((e) {
//   //     if (e.receiveDate.isEmpty) return false;           // ✅ receiveDate
//   //     final d = DateTime.tryParse(e.receiveDate);        // ✅ receiveDate
//   //     if (d == null) return false;
//   //     final end = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
//   //     return !d.isBefore(fromDate!) && !d.isAfter(end);
//   //   }).toList();
//   // }
//
//
//   List<CutPcsItemNardana> get _filtered {
//     return data.where((e) {
//       // ───── SEARCH FILTER ─────
//       final searchMatch =
//           searchQuery.isEmpty ||
//               e.partyName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               e.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               e.component.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               e.poNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               e.articleNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               e.bom.toLowerCase().contains(searchQuery.toLowerCase());
//
//       // ───── DATE FILTER ─────
//       bool dateMatch = true;
//
//       if (fromDate != null && toDate != null) {
//         if (e.receiveDate.isEmpty) return false;
//
//         final d = DateTime.tryParse(e.receiveDate);
//         if (d == null) return false;
//
//         final end = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
//
//         dateMatch = !d.isBefore(fromDate!) && !d.isAfter(end);
//       }
//
//       return searchMatch && dateMatch;
//     }).toList();
//   }
//
//
//
//
//
//   // ───────── PAGINATION ─────────
//   List<CutPcsItemNardana> get _pageItems {
//     final all = _filtered;
//     final start = (_currentPage - 1) * _rowsPerPage;
//     if (start >= all.length) return [];
//     final end = (start + _rowsPerPage).clamp(0, all.length);
//     return all.sublist(start, end);
//   }
//
//   int get _totalPages =>
//       (_filtered.length / _rowsPerPage).ceil().clamp(1, 999999);
//
//   void _resetPage() => setState(() {
//     _currentPage = 1;
//     selectedIndex = null;
//   });
//
//   // ───────── DATE PICKER ─────────
//   Future<void> pickDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         fromDate = picked.start;
//         toDate = picked.end;
//       });
//       await loadData();
//       _resetPage();
//     }
//   }
//
//   void clearDateFilter() {
//     setState(() {
//       fromDate = null;
//       toDate = null;
//     });
//     _resetPage();
//   }
//
//   String _fmt(String raw) {
//     final d = DateTime.tryParse(raw);
//     return d != null ? DateFormat("dd-MMM-yyyy").format(d) : raw;
//   }
//
//
//
//   // ───────── UI ─────────
//   @override
//   Widget build(BuildContext context) {
//     final pageItems = _pageItems;
//     final isFiltered = fromDate != null && toDate != null;
//
//     return Scaffold(
//       backgroundColor: C.pageBg,
//       appBar: AppBar(
//         backgroundColor: C.primary,
//         title: const Text(
//           "Issue Process",
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           if (isFiltered)
//             IconButton(
//               icon: const Icon(Icons.filter_alt_off, color: Colors.white),
//               onPressed: clearDateFilter,
//             ),
//           IconButton(
//             icon: const Icon(Icons.date_range, color: Colors.white),
//             onPressed: pickDateRange,
//           ),
//
//         ],
//         iconTheme: IconThemeData(color: C.bg),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // ── Record Count Pill ──
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: C.textHigh,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: C.brand300),
//                 ),
//                 child: Text(
//                   '${_filtered.length} record${_filtered.length != 1 ? 's' : ''}',
//                   style: const TextStyle(
//                     color: C.bg,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.15),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 onChanged: (v) {
//                   setState(() {
//                     searchQuery = v;
//                     _resetPage();
//                   });
//                 },
//                 style: const TextStyle(fontSize: 14),
//                 decoration: InputDecoration(
//                   hintText: "Search Party, Customer, BOM, PO No...",
//                   hintStyle: TextStyle(color: Colors.grey.shade500),
//
//                   prefixIcon: Icon(Icons.search, color: C.primary),
//
//                   suffixIcon: searchQuery.isNotEmpty
//                       ? IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       setState(() {
//                         searchQuery = "";
//                         _resetPage();
//                       });
//                     },
//                   )
//                       : null,
//
//                   filled: true,
//                   fillColor: Colors.white,
//
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 14,
//                     horizontal: 10,
//                   ),
//
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey.shade200),
//                   ),
//
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: C.primary, width: 1.5),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // ── Table ──
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 20,
//                 headingRowColor: WidgetStateProperty.all(C.brand100),
//                 columns: const [
//                   DataColumn(label: Text("ID")),
//                   DataColumn(label: Text("BOM")),
//                   DataColumn(label: Text("Date")),
//                   DataColumn(label: Text("Party")),          // ✅ partyName
//                   DataColumn(label: Text("Customer")),       // ✅ customerName
//                   DataColumn(label: Text("Component")),
//                   DataColumn(label: Text("Net Wt")),
//                   DataColumn(label: Text("PCS")),
//                   DataColumn(label: Text("Width")),
//                   DataColumn(label: Text("Cut Length")),
//                   DataColumn(label: Text("Per Pcs Wt")),
//                   DataColumn(label: Text("Used PCS")),       // ✅ usedPcs
//                   DataColumn(label: Text("Used KG")),        // ✅ usedKg
//                   DataColumn(label: Text("Rem. PCS")),       // ✅ remainingPcs
//                   DataColumn(label: Text("Rem. KG")),        // ✅ remainingKg
//                   DataColumn(label: Text("PO No")),          // ✅ poNo
//                   DataColumn(label: Text("Article No")),     // ✅ articleNo
//
//                 ],
//                 rows: pageItems.map((item) {
//                   return DataRow(
//                     selected: selectedIndex == pageItems.indexOf(item),
//                     onSelectChanged: (_) {
//                       setState(() => selectedIndex = pageItems.indexOf(item));
//
//
//                       AddRecutPcsPopupNardana.show(
//                         context,
//                         iid:          item.iid,
//                         // woNumber:     item.bom,
//                         partyName:    item.partyName,       // ✅
//
//
//                         width:        item.width,           // ✅
//                         cutLength:    item.cutLength,       // ✅
//                         perPcsWt:     item.perPcsWt,        // ✅
//
//                         onSaved:      () => loadData(),
//                       );
//                     },
//                     cells: [
//                       DataCell(Text(item.iid.toString(),style: TextStyle(color: C.success),)),
//                       DataCell(Text(item.bom,style: TextStyle(color: C.success),)),
//
//                       DataCell(Text(_fmt(item.receiveDate))),        // ✅ receiveDate
//                       DataCell(Text(item.partyName)),                // ✅ partyName
//                       DataCell(Text(item.customerName)),             // ✅ customerName
//                       DataCell(Text(item.component)),
//                       DataCell(Text(item.netWt.toStringAsFixed(2))),
//                       DataCell(Text(item.pcs.toString())),
//                       DataCell(Text(item.width.toStringAsFixed(2))),
//                       DataCell(Text(item.cutLength.toStringAsFixed(2))),
//                       DataCell(Text(item.perPcsWt.toStringAsFixed(3))),
//                       DataCell(Text(item.usedPcs.toString())),       // ✅ usedPcs
//                       DataCell(Text(item.usedKg.toStringAsFixed(2))),// ✅ usedKg
//                       DataCell(Text(item.remainingPcs.toString())),  // ✅ remainingPcs
//                       DataCell(Text(item.remainingKg.toStringAsFixed(2))), // ✅ remainingKg
//                       DataCell(Text(item.poNo)),                     // ✅ poNo
//                       DataCell(Text(item.articleNo)),                // ✅ articleNo
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//
//           // ── Pagination Bar ──
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left),
//                 onPressed: _currentPage > 1
//                     ? () => setState(() => _currentPage--)
//                     : null,
//               ),
//               Text("Page $_currentPage / $_totalPages"),
//               IconButton(
//                 icon: const Icon(Icons.chevron_right),
//                 onPressed: _currentPage < _totalPages
//                     ? () => setState(() => _currentPage++)
//                     : null,
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }
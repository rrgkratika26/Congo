// import 'package:flutter/material.dart';
// import '../../../Color/Colorclass.dart';
// import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../../JBL_Cutting/ModelClass/CuttinfType.dart';
//
// class WebbingReportScreen extends StatefulWidget {
//   final String type;
//   const WebbingReportScreen({super.key, required this.type});
//
//   @override
//   State<WebbingReportScreen> createState() => _WebbingReportScreenState();
// }
//
// class _WebbingReportScreenState extends State<WebbingReportScreen> {
//   final JblApiService _api = JblApiService();
//
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//   String _search = '';
//   late TextEditingController _searchCtrl;
//
//   List<BaseModel> _data = [];
//   bool _loading = true;
//   String _currentType = '';
//
//   int _rowsPerPage = 10;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _searchCtrl = TextEditingController();
//     _currentType = widget.type; // ✅ important
//     _fetchData();
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   String _fmt(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   List<BaseModel> get _filteredData {
//     if (_search.isEmpty) return _data;
//     final q = _search.toLowerCase();
//     return _data.where((row) {
//       final map = row.toJson();
//       return map.values.join(' ').toLowerCase().contains(q);
//     }).toList();
//   }
//
//   List<BaseModel> get _paginatedData {
//     final start = _currentPage * _rowsPerPage;
//     final end = (start + _rowsPerPage).clamp(0, _filteredData.length);
//     return _filteredData.sublist(start, end);
//   }
//
//   int get _totalPages => (_filteredData.isEmpty)
//       ? 1
//       : (_filteredData.length / _rowsPerPage).ceil();
//
//   Future<void> _fetchData() async {
//     setState(() => _loading = true);
//     try {
//       final res = await JblApiService.getWebbingReport(
//         // 🔁 update to your actual API method
//         // type: widget.type,
//         type: _currentType,
//         fromDate: _fmt(_fromDate),
//         toDate: _fmt(_toDate),
//         plant: "JBL",
//       );
//       setState(() {
//         _data = res;
//         _currentPage = 0;
//       });
//     } catch (e) {
//       debugPrint("Error: $e");
//     }
//     setState(() => _loading = false);
//   }
//
//   Future<void> _pickDateRange() async {
//     final range = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: C.primaryBlue,
//             onPrimary: Colors.white,
//             surface: C.cardBg,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (range != null) {
//       setState(() {
//         _fromDate = range.start;
//         _toDate = range.end;
//       });
//       _fetchData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.pageBg,
//       body: Column(
//         children: [
//           _buildHeader(),
//           _buildFilterBar(),
//           Expanded(child: _buildBody()),
//           _buildPaginationBar(),
//         ],
//       ),
//     );
//   }
//
//   // ── HEADER ──────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [C.headerTop, C.headerMid],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x303F88F5),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
//           child: Row(
//             children: [
//               // Back button
//               IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//               ),
//
//               // Title
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "${widget.type} Webbing",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     const SizedBox(width: 2),
//                     Text(
//                       "Report",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Date range chip
//               GestureDetector(
//                 onTap: _pickDateRange,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.calendar_today,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 4),
//
//               // Refresh
//               IconButton(
//                 icon: const Icon(
//                   Icons.refresh_rounded,
//                   color: Colors.white,
//                   size: 21,
//                 ),
//                 onPressed: _fetchData,
//               ),
//               // JBL Button
//               // Container(
//               //
//               //   margin: const EdgeInsets.only(right: 6),
//               //   child: ElevatedButton(
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: Colors.white,
//               //       foregroundColor: C.brand700,
//               //       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(10),
//               //       ),
//               //       elevation: 2,
//               //     ),
//               //     onPressed: () async {
//               //       setState(() {
//               //         widget.type; // keep existing UI label if needed
//               //       });
//               //
//               //       setState(() => _loading = true);
//               //
//               //       try {
//               //         final res = await JblApiService.getWebbingReport(
//               //           type: "OUT", // 🔥 force OUT
//               //           fromDate: _fmt(_fromDate),
//               //           toDate: _fmt(_toDate),
//               //           plant: "JBL",
//               //         );
//               //
//               //         setState(() {
//               //           _data = res;
//               //           _currentPage = 0;
//               //         });
//               //       } catch (e) {
//               //         debugPrint("JBL Button Error: $e");
//               //       }
//               //
//               //       setState(() => _loading = false);
//               //     },
//               //     child: const Text(
//               //       "JBL",
//               //       style: TextStyle(fontSize: 15,color: C.primary, fontWeight: FontWeight.w700),
//               //     ),
//               //   ),
//               // ),
//               Container(
//                 height: 40,
//                 margin: const EdgeInsets.only(right: 6),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                     _currentType == "OUT" ? C.primary : Colors.grey.shade300, // 🎯
//                     foregroundColor:
//                     _currentType == "OUT" ? C.bgColor : Colors.grey.shade600,   // 🎯
//                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//
//                     elevation: _currentType == "OUT" ? 3 : 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () async {
//                     if (_currentType == "OUT") return; // 🚫 already active, do nothing
//
//                     setState(() {
//                       _currentType = "OUT"; // ✅ activate JBL
//                     });
//
//                     await _fetchData();
//                   },
//                   child: const Text(
//                     "JBL",
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── FILTER BAR ───────────────────────────────────────────────
//   Widget _buildFilterBar() {
//     return Container(
//       color: C.cardBg,
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//       child: Row(
//         children: [
//           // Search
//           Expanded(
//             child: SizedBox(
//               height: 42,
//               child: TextField(
//                 controller: _searchCtrl,
//                 onChanged: (v) => setState(() {
//                   _search = v;
//                   _currentPage = 0;
//                 }),
//                 style: const TextStyle(fontSize: 14, color: C.textHigh),
//                 decoration: InputDecoration(
//                   hintText: "Search records...",
//                   hintStyle: const TextStyle(fontSize: 13, color: C.textLow),
//                   prefixIcon: const Icon(
//                     Icons.search_rounded,
//                     color: C.brand500,
//                     size: 20,
//                   ),
//                   suffixIcon: _search.isNotEmpty
//                       ? GestureDetector(
//                           onTap: () => setState(() {
//                             _search = '';
//                             _searchCtrl.clear();
//                           }),
//                           child: const Icon(
//                             Icons.close_rounded,
//                             size: 18,
//                             color: C.textMid,
//                           ),
//                         )
//                       : null,
//                   contentPadding: EdgeInsets.zero,
//                   filled: true,
//                   fillColor: C.brand50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: C.borderLight),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: C.borderLight),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: C.brand500, width: 1.5),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 10),
//
//           // Rows per page
//           Container(
//             height: 42,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               color: C.brand50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: C.borderLight),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<int>(
//                 value: _rowsPerPage,
//                 isDense: true,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: C.textHigh,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 items: [10, 20, 50]
//                     .map(
//                       (e) => DropdownMenuItem(value: e, child: Text("$e rows")),
//                     )
//                     .toList(),
//                 onChanged: (val) => setState(() {
//                   _rowsPerPage = val!;
//                   _currentPage = 0;
//                 }),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 10),
//
//           // Count badge
//           Container(
//             height: 42,
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [C.brand600, C.brand500],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               "${_filteredData.length}",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── BODY ─────────────────────────────────────────────────────
//   Widget _buildBody() {
//     if (_loading) {
//       return const Center(
//         child: CircularProgressIndicator(color: C.brand600, strokeWidth: 2.5),
//       );
//     }
//
//     if (_filteredData.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                 color: C.brand50,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.inbox_outlined,
//                 size: 48,
//                 color: C.brand300,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "No records found",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: C.textHigh,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Try adjusting your date range or search",
//               style: TextStyle(fontSize: 13, color: C.textMid),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final cols = _filteredData.first.toJson().keys.toList();
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: C.cardBg,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: C.borderLight),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x0F2C3A5A),
//               blurRadius: 12,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SingleChildScrollView(
//               child: DataTable(
//                 headingRowHeight: 44,
//                 dataRowMinHeight: 44,
//                 dataRowMaxHeight: 48,
//                 dividerThickness: 0.8,
//                 columnSpacing: 24,
//                 headingRowColor: MaterialStateProperty.all(C.brand100),
//                 dataRowColor: MaterialStateProperty.resolveWith((states) {
//                   if (states.contains(MaterialState.selected)) {
//                     return C.brand50;
//                   }
//                   return null;
//                 }),
//                 columns: cols
//                     .map(
//                       (c) => DataColumn(
//                         label: Text(
//                           c,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 13,
//                             color: C.brand800,
//                             letterSpacing: 0.2,
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//                 rows: List.generate(_paginatedData.length, (i) {
//                   final row = _paginatedData[i];
//                   final map = row.toJson();
//                   return DataRow(
//                     color: MaterialStateProperty.resolveWith(
//                       (states) =>
//                           i.isEven ? Colors.white : C.brand50.withOpacity(0.5),
//                     ),
//                     cells: cols
//                         .map(
//                           (c) => DataCell(
//                             Text(
//                               formatDate(map[c]),
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: C.textHigh,
//                               ),
//                             ),
//                           ),
//                         )
//                         .toList(),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── PAGINATION ───────────────────────────────────────────────
//   Widget _buildPaginationBar() {
//     return Container(
//       color: C.cardBg,
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//       child: Row(
//         children: [
//           // Page info
//           Text(
//             "Page ${_currentPage + 1} of $_totalPages",
//             style: const TextStyle(
//               fontSize: 12,
//               color: C.textMid,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//
//           const SizedBox(width: 8),
//
//           // Page numbers — scrollable horizontally
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _NavButton(
//                     icon: Icons.chevron_left_rounded,
//                     enabled: _currentPage > 0,
//                     onTap: () => setState(() => _currentPage--),
//                   ),
//                   const SizedBox(width: 4),
//                   ..._buildPageNumbers(),
//                   const SizedBox(width: 4),
//                   _NavButton(
//                     icon: Icons.chevron_right_rounded,
//                     enabled: _currentPage < _totalPages - 1,
//                     onTap: () => setState(() => _currentPage++),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildPageNumbers() {
//     final pages = <Widget>[];
//     final start = (_currentPage - 2).clamp(
//       0,
//       (_totalPages - 5).clamp(0, _totalPages),
//     );
//     final end = (start + 5).clamp(0, _totalPages);
//
//     for (int i = start; i < end; i++) {
//       final isActive = i == _currentPage;
//       pages.add(
//         GestureDetector(
//           onTap: () => setState(() => _currentPage = i),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 30, // ✅ 32 → 30 thoda chhota
//             height: 30,
//             margin: const EdgeInsets.symmetric(horizontal: 2),
//             decoration: BoxDecoration(
//               color: isActive ? C.brand600 : Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               border: isActive ? null : Border.all(color: C.borderLight),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               "${i + 1}",
//               style: TextStyle(
//                 fontSize: 12, // ✅ 13 → 12
//                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                 color: isActive ? Colors.white : C.textMid,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     return pages;
//   }
//
//   String formatDate(dynamic value) {
//     if (value == null) return '—';
//     DateTime? dt;
//
//     if (value is String) {
//       dt = DateTime.tryParse(value);
//     } else if (value is DateTime) {
//       dt = value;
//     }
//
//     if (dt == null) return value.toString(); // fallback
//     return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
//   }
// }
//
// // ── NAV BUTTON WIDGET ────────────────────────────────────────
// class _NavButton extends StatelessWidget {
//   final IconData icon;
//   final bool enabled;
//   final VoidCallback onTap;
//
//   const _NavButton({
//     required this.icon,
//     required this.enabled,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: enabled ? C.brand50 : C.pageBg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: enabled ? C.borderLight : C.divider),
//         ),
//         alignment: Alignment.center,
//         child: Icon(icon, size: 20, color: enabled ? C.brand700 : C.textLow),
//       ),
//     );
//   }
// }

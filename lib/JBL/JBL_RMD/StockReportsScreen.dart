// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// //
// // import '../../Color/Colorclass.dart';
// // import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// //
// // class RmdStockScreen extends StatefulWidget {
// //   const RmdStockScreen({super.key});
// //
// //   @override
// //   State<RmdStockScreen> createState() => _RmdStockScreenState();
// // }
// //
// // class _RmdStockScreenState extends State<RmdStockScreen> {
// //   final JblApiService _api = JblApiService();
// //   DateTime _fromDate = DateTime.now();
// //   DateTime _toDate = DateTime.now();
// //   List<dynamic> _data = [];
// //   bool _loading = true;
// //
// //   String _search = '';
// //   final TextEditingController _searchCtrl = TextEditingController();
// //
// //   DateTime _selectedDate = DateTime.now();
// //
// //   // ─────────────────────────────────────────────
// //   String _fmt(DateTime d) =>
// //       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   Future<void> _fetchData() async {
// //     setState(() => _loading = true);
// //
// //     try {
// //       final res = await _api.getRmdStock(
// //         plant: "JBL",
// //         fromDate: _fmt(_fromDate),
// //         toDate: _fmt(_toDate),
// //       );
// //       print("API DATA: $res");
// //       setState(() => _data = res);
// //     } catch (e) {
// //       debugPrint("ERROR: $e");
// //     }
// //
// //     setState(() => _loading = false);
// //   }
// //
// //   Future<void> _pickDateRange() async {
// //     final picked = await showDateRangePicker(
// //       context: context,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
// //     );
// //
// //     if (picked != null) {
// //       setState(() {
// //         _fromDate = picked.start;
// //         _toDate = picked.end;
// //       });
// //
// //       _fetchData();
// //     }
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   List<dynamic> _filtered() {
// //     if (_search.isEmpty) return _data;
// //
// //     return _data.where((row) {
// //       return row.values.join(' ').toLowerCase().contains(_search.toLowerCase());
// //     }).toList();
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   Future<void> _pickDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //     );
// //
// //     if (picked != null) {
// //       setState(() => _selectedDate = picked);
// //       _fetchData();
// //     }
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     final rows = _filtered();
// //
// //     return Scaffold(
// //       backgroundColor: C.pageBg,
// //       appBar: AppBar(
// //         title: const Text("RMD Stock"),
// //         backgroundColor: C.bgrColor,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.calendar_today),
// //               onPressed: _pickDateRange,
// //           ),
// //           IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
// //         ],
// //       ),
// //
// //       body: Column(
// //         children: [
// //           // 🔍 SEARCH BAR
// //           Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: TextField(
// //               controller: _searchCtrl,
// //               onChanged: (v) => setState(() => _search = v),
// //               decoration: InputDecoration(
// //                 hintText: "Search...",
// //                 prefixIcon: const Icon(Icons.search),
// //                 suffixIcon: _search.isNotEmpty
// //                     ? IconButton(
// //                         icon: const Icon(Icons.close),
// //                         onPressed: () {
// //                           _searchCtrl.clear();
// //                           setState(() => _search = '');
// //                         },
// //                       )
// //                     : null,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // 📊 TABLE
// //           Expanded(
// //             child: _loading
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : rows.isEmpty
// //                 ? const Center(child: Text("No Data Found"))
// //                 : SingleChildScrollView(
// //                     scrollDirection: Axis.vertical,
// //                     child: SingleChildScrollView(
// //                       scrollDirection: Axis.horizontal,
// //                       child: _buildTable(rows),
// //                     ),
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   Widget _buildTable(List<dynamic> rows) {
// //     if (rows.isEmpty) {
// //       return const Center(child: Text("No Data Available"));
// //     }
// //
// //     final cols = (rows.first as Map<String, dynamic>).keys.toList();
// //
// //     String formatHeader(String key) {
// //       return key
// //           .replaceAll('_', ' ')
// //           .toLowerCase()
// //           .split(' ')
// //           .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '')
// //           .join(' ');
// //     }
// //
// //     return Container(
// //       margin: const EdgeInsets.all(8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Column(
// //         children: [
// //           // 🔷 HEADER
// //           Container(
// //             decoration: BoxDecoration(
// //               color: C.primaryBlue,
// //               borderRadius: const BorderRadius.vertical(
// //                 top: Radius.circular(12),
// //               ),
// //             ),
// //             child: Row(
// //               children: cols.map<Widget>((c) {
// //                 return Container(
// //                   width: 100,
// //                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
// //                   child: Text(
// //                     formatHeader(c),
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //
// //           // 🔶 BODY
// //           ...rows.asMap().entries.map<Widget>((entry) {
// //             int index = entry.key;
// //             final row = entry.value as Map<String, dynamic>;
// //
// //             return Container(
// //               color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
// //               child: Row(
// //                 children: cols.map<Widget>((c) {
// //                   String value = row[c]?.toString() ?? '';
// //
// //                   return Container(
// //                     width: 100,
// //                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
// //                     child: Text(value),
// //                   );
// //                 }).toList(),
// //               ),
// //             );
// //           }).toList(),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:IMS/Color/Colorclass.dart';
// import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// class RmdStockScreen extends StatefulWidget {
//   const RmdStockScreen({super.key});
//
//   @override
//   State<RmdStockScreen> createState() => _RmdStockScreenState();
// }
//
// class _RmdStockScreenState extends State<RmdStockScreen> {
//   final JblApiService _api = JblApiService();
//
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//
//   List<dynamic> _data = [];
//   bool _loading = true;
//
//   String _search = '';
//   final TextEditingController _searchCtrl = TextEditingController();
//
//   // ── helpers ────────────────────────────────────────────────────────────────
//   String _fmt(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   bool get _isToday =>
//       _fmt(_fromDate) == _fmt(DateTime.now()) &&
//       _fmt(_toDate) == _fmt(DateTime.now());
//
//   List<dynamic> get _filtered {
//     if (_search.isEmpty) return _data;
//     final q = _search.toLowerCase();
//     return _data.where((row) {
//       try {
//         return (row as Map).values.join(' ').toLowerCase().contains(q);
//       } catch (_) {
//         return false;
//       }
//     }).toList();
//   }
//
//   // ── lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── fetch ──────────────────────────────────────────────────────────────────
//   Future<void> _fetchData() async {
//     if (!mounted) return;
//     setState(() => _loading = true);
//     try {
//       final res = await _api.getRmdStock(
//         plant: 'JBL',
//         fromDate: _fmt(_fromDate),
//         toDate: _fmt(_toDate),
//       );
//       if (!mounted) return;
//       setState(() => _data = res);
//     } catch (e) {
//       debugPrint('RmdStock ERROR: $e');
//     }
//     if (!mounted) return;
//     setState(() => _loading = false);
//   }
//
//   // ── date range picker ──────────────────────────────────────────────────────
//   Future<void> _pickDateRange() async {
//     final range = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: C.primaryBlue,
//             onPrimary: Colors.white,
//             surface: C.bgrColor,
//             onSurface: C.textHigh,
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
//   // ── build ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.pageBg,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }
//
//   // ── AppBar ─────────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() => AppBar(
//     elevation: 0,
//     backgroundColor: C.bgrColor,
//     surfaceTintColor: Colors.transparent,
//     systemOverlayStyle: SystemUiOverlayStyle.dark,
//     titleSpacing: 0,
//     leading: IconButton(
//       icon: const Icon(
//         Icons.arrow_back_ios_new_rounded,
//         size: 18,
//         color: C.textHigh,
//       ),
//       onPressed: () => Navigator.pop(context),
//     ),
//     title: Text(
//       'RMD Stock',
//       style: TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w800,
//         color: C.textHigh,
//         letterSpacing: -0.2,
//       ),
//     ),
//     actions: [
//       IconButton(
//         icon: const Icon(Icons.calendar_today),
//         onPressed: _pickDateRange,
//       ),
//       IconButton(
//         icon: const Icon(Icons.refresh_rounded, color: C.textMid, size: 20),
//         tooltip: 'Refresh',
//         onPressed: () {
//           HapticFeedback.lightImpact();
//           _fetchData();
//         },
//       ),
//       const SizedBox(width: 4),
//     ],
//     bottom: PreferredSize(
//       preferredSize: const Size.fromHeight(1),
//       child: Container(height: 1, color: C.borderLight),
//     ),
//   );
//
//   // ── Search bar ─────────────────────────────────────────────────────────────
//   Widget _buildSearchBar() {
//     final count = _filtered.length;
//     return Container(
//       color: C.bgrColor,
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 42,
//               decoration: BoxDecoration(
//                 color: C.brand50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: C.borderLight),
//               ),
//               child: TextField(
//                 controller: _searchCtrl,
//                 onChanged: (v) => setState(() => _search = v),
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: C.textHigh,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search records…',
//                   hintStyle: const TextStyle(color: C.textLow, fontSize: 13),
//                   prefixIcon: const Icon(
//                     Icons.search_rounded,
//                     color: C.textMid,
//                     size: 18,
//                   ),
//                   suffixIcon: _search.isNotEmpty
//                       ? GestureDetector(
//                           onTap: () {
//                             setState(() => _search = '');
//                             _searchCtrl.clear();
//                           },
//                           child: const Icon(
//                             Icons.close_rounded,
//                             color: C.textMid,
//                             size: 16,
//                           ),
//                         )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: _loading
//                 ? SizedBox(
//                     key: const ValueKey('spin'),
//                     width: 46,
//                     height: 42,
//                     child: Center(
//                       child: SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: C.appBar3,
//                         ),
//                       ),
//                     ),
//                   )
//                 : Container(
//                     key: ValueKey('cnt-$count'),
//                     width: 46,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: C.lightBlue,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: C.primaryBlue.withOpacity(0.25),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '$count',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w900,
//                             color: C.primaryBlue,
//                           ),
//                         ),
//                         Text(
//                           'rows',
//                           style: TextStyle(
//                             fontSize: 8,
//                             fontWeight: FontWeight.w600,
//                             color: C.primaryBlue.withOpacity(0.65),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Body ───────────────────────────────────────────────────────────────────
//   Widget _buildBody() {
//     if (_loading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(
//               strokeWidth: 3,
//               color: C.appBar3,
//             ),
//             const SizedBox(height: 14),
//             const Text(
//               'Loading stock data…',
//               style: TextStyle(
//                 color: C.textMid,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final rows = _filtered;
//
//     if (rows.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 68,
//               height: 68,
//               decoration: BoxDecoration(
//                 color: C.lightBlue,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: C.primaryBlue.withOpacity(0.18)),
//               ),
//               child: Icon(
//                 Icons.inventory_2_rounded,
//                 size: 30,
//                 color: C.primaryBlue.withOpacity(0.55),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _search.isNotEmpty
//                   ? 'No results for "$_search"'
//                   : 'No Data Found',
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: C.textHigh,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               _search.isNotEmpty
//                   ? 'Try a different keyword'
//                   : 'No stock records for the selected range',
//               style: const TextStyle(fontSize: 12, color: C.textMid),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final cols = (rows.first as Map<String, dynamic>).keys.toList();
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
//         child: _buildTable(cols, rows),
//       ),
//     );
//   }
//
//   // ── Table ──────────────────────────────────────────────────────────────────
//   Widget _buildTable(List<String> cols, List<dynamic> rows) {
//     String _fmtHeader(String key) => key
//         .replaceAll('_', ' ')
//         .toLowerCase()
//         .split(' ')
//         .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '')
//         .join(' ');
//
//     return Container(
//       decoration: BoxDecoration(
//         color: C.cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: C.borderLight),
//         boxShadow: [
//           BoxShadow(
//             color: C.brandOp10,
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Gradient header
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(colors: [C.primaryBlue, C.headerBlue]),
//             ),
//             child: Row(
//               children: cols
//                   .map((c) => _HeaderCell(label: _fmtHeader(c)))
//                   .toList(),
//             ),
//           ),
//           // Striped rows
//           ...List.generate(rows.length, (i) {
//             final row = rows[i] as Map<String, dynamic>;
//             return _DataRow(
//               cells: cols.map((c) => row[c]?.toString() ?? '—').toList(),
//               isOdd: i % 2 == 0,
//               highlight: _search,
//               accent: C.primaryBlue,
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Shared widgets (Date Chip, Header Cell, Data Row, Data Cell, Highlight Text)
// // ─────────────────────────────────────────────────────────────────────────────
//
// class _DateChip extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final bool isHighlighted;
//   final VoidCallback onTap;
//   const _DateChip({
//     required this.label,
//     required this.date,
//     required this.isHighlighted,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isHighlighted ? const Color(0xFFE65100) : C.primaryBlue;
//     final bgColor = isHighlighted ? const Color(0xFFFFF3E0) : C.lightBlue;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         height: 40,
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.5), width: 1.1),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.calendar_today_rounded, size: 11, color: color),
//             const SizedBox(width: 5),
//             Flexible(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w600,
//                       color: color.withOpacity(0.7),
//                     ),
//                   ),
//                   Text(
//                     DateFormat('dd MMM yy').format(date),
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       color: color,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 3),
//             Icon(Icons.expand_more_rounded, size: 13, color: color),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _HeaderCell extends StatelessWidget {
//   final String label;
//   const _HeaderCell({required this.label});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 130,
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     child: Text(
//       label,
//       style: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w800,
//         color: Colors.white,
//         letterSpacing: 0.4,
//       ),
//       overflow: TextOverflow.ellipsis,
//     ),
//   );
// }
//
// class _DataRow extends StatefulWidget {
//   final List<String> cells;
//   final bool isOdd;
//   final String highlight;
//   final Color accent;
//   const _DataRow({
//     required this.cells,
//     required this.isOdd,
//     required this.highlight,
//     required this.accent,
//   });
//   @override
//   State<_DataRow> createState() => _DataRowState();
// }
//
// class _DataRowState extends State<_DataRow> {
//   bool _hovered = false;
//   @override
//   Widget build(BuildContext context) => MouseRegion(
//     onEnter: (_) => setState(() => _hovered = true),
//     onExit: (_) => setState(() => _hovered = false),
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 110),
//       decoration: BoxDecoration(
//         color: _hovered ? C.brand100 : (widget.isOdd ? C.brand50 : C.cardBg),
//         border: const Border(bottom: BorderSide(color: C.divider)),
//       ),
//       child: Row(
//         children: widget.cells
//             .map(
//               (v) => _DataCell(
//                 value: v,
//                 highlight: widget.highlight,
//                 accent: widget.accent,
//               ),
//             )
//             .toList(),
//       ),
//     ),
//   );
// }
//
// class _DataCell extends StatelessWidget {
//   final String value;
//   final String highlight;
//   final Color accent;
//   const _DataCell({
//     required this.value,
//     required this.highlight,
//     required this.accent,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final hasMatch =
//         highlight.isNotEmpty &&
//         value.toLowerCase().contains(highlight.toLowerCase());
//     return Container(
//       width: 130,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//       child: hasMatch
//           ? _HighlightText(text: value, query: highlight, accent: accent)
//           : Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 12.5,
//                 color: C.textHigh,
//                 fontWeight: FontWeight.w500,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//     );
//   }
// }
//
// class _HighlightText extends StatelessWidget {
//   final String text;
//   final String query;
//   final Color accent;
//   const _HighlightText({
//     required this.text,
//     required this.query,
//     required this.accent,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final lower = text.toLowerCase();
//     final q = query.toLowerCase();
//     final spans = <TextSpan>[];
//     int start = 0, idx;
//     while ((idx = lower.indexOf(q, start)) != -1) {
//       if (idx > start)
//         spans.add(
//           TextSpan(
//             text: text.substring(start, idx),
//             style: const TextStyle(
//               fontSize: 12.5,
//               color: C.textHigh,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         );
//       spans.add(
//         TextSpan(
//           text: text.substring(idx, idx + q.length),
//           style: TextStyle(
//             fontSize: 12.5,
//             color: accent,
//             fontWeight: FontWeight.w800,
//             backgroundColor: accent.withOpacity(0.12),
//           ),
//         ),
//       );
//       start = idx + q.length;
//     }
//     if (start < text.length)
//       spans.add(
//         TextSpan(
//           text: text.substring(start),
//           style: const TextStyle(
//             fontSize: 12.5,
//             color: C.textHigh,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       );
//     return RichText(
//       overflow: TextOverflow.ellipsis,
//       text: TextSpan(children: spans),
//     );
//   }
// }

// import 'package:IMS/Color/Colorclass.dart';
// import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// import '../Reports_model/stockModel.dart';
//
// class WebbingStockScreen extends StatefulWidget {
//
//   const WebbingStockScreen({super.key, });
//
//   @override
//   State<WebbingStockScreen> createState() => _WebbingStockScreenState();
// }
//
// class _WebbingStockScreenState extends State<WebbingStockScreen> {
//   final JblApiService _api = JblApiService();
//
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//
//   List<WebbingStock> _data = [];
//   bool _loading = true;
//
//   String _search = '';
//   final TextEditingController _searchCtrl = TextEditingController();
//
//   String _fmt(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
//
//   List<WebbingStock> get _filtered {
//     if (_search.isEmpty) return _data;
//     final q = _search.toLowerCase();
//     return _data.where((row) {
//       return row.toMap().values.join(' ').toLowerCase().contains(q);  // ✅
//     }).toList();
//   }
//
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
//   Future<void> _fetchData() async {
//     if (!mounted) return;
//     setState(() => _loading = true);
//     try {
//       final res = await _api.fetchStock(
//         // type: widget.type,
//         plant: 'JBL',
//         fromDate: _fmt(_fromDate),
//         toDate: _fmt(_toDate),
//       );
//       if (!mounted) return;
//       setState(() => _data = res);
//     } catch (e) {
//       debugPrint('WebbingStock ERROR: $e');
//     }
//     if (!mounted) return;
//     setState(() => _loading = false);
//   }
//
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
//   PreferredSizeWidget _buildAppBar() => AppBar(
//     elevation: 0,
//     backgroundColor: C.primary,
//     surfaceTintColor: Colors.transparent,
//     systemOverlayStyle: SystemUiOverlayStyle.dark,
//     titleSpacing: 0,
//     leading: IconButton(
//       icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: C.bgColor),
//       onPressed: () => Navigator.pop(context),
//     ),
//     title: Text(
//       'Webbing Stock Report',
//       style: TextStyle(
//         fontSize: 20,
//         // fontWeight: FontWeight.w800,
//         color: C.bgColor,
//         letterSpacing: -0.2,
//       ),
//     ),
//     // iconTheme: const IconThemeData(color: Colors.white),
//     actions: [
//       IconButton(
//         icon: const Icon(Icons.calendar_today),
//         onPressed: _pickDateRange,
//         color: C.bgColor,
//       ),
//       IconButton(
//         icon: const Icon(Icons.refresh_rounded, color: C.bgColor, size: 25),
//         tooltip: 'Refresh',
//         onPressed: _fetchData,
//       ),
//       const SizedBox(width: 4),
//     ],
//     bottom: PreferredSize(
//       preferredSize: const Size.fromHeight(1),
//       child: Container(height: 1, color: C.borderLight),
//     ),
//   );
//
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
//                 style: const TextStyle(fontSize: 13, color: C.textHigh, fontWeight: FontWeight.w500),
//                 decoration: InputDecoration(
//                   hintText: 'Search records…',
//                   prefixIcon: const Icon(Icons.search_rounded, color: C.textMid, size: 18),
//                   suffixIcon: _search.isNotEmpty
//                       ? GestureDetector(
//                     onTap: () {
//                       setState(() => _search = '');
//                       _searchCtrl.clear();
//                     },
//                     child: const Icon(Icons.close_rounded, color: C.textMid, size: 16),
//                   )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: _loading
//                 ? SizedBox(
//               key: const ValueKey('spin'),
//               width: 46,
//               height: 42,
//               child: Center(
//                 child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: C.primaryBlue)),
//               ),
//             )
//                 : Container(
//               key: ValueKey('cnt-$count'),
//               width: 46,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: C.lightBlue,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: C.primaryBlue.withOpacity(0.25)),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: C.primaryBlue)),
//                   Text('rows', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: C.primaryBlue.withOpacity(0.65))),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) {
//       return Center(
//         child: CircularProgressIndicator(color: C.primaryBlue),
//       );
//     }
//
//     final rows = _filtered;
//
//     if (rows.isEmpty) {
//       return const Center(child: Text('No Data Found'));
//     }
//
//     // ✅ toMap() use karo — Map cast error nahi aayega
//     final cols = rows.first.toMap().keys.toList();
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.all(14),
//         child: _buildTable(cols, rows),
//       ),
//     );
//   }
//
//   Widget _buildTable(List<String> cols, List<WebbingStock> rows) {
//     String fmtHeader(String key) => key; // already readable keys hain
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
//           // Header row
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(colors: [C.primaryBlue, C.headerBlue]),
//             ),
//             child: Row(
//               children: cols.map((c) => _HeaderCell(label: c)).toList(),
//             ),
//           ),
//
//           // Data rows — ✅ toMap() se values lo
//           ...List.generate(rows.length, (i) {
//             final map = rows[i].toMap();
//             return _DataRow(
//               cells: cols.map((c) => map[c]?.toString() ?? '—').toList(),
//               isOdd: i % 2 == 0,
//               highlight: _search,
//               accent: C.primaryBlue,
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
// }
//
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
//             value: v,
//             highlight: widget.highlight,
//             accent: widget.accent,
//           ),
//         )
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
//             value.toLowerCase().contains(highlight.toLowerCase());
//     return Container(
//       width: 100,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//       child: hasMatch
//           ? _HighlightText(text: value, query: highlight, accent: accent)
//           : Text(
//         value,
//         style: const TextStyle(
//           fontSize: 12.5,
//           color: C.textHigh,
//           fontWeight: FontWeight.w500,
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
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
//
// class _HeaderCell extends StatelessWidget {
//   final String label;
//   const _HeaderCell({required this.label});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 100,
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     child: Text(
//       label,
//       style: const TextStyle(
//         fontSize: 12.5,
//         fontWeight: FontWeight.w800,
//         color: Colors.white,
//         letterSpacing: 0.4,
//       ),
//       maxLines: 2,
//       softWrap: true,
//       overflow: TextOverflow.ellipsis,
//     ),
//   );
// }
// import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'package:IMS/Color/Colorclass.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// // Teal palette (OUT tab)
// const Color _tealDark = Color(0xFF00695C); // teal 800
// const Color _tealMed = Color(0xFF00897B); // teal 600
// const Color _tealLight = Color(0xFFE0F2F1); // teal 50
//
// // ─────────────────────────────────────────────────────────────────────────────
// class LaminationReportScreen extends StatefulWidget {
//   final String title;
//   final String endpoint;
//   final Map<String, String> initialParams;
//
//   const LaminationReportScreen({
//     super.key,
//     required this.title,
//     required this.endpoint,
//     required this.initialParams,
//   });
//
//   @override
//   State<LaminationReportScreen> createState() => _LaminationReportScreenState();
// }
//
// class _LaminationReportScreenState extends State<LaminationReportScreen>
//     with SingleTickerProviderStateMixin {
//   final JblApiService _api = JblApiService();
//
//   late TabController _tab;
//
//   List<dynamic> _inData = [];
//   List<dynamic> _outData = [];
//   bool _inLoading = true;
//   bool _outLoading = true;
//
//   String _search = '';
//   late TextEditingController _searchCtrl;
//
//   // ── Date range ─────────────────────────────────────────────────────────────
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//
//   late Map<String, String> _baseParams;
//
//   // ── lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _searchCtrl = TextEditingController();
//     _tab = TabController(length: 2, vsync: this);
//     _tab.addListener(_onTabChange);
//     _baseParams = Map<String, String>.from(widget.initialParams);
//     _fetchBoth();
//   }
//
//   @override
//   void dispose() {
//     _tab.removeListener(_onTabChange);
//     _tab.dispose();
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _onTabChange() {
//     if (!_tab.indexIsChanging) {
//       setState(() => _search = '');
//       _searchCtrl.clear();
//     }
//   }
//
//   // ── helpers ────────────────────────────────────────────────────────────────
//   String _fmt(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   String _display(DateTime d) => DateFormat('dd MMM yyyy').format(d);
//
//   bool get _isToday =>
//       _fmt(_fromDate) == _fmt(DateTime.now()) &&
//       _fmt(_toDate) == _fmt(DateTime.now());
//
//   bool get _isSameDay => _fmt(_fromDate) == _fmt(_toDate);
//
//   Future<void> _fetchBoth() {
//     _fetchType('IN');
//     _fetchType('OUT');
//     return Future.value();
//   }
//
//   String formatHeader(String key) {
//     return key
//         .replaceAll('_', ' ') // remove _
//         .replaceAllMapped(
//           RegExp(r'([a-z])([A-Z])'), // camelCase → space
//           (m) => '${m[1]} ${m[2]}',
//         )
//         .toUpperCase(); // CAPITAL
//   }
//
//   Future<void> _fetchType(String type) async {
//     if (!mounted) return;
//
//     setState(() {
//       if (type == 'IN') _inLoading = true;
//       if (type == 'OUT') _outLoading = true;
//     });
//
//     try {
//       final res = await _api.getLaminationReports(
//         type: type, // ✅ IN / OUT
//         fromDate: _fmt(_fromDate), // ✅ correct
//         toDate: _fmt(_toDate),
//         plant: _baseParams['plant'] ?? '', // ✅ pass plant
//       );
//
//       if (!mounted) return;
//
//       setState(() {
//         if (type == 'IN') _inData = res;
//         if (type == 'OUT') _outData = res;
//       });
//     } catch (e) {
//       debugPrint('API ERROR [$type]: $e');
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       if (type == 'IN') _inLoading = false;
//       if (type == 'OUT') _outLoading = false;
//     });
//   }
//
//   List<dynamic> _filtered(List<dynamic> src) {
//     if (_search.isEmpty) return src;
//     final q = _search.toLowerCase();
//     return src.where((row) {
//       try {
//         return (row as Map).values.join(' ').toLowerCase().contains(q);
//       } catch (_) {
//         return false;
//       }
//     }).toList();
//   }
//
//   // ── Date range picker ──────────────────────────────────────────────────────
//   Future<void> _pickDateRange() async {
//     final range = await showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: C.primary,
//             onPrimary: Colors.white,
//             surface: C.bg,
//             onSurface: C.textHigh,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//
//     if (range != null) {
//       setState(() {
//         _fromDate = range.start;
//         _toDate = range.end;
//       });
//       _fetchBoth();
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
//           _buildTabSlider(),
//           Expanded(
//             child: TabBarView(
//               controller: _tab,
//               children: [
//                 _buildBody('IN', _inData, _inLoading),
//                 _buildBody('OUT', _outData, _outLoading),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── AppBar ─────────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: C.bg,
//       surfaceTintColor: Colors.transparent,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       titleSpacing: 0,
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back_ios_new_rounded,
//           size: 18,
//           color: C.textHigh,
//         ),
//         onPressed: () => Navigator.pop(context),
//       ),
//
//       // ✅ Title + Date Range
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//               color: C.textHigh,
//             ),
//           ),
//           const SizedBox(height: 2),
//         ],
//       ),
//
//       actions: [
//         // ✅ DATE PICKER ICON
//         IconButton(
//           icon: const Icon(Icons.calendar_today, color: C.textMid, size: 20),
//           tooltip: 'Select Date Range',
//           onPressed: () async {
//             HapticFeedback.lightImpact();
//             await _pickDateRange();
//           },
//         ),
//
//         // Refresh
//         IconButton(
//           icon: const Icon(Icons.refresh_rounded, color: C.textMid, size: 20),
//           tooltip: 'Refresh',
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             _fetchBoth();
//           },
//         ),
//
//         const SizedBox(width: 4),
//       ],
//
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: C.borderLight),
//       ),
//     );
//   }
//
//   // ── Search bar ─────────────────────────────────────────────────────────────
//   Widget _buildSearchBar() {
//     final idx = _tab.index;
//     final src = idx == 0 ? _inData : _outData;
//     final loading = idx == 0 ? _inLoading : _outLoading;
//     final count = _filtered(src).length;
//     final accent = idx == 0 ? C.primary : _tealDark;
//     final accentLt = idx == 0 ? C.primaryLight : _tealLight;
//
//     return Container(
//       color: C.bg,
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
//           // Count badge
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: loading
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
//                           color: accent,
//                         ),
//                       ),
//                     ),
//                   )
//                 : Container(
//                     key: ValueKey('$idx-$count'),
//                     width: 46,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: accentLt,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: accent.withOpacity(0.25)),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '$count',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w900,
//                             color: accent,
//                           ),
//                         ),
//                         Text(
//                           'rows',
//                           style: TextStyle(
//                             fontSize: 8,
//                             fontWeight: FontWeight.w600,
//                             color: accent.withOpacity(0.65),
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
//   // ── Tab Slider ─────────────────────────────────────────────────────────────
//   Widget _buildTabSlider() {
//     final isIn = _tab.index == 0;
//
//     return Container(
//       color: C.bg,
//       padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
//       child: Container(
//         height: 48,
//         padding: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: C.brand50,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: C.borderLight),
//         ),
//         child: TabBar(
//           controller: _tab,
//           onTap: (_) => setState(() {}),
//           indicator: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: isIn
//                   ? [C.primary, C.headerBlue]
//                   : [_tealDark, _tealMed],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: (isIn ? C.primary : _tealDark).withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           dividerColor: Colors.transparent,
//           labelPadding: EdgeInsets.zero,
//           tabs: [
//             _ModernTab(
//               label: 'LAM IN',
//               icon: Icons.login_rounded,
//               isSelected: isIn,
//               activeColor: Colors.white,
//               inactiveColor: C.primary,
//             ),
//             _ModernTab(
//               label: 'LAM OUT',
//               icon: Icons.logout_rounded,
//               isSelected: !isIn,
//               activeColor: Colors.white,
//               inactiveColor: _tealDark,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Report body ────────────────────────────────────────────────────────────
//   Widget _buildBody(String type, List<dynamic> src, bool loading) {
//     final isIn = type == 'IN';
//     final accent = isIn ? C.primary : _tealDark;
//     final accentLt = isIn ? C.primaryLight : _tealLight;
//
//     if (loading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(strokeWidth: 3, color: accent),
//             const SizedBox(height: 14),
//             Text(
//               'Loading $type data…',
//               style: const TextStyle(
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
//     final rows = _filtered(src);
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
//                 color: accentLt,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: accent.withOpacity(0.18)),
//               ),
//               child: Icon(
//                 Icons.inbox_rounded,
//                 size: 30,
//                 color: accent.withOpacity(0.55),
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
//                   : 'No $type records for the selected range',
//               style: const TextStyle(fontSize: 12, color: C.textMid),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final cols = (rows.first as Map<String, dynamic>).keys.toList();
//
//     // final allCols = (rows.first as Map<String, dynamic>).keys.toList();
//     //
//     // final cols = [
//     //   'rolL_CODE',
//     //   'barcode',
//     //   'fabriC_CODE',
//     //   'grosS_WEIGHT',
//     //   'neT_WEIGHT',
//     //   'rolL_LENGTH',
//     //   'avG_WEIGHT',
//     //   'operatoR_NAME',
//     //   'supervisoR_NAME',
//     //   'worK_ORDER_NO',
//     //   'requireD_QUANTITY',
//     //   'requiredqtymtr',
//     //   'tarE_WEIGHT',
//     //   'status',
//     //   'fabriC_WIDTH',
//     //   'fabriC_GSM',
//     // ].where((c) => allCols.contains(c)).toList();
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
//         child: _buildTable(cols, rows, accent, isIn),
//       ),
//     );
//   }
//
//   // ── Table ──────────────────────────────────────────────────────────────────
//   Widget _buildTable(
//     List<String> cols,
//     List<dynamic> rows,
//     Color accent,
//     bool isIn,
//   ) {
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
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isIn
//                     ? [C.primary, C.headerBlue]
//                     : [_tealDark, _tealMed],
//               ),
//             ),
//             child: Row(
//               children: cols
//                   .map((c) => _HeaderCell(label: formatHeader(c)))
//                   .toList(),
//             ),
//           ),
//           // Striped data rows
//           ...List.generate(rows.length, (i) {
//             final row = rows[i] as Map<String, dynamic>;
//             return _DataRow(
//               cells: cols.map((c) => row[c]?.toString() ?? '—').toList(),
//               isOdd: i % 2 == 0,
//               highlight: _search,
//               accent: accent,
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Date Chip widget
// // ─────────────────────────────────────────────────────────────────────────────
// class _DateChip extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final bool isHighlighted;
//   final VoidCallback onTap;
//
//   const _DateChip({
//     required this.label,
//     required this.date,
//     required this.isHighlighted,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isHighlighted ? const Color(0xFFE65100) : C.primary;
//     final bgColor = isHighlighted ? const Color(0xFFFFF3E0) : C.primaryLight;
//
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
// // ─────────────────────────────────────────────────────────────────────────────
// //  Modern Tab
// // ─────────────────────────────────────────────────────────────────────────────
// class _ModernTab extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final Color activeColor;
//   final Color inactiveColor;
//
//   const _ModernTab({
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.activeColor,
//     required this.inactiveColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: isSelected
//             ? Colors.transparent
//             : inactiveColor.withOpacity(0.08),
//         border: isSelected
//             ? null
//             : Border.all(color: inactiveColor.withOpacity(0.15)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 16, color: isSelected ? activeColor : inactiveColor),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w800,
//               color: isSelected ? activeColor : inactiveColor,
//               letterSpacing: 0.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Header Cell
// // ─────────────────────────────────────────────────────────────────────────────
// class _HeaderCell extends StatelessWidget {
//   final String label;
//   const _HeaderCell({required this.label});
//
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 100,
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     child: Text(
//       label,
//       style: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w800,
//         color: Colors.white,
//         letterSpacing: 0.4,
//       ),
//       softWrap: true,          // ✅ wrap enable
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//     ),
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Data Row  (striped + hover)
// // ─────────────────────────────────────────────────────────────────────────────
// class _DataRow extends StatefulWidget {
//   final List<String> cells;
//   final bool isOdd;
//   final String highlight;
//   final Color accent;
//
//   const _DataRow({
//     required this.cells,
//     required this.isOdd,
//     required this.highlight,
//     required this.accent,
//   });
//
//   @override
//   State<_DataRow> createState() => _DataRowState();
// }
//
// class _DataRowState extends State<_DataRow> {
//   bool _hovered = false;
//
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
// // ─────────────────────────────────────────────────────────────────────────────
// //  Data Cell
// // ─────────────────────────────────────────────────────────────────────────────
// class _DataCell extends StatelessWidget {
//   final String value;
//   final String highlight;
//   final Color accent;
//
//   const _DataCell({
//     required this.value,
//     required this.highlight,
//     required this.accent,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final hasMatch =
//         highlight.isNotEmpty &&
//         value.toLowerCase().contains(highlight.toLowerCase());
//     return Container(
//       width: 100,
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
// // ─────────────────────────────────────────────────────────────────────────────
// //  Highlight Text
// // ─────────────────────────────────────────────────────────────────────────────
// class _HighlightText extends StatelessWidget {
//   final String text;
//   final String query;
//   final Color accent;
//
//   const _HighlightText({
//     required this.text,
//     required this.query,
//     required this.accent,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final lower = text.toLowerCase();
//     final q = query.toLowerCase();
//     final spans = <TextSpan>[];
//     int start = 0;
//     int idx;
//
//     while ((idx = lower.indexOf(q, start)) != -1) {
//       if (idx > start) {
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
//       }
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
//
//     if (start < text.length) {
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
//     }
//
//     return RichText(
//       overflow: TextOverflow.ellipsis,
//       text: TextSpan(children: spans),
//     );
//   }
// }

import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
import 'package:IMS/Color/Colorclass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../services/getSupervisors/getSupervisors.dart';

const Color _tealDark = Color(0xFF00695C);
const Color _tealMed = Color(0xFF00897B);
const Color _tealLight = Color(0xFFE0F2F1);

// ✅ IN aur OUT dono ke liye same fields (same API response)
const List<String> _reportFields = [
  'rolL_CODE',
  'barcode',
  'looM_TYPE',
  'looM_NO',
  'fabriC_CODE',
  'grosS_WEIGHT',
  'neT_WEIGHT',
  'rolL_LENGTH',
  'avG_WEIGHT',
  'operatoR_NAME',
  'supervisoR_NAME',

  'status',
  'partyname',
  'worK_ORDER_NO',
  'conT_NO',
  'requireD_QUANTITY',
  'requireD_QUANTITY_MTR',
];

class LaminationReportScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final Map<String, String> initialParams;

  const LaminationReportScreen({
    super.key,
    required this.title,
    required this.endpoint,
    required this.initialParams,
  });

  @override
  State<LaminationReportScreen> createState() => _LaminationReportScreenState();
}

class _LaminationReportScreenState extends State<LaminationReportScreen>
    with SingleTickerProviderStateMixin {
  final JblApiService _api = JblApiService();

  late TabController _tab;

  List<dynamic> _inData = [];
  List<dynamic> _outData = [];
  bool _inLoading = true;
  bool _outLoading = true;

  String _search = '';
  late TextEditingController _searchCtrl;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _toDate = DateTime.now();

  late Map<String, String> _baseParams;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(_onTabChange);
    _baseParams = Map<String, String>.from(widget.initialParams);
    _fetchBoth();
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabChange);
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (!_tab.indexIsChanging) {
      setState(() => _search = '');
      _searchCtrl.clear();
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ✅ Ab karo — sequential calls
  Future<void> _fetchBoth() async {
    await _fetchType('IN');
    await _fetchType('OUT');
  }

  // ✅ Header format: rolL_CODE → ROLL CODE
  String _formatHeader(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  Future<void> _fetchType(String type) async {
    if (!mounted) return;
    setState(() {
      if (type == 'IN') _inLoading = true;
      if (type == 'OUT') _outLoading = true;
    });

    try {
      // ✅ Token fresh fetch karo har call ke liye
      final headers = await InStockService.authHeaders();
      debugPrint(
        'TOKEN for $type: $headers',
      ); // ✅ check karo same token hai ya nahi

      final res = await _api.getLaminationReports(
        type: type,
        fromDate: _fmt(_fromDate),
        toDate: _fmt(_toDate),
        plant: _baseParams['plant'] ?? '',
      );

      debugPrint('$type DATA COUNT: ${res.length}'); // ✅ count check karo

      if (!mounted) return;
      setState(() {
        if (type == 'IN') _inData = res;
        if (type == 'OUT') _outData = res;
      });
    } catch (e) {
      debugPrint('API ERROR [$type]: $e');
    }

    if (!mounted) return;
    setState(() {
      if (type == 'IN') _inLoading = false;
      if (type == 'OUT') _outLoading = false;
    });
  }

  List<dynamic> _filtered(List<dynamic> src) {
    if (_search.isEmpty) return src;
    final q = _search.toLowerCase();
    return src.where((row) {
      try {
        return (row as Map).values.join(' ').toLowerCase().contains(q);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: C.primary,
            onPrimary: Colors.white,
            surface: C.bg,
            onSurface: C.textHigh,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
      });
      _fetchBoth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabSlider(),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildBody('IN', _inData, _inLoading),
                _buildBody('OUT', _outData, _outLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: C.textHigh,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: C.textHigh,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: C.textMid, size: 20),
          tooltip: 'Select Date Range',
          onPressed: () async {
            HapticFeedback.lightImpact();
            await _pickDateRange();
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: C.textMid, size: 20),
          tooltip: 'Refresh',
          onPressed: () {
            HapticFeedback.lightImpact();
            _fetchBoth();
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: C.borderLight),
      ),
    );
  }

  Widget _buildSearchBar() {
    final idx = _tab.index;
    final src = idx == 0 ? _inData : _outData;
    final loading = idx == 0 ? _inLoading : _outLoading;
    final count = _filtered(src).length;
    final accent = idx == 0 ? C.primary : _tealDark;
    final accentLt = idx == 0 ? C.primaryLight : _tealLight;

    return Container(
      color: C.bg,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: C.brand50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.borderLight),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textHigh,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search records…',
                  hintStyle: const TextStyle(color: C.textLow, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: C.textMid,
                    size: 18,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() => _search = '');
                            _searchCtrl.clear();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: C.textMid,
                            size: 16,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: loading
                ? SizedBox(
                    key: const ValueKey('spin'),
                    width: 46,
                    height: 42,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          backgroundColor: Colors.transparent,

                          color: C.actionOrange,
                        ),
                      ),
                    ),
                  )
                : Container(
                    key: ValueKey('$idx-$count'),
                    width: 46,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentLt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.25)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                        Text(
                          'rows',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: accent.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSlider() {
    final isIn = _tab.index == 0;
    return Container(
      color: C.bg,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: C.brand50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.borderLight),
        ),
        child: TabBar(
          controller: _tab,
          onTap: (_) => setState(() {}),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isIn
                  ? [C.primary, C.headerBlue]
                  : [_tealDark, _tealMed],
            ),
            boxShadow: [
              BoxShadow(
                color: (isIn ? C.primary : _tealDark).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          tabs: [
            _ModernTab(
              label: 'LAM IN',
              icon: Icons.login_rounded,
              isSelected: isIn,
              activeColor: Colors.white,
              inactiveColor: C.primary,
            ),
            _ModernTab(
              label: 'LAM OUT',
              icon: Icons.logout_rounded,
              isSelected: !isIn,
              activeColor: Colors.white,
              inactiveColor: _tealDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(String type, List<dynamic> src, bool loading) {
    final isIn = type == 'IN';
    final accent = isIn ? C.primary : _tealDark;
    final accentLt = isIn ? C.primaryLight : _tealLight;

    if (loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: C.appBar3,),
            const SizedBox(height: 14),
            Text(
              'Loading $type data…',
              style: const TextStyle(
                color: C.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final rows = _filtered(src);

    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: accentLt,
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.18)),
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 30,
                color: accent.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _search.isNotEmpty
                  ? 'No results for "$_search"'
                  : 'No Data Found',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: C.textHigh,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _search.isNotEmpty
                  ? 'Try a different keyword'
                  : 'No $type records for the selected range',
              style: const TextStyle(fontSize: 12, color: C.textMid),
            ),
          ],
        ),
      );
    }

    // ✅ API response mein jo keys actually hain unse filter karo
    final allCols = (rows.first as Map<String, dynamic>).keys.toList();
    final cols = _reportFields.where((c) => allCols.contains(c)).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        child: _buildTable(cols, rows, accent, isIn),
      ),
    );
  }

  Widget _buildTable(
    List<String> cols,
    List<dynamic> rows,
    Color accent,
    bool isIn,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.borderLight),
        boxShadow: [
          BoxShadow(
            color: C.brand50,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Gradient header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isIn
                    ? [C.primary, C.headerBlue]
                    : [_tealDark, _tealMed],
              ),
            ),
            child: Row(
              children: cols
                  .map((c) => _HeaderCell(label: _formatHeader(c)))
                  .toList(),
            ),
          ),
          // ✅ Striped data rows
          ...List.generate(rows.length, (i) {
            final row = rows[i] as Map<String, dynamic>;
            return _DataRow(
              cells: cols.map((c) => row[c]?.toString() ?? '—').toList(),
              isOdd: i % 2 == 0,
              highlight: _search,
              accent: accent,
            );
          }),
        ],
      ),
    );
  }
}

// ── Modern Tab ───────────────────────────────────────────────────────────────
class _ModernTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;

  const _ModernTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Colors.transparent
            : inactiveColor.withOpacity(0.08),
        border: isSelected
            ? null
            : Border.all(color: inactiveColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: isSelected ? activeColor : inactiveColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Cell ──────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    width: 110,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.3,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    ),
  );
}

// ── Data Row ─────────────────────────────────────────────────────────────────
class _DataRow extends StatefulWidget {
  final List<String> cells;
  final bool isOdd;
  final String highlight;
  final Color accent;

  const _DataRow({
    required this.cells,
    required this.isOdd,
    required this.highlight,
    required this.accent,
  });

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      decoration: BoxDecoration(
        color: _hovered ? C.brand100 : (widget.isOdd ? C.brand50 : C.cardBg),
        border: const Border(bottom: BorderSide(color: C.divider)),
      ),
      child: Row(
        children: widget.cells
            .map(
              (v) => _DataCell(
                value: v,
                highlight: widget.highlight,
                accent: widget.accent,
              ),
            )
            .toList(),
      ),
    ),
  );
}

// ── Data Cell ─────────────────────────────────────────────────────────────────
class _DataCell extends StatelessWidget {
  final String value;
  final String highlight;
  final Color accent;

  const _DataCell({
    required this.value,
    required this.highlight,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasMatch =
        highlight.isNotEmpty &&
        value.toLowerCase().contains(highlight.toLowerCase());
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: hasMatch
          ? _HighlightText(text: value, query: highlight, accent: accent)
          : Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: C.textHigh,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}

// ── Highlight Text ────────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final Color accent;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0, idx;

    while ((idx = lower.indexOf(q, start)) != -1) {
      if (idx > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, idx),
            style: const TextStyle(
              fontSize: 12,
              color: C.textHigh,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: TextStyle(
            fontSize: 12,
            color: accent,
            fontWeight: FontWeight.w800,
            backgroundColor: accent.withOpacity(0.12),
          ),
        ),
      );
      start = idx + q.length;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: const TextStyle(
            fontSize: 12,
            color: C.textHigh,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

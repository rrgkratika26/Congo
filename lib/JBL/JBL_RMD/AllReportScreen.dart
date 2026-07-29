// import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'package:IMS/Color/Colorclass.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// const Color _tealDark = Color(0xFF00695C);
// const Color _tealMed = Color(0xFF00897B);
// const Color _tealLight = Color(0xFFE0F2F1);
//
// // ─────────────────────────────────────────────────────────────────────────────
// class DynamicReportScreen extends StatefulWidget {
//   final String title;
//   final String endpoint;
//   final Map<String, String> initialParams;
//
//   const DynamicReportScreen({
//     super.key,
//     required this.title,
//     required this.endpoint,
//     required this.initialParams,
//   });
//
//   @override
//   State<DynamicReportScreen> createState() => _DynamicReportScreenState();
// }
//
// class _DynamicReportScreenState extends State<DynamicReportScreen>
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
//   // ── Date range state ───────────────────────────────────────────────────────
//   DateTime _startDate = DateTime.now();
//   DateTime _endDate = DateTime.now();
//   bool _isRangeFiltered = false; // true = user picked a custom range
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
//   bool get _isToday {
//     final now = DateTime.now();
//     final todayStr = _fmt(now);
//     return _fmt(_startDate) == todayStr && _fmt(_endDate) == todayStr;
//   }
//
//   Future<void> _fetchBoth() {
//     _fetchType('IN');
//     _fetchType('OUT');
//     return Future.value();
//   }
//
//   Future<void> _fetchType(String type) async {
//     if (!mounted) return;
//     setState(() {
//       if (type == 'IN') _inLoading = true;
//       if (type == 'OUT') _outLoading = true;
//     });
//
//     final p = Map<String, String>.from(_baseParams);
//     if (p.containsKey('type')) p['type'] = type;
//     p['fromDate'] = _fmt(_startDate);
//     p['toDate'] = _fmt(_endDate);
//
//     try {
//       final res = await _api.getDynamicReport(
//         endpoint: widget.endpoint,
//         params: p,
//       );
//       if (!mounted) return;
//       setState(() {
//         if (type == 'IN') _inData = res;
//         if (type == 'OUT') _outData = res;
//       });
//     } catch (e) {
//       debugPrint('API ERROR [$type]: $e');
//     }
//
//     if (!mounted) return;
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
//   // ── Date Range Picker ──────────────────────────────────────────────────────
//   Future<void> _pickDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       saveText: 'APPLY',
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
//
//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//         _isRangeFiltered = true;
//       });
//       _fetchBoth(); // fetch with new range
//     }
//   }
//
//   // ── Refresh / Reset to today ───────────────────────────────────────────────
//   void _resetToToday() {
//     HapticFeedback.lightImpact();
//     setState(() {
//       _startDate = DateTime.now();
//       _endDate = DateTime.now();
//       _isRangeFiltered = false;
//     });
//     _fetchBoth();
//   }
//
//
//
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
//       backgroundColor: C.bgrColor,
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
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: C.textHigh,
//               letterSpacing: -0.2,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         GestureDetector(
//           onTap: _pickDateRange,
//           child: Icon(Icons.calendar_today, size: 22, color: Colors.blue),
//         ),
//
//         // ── Refresh / Reset ────────────────────────────────────────────────
//         Tooltip(
//           message: _isRangeFiltered ? 'Reset to Today' : 'Refresh',
//           child: IconButton(
//             icon: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 200),
//               child: const Icon(
//                 Icons.refresh_rounded,
//                 key: ValueKey('refresh'),
//                 color: C.textMid,
//                 size: 21,
//               ),
//             ),
//             onPressed: _resetToToday,
//           ),
//         ),
//         const SizedBox(width: 4),
//       ],
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
//     final accent = idx == 0 ? C.primaryBlue : _tealDark;
//     final accentLt = idx == 0 ? C.lightBlue : _tealLight;
//
//     return Container(
//       color: C.bgrColor,
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
//                           color: C.appBar3,
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
//       color: C.bgrColor,
//       padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
//       child: Container(
//         height: 48,
//         padding: const EdgeInsets.all(4),
//
//         child: TabBar(
//           controller: _tab,
// padding: EdgeInsets.only(),
//           onTap: (_) => setState(() {}),
//           indicator: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: isIn
//                   ? [C.primaryBlue, C.headerBlue]
//                   : [_tealDark, _tealMed],
//             ),
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           dividerColor: Colors.transparent,
//           labelPadding: EdgeInsets.zero,
//           tabs: [
//             _ModernTab(
//               label: "RMD IN",
//               icon: Icons.login_rounded,
//               isSelected: isIn,
//               activeColor: Colors.white,
//               inactiveColor: C.primaryBlue,
//             ),
//
//             _ModernTab(
//               label: "RMD OUT",
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
//     final accent = isIn ? C.lightBlue : C.lightBlue;
//     final accentLt = isIn ? C.lightBlue : C.lightBlue;
//
//     if (loading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(strokeWidth: 3,color: C.appBar3,),
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
//                   : 'No $type records for the selected date range',
//               style: const TextStyle(fontSize: 12, color: C.textMid),
//             ),
//             // ── Reset button in empty state ──────────────────────────────
//             if (_isRangeFiltered) ...[
//               const SizedBox(height: 16),
//               TextButton.icon(
//                 onPressed: _resetToToday,
//                 icon: const Icon(Icons.today_rounded, size: 16),
//                 label: const Text('Reset to Today'),
//                 style: TextButton.styleFrom(foregroundColor: C.primaryBlue),
//               ),
//             ],
//           ],
//         ),
//       );
//     }
//
//     final allCols = (rows.first as Map<String, dynamic>).keys.toList();
//     final cols = [
//       'rolL_CODE',
//       'barcode',
//       'fabriC_CODE',
//       'grosS_WEIGHT',
//       'neT_WEIGHT',
//       'rolL_LENGTH',
//       'avG_WEIGHT',
//       'operatoR_NAME',
//       'supervisoR_NAME',
//       'worK_ORDER_NO',
//       'requireD_QUANTITY',
//       'requiredqtymtr',
//       'tarE_WEIGHT',
//       'status',
//       'fabriC_WIDTH',
//       'fabriC_GSM',
//     ].where((c) => allCols.contains(c)).toList(); // ✅ safe filter
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
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
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isIn
//                     ? [C.primaryBlue, C.headerBlue]
//                     : [_tealDark, _tealMed],
//               ),
//             ),
//             child: Row(
//               children: cols.map((c) => _HeaderCell(label: c)).toList(),
//             ),
//           ),
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
// // ── All helper classes unchanged ───────────────────────────────────────────────
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
//     return SizedBox.expand(
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.transparent,
//           border: isSelected
//               ? null
//               : Border.all(color: inactiveColor.withOpacity(0.25)),
//         ),
//         child: Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 16,
//                 color: isSelected ? activeColor : inactiveColor,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   color: isSelected ? activeColor : inactiveColor,
//
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _HeaderCell extends StatelessWidget {
//   final String label;
//   const _HeaderCell({required this.label});
//
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 85,
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//     child: Text(
//       label.toUpperCase(),
//       style: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w800,
//         color: Colors.white,
//
//         letterSpacing: 0.4,
//       ),
//       softWrap: true, // ✅ wrap enable
//       maxLines: 2,
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
//       width: 85,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
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
//           style: const TextStyle(
//             fontSize: 12.5,
//             color: Colors.white, // ✅ white text
//             // fontWeight: FontWeight.w900, // ✅ more bold
//             backgroundColor: C.primary, // ✅ dark highlight
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
//             color: C.primary,
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

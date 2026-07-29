// import 'package:flutter/material.dart';
// import '../../../Color/Colorclass.dart';
// import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../../JBL_Cutting/ModelClass/CuttinfType.dart';
// import 'bagReportModel.dart';
//
// class BagProductionReportScreen extends StatefulWidget {
//   final String type; // BAGREPORT or PACKAGING
//   const BagProductionReportScreen({super.key, required this.type});
//
//   @override
//   State<BagProductionReportScreen> createState() =>
//       _BagProductionReportScreenState();
// }
//
// class _BagProductionReportScreenState extends State<BagProductionReportScreen> {
//   final JblApiService _api = JblApiService();
//
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//   String _search = '';
//   late TextEditingController _searchCtrl;
//
//   List<BagReportModel> _data = [];
//   bool _loading = true;
//
//   int _rowsPerPage = 10;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _searchCtrl = TextEditingController();
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
//   List<BagReportModel> get _filteredData {
//     if (_search.isEmpty) return _data;
//     final q = _search.toLowerCase();
//     return _data.where((row) {
//       final map = row.toJson();
//       return map.values.join(' ').toLowerCase().contains(q);
//     }).toList();
//   }
//
//   List<BagReportModel> get _paginatedData {
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
//       final res = await JblApiService.getBagReport(
//         type: widget.type,
//         fromDate: _fmt(_fromDate),
//         toDate: _fmt(_toDate),
//       );
//
//       setState(() {
//         if (widget.type.toUpperCase() == "BAGREPORT") {
//           _data = res.cast<BagReportModel>();
//         } else {
//           // For Packaging, either handle separately or create a wrapper model
//           debugPrint("Received PackagingReportModel, handle separately.");
//           _data = []; // Clear _data if you cannot show Packaging in this table
//         }
//         _currentPage = 0;
//       });
//     } catch (e) {
//       debugPrint("Error fetching Bag Production Report: $e");
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
//               IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               Expanded(
//                 child: Text(
//                   "${widget.type} ",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _pickDateRange,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.18),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.35),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.calendar_month_rounded,
//                         color: Colors.white,
//                         size: 15,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         "${_fromDate.day}/${_fromDate.month} – ${_toDate.day}/${_toDate.month}",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.refresh_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   onPressed: _fetchData,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterBar() {
//     return Container(
//       color: C.cardBg,
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//       child: Row(
//         children: [
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
//                     color: C.appBar1,
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
//                     borderSide: const BorderSide(color: C.appBar1, width: 1.5),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
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
//           const SizedBox(width: 10),
//           Container(
//             height: 42,
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [C.brand600, C.appBar1],
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
//                   if (states.contains(MaterialState.selected)) return C.brand50;
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
//   Widget _buildPaginationBar() {
//     return Container(
//       color: C.cardBg,
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//       child: Row(
//         children: [
//           Text(
//             "Page ${_currentPage + 1} of $_totalPages",
//             style: const TextStyle(
//               fontSize: 13,
//               color: C.textMid,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           _NavButton(
//             icon: Icons.chevron_left_rounded,
//             enabled: _currentPage > 0,
//             onTap: () => setState(() => _currentPage--),
//           ),
//           const SizedBox(width: 6),
//           ..._buildPageNumbers(),
//           const SizedBox(width: 6),
//           _NavButton(
//             icon: Icons.chevron_right_rounded,
//             enabled: _currentPage < _totalPages - 1,
//             onTap: () => setState(() => _currentPage++),
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
//             width: 32,
//             height: 32,
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
//                 fontSize: 13,
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
//     if (value is String)
//       dt = DateTime.tryParse(value);
//     else if (value is DateTime)
//       dt = value;
//     if (dt == null) return value.toString();
//     return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
//   }
// }
//
// // NAV BUTTON
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



import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'bagReportModel.dart';
import 'baseModel.dart';


class BagProductionReportScreen extends StatefulWidget {
  final String type;
  const BagProductionReportScreen({super.key, required this.type});

  @override
  State<BagProductionReportScreen> createState() =>
      _BagProductionReportScreenState();
}

class _BagProductionReportScreenState
    extends State<BagProductionReportScreen> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String _search = '';
  late TextEditingController _searchCtrl;

  // ✅ Use the shared base type
  List<ReportRowModel> _data = [];
  bool _loading = true;

  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<ReportRowModel> get _filteredData {
    if (_search.isEmpty) return _data;
    final q = _search.toLowerCase();
    return _data.where((row) {
      return row.toJson().values.join(' ').toLowerCase().contains(q);
    }).toList();
  }

  List<ReportRowModel> get _paginatedData {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _filteredData.length);
    return _filteredData.sublist(start, end);
  }

  int get _totalPages => _filteredData.isEmpty
      ? 1
      : (_filteredData.length / _rowsPerPage).ceil();

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final res = await JblApiService.getBagReport(
        type: widget.type,
        fromDate: _fmt(_fromDate),
        toDate: _fmt(_toDate),
      );

      setState(() {
        // ✅ Both types now cast cleanly via the shared interface
        _data = res.cast<ReportRowModel>();
        _currentPage = 0;
      });
    } catch (e) {
      debugPrint("Error fetching report: $e");
      setState(() => _data = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: C.primary,
            onPrimary: Colors.white,
            surface: C.cardBg,
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
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(child: _buildBody()),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // HEADER  (responsive)
  // ──────────────────────────────────────────
  Widget _buildHeader() {
    final sw = MediaQuery.of(context).size.width;
    final isSmall = sw < 400;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.appBar1, C.borderLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x303F88F5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.type,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Date range pill
              GestureDetector(
                onTap: _pickDateRange,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 22),

                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 20),
                onPressed: _fetchData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // FILTER BAR  (responsive)
  // ──────────────────────────────────────────
  Widget _buildFilterBar() {
    final sw = MediaQuery.of(context).size.width;
    final isSmall = sw < 400;

    return Container(
      color: C.cardBg,
      padding: EdgeInsets.fromLTRB(isSmall ? 8 : 14, 10, isSmall ? 8 : 14, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {
                  _search = v;
                  _currentPage = 0;
                }),
                style: const TextStyle(fontSize: 13, color: C.textHigh),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: const TextStyle(fontSize: 12, color: C.textLow),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: C.appBar1, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? GestureDetector(
                    onTap: () => setState(() {
                      _search = '';
                      _searchCtrl.clear();
                    }),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: C.textMid),
                  )
                      : null,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: C.brand50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: C.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: C.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: C.appBar1, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Rows-per-page dropdown
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: C.brand50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                isDense: true,
                style: const TextStyle(
                    fontSize: 12,
                    color: C.textHigh,
                    fontWeight: FontWeight.w600),
                items: [10, 20, 50]
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text("$e rows")))
                    .toList(),
                onChanged: (val) => setState(() {
                  _rowsPerPage = val!;
                  _currentPage = 0;
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Record count badge
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [C.brand600, C.appBar1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              "${_filteredData.length}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // BODY
  // ──────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
        CircularProgressIndicator(color: C.brand600, strokeWidth: 2.5),
      );
    }

    if (_filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: C.brand50, shape: BoxShape.circle),
              child: const Icon(Icons.inbox_outlined,
                  size: 48, color: C.brand300),
            ),
            const SizedBox(height: 16),
            const Text("No records found",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: C.textHigh)),
            const SizedBox(height: 6),
            const Text("Try adjusting your date range or search",
                style: TextStyle(fontSize: 13, color: C.textMid)),
          ],
        ),
      );
    }

    final cols = _filteredData.first.toJson().keys.toList();
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw < 400 ? 8 : 14, 10, sw < 400 ? 8 : 14, 0),
      child: Container(
        decoration: BoxDecoration(
          color: C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.borderLight),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F2C3A5A),
                blurRadius: 12,
                offset: Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                // Ensure table stretches to at least screen width
                constraints: BoxConstraints(minWidth: sw - (sw < 400 ? 16 : 28)),
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 46,
                  dividerThickness: 0.8,
                  // ✅ Responsive column spacing
                  columnSpacing: sw < 400 ? 12 : (sw < 600 ? 16 : 24),
                  headingRowColor:
                  MaterialStateProperty.all(C.brand100),
                  columns: cols
                      .map((c) => DataColumn(
                    label: Text(
                      c,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: C.brand800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ))
                      .toList(),
                  rows: List.generate(_paginatedData.length, (i) {
                    final map = _paginatedData[i].toJson();
                    return DataRow(
                      color: MaterialStateProperty.resolveWith(
                            (states) => i.isEven
                            ? Colors.white
                            : C.brand50.withOpacity(0.5),
                      ),
                      cells: cols
                          .map((c) => DataCell(
                        Text(
                          _formatCell(map[c]),
                          style: const TextStyle(
                              fontSize: 12, color: C.textHigh),
                        ),
                      ))
                          .toList(),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // PAGINATION BAR  (responsive)
  // ──────────────────────────────────────────
  Widget _buildPaginationBar() {
    final sw = MediaQuery.of(context).size.width;
    final isSmall = sw < 400;

    return Container(
      color: C.cardBg,
      padding: EdgeInsets.fromLTRB(isSmall ? 8 : 16, 10, isSmall ? 8 : 16, 12),
      child: Row(
        children: [
          Text(
            "Page ${_currentPage + 1} of $_totalPages",
            style: const TextStyle(
                fontSize: 12, color: C.textMid, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 0,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),
          ..._buildPageNumbers(),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < _totalPages - 1,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    final start =
    (_currentPage - 2).clamp(0, (_totalPages - 5).clamp(0, _totalPages));
    final end = (start + 5).clamp(0, _totalPages);

    for (int i = start; i < end; i++) {
      final isActive = i == _currentPage;
      pages.add(
        GestureDetector(
          onTap: () => setState(() => _currentPage = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? C.brand600 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive ? null : Border.all(color: C.borderLight),
            ),
            alignment: Alignment.center,
            child: Text(
              "${i + 1}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : C.textMid,
              ),
            ),
          ),
        ),
      );
    }
    return pages;
  }

  // ✅ Smart cell formatter: dates get formatted, numbers stay as-is
  String _formatCell(dynamic value) {
    if (value == null) return '—';
    if (value is String) {
      final dt = DateTime.tryParse(value);
      if (dt != null) {
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
      return value.isEmpty ? '—' : value;
    }
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }
}

// ──────────────────────────────────────────
// NAV BUTTON
// ──────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? C.brand50 : C.pageBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? C.borderLight : C.divider),
        ),
        alignment: Alignment.center,
        child:
        Icon(icon, size: 20, color: enabled ? C.brand700 : C.textLow),
      ),
    );
  }
}
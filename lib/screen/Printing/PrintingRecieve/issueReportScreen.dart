import 'package:flutter/material.dart';
import '../../../../Color/Colorclass.dart';

import '../../../services/NardanaApis/statusTrackerServices.dart';
import 'IssueReportModel.dart';

class PrintingIssueReportScreen extends StatefulWidget {
  const PrintingIssueReportScreen({super.key});

  @override
  State<PrintingIssueReportScreen> createState() =>
      _PrintingIssueReportScreenState();
}

class _PrintingIssueReportScreenState extends State<PrintingIssueReportScreen> {
  final ScrollController _horizontalController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _filterButtonKey = GlobalKey();

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _toDate = DateTime.now();

  // ============================================================
  // DATA
  // ============================================================

  List<PrintingIssueReportModel> _pageData = [];
  List<PrintingIssueReportModel> _filteredData = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // ============================================================
  // SERVER-SIDE PAGINATION
  // ============================================================

  int _pageNumber = 1;
  int _pageSize = 25;

  // API doesn't return a total count, so we infer "has next page"
  // from whether the current page came back full.
  bool get _hasNextPage => _pageData.length == _pageSize;
  bool get _hasPreviousPage => _pageNumber > 1;

  // ============================================================
  // CLIENT-SIDE FILTERS (applied on the currently loaded page only)
  // ============================================================

  String _selectedComponent = 'ALL';
  String _selectedDept = 'ALL';
  List<String> _componentList = ['ALL'];
  List<String> _deptList = ['ALL'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyClientFilters);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyClientFilters);
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // ============================================================
  // API LOAD
  // ============================================================

  Future<void> _loadData({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final data = await StatusTrackerService.fetchPrintingIssueReport(
        fromDate: _fromDate,
        toDate: _toDate,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _pageData = data;
        _isLoading = false;
        _isRefreshing = false;
      });

      _buildFilterLists();
      _applyClientFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refresh() => _loadData(refresh: true);

  // ============================================================
  // DATE RANGE PICKER
  // ============================================================

  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );

    if (result == null) return;

    setState(() {
      _fromDate = result.start;
      _toDate = result.end;
      _pageNumber = 1;
    });

    _loadData();
  }

  // ============================================================
  // FILTER LISTS (from current page)
  // ============================================================

  void _buildFilterLists() {
    final components = <String>{'ALL'};
    final depts = <String>{'ALL'};

    for (final item in _pageData) {
      if (item.component.trim().isNotEmpty) components.add(item.component.trim());
      if (item.issueDepartment.trim().isNotEmpty) depts.add(item.issueDepartment.trim());
    }

    int cmp(String a, String b) {
      if (a == 'ALL') return -1;
      if (b == 'ALL') return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    }

    setState(() {
      _componentList = components.toList()..sort(cmp);
      _deptList = depts.toList()..sort(cmp);
      if (!_componentList.contains(_selectedComponent)) _selectedComponent = 'ALL';
      if (!_deptList.contains(_selectedDept)) _selectedDept = 'ALL';
    });
  }

  void _applyClientFilters() {
    final search = _searchController.text.trim().toLowerCase();

    final result = _pageData.where((item) {
      final componentMatch = _selectedComponent == 'ALL' ||
          item.component.trim().toLowerCase() == _selectedComponent.toLowerCase();

      final deptMatch = _selectedDept == 'ALL' ||
          item.issueDepartment.trim().toLowerCase() == _selectedDept.toLowerCase();

      final searchMatch = search.isEmpty || item.searchText.contains(search);

      return componentMatch && deptMatch && searchMatch;
    }).toList();

    if (!mounted) return;
    setState(() => _filteredData = result);
  }

  void _resetFilters() {
    setState(() {
      _selectedComponent = 'ALL';
      _selectedDept = 'ALL';
      _searchController.clear();
    });
    _applyClientFilters();
  }

  bool get _hasActiveFilters =>
      _selectedComponent != 'ALL' ||
          _selectedDept != 'ALL' ||
          _searchController.text.trim().isNotEmpty;

  // ============================================================
  // PAGINATION (re-fetches from API)
  // ============================================================

  Future<void> _goToPreviousPage() async {
    if (!_hasPreviousPage || _isLoading) return;
    setState(() => _pageNumber--);
    await _loadData();
  }

  Future<void> _goToNextPage() async {
    if (!_hasNextPage || _isLoading) return;
    setState(() => _pageNumber++);
    await _loadData();
  }

  Future<void> _changePageSize(int? value) async {
    if (value == null || value == _pageSize) return;
    setState(() {
      _pageSize = value;
      _pageNumber = 1;
    });
    await _loadData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: _buildAppBar(),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody(context)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: C.appBar1,
      foregroundColor: Colors.white,
      titleSpacing: 18,
      title: const Text(
        'Printing Issue Report',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          key: _filterButtonKey,
          tooltip: 'Filters',
          onPressed: () => _openFilterMenu(context),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.filter_alt_outlined),
              if (_hasActiveFilters)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _isRefreshing ? null : _refresh,
          icon: _isRefreshing
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _pageData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _pageData.isEmpty) {
      return _buildErrorState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(isMobile ? 12 : 18, 14, isMobile ? 12 : 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeBar(),
              const SizedBox(height: 12),
              _buildSummary(isMobile),
              const SizedBox(height: 14),
              _buildTableCard(),
              const SizedBox(height: 12),
              _buildPageFooter(),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR / EMPTY
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load printing issue report',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.textHigh),
            ),
            const SizedBox(height: 7),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE RANGE BAR
  // ============================================================

  Widget _buildDateRangeBar() {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, size: 18, color: C.primaryDark),
            const SizedBox(width: 10),
            Text(
              '${fmt(_fromDate)}  →  ${fmt(_toDate)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.textHigh),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTER MENU
  // ============================================================

  Future<void> _openFilterMenu(BuildContext context) async {
    final RenderBox button =
    _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height + 8), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero) + const Offset(0, 8),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 300),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _ReportFilterMenuContent(
            selectedComponent: _selectedComponent,
            selectedDept: _selectedDept,
            componentList: _componentList,
            deptList: _deptList,
            initialSearch: _searchController.text,
            onApply: (component, dept, search) {
              setState(() {
                _selectedComponent = component;
                _selectedDept = dept;
                _searchController.text = search;
              });
              _applyClientFilters();
            },
            onReset: _resetFilters,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(bool isMobile) {
    final totalPcs = _filteredData.fold<int>(0, (s, i) => s + i.pcs);
    final totalWt = _filteredData.fold<double>(0, (s, i) => s + i.netWt);

    final cards = [
      _card('RECORDS', '${_filteredData.length}', Icons.receipt_long_outlined, C.primary),
      _card('TOTAL PCS', _formatInt(totalPcs), Icons.inventory_2_outlined, Colors.orange.shade700),
      _card('TOTAL WT', '${totalWt.toStringAsFixed(2)} kg', Icons.scale_outlined, Colors.teal.shade700),
    ];

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 8),
        Expanded(child: cards[1]),
        const SizedBox(width: 8),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _card(String title, String value, IconData icon, Color accent) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                const SizedBox(height: 3),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: C.textHigh, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTableCard() {
    if (_filteredData.isEmpty) return _buildEmptyState();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 50,
        horizontalMargin: 14,
        columnSpacing: 18,
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
        columns: [
          DataColumn(label: _head('Sr No')),
          DataColumn(label: _head('Party Name')),
          DataColumn(label: _head('Bom No')),
          DataColumn(label: _head('Component')),
          DataColumn(label: _head('Cut L'), numeric: true),
          DataColumn(label: _head('Cut W'), numeric: true),
          DataColumn(label: _head('Pcs'), numeric: true),
          DataColumn(label: _head('Wt/Pcs'), numeric: true),
          DataColumn(label: _head('Net Wt'), numeric: true),
          DataColumn(label: _head('Type')),
          DataColumn(label: _head('Dept')),
          DataColumn(label: _head('Date')),
        ],
        rows: List.generate(_filteredData.length, (index) {
          final item = _filteredData[index];
          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            color: WidgetStateProperty.all(index.isEven ? Colors.white : const Color(0xFFF8FAFF)),
            cells: [
              DataCell(_cell('$globalIndex', isBold: true)),
              DataCell(SizedBox(width: 120, child: _cell(item.partyName, isBold: true))),
              DataCell(_pill(item.bomNo, C.primaryDark)),
              DataCell(_pill(item.component, _componentColor(item.component))),
              DataCell(_cell(item.cutLength.toStringAsFixed(2))),
              DataCell(_cell(item.cutWidth.toStringAsFixed(2))),
              DataCell(_cell(_formatInt(item.pcs), isBold: true)),
              DataCell(_cell(item.weightPerPcs.toStringAsFixed(3))),
              DataCell(_cell(item.netWt.toStringAsFixed(3), isBold: true)),
              DataCell(_pill(item.transactionType, Colors.indigo.shade700)),
              DataCell(_pill(item.issueDepartment, Colors.brown.shade600)),
              DataCell(_cell(_formatDate(item.issueDate))),
            ],
          );
        }),
      ),
    );
  }

  Widget _head(String text) => Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)),
  );

  Widget _cell(String value, {bool isBold = false, Color? color}) => Text(
    value.isEmpty ? '-' : value,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: TextStyle(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      color: color ?? C.textHigh,
    ),
  );

  Widget _pill(String value, Color color) {
    if (value.trim().isEmpty) {
      return const Text('-', style: TextStyle(fontSize: 12, color: Colors.grey));
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.09), borderRadius: BorderRadius.circular(20)),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Color _componentColor(String component) {
    switch (component.toUpperCase()) {
      case 'BODY':
        return Colors.blue.shade700;
      case 'SIDE':
        return Colors.deepPurple.shade700;
      case 'BOTTOM':
        return Colors.orange.shade800;
      case 'TOP':
        return Colors.green.shade700;
      case 'BAFFLE':
        return Colors.teal.shade700;
      default:
        return C.primaryDark;
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildPageFooter() {
    if (_pageData.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _pageSizeDropdown(),
        Row(
          children: [
            _footerArrow(
              icon: Icons.chevron_left_rounded,
              enabled: _hasPreviousPage && !_isLoading,
              onTap: _goToPreviousPage,
            ),
            const SizedBox(width: 14),
            Text('Page $_pageNumber',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.textHigh)),
            const SizedBox(width: 14),
            _footerArrow(
              icon: Icons.chevron_right_rounded,
              enabled: _hasNextPage && !_isLoading,
              onTap: _goToNextPage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerArrow({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return Material(
      color: enabled ? C.primary.withOpacity(0.08) : Colors.grey.withOpacity(0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: enabled ? C.primaryDark : Colors.grey.shade400),
        ),
      ),
    );
  }

  Widget _pageSizeDropdown() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _pageSize,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textHigh),
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 / page')),
            DropdownMenuItem(value: 25, child: Text('25 / page')),
            DropdownMenuItem(value: 50, child: Text('50 / page')),
            DropdownMenuItem(value: 100, child: Text('100 / page')),
          ],
          onChanged: _changePageSize,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(color: C.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 30, color: C.primaryDark),
          ),
          const SizedBox(height: 14),
          const Text('No records found for this range',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: C.textHigh)),
          const SizedBox(height: 5),
          Text(
            _hasActiveFilters
                ? 'No records match the selected filters.'
                : 'Try a different date range.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
    );
  }
}

// ============================================================
// FILTER MENU CONTENT
// ============================================================

class _ReportFilterMenuContent extends StatefulWidget {
  final String selectedComponent;
  final String selectedDept;
  final List<String> componentList;
  final List<String> deptList;
  final String initialSearch;
  final void Function(String, String, String) onApply;
  final VoidCallback onReset;

  const _ReportFilterMenuContent({
    required this.selectedComponent,
    required this.selectedDept,
    required this.componentList,
    required this.deptList,
    required this.initialSearch,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_ReportFilterMenuContent> createState() => _ReportFilterMenuContentState();
}

class _ReportFilterMenuContentState extends State<_ReportFilterMenuContent> {
  late String _component;
  late String _dept;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _component = widget.selectedComponent;
    _dept = widget.selectedDept;
    _search = TextEditingController(text: widget.initialSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: C.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: C.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_alt_outlined, size: 17, color: C.primaryDark),
                ),
                const SizedBox(width: 9),
                const Text('Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.textHigh)),
              ],
            ),
            const SizedBox(height: 13),
            _dropdown('COMPONENT', _component, widget.componentList, (v) => setState(() => _component = v ?? 'ALL')),
            const SizedBox(height: 10),
            _dropdown('DEPARTMENT', _dept, widget.deptList, (v) => setState(() => _dept = v ?? 'ALL')),
            const SizedBox(height: 10),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search party, BOM...',
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                filled: true,
                fillColor: C.bg,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: C.border)),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onApply(_component, _dept, _search.text);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _component = 'ALL';
                          _dept = 'ALL';
                          _search.clear();
                        });
                        widget.onReset();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: C.textHigh,
                        side: BorderSide(color: C.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final safeValue = items.contains(value) ? value : 'ALL';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.textHigh)),
        const SizedBox(height: 5),
        Container(
          height: 43,
          decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(9), border: Border.all(color: C.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
              style: const TextStyle(fontSize: 12, color: C.textHigh, fontWeight: FontWeight.w600),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
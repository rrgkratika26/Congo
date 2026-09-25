import 'package:flutter/material.dart';

import '../../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/statusTrackerServices.dart';
import 'PrintingIssueDialog.dart';

class PrintingIssueListScreen extends StatefulWidget {
  const PrintingIssueListScreen({super.key});

  @override
  State<PrintingIssueListScreen> createState() =>
      _PrintingIssueListScreenState();
}

class _PrintingIssueListScreenState extends State<PrintingIssueListScreen> {
  final ScrollController _horizontalController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _filterButtonKey = GlobalKey();

  // ============================================================
  // DATA
  // ============================================================

  List<PrintingIssueModel> _allRecords = [];
  List<PrintingIssueModel> _filteredRecords = [];
  List<PrintingIssueModel> _pageRecords = [];

  // ============================================================
  // DROPDOWN LISTS
  // ============================================================

  List<String> _partyList = ['ALL'];
  List<String> _bomList = ['ALL'];
  List<String> _componentList = ['ALL'];

  String _selectedParty = 'ALL';
  String _selectedBom = 'ALL';
  String _selectedComponent = 'ALL';

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  // ============================================================
  // PAGINATION
  // ============================================================

  int _pageNumber = 1;
  int _pageSize = 15;

  int get _totalPages {
    if (_filteredRecords.isEmpty) {
      return 1;
    }

    return (_filteredRecords.length / _pageSize).ceil();
  }

  bool get _hasNextPage => _pageNumber < _totalPages;

  bool get _hasPreviousPage => _pageNumber > 1;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);

    _searchController.dispose();
    _horizontalController.dispose();

    super.dispose();
  }

  // ============================================================
  // API LOAD
  // ============================================================

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // NOTE: add `fetchPrintingIssue()` to StatusTrackerService, hitting
      // `data/Printing/PrintingIssueList` and mapping the `data` array with
      // `PrintingIssueModel.fromJson`, the same way `fetchPrintingReceive()`
      // already does for the Receive screen.
      final data = await StatusTrackerService.fetchPrintingIssue();

      if (!mounted) return;

      setState(() {
        _allRecords = data;
        _isLoading = false;
        _isRefreshing = false;
      });

      _buildDropdownLists();

      _pageNumber = 1;

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    await _loadData(refresh: true);
  }

  // ============================================================
  // DROPDOWN LISTS
  // ============================================================

  void _buildDropdownLists() {
    final parties = <String>{'ALL'};
    final boms = <String>{'ALL'};
    final components = <String>{'ALL'};

    for (final item in _allRecords) {
      if (item.partyName.trim().isNotEmpty) {
        parties.add(item.partyName.trim());
      }

      if (item.bomNo.trim().isNotEmpty) {
        boms.add(item.bomNo.trim());
      }

      if (item.component.trim().isNotEmpty) {
        components.add(item.component.trim());
      }
    }

    int cmp(String a, String b) {
      if (a == 'ALL') return -1;
      if (b == 'ALL') return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    }

    setState(() {
      _partyList = parties.toList()..sort(cmp);
      _bomList = boms.toList()..sort(cmp);
      _componentList = components.toList()..sort(cmp);

      if (!_partyList.contains(_selectedParty)) _selectedParty = 'ALL';
      if (!_bomList.contains(_selectedBom)) _selectedBom = 'ALL';
      if (!_componentList.contains(_selectedComponent)) {
        _selectedComponent = 'ALL';
      }
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    _pageNumber = 1;
    _applyFilters();
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilters() {
    final search = _searchController.text.trim().toLowerCase();

    final result = _allRecords.where((item) {
      final partyMatch =
          _selectedParty == 'ALL' ||
          item.partyName.trim().toLowerCase() ==
              _selectedParty.trim().toLowerCase();

      final bomMatch =
          _selectedBom == 'ALL' ||
          item.bomNo.trim().toLowerCase() == _selectedBom.trim().toLowerCase();

      final componentMatch =
          _selectedComponent == 'ALL' ||
          item.component.trim().toLowerCase() ==
              _selectedComponent.trim().toLowerCase();

      final searchMatch = search.isEmpty || item.searchText.contains(search);

      return partyMatch && bomMatch && componentMatch && searchMatch;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredRecords = result;

      if (_pageNumber > _totalPages) {
        _pageNumber = _totalPages;
      }

      _updatePageRecords();
    });
  }

  // ============================================================
  // PAGINATION DATA
  // ============================================================

  void _updatePageRecords() {
    if (_filteredRecords.isEmpty) {
      _pageRecords = [];
      return;
    }

    final start = (_pageNumber - 1) * _pageSize;

    if (start >= _filteredRecords.length) {
      _pageRecords = [];
      return;
    }

    final end = (start + _pageSize).clamp(0, _filteredRecords.length);

    _pageRecords = _filteredRecords.sublist(start, end);
  }

  // ============================================================
  // RESET FILTERS
  // ============================================================

  void _resetFilters() {
    setState(() {
      _selectedParty = 'ALL';
      _selectedBom = 'ALL';
      _selectedComponent = 'ALL';

      _searchController.clear();

      _pageNumber = 1;
    });

    _applyFilters();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<void> _goToPreviousPage() async {
    if (!_hasPreviousPage || _isLoading) return;

    setState(() {
      _pageNumber--;
      _updatePageRecords();
    });
  }

  Future<void> _goToNextPage() async {
    if (!_hasNextPage || _isLoading) return;

    setState(() {
      _pageNumber++;
      _updatePageRecords();
    });
  }

  Future<void> _changePageSize(int? value) async {
    if (value == null || value == _pageSize) return;

    setState(() {
      _pageSize = value;
      _pageNumber = 1;

      _updatePageRecords();
    });
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

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: C.appBar1,
      foregroundColor: Colors.white,
      titleSpacing: 18,
      title: const Text(
        'Printing Issue List',
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  bool get _hasActiveFilters {
    return _selectedParty != 'ALL' ||
        _selectedBom != 'ALL' ||
        _selectedComponent != 'ALL' ||
        _searchController.text.trim().isNotEmpty;
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
        button.localToGlobal(
          Offset(0, button.size.height + 8),
          ancestor: overlay,
        ),
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
      constraints: const BoxConstraints(maxWidth: 320),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _IssueFilterMenuContent(
            selectedParty: _selectedParty,
            selectedBom: _selectedBom,
            selectedComponent: _selectedComponent,
            partyList: _partyList,
            bomList: _bomList,
            componentList: _componentList,
            initialSearch: _searchController.text,
            onApply: (party, bom, component, search) {
              setState(() {
                _selectedParty = party;
                _selectedBom = bom;
                _selectedComponent = component;

                _searchController.text = search;

                _pageNumber = 1;
              });

              _applyFilters();
            },
            onReset: _resetFilters,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _allRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allRecords.isEmpty) {
      return _buildErrorState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 750;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 18,
            14,
            isMobile ? 12 : 18,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(context, isMobile),
              const SizedBox(height: 14),
              _buildTableCard(context),
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
  // ERROR
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
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load printing issue data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: C.textHigh,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(BuildContext context, bool isMobile) {
    final cards = [
      _SummaryData(
        title: 'TOTAL',
        value: '${_filteredRecords.length}',
        icon: Icons.receipt_long_outlined,
        accentColor: C.primary,
      ),
      _SummaryData(
        title: 'TOTAL PCS',
        value: _formatInt(totalPcs),
        icon: Icons.inventory_2_outlined,
        accentColor: Colors.orange.shade700,
      ),
      _SummaryData(
        title: 'ISSUED WT',
        value: '${totalIssueWt.toStringAsFixed(2)} kg',
        icon: Icons.local_shipping_outlined,
        accentColor: Colors.teal.shade700,
      ),
    ];

    if (isMobile) {
      return Row(
        children: [
          Expanded(child: _summaryCard(cards[0])),
          const SizedBox(width: 8),
          Expanded(child: _summaryCard(cards[1])),
          const SizedBox(width: 8),

          Expanded(child: _summaryCard(cards[2])),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _summaryCard(cards[0])),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard(cards[1])),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard(cards[2])),
      ],
    );
  }

  Widget _summaryCard(_SummaryData data) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(data.icon, size: 17, color: data.accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: C.textHigh,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

  // ============================================================
  // TABLE CARD
  // ============================================================

  Widget _buildTableCard(BuildContext context) {
    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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

  // ============================================================
  // DATA TABLE
  // ============================================================

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 50,
        horizontalMargin: 14,
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
        columns: [
          DataColumn(label: _head('Sr No')),
          DataColumn(label: _head('Party Name')),
          DataColumn(label: _head('Bom No')),
          DataColumn(label: _head('Component')),
          DataColumn(label: _head('Cut Length'), numeric: true),
          DataColumn(label: _head('Cut Width'), numeric: true),
          DataColumn(label: _head('Pcs'), numeric: true),
          DataColumn(label: _head('Bal Pcs'), numeric: true),
          DataColumn(label: _head('Issue Pcs'), numeric: true),

          DataColumn(label: _head('Net Wt'), numeric: true),
          DataColumn(label: _head('Per Pcs Wt'), numeric: true),
          DataColumn(label: _head('Issue Wt'), numeric: true),
          DataColumn(label: _head('Balance Wt'), numeric: true),
          DataColumn(label: _head('Status')),
        ],
        rows: List.generate(_pageRecords.length, (index) {
          final item = _pageRecords[index];

          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            onSelectChanged: (_) => _openIssueDialog(item),
            color: WidgetStateProperty.all(
              index.isEven ? Colors.white : const Color(0xFFF8FAFF),
            ),
            cells: [
              DataCell(_cell('$globalIndex', isBold: true)),
              DataCell(
                SizedBox(
                  width: 110,
                  child: _cell(item.partyName, isBold: true),
                ),
              ),
              DataCell(_pill(item.bomNo, C.primaryDark)),
              DataCell(_pill(item.component, _componentColor(item.component))),
              DataCell(_cell(item.cutLength.toStringAsFixed(2))),
              DataCell(_cell(item.cutWidth.toStringAsFixed(2))),
              DataCell(
                _numberPill(
                  _formatInt(item.pcs),
                  Colors.blue,
                ),
              ),
              DataCell(
                _numberPill(
                  _formatInt(item.balancePcs),
                  item.balancePcs <= 0 ? Colors.green : Colors.orange,
                ),
              ),
          DataCell(
          _numberPill(
          _formatInt(item.issuePcs),
          item.issuePcs > 0 ? Colors.teal : Colors.grey,
          ),),

              DataCell(_cell(item.netWt.toStringAsFixed(3), isBold: true)),
              DataCell(_cell(item.perPcsWt.toStringAsFixed(3))),

              DataCell(_cell(item.issueWt.toStringAsFixed(3))),
              DataCell(_cell(item.balanceWt.toStringAsFixed(3), isBold: true)),
              DataCell(_statusPill(item)),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================
  // TABLE WIDGETS
  // ============================================================

  Widget _head(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1565C0),
      ),
    );
  }

  Widget _cell(String value, {bool isBold = false, Color? color}) {
    return Text(
      value.isEmpty ? '-' : value,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? C.textHigh,
      ),
    );
  }

  Widget _pill(String value, Color color) {
    if (value.trim().isEmpty) {
      return const Text(
        '-',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _statusPill(PrintingIssueModel item) {
    late final String label;
    late final Color color;

    if (item.issuePcs <= 0) {
      label = 'Pending';
      color = Colors.grey.shade600;
    } else if (item.balancePcs <= 0) {
      label = 'Fully Issued';
      color = Colors.green.shade700;
    } else {
      label = 'Partial';
      color = Colors.orange.shade800;
    }

    return _pill(label, color);
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

  // ============================================================
  // PAGE FOOTER — simple "Page X of Y" with prev/next
  // ============================================================

  Widget _buildPageFooter() {
    if (_filteredRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _footerArrow(
          icon: Icons.chevron_left_rounded,
          enabled: _hasPreviousPage && !_isLoading,
          onTap: _goToPreviousPage,
        ),
        const SizedBox(width: 14),
        Text(
          'Page $_pageNumber of $_totalPages',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: C.textHigh,
          ),
        ),
        const SizedBox(width: 14),
        _footerArrow(
          icon: Icons.chevron_right_rounded,
          enabled: _hasNextPage && !_isLoading,
          onTap: _goToNextPage,
        ),
      ],
    );
  }

  Widget _footerArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled
          ? C.primary.withOpacity(0.08)
          : Colors.grey.withOpacity(0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? C.primaryDark : Colors.grey.shade400,
          ),
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: C.textHigh,
          ),
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
            decoration: BoxDecoration(
              color: C.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 30,
              color: C.primaryDark,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No printing issue records found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textHigh,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _hasActiveFilters
                ? 'No records match the selected filters.'
                : 'There are no printing issue records.',
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

  // ============================================================
  // SUMMARY CALCULATIONS
  // ============================================================

  int get totalPcs => _filteredRecords.fold(0, (sum, item) => sum + item.pcs);

  double get totalIssueWt =>
      _filteredRecords.fold(0.0, (sum, item) => sum + item.issueWt);

  double get totalBalanceWt =>
      _filteredRecords.fold(0.0, (sum, item) => sum + item.balanceWt);

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }

  Future<void> _openIssueDialog(PrintingIssueModel item) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PrintingIssueDialog(item: item),
    );

    if (saved == true) {
      _loadData(refresh: true); // list refresh after successful save
    }
  }

  Widget _numberPill(String value, Color color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class PrintingIssueModel {
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final double perPcsWt;
  final int pcs;
  final double netWt;

  final int issuePcs;
  final double issueWt;

  final int balancePcs;
  final double balanceWt;

  const PrintingIssueModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.perPcsWt,
    required this.pcs,
    required this.netWt,
    required this.issuePcs,
    required this.issueWt,
    required this.balancePcs,
    required this.balanceWt,
  });

  factory PrintingIssueModel.fromJson(Map<String, dynamic> json) {
    return PrintingIssueModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      perPcsWt: _toDouble(json['perPcsWt']),
      pcs: _toInt(json['pcs']),
      netWt: _toDouble(json['netWt']),
      issuePcs: _toInt(json['issuePcs']),
      issueWt: _toDouble(json['issueWt']),
      balancePcs: _toInt(json['balancePcs']),
      balanceWt: _toDouble(json['balanceWt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String get searchText {
    return [
      partyName,
      bomNo,
      component,
      cutLength.toString(),
      cutWidth.toString(),
      pcs.toString(),
      netWt.toString(),
      issuePcs.toString(),
      issueWt.toString(),
      balancePcs.toString(),
      balanceWt.toString(),
    ].join(' ').toLowerCase();
  }
}

// ============================================================
// SUMMARY MODEL
// ============================================================

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });
}

// ============================================================
// FILTER MENU CONTENT
// ============================================================

class _IssueFilterMenuContent extends StatefulWidget {
  final String selectedParty;
  final String selectedBom;
  final String selectedComponent;

  final List<String> partyList;
  final List<String> bomList;
  final List<String> componentList;

  final String initialSearch;

  final void Function(String, String, String, String) onApply;

  final VoidCallback onReset;

  const _IssueFilterMenuContent({
    required this.selectedParty,
    required this.selectedBom,
    required this.selectedComponent,
    required this.partyList,
    required this.bomList,
    required this.componentList,
    required this.initialSearch,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_IssueFilterMenuContent> createState() =>
      _IssueFilterMenuContentState();
}

class _IssueFilterMenuContentState extends State<_IssueFilterMenuContent> {
  late String _party;
  late String _bom;
  late String _component;

  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();

    _party = widget.selectedParty;
    _bom = widget.selectedBom;
    _component = widget.selectedComponent;

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
        width: 300,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
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
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    size: 17,
                    color: C.primaryDark,
                  ),
                ),
                const SizedBox(width: 9),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: C.textHigh,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _dropdown(
              label: 'PARTY',
              value: _party,
              items: widget.partyList,
              onChanged: (value) => setState(() => _party = value ?? 'ALL'),
            ),
            const SizedBox(height: 10),
            _dropdown(
              label: 'BOM NO',
              value: _bom,
              items: widget.bomList,
              onChanged: (value) => setState(() => _bom = value ?? 'ALL'),
            ),
            const SizedBox(height: 10),
            _dropdown(
              label: 'COMPONENT',
              value: _component,
              items: widget.componentList,
              onChanged: (value) => setState(() => _component = value ?? 'ALL'),
            ),
            const SizedBox(height: 10),
            _searchField(),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onApply(_party, _bom, _component, _search.text);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
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
                          _party = 'ALL';
                          _bom = 'ALL';
                          _component = 'ALL';
                          _search.clear();
                        });

                        widget.onReset();

                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: C.textHigh,
                        side: BorderSide(color: C.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
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

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : 'ALL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: C.textHigh,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 43,
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: C.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
              style: const TextStyle(
                fontSize: 12,
                color: C.textHigh,
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search party, BOM, component...',
        prefixIcon: const Icon(Icons.search_rounded, size: 19),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _search,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();

            return IconButton(
              tooltip: 'Clear',
              onPressed: _search.clear,
              icon: const Icon(Icons.close_rounded, size: 18),
            );
          },
        ),
        filled: true,
        fillColor: C.bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: C.primary, width: 1.3),
        ),
      ),
    );
  }
}

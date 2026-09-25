import 'package:IMS/services/getSupervisors/RmdService.dart';
import 'package:flutter/material.dart';

import '../../../../Color/Colorclass.dart';
import '../../../ScannedItem/Cutting/NardanaCutting/RecutPOPupNardana.dart';
import 'RollCuttingReport/ModelComponentWise/RollwisecuttingStockmodel.dart';

class CuttingStockreport extends StatefulWidget {
  const CuttingStockreport({super.key});

  @override
  State<CuttingStockreport> createState() => _CuttingStockreportState();
}

class _CuttingStockreportState extends State<CuttingStockreport> {
  final RmdService _service = RmdService();

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _horizontalController = ScrollController();


  // ============================================================
  // ALL API DATA
  // ============================================================

  List<RollWiseCuttingStockModel> _allRecords = [];

  // Search filtered data
  List<RollWiseCuttingStockModel> _filteredRecords = [];

  // Current page data
  List<RollWiseCuttingStockModel> _pageRecords = [];

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  // ============================================================
  // LOCAL PAGINATION
  // ============================================================

  int _pageNumber = 1;

  int _pageSize = 15;

  int get _totalRecords => _filteredRecords.length;

  int get _totalPages {
    if (_totalRecords == 0) {
      return 1;
    }

    return (_totalRecords / _pageSize).ceil();
  }

  bool get _hasPreviousPage {
    return _pageNumber > 1;
  }

  bool get _hasNextPage {
    return _pageNumber < _totalPages;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);

    _searchController.dispose();

    _horizontalController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD ALL API DATA
  // ============================================================

  Future<void> _loadAllData({bool refresh = false}) async {
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
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('CUTTING STOCK REPORT');
      debugPrint('LOADING ALL API DATA');
      debugPrint('==========================================');

      final List<RollWiseCuttingStockModel> allData = [];

      int apiPage = 1;

      // We use a reasonably large API page size so that
      // fewer API requests are required.
      const int apiPageSize = 200;

      while (true) {
        debugPrint('Fetching API page $apiPage, size $apiPageSize');

        final result = await _service.fetchCuttingStockReport(
          pageNumber: apiPage,
          pageSize: apiPageSize,
        );

        allData.addAll(result);

        debugPrint('API page $apiPage returned ${result.length} records');

        // If fewer records than page size came back,
        // this is the last API page.
        if (result.length < apiPageSize) {
          break;
        }

        apiPage++;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _allRecords = allData;

        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = null;

        _pageNumber = 1;
      });

      _applySearchAndPagination();

      debugPrint('');
      debugPrint('TOTAL API RECORDS: ${_allRecords.length}');
      debugPrint('TOTAL FILTERED: ${_filteredRecords.length}');
      debugPrint('TOTAL LOCAL PAGES: $_totalPages');
      debugPrint('==========================================');
    } catch (e) {
      debugPrint('CUTTING STOCK ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadAllData(refresh: true);
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    _pageNumber = 1;

    _applySearchAndPagination();

    if (mounted) {
      setState(() {});
    }
  }

  void _applySearchAndPagination() {
    final query = _searchController.text.trim().toLowerCase();

    // ==========================================================
    // SEARCH WHOLE DATA
    // ==========================================================

    if (query.isEmpty) {
      _filteredRecords = List.from(_allRecords);
    } else {
      _filteredRecords = _allRecords.where((item) {
        final partyName = item.partyName.trim().toLowerCase();

        final bomNo = item.bomNo.trim().toLowerCase();

        return partyName.contains(query) || bomNo.contains(query);
      }).toList();
    }

    // ==========================================================
    // SAFETY: CURRENT PAGE MUST EXIST
    // ==========================================================

    if (_pageNumber > _totalPages) {
      _pageNumber = _totalPages;
    }

    if (_pageNumber < 1) {
      _pageNumber = 1;
    }

    // ==========================================================
    // LOCAL PAGINATION
    // ==========================================================

    final startIndex = (_pageNumber - 1) * _pageSize;

    if (startIndex >= _filteredRecords.length) {
      _pageRecords = [];
      return;
    }

    final endIndex = (startIndex + _pageSize).clamp(0, _filteredRecords.length);

    _pageRecords = _filteredRecords.sublist(startIndex, endIndex);
  }

  void _clearSearch() {
    _searchController.clear();
  }

  // ============================================================
  // PAGE NAVIGATION
  // ============================================================

  void _goToPreviousPage() {
    if (!_hasPreviousPage) {
      return;
    }

    setState(() {
      _pageNumber--;
      _applySearchAndPagination();
    });

    _scrollTableToTop();
  }

  void _goToNextPage() {
    if (!_hasNextPage) {
      return;
    }

    setState(() {
      _pageNumber++;
      _applySearchAndPagination();
    });

    _scrollTableToTop();
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) {
      return;
    }

    if (page == _pageNumber) {
      return;
    }

    setState(() {
      _pageNumber = page;
      _applySearchAndPagination();
    });

    _scrollTableToTop();
  }

  void _scrollTableToTop() {
    // Small delay allows the table to rebuild first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final controller = PrimaryScrollController.of(context);

      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============================================================
  // PAGE SIZE
  // ============================================================

  void _changePageSize(int? value) {
    if (value == null || value == _pageSize) {
      return;
    }

    setState(() {
      _pageSize = value;

      // Start from page 1 whenever page size changes.
      _pageNumber = 1;

      _applySearchAndPagination();
    });
  }

  // ============================================================
  // RECUT POPUP
  // ============================================================

  void _openRecutPopup(RollWiseCuttingStockModel item) {
    CuttingIssueData.show(
      context,
      partyName: item.partyName,
      width: item.cutWidth,
      cutLength: item.cutLength,
      perPcsWt: item.weightPerPcs,
      bomNo: item.bomNo.trim().isEmpty ? null : item.bomNo,
      component: item.component.trim().isEmpty ? null : item.component,
      onSaved: _refresh,
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  int get totalPcs {
    return _filteredRecords.fold(0, (sum, item) => sum + item.pcs);
  }

  int get usedPcs {
    return _filteredRecords.fold(0, (sum, item) => sum + item.usedPcs);
  }

  int get balancePcs {
    return _filteredRecords.fold(0, (sum, item) => sum + item.balancePcs);
  }

  double get totalNetWt {
    return _filteredRecords.fold(0.0, (sum, item) => sum + item.netWt);
  }

  double get totalUsedWt {
    return _filteredRecords.fold(0.0, (sum, item) => sum + item.usedWt);
  }

  double get totalBalanceWt {
    return _filteredRecords.fold(0.0, (sum, item) => sum + item.balanceWt);
  }

  double get usedPercentage {
    if (totalNetWt <= 0) {
      return 0;
    }

    return (totalUsedWt / totalNetWt) * 100;
  }

  double get balancePercentage {
    if (totalNetWt <= 0) {
      return 0;
    }

    return (totalBalanceWt / totalNetWt) * 100;
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
        'Cutting Stock Report',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _isRefreshing ? null : _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
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
        final bool isMobile = constraints.maxWidth < 700;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? 12 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchSection(context, isMobile),

              const SizedBox(height: 8),

              _buildSummaryCards(context, isMobile),

              const SizedBox(height: 8),

              _buildTableCard(context),

              const SizedBox(height: 8),

              // PAGINATION IS AT BOTTOM
              _buildPagination(context),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH SECTION
  // ============================================================

  Widget _buildSearchSection(BuildContext context, bool isMobile) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search Party Name or BOM No...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear',
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded, size: 19),
              )
            : null,
        filled: true,
        fillColor: C.bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: C.primary, width: 1.3),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE SIZE DROPDOWN
  // ============================================================

  Widget _pageSizeDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _pageSize,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: const [
            DropdownMenuItem(
              value: 15,
              child: Text('15 / page', style: TextStyle(fontSize: 11)),
            ),
            DropdownMenuItem(
              value: 25,
              child: Text('25 / page', style: TextStyle(fontSize: 11)),
            ),
            DropdownMenuItem(
              value: 50,
              child: Text('50 / page', style: TextStyle(fontSize: 11)),
            ),
            DropdownMenuItem(
              value: 100,
              child: Text('100 / page', style: TextStyle(fontSize: 11)),
            ),
            DropdownMenuItem(
              value: 200,
              child: Text('200 / page', style: TextStyle(fontSize: 11)),
            ),
          ],
          onChanged: _changePageSize,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCards(BuildContext context, bool isMobile) {
    final cards = [
      // _SummaryData(
      //   title: 'Net PCS',
      //   value: _formatInt(totalPcs),
      //
      //   icon: Icons.inventory_2_outlined,
      //   iconColor: C.primary,
      // ),

      _SummaryData(
        title: 'Total PCS',
        value: _formatInt(balancePcs),

        icon: Icons.inventory_outlined,
        iconColor: Colors.green.shade700,
      ),

      _SummaryData(
        title: 'Total Weight',
        value: '${totalBalanceWt.toStringAsFixed(2)} kg',

        icon: Icons.account_balance_wallet_outlined,
        iconColor: Colors.green.shade700,
      ),
    ];

    if (isMobile) {
      return Row(
        children: [
          // _summaryCard(cards[0]),
          // const SizedBox(width: 5),
          _summaryCard(cards[0]),
          const SizedBox(width: 5),
          _summaryCard(cards[1]),


        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 1200
            ? 6
            : MediaQuery.of(context).size.width >= 900
            ? 3
            : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        return _summaryCard(cards[index]);
      },
    );
  }

  Widget _summaryCard(_SummaryData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Row(

            children: [
              Icon(data.icon, size: 15, color: data.iconColor),
              const SizedBox(width: 10),
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: C.textHigh,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTableCard(BuildContext context) {
    if (_pageRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
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



  Widget _head(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
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
        fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
      child: DataTable(
        headingRowHeight: 34,
        dataRowMinHeight: 30,
        dataRowMaxHeight: 34,
        horizontalMargin: 12,
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
        columns: [
          DataColumn(label: _head('Sr')),
          DataColumn(label: _head('Party')),
          DataColumn(label: _head('BOM No')),
          DataColumn(label: _head('Component')),
          DataColumn(label: _head('Cut Width'), numeric: true),
          DataColumn(label: _head('Cut Length'), numeric: true),
          DataColumn(label: _head('Net Wt'), numeric: true),
          DataColumn(label: _head('PCS'), numeric: true),
          DataColumn(label: _head('Wt/Pcs'), numeric: true),
          DataColumn(label: _head('Used Pcs'), numeric: true),
          DataColumn(label: _head('Used Wt'), numeric: true),
          DataColumn(label: _head('Bal Pcs'), numeric: true),
          DataColumn(label: _head('Bal Wt'), numeric: true),
        ],
        rows: List.generate(_pageRecords.length, (index) {
          final item = _pageRecords[index];

          // Serial number across
          // filtered pages.
          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            onSelectChanged: (_) => _openRecutPopup(item),
            color: WidgetStateProperty.all(
              index.isEven ? Colors.white : const Color(0xFFF8FAFF),
            ),
            cells: [
              DataCell(_cell('$globalIndex', isBold: true)),

              DataCell(
                SizedBox(
                  width: 140,
                  child: _cell(item.partyName, isBold: true),
                ),
              ),

              DataCell(_pill(item.bomNo, C.primaryDark)),

              DataCell(_pill(item.component, _componentColor(item.component))),

              DataCell(_cell(item.cutWidth.toStringAsFixed(2))),

              DataCell(_cell(item.cutLength.toStringAsFixed(2))),

              DataCell(_cell(item.netWt.toStringAsFixed(2), isBold: true)),

              DataCell(_cell(_formatInt(item.pcs), isBold: true)),

              DataCell(_cell(item.weightPerPcs.toStringAsFixed(3))),

              DataCell(
                _cell(
                  '${item.usedPcs}',
                  color: item.usedPcs > 0
                      ? Colors.orange.shade800
                      : Colors.grey.shade600,
                ),
              ),

              DataCell(
                _cell(
                  item.usedWt.toStringAsFixed(2),
                  color: item.usedWt > 0
                      ? Colors.orange.shade800
                      : Colors.grey.shade600,
                ),
              ),

              DataCell(
                _cell(
                  _formatInt(item.balancePcs),
                  isBold: true,
                  color: item.balancePcs > 0
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),

              DataCell(
                _cell(
                  item.balanceWt.toStringAsFixed(2),
                  isBold: true,
                  color: item.balanceWt > 0
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination(BuildContext context) {
    if (_totalRecords == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 650;

          if (isMobile) {
            return Column(
              children: [
                Text(
                  'Page $_pageNumber of $_totalPages',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: C.textHigh,
                  ),
                ),



                Row(
                  children: [
                    Expanded(
                      child: _paginationButton(
                        icon: Icons.chevron_left_rounded,
                        text: 'Previous',
                        enabled: _hasPreviousPage,
                        onTap: _goToPreviousPage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _paginationButton(
                        icon: Icons.chevron_right_rounded,
                        text: 'Next',
                        enabled: _hasNextPage,
                        iconAfterText: true,
                        onTap: _goToNextPage,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Text(
                'Page $_pageNumber of $_totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
              ),

              const SizedBox(width: 20),

              _paginationButton(
                icon: Icons.chevron_left_rounded,
                text: 'Previous',
                enabled: _hasPreviousPage,
                onTap: _goToPreviousPage,
              ),

              const SizedBox(width: 10),

              Expanded(child: _buildPageNumbers()),

              const SizedBox(width: 10),

              _paginationButton(
                icon: Icons.chevron_right_rounded,
                text: 'Next',
                enabled: _hasNextPage,
                iconAfterText: true,
                onTap: _goToNextPage,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE NUMBER BUTTONS
  // ============================================================

  Widget _buildPageNumbers({bool isMobile = false}) {
    final pages = _getVisiblePages();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pages.map((page) {
          if (page == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                '...',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final bool selected = page == _pageNumber;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _goToPage(page),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? C.primary : C.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : C.primaryDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<int> _getVisiblePages() {
    final total = _totalPages;

    if (total <= 7) {
      return List.generate(total, (index) => index + 1);
    }

    final List<int> pages = [];

    pages.add(1);

    if (_pageNumber > 4) {
      pages.add(-1);
    }

    final int start = (_pageNumber - 1).clamp(2, total - 1);

    final int end = (_pageNumber + 1).clamp(2, total - 1);

    for (int i = start; i <= end; i++) {
      if (!pages.contains(i)) {
        pages.add(i);
      }
    }

    if (_pageNumber < total - 3) {
      pages.add(-1);
    }

    if (!pages.contains(total)) {
      pages.add(total);
    }

    return pages;
  }

  // ============================================================
  // PAGINATION BUTTON
  // ============================================================

  Widget _paginationButton({
    required IconData icon,
    required String text,
    required bool enabled,
    required VoidCallback onTap,
    bool iconAfterText = false,
  }) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!iconAfterText) Icon(icon, size: 18),

        if (!iconAfterText) const SizedBox(width: 4),

        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),

        if (iconAfterText) const SizedBox(width: 4),

        if (iconAfterText) Icon(icon, size: 18),
      ],
    );

    return Material(
      color: enabled
          ? C.primary.withOpacity(0.08)
          : Colors.grey.withOpacity(0.06),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: DefaultTextStyle(
            style: TextStyle(
              color: enabled ? C.primaryDark : Colors.grey.shade400,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: enabled ? C.primaryDark : Colors.grey.shade400,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;

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
              Icons.inventory_2_outlined,
              size: 30,
              color: C.primaryDark,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            hasSearch ? 'No matching records' : 'No cutting stock found',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textHigh,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasSearch
                ? 'No records match your Party Name or BOM No search.'
                : 'There are no cutting stock records.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(25),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),

        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.red.shade700,
                  size: 30,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Unable to load cutting stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: C.textHigh,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                _errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT
  // ============================================================

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
}

// ================================================================
// SUMMARY MODEL
// ================================================================

class _SummaryData {
  final String title;
  final String value;

  final IconData icon;
  final Color iconColor;

  const _SummaryData({
    required this.title,
    required this.value,

    required this.icon,
    required this.iconColor,
  });
}

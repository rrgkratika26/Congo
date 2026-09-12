import 'package:IMS/services/getSupervisors/RmdService.dart';
import 'package:flutter/material.dart';

import '../../../../Color/Colorclass.dart';
import '../../../ScannedItem/Cutting/NardanaCutting/RecutPOPupNardana.dart';
import 'RollCuttingReport/ModelComponentWise/RollwisecuttingStockmodel.dart';

class RollWiseCuttingStockReport extends StatefulWidget {
  const RollWiseCuttingStockReport({super.key});

  @override
  State<RollWiseCuttingStockReport> createState() =>
      _RollWiseCuttingStockReportState();
}

class _RollWiseCuttingStockReportState
    extends State<RollWiseCuttingStockReport> {
  final RmdService _service = RmdService();
  final issueToCtrl = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _horizontalController = ScrollController();

  List<RollWiseCuttingStockModel> _records = [];
  List<RollWiseCuttingStockModel> _filteredRecords = [];

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  int _pageNumber = 1;
  int _pageSize = 15;

  bool _hasNextPage = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_applySearch);

    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();

    _horizontalController.dispose();

    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('');
      debugPrint('ROLL WISE CUTTING STOCK');
      debugPrint('Loading page $_pageNumber with size $_pageSize');

      final result = await _service.fetchCuttingStockReport(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _records = result;

        _hasNextPage = result.length >= _pageSize;

        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = null;
      });

      _applySearch();

      debugPrint('Page $_pageNumber loaded: ${result.length} records');
      debugPrint('Has Next Page: $_hasNextPage');
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

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredRecords = List.from(_records);
        });
      }

      return;
    }

    final result = _records.where((item) {
      return item.searchText.contains(query);
    }).toList();

    if (mounted) {
      setState(() {
        _filteredRecords = result;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Future<void> _goToPreviousPage() async {
    if (_pageNumber <= 1 || _isLoading) {
      return;
    }

    setState(() {
      _pageNumber--;
    });

    await _loadData();
  }

  Future<void> _goToNextPage() async {
    if (!_hasNextPage || _isLoading) {
      return;
    }

    setState(() {
      _pageNumber++;
    });

    await _loadData();
  }

  Future<void> _changePageSize(int? value) async {
    if (value == null || value == _pageSize) {
      return;
    }

    setState(() {
      _pageSize = value;
      _pageNumber = 1;
    });

    await _loadData();
  }

  void _openRecutPopup(RollWiseCuttingStockModel item) {
    final parts = item.cutSize.split(RegExp(r'[xX*]'));
    final width = parts.isNotEmpty ? double.tryParse(parts[0].trim()) : null;
    final cutLength = parts.length > 1
        ? double.tryParse(parts[1].trim())
        : null;

    AddRecutPcsPopupNardana.show(
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
      title: Text(
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

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _records.isEmpty) {
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
              _buildTableCard(context),

              const SizedBox(height: 14),

              _buildPagination(context),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 15 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleContent(),
                const SizedBox(height: 14),
                _pageInfo(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _titleContent()),
                _pageInfo(),
              ],
            ),
    );
  }

  Widget _titleContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: C.primary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.content_cut_rounded,
            color: C.primaryDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cutting Stock Report',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: C.textHigh,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitor cut stock, usage and remaining balance.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: C.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers_outlined, size: 17, color: C.primaryDark),
          const SizedBox(width: 7),
          Text(
            'Page $_pageNumber',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: C.primaryDark,
            ),
          ),
          const SizedBox(width: 9),
          Container(width: 1, height: 16, color: C.border),
          const SizedBox(width: 9),
          Text(
            'Total: ${_filteredRecords.length} records',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCards(BuildContext context, bool isMobile) {
    final cards = [
      _SummaryData(
        title: 'Net PCS',
        value: _formatInt(totalPcs),
        subtitle: 'Current page',
        icon: Icons.inventory_2_outlined,
        iconColor: C.primary,
      ),
      _SummaryData(
        title: 'Used PCS',
        value: _formatInt(usedPcs),
        subtitle: '${usedPercentage.toStringAsFixed(1)}% used',
        icon: Icons.output_rounded,
        iconColor: Colors.orange.shade700,
      ),
      _SummaryData(
        title: 'Balance PCS',
        value: _formatInt(balancePcs),
        subtitle: '${balancePercentage.toStringAsFixed(1)}% balance',
        icon: Icons.inventory_outlined,
        iconColor: Colors.green.shade700,
      ),
      _SummaryData(
        title: 'Net Weight',
        value: '${totalNetWt.toStringAsFixed(2)} kg',
        subtitle: 'Current page',
        icon: Icons.scale_outlined,
        iconColor: Colors.blue.shade700,
      ),
      _SummaryData(
        title: 'Used Weight',
        value: '${totalUsedWt.toStringAsFixed(2)} kg',
        subtitle: '${usedPercentage.toStringAsFixed(1)}%',
        icon: Icons.trending_up_rounded,
        iconColor: Colors.deepOrange.shade700,
      ),
      _SummaryData(
        title: 'Balance Weight',
        value: '${totalBalanceWt.toStringAsFixed(2)} kg',
        subtitle: '${balancePercentage.toStringAsFixed(1)}%',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: Colors.green.shade700,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _summaryCard(cards[0])),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard(cards[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _summaryCard(cards[2])),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard(cards[3])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _summaryCard(cards[4])),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard(cards[5])),
            ],
          ),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, size: 20, color: data.iconColor),
          ),
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
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
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
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: data.iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border),
      ),
      child: isMobile
          ? Column(
              children: [
                _searchField(),
                const SizedBox(height: 10),
                _pageSizeDropdown(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _searchField()),
                const SizedBox(width: 12),
                _pageSizeDropdown(),
              ],
            ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search party, BOM, component, size, PCS or weight...',
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
      onChanged: (_) {
        setState(() {});
        _applySearch();
      },
    );
  }

  Widget _pageSizeDropdown() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _pageSize,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 / page')),
            DropdownMenuItem(value: 25, child: Text('25 / page')),
            DropdownMenuItem(value: 50, child: Text('50 / page')),
            DropdownMenuItem(value: 100, child: Text('100 / page')),
            DropdownMenuItem(value: 200, child: Text('200 / page')),
          ],
          onChanged: _changePageSize,
        ),
      ),
    );
  }

  Widget _buildTableCard(BuildContext context) {
    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildTableHeader(),

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
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: C.warning.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_outlined,
            size: 19,
            color: C.primaryDark,
          ),
          const SizedBox(width: 5),
          const Text(
            'Cutting Stock Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: C.textHigh,
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredRecords.length} shown',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
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
          DataColumn(label: _head('Cut Width'), numeric: true), // ← naya
          DataColumn(label: _head('Cut Length'), numeric: true),
          DataColumn(label: _head('Net Wt'), numeric: true),
          DataColumn(label: _head('PCS'), numeric: true),
          DataColumn(label: _head('Wt/Pcs'), numeric: true),
          DataColumn(label: _head('Used Pcs'), numeric: true),
          DataColumn(label: _head('Used Wt'), numeric: true),
          DataColumn(label: _head('Bal Pcs'), numeric: true),
          DataColumn(label: _head('Bal Wt'), numeric: true),
        ],
        rows: List.generate(_filteredRecords.length, (index) {
          final item = _filteredRecords[index];
          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            onSelectChanged: (_) => _openRecutPopup(item), // ← ye line add karo

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
              DataCell(_cell(item.cutWidth.toStringAsFixed(2))), // ← Cut Width
              DataCell(
                _cell(item.cutLength.toStringAsFixed(2)),
              ), // ← Cut Length

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
  // PAGINATION UI
  // ============================================================

  Widget _buildPagination(BuildContext context) {
    final bool isFirstPage = _pageNumber <= 1;

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
          final bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                Text(
                  'Page $_pageNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: C.textHigh,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _paginationButton(
                        icon: Icons.chevron_left_rounded,
                        text: 'Previous',
                        enabled: !isFirstPage && !_isLoading,
                        onTap: _goToPreviousPage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _paginationButton(
                        icon: Icons.chevron_right_rounded,
                        text: 'Next',
                        enabled: _hasNextPage && !_isLoading,
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
                'Page $_pageNumber',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
              ),
              const Spacer(),
              _paginationButton(
                icon: Icons.chevron_left_rounded,
                text: 'Previous',
                enabled: !isFirstPage && !_isLoading,
                onTap: _goToPreviousPage,
              ),
              const SizedBox(width: 8),
              _paginationButton(
                icon: Icons.chevron_right_rounded,
                text: 'Next',
                enabled: _hasNextPage && !_isLoading,
                iconAfterText: true,
                onTap: _goToNextPage,
              ),
            ],
          );
        },
      ),
    );
  }

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
          const Text(
            'No cutting stock found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textHigh,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _searchController.text.trim().isNotEmpty
                ? 'No records match your search.'
                : 'There are no records on this page.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

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
                onPressed: _loadData,
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

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
}

class _SummaryData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

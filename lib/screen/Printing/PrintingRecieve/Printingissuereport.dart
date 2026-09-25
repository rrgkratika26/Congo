import 'package:IMS/services/getSupervisors/RmdService.dart';
import 'package:flutter/material.dart';
import '../../../../Color/Colorclass.dart';
import '../ModelClass/PrintingissueListModel.dart';
import 'AddPrintingIssuePopup.dart';

class PrintingIssueListReport extends StatefulWidget {
  const PrintingIssueListReport({super.key});

  @override
  State<PrintingIssueListReport> createState() =>
      _PrintingIssueListReportState();
}

class _PrintingIssueListReportState extends State<PrintingIssueListReport> {
  final RmdService _service = RmdService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalController = ScrollController();

  List<PrintingIssueListModel> _records = [];
  List<PrintingIssueListModel> _filteredRecords = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  int _pageNumber = 1;
  int _pageSize = 15;
  bool _hasNextPage = false;

  // filters shown in the header (Party / Bom No / Component) — "ALL" by default
  String _partyFilter = 'ALL';
  String _bomFilter = 'ALL';
  String _componentFilter = 'ALL';

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
      setState(() => _isRefreshing = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('');
      debugPrint('PRINTING ISSUE LIST');
      debugPrint('Loading page $_pageNumber with size $_pageSize');

      // final result = await _service.fetchPrintingIssueList(
      //   pageNumber: _pageNumber,
      //   pageSize: _pageSize,
      //   party: _partyFilter == 'ALL' ? null : _partyFilter,
      //   bomNo: _bomFilter == 'ALL' ? null : _bomFilter,
      //   component: _componentFilter == 'ALL' ? null : _componentFilter,
      // );

      if (!mounted) return;

      // setState(() {
      //   _records = result;
      //   _hasNextPage = result.length >= _pageSize;
      //   _isLoading = false;
      //   _isRefreshing = false;
      //   _errorMessage = null;
      // });

      _applySearch();

      // debugPrint('Page $_pageNumber loaded: ${result.length} records');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refresh() async => _loadData(refresh: true);

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();

    final result = _records.where((item) {
      final partyName = item.partyName.trim().toLowerCase();
      final bomNo = item.bomNo.trim().toLowerCase();

      if (query.isEmpty) return true;
      return partyName.contains(query) || bomNo.contains(query);
    }).toList();

    if (mounted) setState(() => _filteredRecords = result);
  }

  void _clearSearch() => _searchController.clear();

  Future<void> _goToPreviousPage() async {
    if (_pageNumber <= 1 || _isLoading) return;
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

  // Opens the "PRINTING ISSUE DATA" popup for the tapped row.
  void _openIssuePopup(PrintingIssueListModel item) {
    AddPrintingIssuePopup.show(
      context,
      item: item,
      workOrderNo: item.bomNo, // BOM No doubles as Work Order No here
      onSaved: _refresh,
    );
  }

  int get totalPcs => _filteredRecords.fold(0, (sum, i) => sum + i.pcs);
  int get issuePcsTotal =>
      _filteredRecords.fold(0, (sum, i) => sum + i.issuePcs);
  int get balancePcsTotal =>
      _filteredRecords.fold(0, (sum, i) => sum + i.balancePcs);
  double get totalNetWt =>
      _filteredRecords.fold(0.0, (sum, i) => sum + i.netWt);
  double get issueWtTotal =>
      _filteredRecords.fold(0.0, (sum, i) => sum + i.issueWt);
  double get balanceWtTotal =>
      _filteredRecords.fold(0.0, (sum, i) => sum + i.balanceWt);

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
        'Printing Issue List',
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
              _buildTotalsStrip(isMobile),
              const SizedBox(height: 14),
              _buildSearchSection(context, isMobile),
              const SizedBox(height: 14),
              _buildTableCard(context),
              const SizedBox(height: 64),
              _buildPagination(context),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Mirrors "TOTAL RECORD / TOTAL WT / TOTAL PCS" strip in the reference screenshot.
  Widget _buildTotalsStrip(bool isMobile) {
    Widget stat(String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.orange,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.orange,
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 8,
        children: [
          stat('Total Record', '${_filteredRecords.length}'),
          stat('Total Wt', totalNetWt.toStringAsFixed(2)),
          stat('Total Pcs', '$totalPcs'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: _searchField()),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: C.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.layers_outlined,
                      size: 16,
                      color: C.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Page $_pageNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: C.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: _pageSizeDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
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
    if (_filteredRecords.isEmpty) return _buildEmptyState();

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
          const Icon(Icons.print_outlined, size: 19, color: C.primaryDark),
          const SizedBox(width: 5),
          const Text(
            'Printing Issue Details',
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
          DataColumn(label: _head('Cut Length'), numeric: true),
          DataColumn(label: _head('Cut Width'), numeric: true),
          DataColumn(label: _head('Per Pcs Wt'), numeric: true),
          DataColumn(label: _head('Pcs'), numeric: true),
          DataColumn(label: _head('Issue Pcs'), numeric: true),

          DataColumn(label: _head('Net Wt'), numeric: true),
          DataColumn(label: _head('Issue Wt'), numeric: true),
          DataColumn(label: _head('Bal Pcs'), numeric: true),
          DataColumn(label: _head('Bal Wt'), numeric: true),
        ],
        rows: List.generate(_filteredRecords.length, (index) {
          final item = _filteredRecords[index];
          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            // Tapping a row opens the "PRINTING ISSUE DATA" popup.
            onSelectChanged: (_) => _openIssuePopup(item),
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
              DataCell(_cell(item.cutLength.toStringAsFixed(2))),
              DataCell(_cell(item.cutWidth.toStringAsFixed(2))),
              DataCell(_cell(item.perPcsWt.toStringAsFixed(3))),
              DataCell(
                _cell(
                  '${item.issuePcs}',
                  color: item.issuePcs > 0
                      ? Colors.orange.shade800
                      : Colors.teal.shade600,
                ),
              ),
              DataCell(_cell(_formatInt(item.pcs), isBold: true)),
              DataCell(_cell(item.netWt.toStringAsFixed(2), isBold: true)),

              DataCell(
                _cell(
                  item.issueWt.toStringAsFixed(2),
                  color: item.issueWt > 0
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
              Icons.print_outlined,
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
                'Unable to load printing issue list',
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

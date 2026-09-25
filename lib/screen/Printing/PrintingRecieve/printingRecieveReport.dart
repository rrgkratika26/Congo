import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/statusTrackerServices.dart';
import 'REcieveModel.dart';

class PrintingRecieveReportScreen extends StatefulWidget {
  const PrintingRecieveReportScreen({super.key});

  @override
  State<PrintingRecieveReportScreen> createState() =>
      _PrintingRecieveReportScreenState();
}

class _PrintingRecieveReportScreenState
    extends State<PrintingRecieveReportScreen> {
  final ScrollController _horizontalController = ScrollController();

  // ============================================================
  // DATA
  // ============================================================

  List<receiveReportModel> _records = [];

  List<receiveReportModel> _filteredRecords = [];

  /// Records for the currently visible page.
  List<receiveReportModel> _pageRecords = [];

  // ============================================================
  // DATES
  // ============================================================

  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime _toDate = DateTime.now();

  // ============================================================
  // FILTERS
  // ============================================================

  String _selectedParty = 'ALL';
  String _selectedBom = 'ALL';
  String _selectedComponent = 'ALL';

  List<String> _partyList = ['ALL'];
  List<String> _bomList = ['ALL'];
  List<String> _componentList = ['ALL'];

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = false;
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

    _loadReport();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> _loadReport({bool refresh = false}) async {
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
      // Pull a generous batch for the selected date range — pagination
      // below is then handled locally alongside the party/BOM/component
      // filters, so the page controls stay in sync with filtering.
      final data = await StatusTrackerService.fetchPrintingReceiveReport(
        fromDate: _fromDate,
        toDate: _toDate,
        pageNumber: 1,
        pageSize: 1000,
      );

      if (!mounted) return;

      setState(() {
        _records = data;
        _filteredRecords = List.from(data);

        _isLoading = false;
        _isRefreshing = false;
      });

      _buildDropdownLists();

      _pageNumber = 1;

      _applyLocalFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refresh() async {
    await _loadReport(refresh: true);
  }

  // ============================================================
  // DROPDOWN LISTS
  // ============================================================

  void _buildDropdownLists() {
    final parties = <String>{'ALL'};
    final boms = <String>{'ALL'};
    final components = <String>{'ALL'};

    for (final item in _records) {
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

    final sortedParties = parties.toList()
      ..sort((a, b) {
        if (a == 'ALL') return -1;
        if (b == 'ALL') return 1;

        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    final sortedBoms = boms.toList()
      ..sort((a, b) {
        if (a == 'ALL') return -1;
        if (b == 'ALL') return 1;

        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    final sortedComponents = components.toList()
      ..sort((a, b) {
        if (a == 'ALL') return -1;
        if (b == 'ALL') return 1;

        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    if (!mounted) return;

    setState(() {
      _partyList = sortedParties;
      _bomList = sortedBoms;
      _componentList = sortedComponents;

      if (!_partyList.contains(_selectedParty)) {
        _selectedParty = 'ALL';
      }

      if (!_bomList.contains(_selectedBom)) {
        _selectedBom = 'ALL';
      }

      if (!_componentList.contains(_selectedComponent)) {
        _selectedComponent = 'ALL';
      }
    });
  }

  // ============================================================
  // LOCAL FILTER
  // ============================================================

  void _applyLocalFilters() {
    final result = _records.where((item) {
      final partyMatch =
          _selectedParty == 'ALL' ||
              item.partyName.toLowerCase() == _selectedParty.toLowerCase();

      final bomMatch =
          _selectedBom == 'ALL' ||
              item.bomNo.toLowerCase() == _selectedBom.toLowerCase();

      final componentMatch =
          _selectedComponent == 'ALL' ||
              item.component.toLowerCase() == _selectedComponent.toLowerCase();

      return partyMatch && bomMatch && componentMatch;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredRecords = result;

      // Prevent landing on a page that no longer exists after filtering.
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
  // DATE RANGE PICKER
  // ============================================================
  //
  // Single calendar trigger — no persistent from/to boxes taking up
  // space. Tapping it opens the native date-range picker; picking a
  // range immediately reloads the report.

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );

    if (picked == null) return;

    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });

    _loadReport();
  }

  // ============================================================
  // FILTER DRAWER
  // ============================================================

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildFilterBottomSheet();
      },
    );
  }

  void _applyFilters() {
    Navigator.pop(context);

    _pageNumber = 1;

    _applyLocalFilters();
  }

  void _resetFilters() {
    setState(() {
      _selectedParty = 'ALL';
      _selectedBom = 'ALL';
      _selectedComponent = 'ALL';

      _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

      _toDate = DateTime.now();

      _pageNumber = 1;
    });

    Navigator.pop(context);

    _loadReport();
  }

  int get _activeFilterCount {
    int count = 0;

    if (_selectedParty != 'ALL') count++;
    if (_selectedBom != 'ALL') count++;
    if (_selectedComponent != 'ALL') count++;

    return count;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  int get totalPcs {
    return _filteredRecords.fold(0, (sum, item) => sum + item.pcs);
  }

  double get totalWeight {
    return _filteredRecords.fold(0.0, (sum, item) => sum + item.netWt);
  }

  double get averageWeightPerPcs {
    if (totalPcs == 0) return 0;

    return totalWeight / totalPcs;
  }

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.appBar1,
        foregroundColor: C.bg,
        elevation: 0,
        title: const Text(
          'Receive Report',
          style: TextStyle(
            color: C.bg,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Select date range',
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range_outlined),
          ),

          IconButton(
            tooltip: 'Refresh',
            onPressed: _isRefreshing ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Filter',
                  onPressed: _openFilterDrawer,
                  icon: const Icon(Icons.filter_alt_outlined, size: 23),
                ),

                if (_activeFilterCount > 0)
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: C.appBar1, width: 1.5),
                      ),
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody()),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading && _records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _records.isEmpty) {
      return _buildErrorState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? 12 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(isMobile),

              const SizedBox(height: 12),

              _buildTable(),

              const SizedBox(height: 14),

              _buildPageFooter(),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DATE RANGE — compact chip, calendar-driven only
  // ============================================================

  Widget _buildDateRangeChip(bool isMobile) {
    final label =
        '${DateFormat('dd MMM yyyy').format(_fromDate)}  —  ${DateFormat('dd MMM yyyy').format(_toDate)}';

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: isMobile ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.border),
        ),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: C.primary,
            ),

            const SizedBox(width: 9),

            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY — always one row, sized to fit the available width
  // ============================================================

  Widget _buildSummary(bool isMobile) {
    final cards = [
      _SummaryData(
        title: 'RECORDS',
        value: '${_filteredRecords.length}',
        icon: Icons.receipt_long_outlined,
        iconColor: C.primary,
      ),
      _SummaryData(
        title: 'TOTAL PCS',
        value: _formatInt(totalPcs),
        icon: Icons.inventory_2_outlined,
        iconColor: Colors.orange.shade700,
      ),
      _SummaryData(
        title: 'NET WEIGHT',
        value: '${totalWeight.toStringAsFixed(2)} kg',
        icon: Icons.scale_outlined,
        iconColor: Colors.green.shade700,
      ),
    ];

    final spacing = isMobile ? 6.0 : 10.0;

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i != 0) SizedBox(width: spacing),
          Expanded(child: _summaryCard(cards[i], isMobile)),
        ],
      ],
    );
  }

  Widget _summaryCard(_SummaryData data, bool isMobile) {
    return Container(
      height: isMobile ? 58 : 62,
      padding: EdgeInsets.all(isMobile ? 7 : 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: isMobile ? 14 : 16, color: data.iconColor),

          SizedBox(width: isMobile ? 4 : 6),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    color: C.textHigh,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BOTTOM SHEET
  // ============================================================

  Widget _buildFilterBottomSheet() {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: C.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color: C.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Filter Report',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: C.textHigh,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterDropdown(
                      label: 'Party',
                      icon: Icons.business_outlined,
                      value: _selectedParty,
                      items: _partyList,
                      onChanged: (value) {
                        setState(() {
                          _selectedParty = value ?? 'ALL';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _filterDropdown(
                      label: 'BOM',
                      icon: Icons.description_outlined,
                      value: _selectedBom,
                      items: _bomList,
                      onChanged: (value) {
                        setState(() {
                          _selectedBom = value ?? 'ALL';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _filterDropdown(
                      label: 'Component',
                      icon: Icons.category_outlined,
                      value: _selectedComponent,
                      items: _componentList,
                      onChanged: (value) {
                        setState(() {
                          _selectedComponent = value ?? 'ALL';
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Reset'),
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

                        const SizedBox(width: 12),

                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _applyFilters,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text(
                                'Apply Filter',
                                style: TextStyle(fontWeight: FontWeight.w700),
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : 'ALL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: C.primary),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: C.textHigh,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: C.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 21),
              style: const TextStyle(
                fontSize: 13,
                color: C.textHigh,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
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

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [



        if (_isLoading) const LinearProgressIndicator(minHeight: 2),

        Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(C.borderLight),
              headingRowHeight: 46,
              dataRowMinHeight: 45,
              dataRowMaxHeight: 55,
              columnSpacing: 15,
              horizontalMargin: 18,
              dividerThickness: 0.6,

              columns: const [
                DataColumn(label: _TableHeader('Sr No')),
                DataColumn(label: _TableHeader('Party Name')),
                DataColumn(label: _TableHeader('BOM')),
                DataColumn(label: _TableHeader('Component')),
                DataColumn(numeric: true, label: _TableHeader('Cut Length')),
                DataColumn(numeric: true, label: _TableHeader('Cut Width')),
                DataColumn(numeric: true, label: _TableHeader('Pcs')),
                DataColumn(numeric: true, label: _TableHeader('Net Wt')),
                DataColumn(numeric: true, label: _TableHeader('Wt/Pcs')),
                DataColumn(label: _TableHeader('Type')),
                DataColumn(label: _TableHeader('Receive From')),
                DataColumn(label: _TableHeader('Receive Date')),
              ],

              rows: List.generate(_pageRecords.length, (index) {
                final item = _pageRecords[index];

                final globalIndex =
                    ((_pageNumber - 1) * _pageSize) + index + 1;

                return DataRow(
                  color: WidgetStateProperty.all(
                    index.isEven ? Colors.white : const Color(0xFFF8FAFF),
                  ),
                  cells: [
                    DataCell(
                      Text(
                        '$globalIndex',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    DataCell(
                      SizedBox(
                        width: 110,
                        child: Text(
                          item.partyName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    DataCell(_pill(item.bomNo, C.primaryDark)),

                    DataCell(_componentBadge(item.component)),

                    DataCell(
                      Text(
                        item.cutLength.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    DataCell(
                      Text(
                        item.cutWidth.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    DataCell(
                      Text(
                        _formatInt(item.pcs),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    DataCell(
                      Text(
                        item.netWt.toStringAsFixed(3),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    DataCell(
                      Text(
                        item.weightPerPcs.toStringAsFixed(3),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    DataCell(_typeBadge(item.transactionType)),

                    DataCell(_pill(item.receiveFrom, Colors.teal)),

                    DataCell(
                      Text(
                        _formatDateTime(item.receiveDate),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABLE HELPERS
  // ============================================================

  Widget _pill(String value, Color color) {
    if (value.trim().isEmpty) {
      return const Text(
        '-',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _componentBadge(String component) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: C.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        component,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: C.primary,
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.isEmpty ? '-' : type,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.green,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return DateFormat('dd/MM/yyyy').format(date);
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
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.redAccent),

            const SizedBox(height: 12),

            const Text(
              'Unable to load report',
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

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.bg, shape: BoxShape.circle),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 35,
              color: C.textLow,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No records found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: C.textHigh,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try changing the selected date range or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: C.textLow),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TABLE HEADER
// ============================================================

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: C.appBar1,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ============================================================
// SUMMARY MODEL
// ============================================================

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

// ============================================================
// MODEL
// ============================================================

class PrintingReportModel {
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final int pcs;

  final double netWt;
  final double weightPerPcs;

  final String transactionType;
  final String receiveFrom;
  final DateTime? receiveDate;

  const PrintingReportModel({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
    required this.transactionType,
    required this.receiveFrom,
    required this.receiveDate,
  });

  factory PrintingReportModel.fromJson(Map<String, dynamic> json) {
    return PrintingReportModel(
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      cutLength: _toDouble(json['cutLength']),
      cutWidth: _toDouble(json['cutWidth']),
      pcs: _toInt(json['pcs']),
      netWt: _toDouble(json['netWt']),
      weightPerPcs: _toDouble(json['weightPerPcs']),
      transactionType: json['transactionType']?.toString() ?? '',
      receiveFrom: json['receiveFrom']?.toString() ?? '',
      receiveDate: DateTime.tryParse(json['receiveDate']?.toString() ?? ''),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
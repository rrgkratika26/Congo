import 'package:flutter/material.dart';

import '../../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/statusTrackerServices.dart';

class PrintingReceiveListScreen extends StatefulWidget {
  const PrintingReceiveListScreen({super.key});

  @override
  State<PrintingReceiveListScreen> createState() =>
      _PrintingReceiveListScreenState();
}

class _PrintingReceiveListScreenState extends State<PrintingReceiveListScreen> {
  final ScrollController _horizontalController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _filterButtonKey = GlobalKey();

  // ============================================================
  // DATA
  // ============================================================

  /// All records received from API.
  List<PrintingReceiveModel> _allRecords = [];

  /// Records after applying filters/search.
  List<PrintingReceiveModel> _filteredRecords = [];

  /// Records displayed on current page.
  List<PrintingReceiveModel> _pageRecords = [];

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

  bool get _hasNextPage {
    return _pageNumber < _totalPages;
  }

  bool get _hasPreviousPage {
    return _pageNumber > 1;
  }

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
      final data = await StatusTrackerService.fetchPrintingReceive();

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

      // Prevent invalid page after filtering.
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
    if (!_hasPreviousPage || _isLoading) {
      return;
    }

    setState(() {
      _pageNumber--;
      _updatePageRecords();
    });
  }

  Future<void> _goToNextPage() async {
    if (!_hasNextPage || _isLoading) {
      return;
    }

    setState(() {
      _pageNumber++;
      _updatePageRecords();
    });
  }

  Future<void> _changePageSize(int? value) async {
    if (value == null || value == _pageSize) {
      return;
    }

    setState(() {
      _pageSize = value;
      _pageNumber = 1;

      _updatePageRecords();
    });
  }

  // ============================================================
  // RECEIVE
  // ============================================================


  
  Future<void> _receiveItem(PrintingReceiveModel item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 5),
          actionsPadding: const EdgeInsets.fromLTRB(15, 5, 15, 12),

          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: C.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: C.primaryDark,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Confirm Receive',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: C.textHigh,
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do you want to receive this item?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: C.textHigh,
                ),
              ),

              const SizedBox(height: 14),

              _confirmationRow('Party', item.partyName),
              _confirmationRow('BOM No', item.bomNo),
              _confirmationRow('Component', item.component),
              _confirmationRow('PCS', _formatInt(item.pcs)),
              _confirmationRow(
                'Net Wt',
                '${item.netWt.toStringAsFixed(3)} kg',
              ),
            ],
          ),

          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: C.textHigh,
                side: BorderSide(color: C.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Receive',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    // User clicked No or closed dialog
    if (confirmed != true) {
      return;
    }

    // ============================================================
    // CALL RECEIVE API
    // ============================================================

    _showLoadingDialog();

    try {
      final response = await StatusTrackerService.receivePrinting(
        transactionId: item.id,
        partyName: item.partyName,
        bomNo: item.bomNo,
        component: item.component,
        cutLength: item.cutLength,
        cutWidth: item.cutWidth,
        pcs: item.pcs.toDouble(),
        netWt: item.netWt,
        weightPerPcs: item.weightPerPcs,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      final bool success = response['success'] == true;

      final String message =
          response['message']?.toString() ??
              (success
                  ? 'Received successfully.'
                  : 'Printing receive failed.');

      if (success) {
        setState(() {
          _allRecords.removeWhere((e) => e.id == item.id);
        });

        _buildDropdownLists();
        _applyFilters();

        _showMessage(
          message,
          isError: false,
        );
      } else {
        _showMessage(
          message,
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }



  // ============================================================
  // LOADING DIALOG
  // ============================================================

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(22),
              child: SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
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
        'Printing Receive List',
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
          icon: const Icon(Icons.refresh_rounded),
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
          child: _FilterMenuContent(
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
          padding: EdgeInsets.all(isMobile ? 12 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(context, isMobile),

              const SizedBox(height: 12),

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
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load printing receive data',
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

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
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
  // SUMMARY
  // ============================================================

  Widget _buildSummary(BuildContext context, bool isMobile) {
    final cards = [
      _SummaryData(
        title: 'TOTAL',
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
        title: 'TOTAL WT',
        value: '${totalWeight.toStringAsFixed(2)} kg',
        icon: Icons.scale_outlined,
        iconColor: Colors.green.shade700,
      ),

      _SummaryData(
        title: 'AVG WT / PCS',
        value: '${averageWeightPerPcs.toStringAsFixed(3)} kg',
        icon: Icons.monitor_weight_outlined,
        iconColor: Colors.blue.shade700,
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

              const SizedBox(width: 10),

              Expanded(child: _summaryCard(cards[2])),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _summaryCard(cards[0])),

        const SizedBox(width: 10),

        Expanded(child: _summaryCard(cards[1])),

        const SizedBox(width: 10),

        Expanded(child: _summaryCard(cards[2])),

        const SizedBox(width: 10),

        Expanded(child: _summaryCard(cards[3])),
      ],
    );
  }

  Widget _summaryCard(_SummaryData data) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 15, color: data.iconColor),

          const SizedBox(width: 2),

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
    );
  }

  // ============================================================
  // TABLE CARD
  // ============================================================

  Widget _buildTableCard(BuildContext context) {
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
            child: _buildDataTable(),
          ),
        ),
      ],
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
        dataRowMinHeight: 42,
        dataRowMaxHeight: 48,
        horizontalMargin: 12,
        columnSpacing: 15,

        headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),

        columns: [
          DataColumn(label: _head('Sr No')),

          DataColumn(label: _head('ID')),

          DataColumn(label: _head('Party Name')),

          DataColumn(label: _head('Bom No')),

          DataColumn(label: _head('Component')),

          DataColumn(label: _head('Cut Length'), numeric: true),

          DataColumn(label: _head('Cut Width'), numeric: true),

          DataColumn(label: _head('Pcs'), numeric: true),

          DataColumn(label: _head('Net Wt'), numeric: true),

          DataColumn(label: _head('Wt Per Pcs'), numeric: true),

          DataColumn(label: _head('Receive')),
        ],

        rows: List.generate(_pageRecords.length, (index) {
          final item = _pageRecords[index];

          final globalIndex = ((_pageNumber - 1) * _pageSize) + index + 1;

          return DataRow(
            color: WidgetStateProperty.all(
              index.isEven ? Colors.white : const Color(0xFFF8FAFF),
            ),
            cells: [
              DataCell(_cell('$globalIndex', isBold: true)),

              DataCell(_cell('${item.id}', isBold: true)),

              DataCell(
                SizedBox(
                  width: 100,
                  child: _cell(item.partyName, isBold: true),
                ),
              ),

              DataCell(_pill(item.bomNo, C.primaryDark)),

              DataCell(_pill(item.component, _componentColor(item.component))),

              DataCell(_cell(item.cutLength.toStringAsFixed(2))),

              DataCell(_cell(item.cutWidth.toStringAsFixed(2))),

              DataCell(_cell(_formatInt(item.pcs), isBold: true)),

              DataCell(_cell(item.netWt.toStringAsFixed(3), isBold: true)),

              DataCell(_cell(item.weightPerPcs.toStringAsFixed(3))),

              DataCell(_receiveButton(item)),
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

  Widget _receiveButton(PrintingReceiveModel item) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _receiveItem(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: C.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Text(
          'Receive',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination(BuildContext context) {
    final bool isFirstPage = !_hasPreviousPage;

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
                Row(
                  children: [
                    _pageSizeDropdown(),

                    const Spacer(),

                    Text(
                      'Page $_pageNumber / $_totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: C.textHigh,
                      ),
                    ),
                  ],
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
              _pageSizeDropdown(),

              const SizedBox(width: 15),

              Text(
                'Page $_pageNumber / $_totalPages',
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

  Widget _pageSizeDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _pageSize,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
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
              Icons.print_disabled_outlined,
              size: 30,
              color: C.primaryDark,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No printing receive records found',
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
                : 'There are no printing receive records.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CALCULATIONS
  // ============================================================

  int get totalPcs {
    return _filteredRecords.fold(0, (sum, item) => sum + item.pcs);
  }

  double get totalWeight {
    return _filteredRecords.fold(0.0, (sum, item) => sum + item.netWt);
  }

  double get averageWeightPerPcs {
    if (totalPcs <= 0) {
      return 0;
    }

    return totalWeight / totalPcs;
  }

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }


  Widget _confirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Text(
            ': ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                color: C.textHigh,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ============================================================
// MODEL
// ============================================================

class PrintingReceiveModel {
  final int id;
  final String partyName;
  final String bomNo;
  final String component;

  final double cutLength;
  final double cutWidth;

  final int pcs;

  final double netWt;
  final double weightPerPcs;

  const PrintingReceiveModel({
    required this.id,
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory PrintingReceiveModel.fromJson(Map<String, dynamic> json) {
    return PrintingReceiveModel(
      id: _toInt(json['id']),
      partyName: json['partyName']?.toString() ?? '',
      bomNo: json['bomNo']?.toString() ?? '',
      component: json['component']?.toString() ?? '',

      cutLength: _toDouble(json['cutLength']),

      cutWidth: _toDouble(json['cutWidth']),

      pcs: _toInt(json['pcs']),

      netWt: _toDouble(json['netWt']),

      weightPerPcs: _toDouble(json['weightPerPcs']),
    );
  }

  // ============================================================
  // JSON HELPERS
  // ============================================================

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

  // ============================================================
  // SEARCH TEXT
  // ============================================================

  String get searchText {
    return [
      id.toString(),
      partyName,
      bomNo,
      component,
      cutLength.toString(),
      cutWidth.toString(),
      pcs.toString(),
      netWt.toString(),
      weightPerPcs.toString(),
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
  final Color iconColor;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
}

// ============================================================
// FILTER MENU CONTENT
// ============================================================

class _FilterMenuContent extends StatefulWidget {
  final String selectedParty;
  final String selectedBom;
  final String selectedComponent;

  final List<String> partyList;
  final List<String> bomList;
  final List<String> componentList;

  final String initialSearch;

  final void Function(String, String, String, String) onApply;

  final VoidCallback onReset;

  const _FilterMenuContent({
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
  State<_FilterMenuContent> createState() => _FilterMenuContentState();
}

class _FilterMenuContentState extends State<_FilterMenuContent> {
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
              onChanged: (value) {
                setState(() {
                  _party = value ?? 'ALL';
                });
              },
            ),

            const SizedBox(height: 10),

            _dropdown(
              label: 'BOM NO',
              value: _bom,
              items: widget.bomList,
              onChanged: (value) {
                setState(() {
                  _bom = value ?? 'ALL';
                });
              },
            ),

            const SizedBox(height: 10),

            _dropdown(
              label: 'COMPONENT',
              value: _component,
              items: widget.componentList,
              onChanged: (value) {
                setState(() {
                  _component = value ?? 'ALL';
                });
              },
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
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }

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

import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
import 'package:flutter/material.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/dateFilterService.dart';
import '../../../util/widget/searchBar.dart';
import '../../Color/Colorclass.dart';
import 'JblFormENtryScreen.dart';

class JBLBagEntryModel {
  final String customerName;
  final String woNumber;
  final String articleNo;
  final int quantity;
  final int remainingToProduce;
  final int canProduction;

  JBLBagEntryModel({
    required this.customerName,
    required this.woNumber,
    required this.articleNo,
    required this.quantity,
    required this.remainingToProduce,
    required this.canProduction,
  });

  factory JBLBagEntryModel.fromJson(Map<String, dynamic> json) {
    return JBLBagEntryModel(
      customerName: json['customeR_NAME'] ?? '',
      woNumber: json['wO_NUMBER'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      quantity: json['quantity'] ?? 0,
      remainingToProduce: json['remaininG_TO_PRODUCE'] ?? 0,
      canProduction: json['caN_PRODUCTION'] ?? 0,
    );
  }
}

class JBLBagEntryScreen extends StatefulWidget {
  const JBLBagEntryScreen({super.key});

  @override
  State<JBLBagEntryScreen> createState() => _JBLBagEntryScreenState();
}

class _JBLBagEntryScreenState extends State<JBLBagEntryScreen> {
  final JblApiService _service = JblApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  List<JBLBagEntryModel> _allData = [];
  List<JBLBagEntryModel> _filteredData = [];
  List<JBLBagEntryModel> _visibleData = [];

  bool _showDateFilter = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  final int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(
      () => _onSearchChanged(_searchController.text),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF42A5F6),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _applyDateFilter();
    }
  }

  void _applyDateFilter() {
    final filtered = _allData.where((item) {

      final q = _searchController.text.toLowerCase().trim();
      if (q.isEmpty) return true;
      return item.customerName.toLowerCase().contains(q) ||
          item.woNumber.toLowerCase().contains(q) ||
          item.articleNo.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _filteredData = filtered;
      _currentPage = 1;
      _visibleData = filtered.take(_pageSize).toList();
    });
  }

  /// ───────────────── Scroll Pagination ─────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  /// ───────────────── Load Data ─────────────────

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final data = await JblApiService.getjblBagEntryData();

      if (!mounted) return;

      setState(() {
        _allData = data;
        _filteredData = data;
        _visibleData = data.take(_pageSize).toList();
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    _searchController.clear();
    await _loadInitialData();
  }

  void _loadMore() {
    if (_visibleData.length >= _filteredData.length) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
      _visibleData = _filteredData.take(_currentPage * _pageSize).toList();
      _isLoadingMore = false;
    });
  }

  /// ───────────────── Search ─────────────────

  void _onSearchChanged(String query) {
    final q = query.toLowerCase().trim();

    final filtered = q.isEmpty
        ? _allData
        : _allData.where((item) {
            return item.customerName.toLowerCase().contains(q) ||
                item.woNumber.toLowerCase().contains(q) ||
                item.articleNo.toLowerCase().contains(q);
          }).toList();

    setState(() {
      _filteredData = filtered;
      _currentPage = 1;
      _visibleData = filtered.take(_pageSize).toList();
    });
  }

  /// ───────────────── Navigation ─────────────────

  void _navigateToDetails(JBLBagEntryModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JBLFormScreen(
          partyName: item.customerName,
          woNumber: item.woNumber,
          articleNo: item.articleNo,
          quantity: item.quantity,
          remainingToProduce: item.remainingToProduce,
            canProduction:item.canProduction

        ),
      ),
    );
  }

  /// ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      appBar: AppBar(
        title: const Text("Bag Entries", style: TextStyle(color: C.bgColor)),
        iconTheme: IconThemeData(color: C.bgColor),
        backgroundColor: const Color(0xFF42A5F6),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: "Filter by Date",
            onPressed: _openDateRangePicker,
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator(color: C.appBar3,));
          }

          if (_allData.isEmpty) {
            return _EmptyState(onRefresh: _refreshData);
          }

          return RefreshIndicator(
            onRefresh: _refreshData,

            child: Column(
              children: [
                /// Date Filter
                if (_showDateFilter)
                  DateRangeFilter(
                    initialFromDate: _fromDate,
                    initialToDate: _toDate,
                    onDateChanged: (from, to) {
                      setState(() {
                        _fromDate = from;
                        _toDate = to;
                      });
                    },
                  ),

                /// Search
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: InlineSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),

                /// Count Bar
                _CountBar(
                  visible: _visibleData.length,
                  total: _filteredData.length,
                ),

                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 8,
                    child: SingleChildScrollView(

          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal, // ✅ horizontal scroll alag
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  const Color(0xFF42A5F6),
                                ),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                dataRowMinHeight: 44,
                                dataRowMaxHeight: 44,
                                columnSpacing: 20,
                                horizontalMargin: 12,
                                border: TableBorder.all(
                                  color: Colors.blue.shade100,
                                  width: 1,
                                ),
                                columns: const [
                                  DataColumn(label: Text("#")),
                                  DataColumn(label: Text("Customer Name")),
                                  DataColumn(label: Text("WO Number")),
                                  DataColumn(label: Text("Article No")),
                                  DataColumn(
                                    label: Text("Quantity"),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text("Remaining"),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text("Can Prod."),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text("Action")),
                                ],
                                rows: _visibleData.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final item = entry.value;

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith(
                                      (_) => i.isEven
                                          ? Colors.white
                                          : Colors.blue.shade50,
                                    ),
                                    cells: [
                                      DataCell(
                                        Text(
                                          "${i + 1}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            item.customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.woNumber,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.articleNo,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.remainingToProduce.toString(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: item.remainingToProduce > 0
                                                ? Colors.orange.shade700
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.canProduction.toString(),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      DataCell(
                                        InkWell(
                                          borderRadius: BorderRadius.circular(6),
                                          onTap: () => _navigateToDetails(item),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF42A5F6),    // for enable
                                              // color: Colors.grey,
                                              borderRadius: BorderRadius.circular(
                                                6,
                                              ),
                                            ),
                                            child: const Text(
                                              "Open",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),

                              // ✅ Load more indicator at bottom
                              if (_isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: C.appBar3,),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ───────────────── Count Bar ─────────────────

class _CountBar extends StatelessWidget {
  final int visible;
  final int total;

  const _CountBar({required this.visible, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      color: const Color(0xFF42A5F6).withOpacity(0.15),

      child: Row(
        children: [
          const Icon(Icons.list, size: 18),

          const SizedBox(width: 8),

          Text("Showing $visible of $total entries"),
        ],
      ),
    );
  }
}

/// ───────────────── Loading Indicator ─────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),

      child: Center(child: CircularProgressIndicator(color: C.appBar3,)),
    );
  }
}

/// ───────────────── Empty State ─────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const Icon(Icons.inbox, size: 60),

          const SizedBox(height: 10),

          const Text("No entries found"),

          const SizedBox(height: 10),

          ElevatedButton(onPressed: onRefresh, child: const Text("Refresh")),
        ],
      ),
    );
  }
}

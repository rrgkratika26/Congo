import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/dateFilterService.dart';
import '../../../util/widget/searchBar.dart';
import '../modelClass/BagReportModelClass.dart';
import 'BadProductionModel.dart';
import 'FormScreen.dart';

class BagEntryScreen extends StatefulWidget {
  const BagEntryScreen({super.key});

  @override
  State<BagEntryScreen> createState() => _BagEntryScreenState();
}

class _BagEntryScreenState extends State<BagEntryScreen> {
  final InStockService _service = InStockService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  List<BagEntryModel> _allData = [];
  List<BagEntryModel> _filteredData = [];
  List<BagEntryModel> _visibleData = [];

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
      final data = await _service.getBagEntryData();

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
                item.generatedInquiry.toLowerCase().contains(q) ||
                item.articleNo.toLowerCase().contains(q) ||
                item.poNum.toLowerCase().contains(q);
          }).toList();

    setState(() {
      _filteredData = filtered;
      _currentPage = 1;
      _visibleData = filtered.take(_pageSize).toList();
    });
  }

  /// ───────────────── Navigation ─────────────────

  void _navigateToDetails(BagEntryModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          customerName: item.customerName,
          generatedInquiry: item.generatedInquiry,
          articleNo: item.articleNo,
          quantity: item.quantity,
          poNum: item.poNum,
          requiredBag: item.remainingBag,
          bagType: item.bagType,
          bagSize: item.bagSize,
          bagWeight: item.bagWeight,
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
        title: const Text("Bag Entries", style: TextStyle(color: C.bg,  fontWeight: FontWeight.w600,)),
        backgroundColor: C.appBar1,
        iconTheme: IconThemeData(
          color: C.bg, // 👈 Back arrow color white
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
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

                  /// Count Bar
                  _CountBar(
                    visible: _visibleData.length,
                    total: _filteredData.length,
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

                  /// List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,

                      padding: const EdgeInsets.all(5),

                      itemCount: _visibleData.length + (_isLoadingMore ? 1 : 0),

                      itemBuilder: (context, index) {
                        if (index == _visibleData.length) {
                          return const _LoadingIndicator();
                        }

                        final item = _visibleData[index];

                        return _BagEntryCard(
                          item: item,
                          onTap: () => _navigateToDetails(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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

/// ───────────────── Card ─────────────────

class _BagEntryCard extends StatelessWidget {
  final BagEntryModel item;
  final VoidCallback onTap;

  const _BagEntryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.only(bottom: 12),
      color: C.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───── Customer Name + Arrow ─────
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: (item.customerName ?? '').toUpperCase(),
                            style: const TextStyle(
                              color: C.actionOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: "  •  ${item.generatedInquiry}", // BOM No
                            style: TextStyle(
                              fontSize: 15,
                              color: C.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),

              const Divider(),

              // ───── Details ─────
              _row("Generated Enq.", item.generatedInquiry),
              const SizedBox(height: 6),

              _row("Article No", item.articleNo), // ✅ ADDED
              const SizedBox(height: 6),

              _row("PO Number", item.poNum),
              const SizedBox(height: 6),

              _row("Bag Qty", item.quantity.toStringAsFixed(0)),
              const SizedBox(height: 6),

              _row("Remaining Bag", item.remainingBag.toStringAsFixed(0)), // ✅ ADDED
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: C.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: null,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

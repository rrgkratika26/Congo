import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/dateFilterService.dart';
import '../../../util/widget/searchBar.dart';

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
      backgroundColor: C.bg,

      appBar: AppBar(
        title: const Text(
          "Bag Entries",
          style: TextStyle(color: C.bg, fontWeight: FontWeight.w600),
        ),
        backgroundColor: C.appBar1,
        iconTheme: const IconThemeData(color: C.bg),
        actions: [
          IconButton(
            icon: Icon(
              _showDateFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: C.bg,
            ),
            tooltip: "Date filter",
            onPressed: () => setState(() => _showDateFilter = !_showDateFilter),
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: C.appBar3),
              );
            }

            if (_allData.isEmpty) {
              return _EmptyState(onRefresh: _refreshData);
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: C.appBar3,

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
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
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

                  /// List
                  Expanded(
                    child: _filteredData.isEmpty
                        ? _NoSearchResults(query: _searchController.text)
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      itemCount:
                      _visibleData.length + (_isLoadingMore ? 1 : 0),
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

class _CountBar extends StatelessWidget {
  final int visible;
  final int total;

  const _CountBar({required this.visible, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          Icon(Icons.list_alt, size: 16, color: C.textLow),
          const SizedBox(width: 6),
          Text(
            "Showing $visible of $total entries",
            style: TextStyle(fontSize: 12.5, color: C.textLow),
          ),
        ],
      ),
    );
  }
}

class _BagEntryCard extends StatelessWidget {
  final BagEntryModel item;
  final VoidCallback onTap;

  const _BagEntryCard({required this.item, required this.onTap});

  // Party name -> brand blue, BOM No -> brand orange (per app palette)
  static const Color _partyColor = C.appBar1; // Logo Blue #287DB3
  static const Color _bomColor = C.actionOrange; // Logo Orange #EE7D00

  Color _remainingColor(double qty, double remaining) {
    if (qty <= 0) return C.textLow;
    final ratio = remaining / qty;
    if (ratio <= 0.15) return const Color(0xFFD64545); // red - almost done
    if (ratio <= 0.4) return const Color(0xFFE0A22C); // amber - low
    return const Color(0xFF16A34A); // green - healthy
  }

  @override
  Widget build(BuildContext context) {
    final remColor = _remainingColor(item.quantity, item.remainingBag);
    final initial = (item.customerName ?? '').trim().isNotEmpty
        ? item.customerName.trim()[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: C.bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: C.rmdColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───── Header: avatar + party name + arrow ─────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:  C.darkgreen.withOpacity(0.12),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: C.darkgreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item.customerName ?? '').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: C.darkgreen,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _Chip(
                            label: "BOM ${item.generatedInquiry}",
                            color: _bomColor,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: C.primary),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: C.rmdColor),
                const SizedBox(height: 12),

                // ───── Details grid ─────
                Row(
                  children: [
                    Expanded(
                      child: _InfoBlock(label: "Article No", value: item.articleNo),
                    ),
                    Expanded(
                      child: _InfoBlock(label: "PO Number", value: item.poNum),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoBlock(
                        label: "Bag Qty",
                        value: item.quantity.toStringAsFixed(0),
                      ),
                    ),
                    Expanded(
                      child: _InfoBlock(
                        label: "Remaining",
                        value: item.remainingBag.toStringAsFixed(0),
                        valueColor: remColor,
                        bold: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill/chip used for BOM No (and reusable elsewhere)
class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Label-on-top / value-below block for scannable details
class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoBlock({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: C.textLow,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? C.textBody,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
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
      child: Center(child: CircularProgressIndicator(color: C.appBar3)),
    );
  }
}

/// ───────────────── Empty State (no data at all) ─────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: C.textLow),
          const SizedBox(height: 12),
          Text(
            "No entries found",
            style: TextStyle(color: C.textLow, fontSize: 15),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.appBar3,
              foregroundColor: C.bg,
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── No Search Results (data exists, filter is empty) ─────────────────

class _NoSearchResults extends StatelessWidget {
  final String query;

  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: C.textLow),
          const SizedBox(height: 10),
          Text(
            'No results for "$query"',
            style: TextStyle(color: C.textLow, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
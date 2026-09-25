import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/statusTrackerServices.dart';
import 'OrderLifeCucleScreen.dart';
import 'StatusTrackerModel.dart';

class StatusTrackerListScreen extends StatefulWidget {
  const StatusTrackerListScreen({super.key});

  @override
  State<StatusTrackerListScreen> createState() =>
      _StatusTrackerListScreenState();
}

class _StatusTrackerListScreenState extends State<StatusTrackerListScreen> {
  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchCtrl = TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  List<OrderStatusItem> _orders = [];
  List<OrderStatusItem> _filteredOrders = [];

  bool _loading = true;
  bool _pageLoading = false;

  String? _error;

  // ============================================================
  // PAGINATION
  // ============================================================

  int _page = 1;

  // API returns this many records per page
  static const int _pageSize = 10;

  // API doesn't return a total count, so we can't know total pages
  // up front. We infer "is there a next page" from whether the
  // current fetch came back full (== _pageSize).
  bool _hasMore = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ORDERS FROM API
  // ============================================================

  Future<void> _loadOrders({bool resetPage = false}) async {
    if (!mounted) return;

    if (resetPage) {
      _page = 1;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      debugPrint('========================================');
      debugPrint('STATUS TRACKER API CALL');
      debugPrint('Page Number: $_page');
      debugPrint('Page Size: $_pageSize');
      debugPrint('========================================');

      final data = await StatusTrackerService.getOrders(
        fromDate: _selectedRange.start,
        toDate: _selectedRange.end,
        pageNumber: _page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _orders = data;
        _hasMore = data.length == _pageSize;
        _loading = false;
      });

      // IMPORTANT: apply the current search text (if any) to the
      // freshly loaded page. This also covers the "no search" case,
      // since _applyFilters falls back to the full list.
      _applyFilters();

      debugPrint('Current Page: $_page');
      debugPrint('Records Received: ${data.length}');
      debugPrint('Has More: $_hasMore');
    } catch (e) {
      debugPrint('STATUS TRACKER ERROR: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');

        _loading = false;

        _orders = [];
        _filteredOrders = [];

        _hasMore = false;
      });
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
      helpText: 'SELECT ORDER DATE RANGE',
      saveText: 'APPLY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: C.primary ?? Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedRange = picked;
    });

    // New date range -> always go back to page 1.
    await _loadOrders(resetPage: true);
  }

  // ============================================================
  // SEARCH  (filters only within the currently loaded page,
  // since the API paginates server-side)
  // ============================================================

  void _applyFilters() {
    final search = _searchCtrl.text.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _filteredOrders = _orders;
      });
      return;
    }

    final result = _orders.where((order) {
      return order.customerName.toLowerCase().contains(search) ||
          order.generatedInquiry.toLowerCase().contains(search) ||
          order.articleNo.toLowerCase().contains(search) ||
          order.wono.toLowerCase().contains(search) ||
          order.typee.toLowerCase().contains(search) ||
          order.sizeDisplay.toLowerCase().contains(search) ||
          order.quantity.toLowerCase().contains(search);
    }).toList();

    setState(() {
      _filteredOrders = result;
    });
  }

  // ============================================================
  // TRACK ORDER
  // ============================================================

  void _openTracker(OrderStatusItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderLifecycleScreen(order: item)),
    );
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  Future<void> _nextPage() async {
    if (_pageLoading || !_hasMore) return;

    setState(() {
      _pageLoading = true;
    });

    _page++;

    await _loadOrders();

    if (!mounted) return;

    setState(() {
      _pageLoading = false;
    });
  }

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  Future<void> _previousPage() async {
    if (_pageLoading || _page <= 1) return;

    setState(() {
      _pageLoading = true;
    });

    _page--;

    await _loadOrders();

    if (!mounted) return;

    setState(() {
      _pageLoading = false;
    });
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg ?? const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildStatusHeader(),
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildTable()),
            _buildPagination(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.track_changes_rounded,
            color: C.primary ?? Colors.indigo,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Status Tracker',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_filteredOrders.length} orders on this page  •  '
                      '${DateFormat('dd-MMM').format(_selectedRange.start)} - '
                      '${DateFormat('dd-MMM-yyyy').format(_selectedRange.end)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _pickDateRange,
            tooltip: 'Select date range',
            icon: Icon(
              Icons.calendar_month_rounded,
              color: C.primary ?? Colors.indigo,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => _applyFilters(),
        decoration: InputDecoration(
          hintText: 'Search customer, inquiry, article, WO...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _filteredOrders = _orders;
              });
            },
            icon: const Icon(Icons.clear),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.deepOrangeAccent.shade200),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 45, color: Colors.red.shade400),
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              TextButton(onPressed: _loadOrders, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No orders found.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Try changing the date range or search.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // API already returns only the current page's records — no
    // local slicing needed.
    final pageOrders = _filteredOrders;

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 15,
            horizontalMargin: 10,
            headingRowHeight: 38,
            dataRowMinHeight: 42,
            dataRowMaxHeight: 50,
            headingRowColor: WidgetStateProperty.all(
              C.brand200 ?? Colors.indigo,
            ),
            headingTextStyle: const TextStyle(
              color: C.textHigh,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
            dataTextStyle: const TextStyle(fontSize: 12.5),
            columns: const [
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Inquiry No')),
              DataColumn(label: Text('Article')),
              DataColumn(label: Text('WO')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Bag Size')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Action')),
            ],
            rows: pageOrders.map((o) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      o.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      o.generatedInquiry,
                      style: TextStyle(
                        color: C.warning ?? Colors.indigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DataCell(Text(o.articleNo)),
                  DataCell(Text(o.wono.isEmpty ? '-' : o.wono)),
                  DataCell(_typeChip(o.typee)),
                  DataCell(
                    Text(
                      o.todayDate != null
                          ? DateFormat('dd-MMM-yyyy').format(o.todayDate!)
                          : '-',
                    ),
                  ),
                  DataCell(Text(o.sizeDisplay)),
                  DataCell(
                    Text(
                      o.quantity,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      height: 29,
                      child: ElevatedButton.icon(
                        onPressed: () => _openTracker(o),
                        icon: const Icon(Icons.timeline_rounded, size: 14),
                        label: const Text(
                          'Track',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.brand50 ?? Colors.indigo,
                          foregroundColor: C.warning,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TYPE CHIP
  // ============================================================

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (C.brand600 ?? Colors.indigo).withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.isEmpty ? '-' : type,
        style: TextStyle(
          color: C.primary ?? Colors.indigo,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // PAGINATION  (no total count from API, so we show current
  // page number and enable Next only when the page came back full)
  // ============================================================

  Widget _buildPagination() {
    if (_orders.isEmpty && !_loading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn(
            icon: Icons.chevron_left,
            onTap: (_page > 1 && !_pageLoading) ? _previousPage : null,
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: C.primary ?? Colors.indigo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _pageLoading
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              'Page $_page',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          _pageBtn(
            icon: Icons.chevron_right,
            onTap: (_hasMore && !_pageLoading) ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  Widget _pageBtn({required IconData icon, required VoidCallback? onTap}) {
    final bool active = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? (C.primary ?? Colors.indigo) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}
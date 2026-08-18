import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_printer_plus/printer.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../cutOutModelClass/ModelClassOutstock.dart';
import 'CutOutStockFormNardana.dart';
import 'modelclass/CuttingOutStockNardana.dart';

class CutOutSavedListNardana extends StatefulWidget {
  final String title;
  final List<CuttingOutstockNaradana> initialItems;

  const CutOutSavedListNardana({
    super.key,
    this.title = "Cutting OUT Stock",
    this.initialItems = const [],
  });

  @override
  State<CutOutSavedListNardana> createState() => _CutOutSavedListNardanaState();
}

class _CutOutSavedListNardanaState extends State<CutOutSavedListNardana> {
  // ============================================================
  // DATA
  // ============================================================

  final ScrollController _scrollController = ScrollController();     // vertical
  final ScrollController _horizontalController = ScrollController(); // horizontal
  final TextEditingController _searchController = TextEditingController();

  final List<CuttingOutstockNaradana> _items = [];
  List<CuttingOutstockNaradana> _filteredItems = [];

  String _searchText = '';
  String unitName = '';

  int _page = 1;
  final int _pageSize = 50;

  bool _loading = false;
  bool _hasMore = true;

  int? _selectedRollId;

  Timer? _debounce;
  String _status = '';

  final _storage = GetStorage();
  bool _printing = false;
  StreamSubscription<BTStatus>? _btSub;

  bool _isRollFinishLoading = false;

  // ============================================================
  // TABLE COLUMN DEFINITIONS
  // ============================================================

  late final List<_ColDef> _columns = [
    _ColDef("ID", 45, (r) => r.id.toString()),
    _ColDef("Roll", 65, (r) => r.rollCode.toString()),
    _ColDef("Barcode", 90, (r) => r.barcode),
    _ColDef("WO", 75, (r) => r.partyname),
    _ColDef("Supervisor", 95, (r) => r.supervisorName),
    _ColDef("Operator", 90, (r) => r.operatorName),
    _ColDef("Loom Type", 75, (r) => r.loomNo),
    _ColDef("Fabric", 80, (r) => r.fabricType),
    _ColDef("Party", 90, (r) => r.component),
    _ColDef("Fabric Code", 85, (r) => r.fabricCode),
    _ColDef("Week", 55, (r) => r.weekNo),
    _ColDef("Req KG", 70, (r) => r.requiredQtyKg.toString()),
    _ColDef("Req Mtr", 70, (r) => r.requiredQtyMtr.toString()),
    _ColDef("Loom No", 65, (r) => r.loomType),
    _ColDef("Color", 65, (r) => r.color),
    _ColDef("GSM", 50, (r) => r.fabricGsm),
    _ColDef("Date", 75, (r) => _safeDate(r.date)),
    _ColDef("Time", 65, (r) => _safeTime(r.time)),
  ];

  static const double _checkboxColWidth = 32;
  static const double _statusColWidth = 90;

  double _getTableWidth(double screenWidth) {
    final minimumWidth =
        _checkboxColWidth +
            _columns.fold(0.0, (sum, c) => sum + c.width);

    return minimumWidth < screenWidth ? screenWidth : minimumWidth;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitial();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _btSub?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  Future<void> _fetchInitial() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _status = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      unitName = prefs.getString('unit') ?? '';

      if (unitName.isEmpty) {
        _setStatus("Unit not found.");
        return;
      }

      final data = await NaradanaApiService.fetchOutStockListNaradana();

      if (!mounted) return;

      setState(() {
        _page = 1;
        _items.clear();

        if (data.isNotEmpty) {
          _items.addAll(data);
        } else if (widget.initialItems.isNotEmpty) {
          _items.addAll(widget.initialItems);
        }

        _filteredItems = List.from(_items);
        _hasMore = data.length >= _pageSize;
      });
    } catch (e) {
      _setStatus("❌ Load error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _applyFilter(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final query = value.trim().toLowerCase();

      setState(() {
        _searchText = query;
        _applyCurrentFilter();
      });
    });
  }

  void _applyCurrentFilter() {
    if (_searchText.isEmpty) {
      _filteredItems = List.from(_items);
      return;
    }

    _filteredItems = _items.where((item) {
      return item.id.toString().toLowerCase().contains(_searchText) ||
          item.barcode.toLowerCase().contains(_searchText) ||
          item.rollCode.toString().toLowerCase().contains(_searchText) ||
          item.partyname.toLowerCase().contains(_searchText) ||
          item.fabricCode.toLowerCase().contains(_searchText);
    }).toList();
  }

  // ============================================================
  // LOAD MORE - INFINITE SCROLL
  // ============================================================

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || unitName.isEmpty) return;
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final nextPage = _page + 1;
      final data = await NaradanaApiService.fetchOutStockListNaradana();

      if (!mounted) return;

      setState(() {
        if (data.isNotEmpty) {
          _items.addAll(data);
          _page = nextPage;
        }
        _hasMore = data.length >= _pageSize;
        _applyCurrentFilter();
      });
    } catch (e) {
      _setStatus("❌ Pagination error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250 &&
        !_loading &&
        _hasMore) {
      _loadMore();
    }
  }

  // ============================================================
  // MANUAL PAGE LOAD
  // ============================================================

  Future<void> _fetchPage(int page) async {
    if (_loading || page < 1 || unitName.isEmpty) return;
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final data = await NaradanaApiService.fetchOutStockListNaradana();

      if (!mounted) return;

      setState(() {
        _page = page;
        _items.clear();
        _items.addAll(data);
        _applyCurrentFilter();
        _hasMore = data.length >= _pageSize;

        if (_selectedRollId != null &&
            !_items.any((e) => e.id == _selectedRollId)) {
          _selectedRollId = null;
        }
      });
    } catch (e) {
      _setStatus("❌ Page load error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ============================================================
  // ROLL FINISH
  // ============================================================

  Future<void> _rollFinish() async {
    if (_selectedRollId == null || _isRollFinishLoading) return;

    setState(() => _isRollFinishLoading = true);

    try {
      final response = await NaradanaApiService.rollFinish(_selectedRollId!);
      if (!mounted) return;

      final success = response["success"] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"]?.toString() ??
                (success ? "Roll finished successfully" : "Roll finish failed"),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (success) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Roll finish error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRollFinishLoading = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.bg,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(
                  "${_items.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: C.bg),
      ),
      body: Column(
        children: [
          // ============= SEARCH =============
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: _applyFilter,
              decoration: InputDecoration(
                hintText: "Search ID, Roll Code, Party or Fabric",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilter('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          if (_status.isNotEmpty) _statusBar(),

          if (_selectedRollId != null) _selectionBanner(),

          // ============= TABLE =============
          Expanded(
            child: _loading && _items.isEmpty ? _buildLoading() : _buildTable(),
          ),

          // ============= ROLL FINISH =============
          if (_selectedRollId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: _isRollFinishLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_circle),
                  label: Text(_isRollFinishLoading ? "Finishing..." : "Roll Finish"),
                  onPressed: _isRollFinishLoading ? null : _rollFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

          _bottomBar(),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTION BANNER
  // ============================================================

  Widget _selectionBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: C.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Roll #$_selectedRollId selected",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedRollId = null),
            child: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: C.appBar3),
            const SizedBox(height: 15),
            Text(
              "Fetching Out List...",
              style: TextStyle(color: C.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_filteredItems.isEmpty && !_loading) {
      return const Center(
        child: Text(
          "No records found",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = _getTableWidth(constraints.maxWidth);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    _tableHeader(),

                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                        _filteredItems.length + (_loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredItems.length) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: C.appBar3,
                                ),
                              ),
                            );
                          }

                          return _tableRow(
                            _filteredItems[index],
                            index,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader() {
    return Container(
      color: C.primary,
      child: Row(
        children: [
          _headerCell("", _checkboxColWidth),
          // _headerCell("Status", _statusColWidth),
          for (final c in _columns) _headerCell(c.label, c.width),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 9,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _tableRow(CuttingOutstockNaradana r, int index) {
    final isSelected = _selectedRollId == r.id;
    final isEven = index.isEven;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CuttingOutStockFormNardana(production: r),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? C.warning.withOpacity(0.18)
              : (isEven ? Colors.white : Colors.grey.shade50),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // ================= CHECKBOX =================
            SizedBox(
              width: _checkboxColWidth,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _selectedRollId = value == true ? r.id : null;
                  });
                },
              ),
            ),

            // ================= COLUMNS =================
            for (final c in _columns)
              SizedBox(
                width: c.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 7,
                  ),
                  child: _buildCell(
                    c,
                    r,
                    isSelected,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildCell(
      _ColDef column,
      CuttingOutstockNaradana r,
      bool isSelected,
      ) {
    final value = column.getValue(r);
    final isRoll = column.label == "Roll";
    final isBarcode = column.label == "Barcode";

    // Highlight Roll and Barcode
    if (isRoll || isBarcode) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? C.warning
              : (isRoll
              ? C.primaryDark
              : C.danger),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected
                ? C.warning.withOpacity(0.5)
                : (isRoll
                ? Colors.blue.withOpacity(0.25)
                : Colors.green.withOpacity(0.25)),
          ),
        ),
        child: Text(
          value.isEmpty ? "-" : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isRoll ? Colors.blue.shade800 : Colors.green.shade800,
          ),
        ),
      );
    }

    // Normal cells
    return Text(
      value.isEmpty ? "-" : value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black87,
      ),
    );
  }
  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.isEmpty ? "-" : status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('finish') || s.contains('complete') || s.contains('done')) {
      return Colors.green;
    }
    if (s.contains('pending') || s.contains('progress')) {
      return Colors.orange;
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return Colors.red;
    }
    return Colors.blueGrey;
  }

  // ============================================================
  // BOTTOM PAGINATION
  // ============================================================

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: (_page > 1 && !_loading) ? () => _fetchPage(_page - 1) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text("Prev"),
          ),
          Text("Page $_page", style: const TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            onPressed: (_hasMore && !_loading) ? () => _fetchPage(_page + 1) : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text("Next"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BAR
  // ============================================================

  Widget _statusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_status, style: const TextStyle(fontSize: 12)),
    );
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _status = message);
  }

  // ============================================================
  // SAFE DATE / TIME
  // ============================================================

  String _safeDate(String value) {
    if (value.trim().isEmpty) return "-";
    try {
      return value.split(" ")[0];
    } catch (_) {
      return value;
    }
  }

  String _safeTime(String value) {
    if (value.trim().isEmpty) return "-";
    try {
      return value.split(" ")[0];
    } catch (_) {
      return value;
    }
  }
}

// ============================================================
// COLUMN DEFINITION HELPER
// ============================================================

class _ColDef {
  final String label;
  final double width;
  final String Function(CuttingOutstockNaradana) getValue;

  _ColDef(this.label, this.width, this.getValue);
}
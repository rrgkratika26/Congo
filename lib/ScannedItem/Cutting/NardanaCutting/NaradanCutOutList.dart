import 'dart:async';

import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
    this.title = "Cutting OUT Stock-",
    this.initialItems = const [],
  });

  @override
  State<CutOutSavedListNardana> createState() => _CutOutSavedListNardanaState();
}

// ─────────────────────────────────────────────

class _CutOutSavedListNardanaState extends State<CutOutSavedListNardana> {
  // ── Data ──
  final ScrollController _scrollController = ScrollController();
  final List<CuttingOutstockNaradana> _items = [];
  List<CuttingOutstockNaradana> _filteredItems = [];
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  int _page = 1;
  final int _pageSize = 50;
  bool _loading = false;
  bool _hasMore = true;
  int? _selectedIndex;
  Timer? _debounce;
  // ── Printer ──
  final _storage = GetStorage();
  bool _printing = false;
  String _status = '';
  StreamSubscription<BTStatus>? _btSub;

  @override
  void initState() {
    super.initState();
    // _fetchPage(1);
    // _items.addAll(widget.initialItems);
    // _filteredItems = List.from(_items);
    _fetchInitial();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _btSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────



  void _applyFilter(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchText = value.toLowerCase();

        _filteredItems = _searchText.isEmpty
            ? List.from(_items)
            : _items.where((item) {
          return item.id.toString().toLowerCase().contains(_searchText) ||
              item.barcode.toLowerCase().contains(_searchText) ||
              item.rollCode.toString().toLowerCase().contains(_searchText);
        }).toList();
      });
    });
  }

  Future<void> _fetchInitial() async {
    setState(() => _loading = true);

    try {
      final data = await NaradanaApiService.fetchOutStockListNaradana(
        plant: AppGlobals.unit,
        // plant: 'UNIT-SILVASSA',

        page: 1,
        pageSize: _pageSize,
      );

      setState(() {
        _page = 1;
        _items
          ..clear()
          ..addAll(data);

        _filteredItems = List.from(_items); // ✅ FIX HERE
        _hasMore = data.isNotEmpty;
      });
    } catch (e) {
      _setStatus("❌ Load error: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    try {
      final nextPage = _page + 1;

      final data = await NaradanaApiService.fetchOutStockListNaradana(
        plant: AppGlobals.unit,
        // plant: 'UNIT-SILVASSA',

        page: nextPage,
        pageSize: _pageSize,
      );

      setState(() {
        _page = nextPage;
        _items.addAll(data);
        _hasMore = data.isNotEmpty;
      });

// Apply filter immediately
      if (_searchText.isEmpty) {
        setState(() {
          _filteredItems = List.from(_items);
        });
      } else {
        setState(() {
          _filteredItems = _items.where((item) {
            return item.id.toString().toLowerCase().contains(_searchText) ||
                item.barcode.toLowerCase().contains(_searchText) ||
                item.rollCode.toString().toLowerCase().contains(_searchText);
          }).toList();
        });
      }
    } catch (e) {
      _setStatus("❌ Pagination error: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _fetchPage(int page) async {
    setState(() => _loading = true);

    try {
      final data = await NaradanaApiService.fetchOutStockListNaradana(
        plant: AppGlobals.unit,
        // plant: 'UNIT-SILVASSA',

        page: page,
        pageSize: 20, // ✅ FIXED 20
      );

      setState(() {
        _page = page;

        _items
          ..clear() // ✅ IMPORTANT (replace data)
          ..addAll(data);
        _filteredItems = List.from(_items);
        _hasMore = data.length == 20; // if less → last page
      });
    } catch (e) {
      _setStatus("❌ Page load error: $e");
    }

    setState(() => _loading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loading) {
      _loadMore();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 14,
                ),
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
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: _applyFilter,
              decoration: InputDecoration(
                hintText: "Search by ID or Roll Code",
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          if (_status.isNotEmpty) _statusBar(),
          Expanded(
            child: _loading && _items.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: C.appBar3),
                          const SizedBox(height: 15),
                          Text(
                            "Fetching Out List...",
                            style: TextStyle(
                              color: C.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildTable(),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ── TABLE ──
  Widget _buildTable() {
    return ListView.builder(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,

      controller: _scrollController,
      itemCount: _filteredItems.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        // 🔹 Loader at bottom while pagination
        if (index == _filteredItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: C.appBar3,)),
          );
        }

        final r = _filteredItems[index];
        final isSelected = _selectedIndex == index;

        return InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CuttingOutStockFormNardana(production: r),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? C.warning.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("ID", r.id.toString()),
                _row("Roll Code", r.rollCode.toString()),
                _row("Barcode", r.barcode),
                _row("WO", r.partyname),
                _row("Supervisor", r.supervisorName),
                _row("Operator", r.operatorName),
                _row("Loom Type", r.loomNo),
                _row("Fabric Type/use", r.fabricType),
                _row("Party Name", r.component),
                _row("Fabric Code", r.fabricCode),
                _row("Week No", r.weekNo),
                _row("Req Qty(KG)", r.requiredQtyKg.toString()),
                _row("Req Qty(Mtr)", r.requiredQtyMtr.toString()),
                _row("Loom No", r.loomType),
                _row("Color", r.color),
                _row("GSM", r.fabricGsm),
                _row("Status", r.status),
                _row("Date", r.date.split(" ")[0]),
                _row("Time", r.time.split(" ")[0]),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── STATUS ──
  Widget _statusBar() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    color: Colors.blue.shade50,
    child: Text(_status),
  );

  // ── BOTTOM ──
  Widget _bottomBar() => Container(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _page > 1 ? () => _fetchPage(_page - 1) : null,
          child: const Text("Prev"),
        ),

        Text("Page $_page"),

        ElevatedButton(
          onPressed: _hasMore ? () => _fetchPage(_page + 1) : null,
          child: const Text("Next"),
        ),
      ],
    ),
  );

  // ── HELPERS ──
  void _setStatus(String msg) {
    if (mounted) setState(() => _status = msg);
  }

  String _formatDate(String d) {
    try {
      return DateTime.parse(d).toString().split(" ")[0];
    } catch (_) {
      return d;
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

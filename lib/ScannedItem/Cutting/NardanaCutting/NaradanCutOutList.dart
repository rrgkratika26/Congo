// import 'dart:async';
//
// import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:thermal_printer_plus/printer.dart';
//
// import '../../../Color/Colorclass.dart';
// import '../../../services/NardanaApis/NardanaApi.dart';
// import '../cutOutModelClass/ModelClassOutstock.dart';
// import 'CutOutStockFormNardana.dart';
// import 'modelclass/CuttingOutStockNardana.dart';
//
// class CutOutSavedListNardana extends StatefulWidget {
//   final String title;
//   final List<CuttingOutstockNaradana> initialItems;
//
//   const CutOutSavedListNardana({
//     super.key,
//     this.title = "Cutting OUT Stock",
//     this.initialItems = const [],
//   });
//
//   @override
//   State<CutOutSavedListNardana> createState() => _CutOutSavedListNardanaState();
// }
//
// // ─────────────────────────────────────────────
//
// class _CutOutSavedListNardanaState extends State<CutOutSavedListNardana> {
//   // ── Data ──
//   final ScrollController _scrollController = ScrollController();
//   final List<CuttingOutstockNaradana> _items = [];
//   List<CuttingOutstockNaradana> _filteredItems = [];
//   String _searchText = '';
//   final TextEditingController _searchController = TextEditingController();
//   int _page = 1;
//   final int _pageSize = 50;
//   bool _loading = false;
//   bool _hasMore = true;
//   int? _selectedIndex;
//   Timer? _debounce;
//   // ── Printer ──
//   final _storage = GetStorage();
//   bool _printing = false;
//   String _status = '';
//   StreamSubscription<BTStatus>? _btSub;
//
//   @override
//   void initState() {
//     super.initState();
//     // _fetchPage(1);
//     // _items.addAll(widget.initialItems);
//     // _filteredItems = List.from(_items);
//     _fetchInitial();
//
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _btSub?.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // ─────────────────────────────────────────────
//   // DATA
//   // ─────────────────────────────────────────────
//
//
//
//   void _applyFilter(String value) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         _searchText = value.toLowerCase();
//
//         _filteredItems = _searchText.isEmpty
//             ? List.from(_items)
//             : _items.where((item) {
//           return item.id.toString().toLowerCase().contains(_searchText) ||
//               item.barcode.toLowerCase().contains(_searchText) ||
//               item.rollCode.toString().toLowerCase().contains(_searchText);
//         }).toList();
//       });
//     });
//   }
//
//   Future<void> _fetchInitial() async {
//     setState(() => _loading = true);
//
//     try {
//       final data = await NaradanaApiService.fetchOutStockListNaradana(
//         plant: AppGlobals.unit,
//         // plant: 'UNIT-SILVASSA',
//
//         page: 1,
//         pageSize: _pageSize,
//       );
//
//       setState(() {
//         _page = 1;
//         _items
//           ..clear()
//           ..addAll(data);
//
//         _filteredItems = List.from(_items); // ✅ FIX HERE
//         _hasMore = data.isNotEmpty;
//       });
//     } catch (e) {
//       _setStatus("❌ Load error: $e");
//     }
//
//     setState(() => _loading = false);
//   }
//
//   Future _loadMore() async {
//     if (_loading || !_hasMore) return;
//
//     setState(() => _loading = true);
//
//     try {
//       final nextPage = _page + 1;
//
//       final data =
//       await NaradanaApiService.fetchOutStockListNaradana(
//         plant: AppGlobals.unit,
//         page: nextPage,
//         pageSize: _pageSize,
//       );
//
//       final existingIds = _items.map((e) => e.id).toSet();
//
//       _items.addAll(
//         data.where((e) => !existingIds.contains(e.id)),
//       );
//
//       _page = nextPage;
//
//       _filteredItems = _searchText.isEmpty
//           ? List.from(_items)
//           : _items.where((item) {
//         return item.id
//             .toString()
//             .toLowerCase()
//             .contains(_searchText) ||
//             item.barcode
//                 .toLowerCase()
//                 .contains(_searchText) ||
//             item.rollCode
//                 .toString()
//                 .toLowerCase()
//                 .contains(_searchText);
//       }).toList();
//
//       _hasMore = data.length == _pageSize;
//     } catch (e) {
//       _setStatus("❌ Pagination error: $e");
//     }
//
//     setState(() => _loading = false);
//   }
//
//   Future<void> _fetchPage(int page) async {
//     setState(() => _loading = true);
//
//     try {
//       final data = await NaradanaApiService.fetchOutStockListNaradana(
//         plant: AppGlobals.unit,
//         // plant: 'UNIT-SILVASSA',
//
//         page: page,
//         pageSize: 20, // ✅ FIXED 20
//       );
//
//       setState(() {
//         _page = page;
//
//         _items
//           ..clear() // ✅ IMPORTANT (replace data)
//           ..addAll(data);
//         _filteredItems = List.from(_items);
//         _hasMore = data.length == 20; // if less → last page
//       });
//     } catch (e) {
//       _setStatus("❌ Page load error: $e");
//     }
//
//     setState(() => _loading = false);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_loading) {
//       _loadMore();
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.bg,
//       appBar: AppBar(
//         backgroundColor: C.primary,
//         title: Text(
//           widget.title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: C.bg,
//           ),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 12),
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.inventory_2_outlined,
//                   color: Colors.white,
//                   size: 14,
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   "${_items.length}",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         iconTheme: IconThemeData(color: C.bg),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _applyFilter,
//               decoration: InputDecoration(
//                 hintText: "Search by ID or Roll Code",
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchText.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _applyFilter('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//
//           if (_status.isNotEmpty) _statusBar(),
//           Expanded(
//             child: _loading && _items.isEmpty
//                 ? Center(
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircularProgressIndicator(color: C.appBar3),
//                           const SizedBox(height: 15),
//                           Text(
//                             "Fetching Out List...",
//                             style: TextStyle(
//                               color: C.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : _buildTable(),
//           ),
//           _bottomBar(),
//         ],
//       ),
//     );
//   }
//
//   // ── TABLE ──
//   Widget _buildTable() {
//     return ListView.builder(
//       addAutomaticKeepAlives: false,
//       addRepaintBoundaries: true,
//
//       controller: _scrollController,
//       itemCount: _filteredItems.length + (_loading ? 1 : 0),
//       itemBuilder: (context, index) {
//         // 🔹 Loader at bottom while pagination
//         if (index == _filteredItems.length) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator(color: C.appBar3,)),
//           );
//         }
//
//         final r = _filteredItems[index];
//         final isSelected = _selectedIndex == index;
//
//         return InkWell(
//           onTap: () {
//             setState(() => _selectedIndex = index);
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => CuttingOutStockFormNardana(production: r),
//               ),
//             );
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isSelected ? C.warning.withOpacity(0.2) : Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _row("ID", r.id.toString()),
//                 _row("Roll Code", r.rollCode.toString()),
//                 _row("Barcode", r.barcode),
//                 _row("WO", r.partyname),
//                 _row("Supervisor", r.supervisorName),
//                 _row("Operator", r.operatorName),
//                 _row("Loom Type", r.loomNo),
//                 _row("Fabric Type/use", r.fabricType),
//                 _row("Party Name", r.component),
//                 _row("Fabric Code", r.fabricCode),
//                 _row("Week No", r.weekNo),
//                 _row("Req Qty(KG)", r.requiredQtyKg.toString()),
//                 _row("Req Qty(Mtr)", r.requiredQtyMtr.toString()),
//                 _row("Loom No", r.loomType),
//                 _row("Color", r.color),
//                 _row("GSM", r.fabricGsm),
//                 _row("Status", r.status),
//                 _row("Date", r.date.split(" ")[0]),
//                 _row("Time", r.time.split(" ")[0]),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // ── STATUS ──
//   Widget _statusBar() => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(10),
//     color: Colors.blue.shade50,
//     child: Text(_status),
//   );
//
//   // ── BOTTOM ──
//   Widget _bottomBar() => Container(
//     padding: const EdgeInsets.all(12),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed: _page > 1 ? () => _fetchPage(_page - 1) : null,
//           child: const Text("Prev"),
//         ),
//
//         Text("Page $_page"),
//
//         ElevatedButton(
//           onPressed: _hasMore ? () => _fetchPage(_page + 1) : null,
//           child: const Text("Next"),
//         ),
//       ],
//     ),
//   );
//
//   // ── HELPERS ──
//   void _setStatus(String msg) {
//     if (mounted) setState(() => _status = msg);
//   }
//
//   String _formatDate(String d) {
//     try {
//       return DateTime.parse(d).toString().split(" ")[0];
//     } catch (_) {
//       return d;
//     }
//   }
//
//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               "$label:",
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
//         ],
//       ),
//     );
//   }
// }

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

  final ScrollController _scrollController = ScrollController();
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

  // ============================================================
  // PRINTER
  // ============================================================

  final _storage = GetStorage();

  bool _printing = false;

  StreamSubscription<BTStatus>? _btSub;

  // ============================================================
  // ROLL FINISH
  // ============================================================

  bool _isRollFinishLoading = false;

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

      // If unit is stored somewhere else in your project,
      // you can replace this with AppGlobals.unit.
      if (unitName.isEmpty) {
        _setStatus("Unit not found.");
        return;
      }

      final data = await NaradanaApiService.fetchOutStockListNaradana(
        // plant: unitName,
        // page: 1,
        // pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _page = 1;

        _items.clear();

        // Add initial widget data only if API returned nothing.
        if (data.isNotEmpty) {
          _items.addAll(data);
        } else if (widget.initialItems.isNotEmpty) {
          _items.addAll(widget.initialItems);
        }

        _filteredItems = List.from(_items);

        // If less than page size, probably last page.
        _hasMore = data.length >= _pageSize;
      });
    } catch (e) {
      _setStatus("❌ Load error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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

        if (query.isEmpty) {
          _filteredItems = List.from(_items);
        } else {
          _filteredItems = _items.where((item) {
            return item.id.toString().toLowerCase().contains(query) ||
                item.barcode.toLowerCase().contains(query) ||
                item.rollCode.toString().toLowerCase().contains(query) ||
                item.partyname.toLowerCase().contains(query) ||
                item.fabricCode.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  // ============================================================
  // LOAD MORE - INFINITE SCROLL
  // ============================================================

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || unitName.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final nextPage = _page + 1;

      final data = await NaradanaApiService.fetchOutStockListNaradana(
        // plant: unitName,
        // page: nextPage,
        // pageSize: _pageSize,
      );

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
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // APPLY CURRENT FILTER
  // ============================================================

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
  // SCROLL
  // ============================================================

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
    if (_loading || page < 1 || unitName.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final data = await NaradanaApiService.fetchOutStockListNaradana(
        // plant: unitName,
        // page: page,
        // pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _page = page;

        _items.clear();
        _items.addAll(data);

        _applyCurrentFilter();

        _hasMore = data.length >= _pageSize;

        // Clear selected roll if it isn't in current page.
        if (_selectedRollId != null &&
            !_items.any((e) => e.id == _selectedRollId)) {
          _selectedRollId = null;
        }
      });
    } catch (e) {
      _setStatus("❌ Page load error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // ROLL FINISH
  // ============================================================

  Future<void> _rollFinish() async {
    if (_selectedRollId == null || _isRollFinishLoading) {
      return;
    }

    setState(() {
      _isRollFinishLoading = true;
    });

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
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRollFinishLoading = false;
        });
      }
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

        iconTheme: const IconThemeData(color: C.bg),
      ),

      body: Column(
        children: [
          // =====================================================
          // SEARCH
          // =====================================================
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

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // =====================================================
          // STATUS
          // =====================================================
          if (_status.isNotEmpty) _statusBar(),

          // =====================================================
          // LIST
          // =====================================================
          Expanded(
            child: _loading && _items.isEmpty ? _buildLoading() : _buildTable(),
          ),

          // =====================================================
          // ROLL FINISH BUTTON
          // =====================================================
          if (_selectedRollId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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

                  label: Text(
                    _isRollFinishLoading ? "Finishing..." : "Roll Finish",
                  ),

                  onPressed: _isRollFinishLoading ? null : _rollFinish,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),

          // =====================================================
          // PAGINATION
          // =====================================================
          _bottomBar(),
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
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
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

  // ============================================================
  // LIST
  // ============================================================

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

    return ListView.builder(
      controller: _scrollController,

      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,

      itemCount: _filteredItems.length + (_loading ? 1 : 0),

      itemBuilder: (context, index) {
        // Bottom loader
        if (index == _filteredItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: C.appBar3)),
          );
        }

        final r = _filteredItems[index];

        final isSelected = _selectedRollId == r.id;

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
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: isSelected ? C.warning.withOpacity(0.2) : Colors.white,

              borderRadius: BorderRadius.circular(10),

              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // SELECT
                // =================================================
                Row(
                  children: [
                    Checkbox(
                      value: isSelected,

                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedRollId = r.id;
                          } else {
                            _selectedRollId = null;
                          }
                        });
                      },
                    ),

                    const Expanded(
                      child: Text(
                        "Select Roll",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

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

                _row("Date", _safeDate(r.date)),

                _row("Time", _safeTime(r.time)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTTOM PAGINATION
  // ============================================================

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          ElevatedButton.icon(
            onPressed: (_page > 1 && !_loading)
                ? () => _fetchPage(_page - 1)
                : null,

            icon: const Icon(Icons.chevron_left),

            label: const Text("Prev"),
          ),

          Text(
            "Page $_page",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          ElevatedButton.icon(
            onPressed: (_hasMore && !_loading)
                ? () => _fetchPage(_page + 1)
                : null,

            icon: const Icon(Icons.chevron_right),

            label: const Text("Next"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),

      color: Colors.blue.shade50,

      child: Text(_status, style: const TextStyle(fontSize: 12)),
    );
  }

  void _setStatus(String message) {
    if (!mounted) return;

    setState(() {
      _status = message;
    });
  }

  // ============================================================
  // SAFE DATE
  // ============================================================

  String _safeDate(String value) {
    if (value.trim().isEmpty) {
      return "-";
    }

    try {
      return value.split(" ")[0];
    } catch (_) {
      return value;
    }
  }

  String _safeTime(String value) {
    if (value.trim().isEmpty) {
      return "-";
    }

    try {
      return value.split(" ")[0];
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              "$label:",

              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,

              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

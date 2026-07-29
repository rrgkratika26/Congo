import 'dart:io';
import 'dart:async';

import 'package:IMS/ScannedItem/Cutting/NardanaCutting/CutOutStockFormNardana.dart';
import 'package:IMS/services/visa_apis/visa_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/Bluetooth_services.dart';
import '../../../services/GlobalLoader/GloabalUnit.dart';
import '../cutOutModelClass/ModelClassOutstock.dart';
import 'Cut_OutStock.dart';

class CuttingOutStockSavedList extends StatefulWidget {
  /// Title shown in AppBar — e.g. "Cutting Out Stock"
  final String title;

  /// Pass already-saved items if you pre-load them; else start empty
  final List<CuttingOutstock> initialItems;

  const CuttingOutStockSavedList({
    super.key,
    required this.title,
    this.initialItems = const [],
  });

  @override
  State<CuttingOutStockSavedList> createState() =>
      _CuttingOutStockSavedListState();

  // ── Static helper — call this after a successful save ──────────────────────
  static final _notifier = ValueNotifier<CuttingOutstock?>(null);

  static void addItem(CuttingOutstock data) {
    _notifier.value = data;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CuttingOutStockSavedListState extends State<CuttingOutStockSavedList> {
  // ── Theme ──
  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Color(0xFF6B7A9F);
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex;
  List<CuttingOutstock> _items = [];
  bool isLoading = false;

  // Print state
  final _storage = GetStorage();
  bool _printing = false;
  String _printStatus = '';
  StreamSubscription<BTStatus>? _btSub;


  @override
  void initState() {
    super.initState();

    _items.addAll(widget.initialItems);
    _loadApiData();

    _scrollController.addListener(_onScroll);

    CuttingOutStockSavedList._notifier.addListener(_onNewItem);
  }

  @override
  void dispose() {
    CuttingOutStockSavedList._notifier.removeListener(_onNewItem);
    _btSub?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      _loadMoreData();
    }
  }




  Future<void> _nextPage() async {
    setState(() {
      _currentPage++;
      isLoading = true;
    });

    try {
      final data = await VisaApiService.fetchOutStockList(
        plant: AppGlobals.unit,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _items = data;
        isLoading = false;
        _hasMore = data.length == _pageSize;
        _selectedIndex = null;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _setStatus("❌ Next page error: $e");
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage == 1) return;

    setState(() {
      _currentPage--;
      isLoading = true;
    });

    try {
      final data = await VisaApiService.fetchOutStockList(
        plant: AppGlobals.unit,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _items = data;
        isLoading = false;
        _hasMore = true; // safe assumption
        _selectedIndex = null;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _setStatus("❌ Previous page error: $e");
    }
  }


  Future<void> _loadApiData() async {
    setState(() {
      isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final List<CuttingOutstock> mapped =
          await VisaApiService.fetchOutStockList(
            plant: AppGlobals.unit,
            page: _currentPage,
            pageSize: _pageSize,
          );

      setState(() {
        _items = mapped;
        isLoading = false;
        _hasMore = mapped.length == _pageSize;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _setStatus("❌ API Error: $e");
    }
  }

  Future<void> _loadMoreData() async {
    if (_isFetchingMore) return;

    _isFetchingMore = true;
    _currentPage++;

    try {
      final List<CuttingOutstock> mapped =
          await VisaApiService.fetchOutStockList(
            plant:AppGlobals.unit,
            page: _currentPage,
            pageSize: _pageSize,
          );

      setState(() {
        _items.addAll(mapped);
        _hasMore = mapped.length == _pageSize;
      });
    } catch (e) {
      _setStatus("❌ Load more error: $e");
    }

    _isFetchingMore = false;
  }

  void _onNewItem() {
    final item = CuttingOutStockSavedList._notifier.value;
    if (item != null && mounted) {
      setState(() {
        _items.insert(0, item);
        _selectedIndex = 0;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_printStatus.isNotEmpty) _statusBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
                : _items.isEmpty
                ? _emptyState()
                : _buildList(),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}-"
        "${_monthName(now.month)}-"
        "${now.year}";

    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        // Bluetooth settings
        IconButton(
          icon: const Icon(Icons.bluetooth_rounded, size: 20),
          tooltip: "Printer",
          onPressed: () => Get.to(() => const BluetoothDeviceListScreen()),
        ),
        // Item count badge
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.content_cut_rounded,
                color: Colors.white70,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                "${_items.length} Items",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Status bar ─────────────────────────────────────────────────────────────
  Widget _statusBar() => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: _printStatus.startsWith('✅')
        ? Colors.green.shade50
        : _printStatus.startsWith('❌')
        ? Colors.red.shade50
        : Colors.blue.shade50,
    child: Row(
      children: [
        if (_printing)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(color: C.appBar3,strokeWidth: 2),
          )
        else
          Icon(
            _printStatus.startsWith('✅')
                ? Icons.check_circle_rounded
                : _printStatus.startsWith('❌')
                ? Icons.error_rounded
                : Icons.info_rounded,
            size: 16,
            color: _printStatus.startsWith('✅')
                ? Colors.green
                : _printStatus.startsWith('❌')
                ? Colors.red
                : _primary,
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(_printStatus, style: const TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.content_cut_rounded, size: 60, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          "Data Not Found",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    ),
  );

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,


        child: DataTable(
          dataRowColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.2);
            }
            return null;
          }),
          columnSpacing: 12,
          columns: const [
            DataColumn(label: Text("Sr No")),
            DataColumn(label: Text("Barcode")),
            DataColumn(label: Text("Component")),
            DataColumn(label: Text("Supervisor")),
            DataColumn(label: Text("Operator")),

            DataColumn(label: Text("Party")),

            DataColumn(label: Text("Order Type")),
            DataColumn(label: Text("Req Qty(Kg)")),
            DataColumn(label: Text("Req Qty(Mtr)")),

            DataColumn(label: Text("Work Order")),
            DataColumn(label: Text("Loom No")),
            DataColumn(label: Text("Loom Type")),
            DataColumn(label: Text("Fabric_GSM")),
            DataColumn(label: Text("Fabric Width")),
            DataColumn(label: Text("Color")),
            DataColumn(label: Text("Cut/Slip type")),
            DataColumn(label: Text("Net Wt")),
            DataColumn(label: Text("Qty")),
            DataColumn(label: Text("Dept")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Date")),
            // DataColumn(label: Text("Action")),
            DataColumn(label: Text("Open")),
          ],
          rows: _items.asMap().entries.map((entry) {
            int index = entry.key;
            var r = entry.value;
            return DataRow(
              selected: _selectedIndex == index,
              onSelectChanged: (val) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              color: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (_selectedIndex == index) {
                  return Colors.lightGreen.withOpacity(0.2);
                }
                return Colors.transparent;
              }),
              cells: [
                // Sr No
                DataCell(
                  Text(r.srno, style: TextStyle(color: C.primary, fontSize: 15)),
                ),

                // Barcode
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: C.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.barcode,
                      style: const TextStyle(color: C.textHigh, fontSize: 11),
                    ),
                  ),
                ),
                DataCell(Text(r.machineno)),

                // Supervisor
                DataCell(Text(r.supervisor)),

                // Operator
                DataCell(Text(r.operatorName)),
                // Party
                DataCell(Text(r.partyname)),
                DataCell(Text(r.jobwork)),
                DataCell(Text(r.requiredNetWeight.toString())),
                DataCell(Text(r.requiredQtyMtr.toString())),

                // Work Order
                DataCell(Text(r.workorderno)),

                // Machine
                DataCell(Text(r.machine)),

                // Model No
                DataCell(Text(r.modelno)),

                // GSM
                DataCell(Text(r.gsm)),

                // Fabric Width
                DataCell(Text(r.fabricwidth)),

                // Color
                DataCell(Text(r.color)),

                // Cut Type
                DataCell(Text(r.cuttype)),

                // Net Weight
                DataCell(Text(r.netwt.toStringAsFixed(2))),

                // Quantity
                DataCell(Text(r.quantity.toStringAsFixed(2))),

                // Department
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.indigo.withOpacity(0.4)),
                    ),
                    child: Text(
                      r.department,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                DataCell(Text(r.rmStatus)),

                // Date
                DataCell(
                  Text(
                    _formatDate(r.laminationDate.toIso8601String()),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),

                // Print Button
                // DataCell(
                //   ElevatedButton(
                //     onPressed: _printing ? null : () => _printSingle(r),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: _primary,
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //     ),
                //     child: const Text(
                //       "Print",
                //       style: TextStyle(fontSize: 12, color: Colors.white),
                //     ),
                //   ),
                // ),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex =
                            index; // make sure 'index' is defined in your row builder
                      });
                      print("Passing SRNO 👉 ${r.srno}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          // CuttingOutStockFormNardana()
                              CuttingOutStockForm(
                            production: r,
                          ), // ensure 'r' is your row data
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.borderLight,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text(
                      "Open",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────
  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _border)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected info
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedIndex != null
                    ? "Barcode: ${_items[_selectedIndex!].barcode} selected"
                    : "Select a row to print",
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedIndex != null ? _primary : _labelColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Pagination buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 1 ? _previousPage : null,
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text("⬅ Previous",style: TextStyle(color: C.bg),),
            ),

            Text(
              "Page $_currentPage",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            ElevatedButton(
              onPressed: _hasMore ? _nextPage : null,
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text("Next ➡",style: TextStyle(color: C.bg),),
            ),
          ],
        ),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  PRINT LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _printSingle(CuttingOutstock item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Print Label"),
        content: Text(
          "Print barcode ${item.barcode}?",
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Print"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _selectedIndex = _items.indexOf(item);
    await _confirmAndPrint();
  }

  Future<void> _confirmAndPrint() async {
    if (_selectedIndex == null) return;

    final item = _items[_selectedIndex!];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirm Issue"),
        content: Text(
          "Are you sure you want to issue barcode?\n\n${item.barcode}",
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Issue"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _setStatus("⏳ Issuing barcode...");

    // final success = await VisaApiService.cutting_issueBarcode(
    //   barcode: item.barcode,
    //   type: item.department.toUpperCase(),
    // );

    // if (!success) {
    //   _setStatus("❌ Issue failed");
    //   return;
    // }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Issued Successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    }

    await _onPrint();
  }

  Future<void> _onPrint() async {
    if (_selectedIndex == null) return;
    final item = _items[_selectedIndex!];

    final address = _storage.read<String>('printer_address');
    final name = _storage.read<String>('printer_name') ?? 'Printer';

    if (address == null) {
      _setStatus('❌ First Connect with Printer (Bluetooth icon)');
      return;
    }

    _setStatus('🔗 Connecting $name...');

    if (Platform.isIOS) {
      await _iosPrint(address, item);
    } else {
      await _androidPrint(address, name, item);
    }
  }

  // ── Android ────────────────────────────────────────────────────────────────
  Future<void> _androidPrint(
    String address,
    String name,
    CuttingOutstock item,
  ) async {
    bool triggered = false;

    _btSub?.cancel();
    _btSub = PrinterManager.instance.stateBluetooth.listen((status) async {
      if (status == BTStatus.connected && !triggered) {
        triggered = true;
        _setStatus('✅ Connected. Printing...');
        await Future.delayed(const Duration(milliseconds: 800));
        try {
          await PrinterManager.instance.send(
            type: PrinterType.bluetooth,
            bytes: [27, 64],
          );
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {}
        await _executePrint(item);
      }
    });

    try {
      await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (_) {}

    try {
      await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: name,
          address: address,
          isBle: false,
          autoConnect: false,
        ),
      );
    } catch (e) {
      _setStatus('❌ Connect error: $e');
    }
  }

  // ── iOS ────────────────────────────────────────────────────────────────────
  Future<void> _iosPrint(String address, CuttingOutstock item) async {
    try {
      final ok = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );
      if (!ok) {
        _setStatus('❌ iOS connect fail');
        return;
      }
      _setStatus('✅ Connected. Printing...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _executePrint(item);
    } catch (e) {
      _setStatus('❌ iOS error: $e');
    }
  }

  // ── Execute Print ──────────────────────────────────────────────────────────
  Future<void> _executePrint(CuttingOutstock r) async {
    if (_printing) return;
    setState(() => _printing = true);

    try {
      _setStatus('🖨️ Sending label...');

      final String tspl =
          '''
SIZE 100 mm,100 mm
GAP 2 mm,1 mm
DIRECTION 1
CLS

REM === LEFT COLUMN ===
TEXT 20,20,"2",0,2,2,"${r.machine}"
TEXT 20,80,"2",0,2,2,"GSM:${r.gsm}"
TEXT 20,140,"2",0,2,2,"Party:${r.partyname}"
TEXT 20,200,"2",0,2,2,"WO.No:${r.workorderno}"
TEXT 20,260,"2",0,2,2,"Date:${_formatDate(r.laminationDate.toIso8601String())}"

REM === QR CODE (left, below date) ===
QRCODE 20,330,L,9,A,0,"${r.barcode}"

REM === BARCODE ID below QR ===
TEXT 20,560,"2",0,2,2,"${r.barcode}"

REM === RIGHT COLUMN ===
TEXT 430,20,"2",0,2,2,"SR:${r.srno}"
TEXT 430,80,"2",0,2,2,"Model:${r.modelno}"
TEXT 430,140,"2",0,2,2,"Width:${r.fabricwidth}"
TEXT 430,200,"2",0,2,2,"Color:${r.color}"
TEXT 430,260,"2",0,2,2,"CutType:${r.cuttype}"

REM === WEIGHTS ===
TEXT 380,330,"2",0,2,2,"Net Wt(Kg):${r.netwt.toStringAsFixed(2)}"
TEXT 380,390,"2",0,2,2,"Qty:${r.quantity.toStringAsFixed(2)}"
TEXT 380,450,"2",0,2,2,"Req Wt:${r.requiredNetWeight.toStringAsFixed(2)}"
TEXT 380,510,"2",0,2,2,"Req Mtr:${r.requiredQtyMtr.toStringAsFixed(2)}"

REM === OPERATOR ===
TEXT 380,560,"2",0,2,2,"${r.operatorName}"

REM === FABRIC / DEPT (bottom) ===
TEXT 20,630,"2",0,2,2,"${r.typeuse}"
TEXT 600,670,"2",0,2,2,"${r.department}"

PRINT 1
''';

      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: tspl.codeUnits,
      );

      _setStatus('✅ Label printed successfully!');
    } catch (e) {
      _setStatus('❌ Print error: $e');
    } finally {
      setState(() => _printing = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setStatus(String msg) {
    debugPrint('[PRINT] $msg');
    if (mounted) setState(() => _printStatus = msg);
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _formatDate(String inputDate) {
    try {
      final parsed = DateTime.parse(inputDate);
      return "${parsed.day.toString().padLeft(2, '0')}-"
          "${_monthName(parsed.month)}-"
          "${parsed.year}";
    } catch (e) {
      try {
        final parts = inputDate.split(" ");
        final datePart = parts[0];
        final d = datePart.split("/");
        final month = int.parse(d[0]);
        final day = int.parse(d[1]);
        final year = int.parse(d[2]);
        return "${day.toString().padLeft(2, '0')}-"
            "${_monthName(month)}-"
            "$year";
      } catch (_) {
        return inputDate;
      }
    }
  }
}





//
// import 'dart:io';
// import 'dart:async';
//
// import 'package:IMS/services/visa_apis/visa_api.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:thermal_printer_plus/thermal_printer.dart';
//
// import '../../../Color/Colorclass.dart';
// import '../../../services/Bluetooth_services.dart';
// import '../cutOutModelClass/ModelClassOutstock.dart';
// import 'Cut_OutStock.dart';
//
// class CuttingOutStockSavedList extends StatefulWidget {
//   final String title;
//   final List<CuttingOutstock> initialItems;
//
//   const CuttingOutStockSavedList({
//     super.key,
//     required this.title,
//     this.initialItems = const [],
//   });
//
//   @override
//   State<CuttingOutStockSavedList> createState() =>
//       _CuttingOutStockSavedListState();
//
//   static final _notifier = ValueNotifier<CuttingOutstock?>(null);
//
//   static void addItem(CuttingOutstock data) {
//     _notifier.value = data;
//   }
// }
//
// class _CuttingOutStockSavedListState extends State<CuttingOutStockSavedList> {
//   static const _primary = Color(0xFF1A56DB);
//   static const _surface = Color(0xFFF8FAFF);
//   static const _border = Color(0xFFDDE3F0);
//   static const _labelColor = Color(0xFF6B7A9F);
//
//   int _currentPage = 1;
//   final int _pageSize = 20;
//   bool _hasMore = true;
//   bool _isFetchingMore = false;
//
//   final ScrollController _scrollController = ScrollController();
//   int? _selectedIndex;
//   List<CuttingOutstock> _items = [];
//   List<CuttingOutstock> _filteredItems = [];
//   bool isLoading = false;
//
//   // Search
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//
//   // Print state
//   final _storage = GetStorage();
//   bool _printing = false;
//   String _printStatus = '';
//   StreamSubscription<BTStatus>? _btSub;
//
//   @override
//   void initState() {
//     super.initState();
//     _items.addAll(widget.initialItems);
//     _filteredItems = List.from(_items);
//     _loadApiData();
//     _scrollController.addListener(_onScroll);
//     CuttingOutStockSavedList._notifier.addListener(_onNewItem);
//
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase().trim();
//         _applyFilter();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     CuttingOutStockSavedList._notifier.removeListener(_onNewItem);
//     _btSub?.cancel();
//     super.dispose();
//   }
//
//   void _applyFilter() {
//     if (_searchQuery.isEmpty) {
//       _filteredItems = List.from(_items);
//     } else {
//       _filteredItems = _items.where((r) {
//         return r.barcode.toLowerCase().contains(_searchQuery) ||
//             r.machineno.toLowerCase().contains(_searchQuery) ||
//             r.supervisor.toLowerCase().contains(_searchQuery) ||
//             r.operatorName.toLowerCase().contains(_searchQuery) ||
//             r.partyname.toLowerCase().contains(_searchQuery) ||
//             r.workorderno.toLowerCase().contains(_searchQuery) ||
//             r.modelno.toLowerCase().contains(_searchQuery) ||
//             r.color.toLowerCase().contains(_searchQuery) ||
//             r.cuttype.toLowerCase().contains(_searchQuery) ||
//             r.department.toLowerCase().contains(_searchQuery) ||
//             r.srno.toLowerCase().contains(_searchQuery);
//       }).toList();
//     }
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         !_isFetchingMore &&
//         _hasMore) {
//       _loadMoreData();
//     }
//   }
//
//   Future<void> _nextPage() async {
//     setState(() {
//       _currentPage++;
//       isLoading = true;
//     });
//
//     try {
//       final data = await VisaApiService.fetchOutStockList(
//         plant: 'FIBC',
//         page: _currentPage,
//         pageSize: _pageSize,
//       );
//
//       setState(() {
//         _items = data;
//         isLoading = false;
//         _hasMore = data.length == _pageSize;
//         _selectedIndex = null;
//         _applyFilter();
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       _setStatus("❌ Next page error: $e");
//     }
//   }
//
//   Future<void> _previousPage() async {
//     if (_currentPage == 1) return;
//
//     setState(() {
//       _currentPage--;
//       isLoading = true;
//     });
//
//     try {
//       final data = await VisaApiService.fetchOutStockList(
//         plant: 'FIBC',
//         page: _currentPage,
//         pageSize: _pageSize,
//       );
//
//       setState(() {
//         _items = data;
//         isLoading = false;
//         _hasMore = true;
//         _selectedIndex = null;
//         _applyFilter();
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       _setStatus("❌ Previous page error: $e");
//     }
//   }
//
//   Future<void> _loadApiData() async {
//     setState(() {
//       isLoading = true;
//       _currentPage = 1;
//       _hasMore = true;
//     });
//
//     try {
//       final List<CuttingOutstock> mapped =
//       await VisaApiService.fetchOutStockList(
//         plant: 'FIBC',
//         page: _currentPage,
//         pageSize: _pageSize,
//       );
//
//       setState(() {
//         _items = mapped;
//         isLoading = false;
//         _hasMore = mapped.length == _pageSize;
//         _applyFilter();
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       _setStatus("❌ API Error: $e");
//     }
//   }
//
//   Future<void> _loadMoreData() async {
//     if (_isFetchingMore) return;
//     _isFetchingMore = true;
//     _currentPage++;
//
//     try {
//       final List<CuttingOutstock> mapped =
//       await VisaApiService.fetchOutStockList(
//         plant: 'FIBC',
//         page: _currentPage,
//         pageSize: _pageSize,
//       );
//
//       setState(() {
//         _items.addAll(mapped);
//         _hasMore = mapped.length == _pageSize;
//         _applyFilter();
//       });
//     } catch (e) {
//       _setStatus("❌ Load more error: $e");
//     }
//
//     _isFetchingMore = false;
//   }
//
//   void _onNewItem() {
//     final item = CuttingOutStockSavedList._notifier.value;
//     if (item != null && mounted) {
//       setState(() {
//         _items.insert(0, item);
//         _selectedIndex = 0;
//         _applyFilter();
//       });
//     }
//   }
//
//   // ── Build ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _surface,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           if (_printStatus.isNotEmpty) _statusBar(),
//           _searchBar(),
//           if (_searchQuery.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   '${_filteredItems.length} result${_filteredItems.length == 1 ? '' : 's'} found',
//                   style: const TextStyle(fontSize: 11, color: _labelColor),
//                 ),
//               ),
//             ),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredItems.isEmpty
//                 ? _emptyState()
//                 : _buildList(),
//           ),
//           _bottomBar(),
//         ],
//       ),
//     );
//   }
//
//   // ── AppBar ─────────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     final now = DateTime.now();
//     final formattedDate =
//         "${now.day.toString().padLeft(2, '0')}-"
//         "${_monthName(now.month)}-"
//         "${now.year}";
//
//     return AppBar(
//       backgroundColor: _primary,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//         onPressed: () => Navigator.maybePop(context),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.title,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//           ),
//           Text(
//             formattedDate,
//             style: const TextStyle(fontSize: 11, color: Colors.white70),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.bluetooth_rounded, size: 20),
//           tooltip: "Printer",
//           onPressed: () => Get.to(() => const BluetoothDeviceListScreen()),
//         ),
//         Container(
//           margin: const EdgeInsets.only(right: 12),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.18),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.content_cut_rounded,
//                 color: Colors.white70,
//                 size: 13,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 "${_filteredItems.length} Items",
//                 style: const TextStyle(color: Colors.white, fontSize: 11),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Search Bar ─────────────────────────────────────────────────────────────
//   Widget _searchBar() => Padding(
//     padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
//     child: TextField(
//       controller: _searchController,
//       decoration: InputDecoration(
//         hintText: 'Search barcode, party, operator, work order…',
//         hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
//         prefixIcon: const Icon(
//           Icons.search_rounded,
//           size: 20,
//           color: Colors.grey,
//         ),
//         suffixIcon: _searchQuery.isNotEmpty
//             ? IconButton(
//           icon: const Icon(Icons.close_rounded, size: 18),
//           onPressed: () {
//             _searchController.clear();
//             setState(() {
//               _searchQuery = '';
//               _applyFilter();
//             });
//           },
//         )
//             : null,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 10,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _border),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _border),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _primary, width: 1.5),
//         ),
//       ),
//       style: const TextStyle(fontSize: 13),
//     ),
//   );
//
//   // ── Status bar ─────────────────────────────────────────────────────────────
//   Widget _statusBar() => AnimatedContainer(
//     duration: const Duration(milliseconds: 300),
//     width: double.infinity,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//     color: _printStatus.startsWith('✅')
//         ? Colors.green.shade50
//         : _printStatus.startsWith('❌')
//         ? Colors.red.shade50
//         : Colors.blue.shade50,
//     child: Row(
//       children: [
//         if (_printing)
//           const SizedBox(
//             width: 14,
//             height: 14,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           )
//         else
//           Icon(
//             _printStatus.startsWith('✅')
//                 ? Icons.check_circle_rounded
//                 : _printStatus.startsWith('❌')
//                 ? Icons.error_rounded
//                 : Icons.info_rounded,
//             size: 16,
//             color: _printStatus.startsWith('✅')
//                 ? Colors.green
//                 : _printStatus.startsWith('❌')
//                 ? Colors.red
//                 : _primary,
//           ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(_printStatus, style: const TextStyle(fontSize: 12)),
//         ),
//       ],
//     ),
//   );
//
//   // ── Empty state ────────────────────────────────────────────────────────────
//   Widget _emptyState() => Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           _searchQuery.isNotEmpty
//               ? Icons.search_off_rounded
//               : Icons.content_cut_rounded,
//           size: 60,
//           color: Colors.grey.shade300,
//         ),
//         const SizedBox(height: 12),
//         Text(
//           _searchQuery.isNotEmpty
//               ? 'No results for "$_searchQuery"'
//               : 'Data Not Found',
//           style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//         ),
//         if (_searchQuery.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           TextButton(
//             onPressed: () {
//               _searchController.clear();
//               setState(() {
//                 _searchQuery = '';
//                 _applyFilter();
//               });
//             },
//             child: const Text('Clear search'),
//           ),
//         ],
//       ],
//     ),
//   );
//
//   // ── List ───────────────────────────────────────────────────────────────────
//   Widget _buildList() {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       scrollDirection: Axis.horizontal,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: DataTable(
//           dataRowColor: MaterialStateProperty.resolveWith<Color?>((
//               Set<MaterialState> states,
//               ) {
//             if (states.contains(MaterialState.selected)) {
//               return Colors.blue.withOpacity(0.2);
//             }
//             return null;
//           }),
//           columnSpacing: 12,
//           columns: const [
//             DataColumn(label: Text("Sr No")),
//             DataColumn(label: Text("Barcode")),
//             DataColumn(label: Text("Component")),
//             DataColumn(label: Text("Supervisor")),
//             DataColumn(label: Text("Operator")),
//             DataColumn(label: Text("Party")),
//             DataColumn(label: Text("Order Type")),
//             DataColumn(label: Text("Req Qty(Kg)")),
//             DataColumn(label: Text("Req Qty(Mtr)")),
//             DataColumn(label: Text("Work Order")),
//             DataColumn(label: Text("Loom No")),
//             DataColumn(label: Text("Loom Type")),
//             DataColumn(label: Text("Fabric_GSM")),
//             DataColumn(label: Text("Fabric Width")),
//             DataColumn(label: Text("Color")),
//             DataColumn(label: Text("Cut/Slip type")),
//             DataColumn(label: Text("Net Wt")),
//             DataColumn(label: Text("Qty")),
//             DataColumn(label: Text("Dept")),
//             DataColumn(label: Text("Status")),
//             DataColumn(label: Text("Date")),
//             DataColumn(label: Text("Action")),
//             DataColumn(label: Text("Open")),
//           ],
//           rows: _filteredItems.asMap().entries.map((entry) {
//             int index = entry.key;
//             var r = entry.value;
//             return DataRow(
//               selected: _selectedIndex == index,
//               onSelectChanged: (val) {
//                 setState(() {
//                   _selectedIndex = index;
//                 });
//               },
//               color: MaterialStateProperty.resolveWith<Color?>((
//                   Set<MaterialState> states,
//                   ) {
//                 if (_selectedIndex == index) {
//                   return Colors.lightGreen.withOpacity(0.2);
//                 }
//                 return Colors.transparent;
//               }),
//               cells: [
//                 DataCell(
//                   Text(
//                     r.srno,
//                     style: TextStyle(color: C.primary, fontSize: 15),
//                   ),
//                 ),
//                 DataCell(
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: C.lightBlue,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       r.barcode,
//                       style: const TextStyle(color: C.text, fontSize: 11),
//                     ),
//                   ),
//                 ),
//                 DataCell(Text(r.machineno)),
//                 DataCell(Text(r.supervisor)),
//                 DataCell(Text(r.operatorName)),
//                 DataCell(Text(r.partyname)),
//                 DataCell(Text(r.jobwork)),
//                 DataCell(Text(r.requiredNetWeight.toString())),
//                 DataCell(Text(r.requiredQtyMtr.toString())),
//                 DataCell(Text(r.workorderno)),
//                 DataCell(Text(r.machine)),
//                 DataCell(Text(r.modelno)),
//                 DataCell(Text(r.gsm)),
//                 DataCell(Text(r.fabricwidth)),
//                 DataCell(Text(r.color)),
//                 DataCell(Text(r.cuttype)),
//                 DataCell(Text(r.netwt.toStringAsFixed(2))),
//                 DataCell(Text(r.quantity.toStringAsFixed(2))),
//                 DataCell(
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 7,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.indigo.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                         color: Colors.indigo.withOpacity(0.4),
//                       ),
//                     ),
//                     child: Text(
//                       r.department,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.indigo,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//                 DataCell(Text(r.rmStatus)),
//                 DataCell(
//                   Text(
//                     _formatDate(r.laminationDate.toIso8601String()),
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ),
//                 // DataCell(
//                 //   ElevatedButton(
//                 //     onPressed: _printing ? null : () => _printSingle(r),
//                 //     style: ElevatedButton.styleFrom(
//                 //       backgroundColor: _primary,
//                 //       padding: const EdgeInsets.symmetric(horizontal: 10),
//                 //     ),
//                 //     child: const Text(
//                 //       "Print",
//                 //       style: TextStyle(fontSize: 12, color: Colors.white),
//                 //     ),
//                 //   ),
//                 // ),
//                 DataCell(
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _selectedIndex = index;
//                       });
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CuttingOutStockForm(production: r),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: C.lightBlue,
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                     ),
//                     child: const Text(
//                       "Open",
//                       style: TextStyle(fontSize: 12, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   // ── Bottom Bar ─────────────────────────────────────────────────────────────
//   Widget _bottomBar() => Container(
//     padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       border: Border(top: BorderSide(color: _border)),
//     ),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 _selectedIndex != null
//                     ? "Barcode: ${_filteredItems.length > _selectedIndex! ? _filteredItems[_selectedIndex!].barcode : ''} selected"
//                     : "Select a row to print",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: _selectedIndex != null ? _primary : _labelColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ElevatedButton(
//               onPressed: _currentPage > 1 ? _previousPage : null,
//               style: ElevatedButton.styleFrom(backgroundColor: _primary),
//               child: const Text(
//                 "⬅ Previous",
//                 style: TextStyle(color: C.bg),
//               ),
//             ),
//             Text(
//               "Page $_currentPage",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton(
//               onPressed: _hasMore ? _nextPage : null,
//               style: ElevatedButton.styleFrom(backgroundColor: _primary),
//               child: const Text(
//                 "Next ➡",
//                 style: TextStyle(color: C.bg),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  PRINT LOGIC
//   // ══════════════════════════════════════════════════════════════════════════
//
//   Future<void> _printSingle(CuttingOutstock item) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text("Print Label"),
//         content: Text(
//           "Print barcode ${item.barcode}?",
//           style: const TextStyle(fontSize: 13),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Print"),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     _selectedIndex = _filteredItems.indexOf(item);
//     await _confirmAndPrint();
//   }
//
//   Future<void> _confirmAndPrint() async {
//     if (_selectedIndex == null) return;
//
//     final item = _filteredItems[_selectedIndex!];
//
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text("Confirm Issue"),
//         content: Text(
//           "Are you sure you want to issue barcode?\n\n${item.barcode}",
//           style: const TextStyle(fontSize: 13),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Yes, Issue"),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     _setStatus("⏳ Issuing barcode...");
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Issued Successfully ✅"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//
//     await _onPrint();
//   }
//
//   Future<void> _onPrint() async {
//     if (_selectedIndex == null) return;
//     final item = _filteredItems[_selectedIndex!];
//
//     final address = _storage.read<String>('printer_address');
//     final name = _storage.read<String>('printer_name') ?? 'Printer';
//
//     if (address == null) {
//       _setStatus('❌ Pehle printer connect karein (Bluetooth icon)');
//       return;
//     }
//
//     _setStatus('🔗 Connecting $name...');
//
//     if (Platform.isIOS) {
//       await _iosPrint(address, item);
//     } else {
//       await _androidPrint(address, name, item);
//     }
//   }
//
//   Future<void> _androidPrint(
//       String address,
//       String name,
//       CuttingOutstock item,
//       ) async {
//     bool triggered = false;
//
//     _btSub?.cancel();
//     _btSub = PrinterManager.instance.stateBluetooth.listen((status) async {
//       if (status == BTStatus.connected && !triggered) {
//         triggered = true;
//         _setStatus('✅ Connected. Printing...');
//         await Future.delayed(const Duration(milliseconds: 800));
//         try {
//           await PrinterManager.instance.send(
//             type: PrinterType.bluetooth,
//             bytes: [27, 64],
//           );
//           await Future.delayed(const Duration(milliseconds: 200));
//         } catch (_) {}
//         await _executePrint(item);
//       }
//     });
//
//     try {
//       await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//       await Future.delayed(const Duration(milliseconds: 400));
//     } catch (_) {}
//
//     try {
//       await PrinterManager.instance.connect(
//         type: PrinterType.bluetooth,
//         model: BluetoothPrinterInput(
//           name: name,
//           address: address,
//           isBle: false,
//           autoConnect: false,
//         ),
//       );
//     } catch (e) {
//       _setStatus('❌ Connect error: $e');
//     }
//   }
//
//   Future<void> _iosPrint(String address, CuttingOutstock item) async {
//     try {
//       final ok = await PrintBluetoothThermal.connect(
//         macPrinterAddress: address,
//       );
//       if (!ok) {
//         _setStatus('❌ iOS connect fail');
//         return;
//       }
//       _setStatus('✅ Connected. Printing...');
//       await Future.delayed(const Duration(milliseconds: 500));
//       await _executePrint(item);
//     } catch (e) {
//       _setStatus('❌ iOS error: $e');
//     }
//   }
//
//   Future<void> _executePrint(CuttingOutstock r) async {
//     if (_printing) return;
//     setState(() => _printing = true);
//
//     try {
//       _setStatus('🖨️ Sending label...');
//
//       final String tspl = '''
// SIZE 100 mm,100 mm
// GAP 2 mm,1 mm
// DIRECTION 1
// CLS
//
// REM === LEFT COLUMN ===
// TEXT 20,20,"2",0,2,2,"${r.machine}"
// TEXT 20,80,"2",0,2,2,"GSM:${r.gsm}"
// TEXT 20,140,"2",0,2,2,"Party:${r.partyname}"
// TEXT 20,200,"2",0,2,2,"WO.No:${r.workorderno}"
// TEXT 20,260,"2",0,2,2,"Date:${_formatDate(r.laminationDate.toIso8601String())}"
//
// REM === QR CODE (left, below date) ===
// QRCODE 20,330,L,9,A,0,"${r.barcode}"
//
// REM === BARCODE ID below QR ===
// TEXT 20,560,"2",0,2,2,"${r.barcode}"
//
// REM === RIGHT COLUMN ===
// TEXT 430,20,"2",0,2,2,"SR:${r.srno}"
// TEXT 430,80,"2",0,2,2,"Model:${r.modelno}"
// TEXT 430,140,"2",0,2,2,"Width:${r.fabricwidth}"
// TEXT 430,200,"2",0,2,2,"Color:${r.color}"
// TEXT 430,260,"2",0,2,2,"CutType:${r.cuttype}"
//
// REM === WEIGHTS ===
// TEXT 380,330,"2",0,2,2,"Net Wt(Kg):${r.netwt.toStringAsFixed(2)}"
// TEXT 380,390,"2",0,2,2,"Qty:${r.quantity.toStringAsFixed(2)}"
// TEXT 380,450,"2",0,2,2,"Req Wt:${r.requiredNetWeight.toStringAsFixed(2)}"
// TEXT 380,510,"2",0,2,2,"Req Mtr:${r.requiredQtyMtr.toStringAsFixed(2)}"
//
// REM === OPERATOR ===
// TEXT 380,560,"2",0,2,2,"${r.operatorName}"
//
// REM === FABRIC / DEPT (bottom) ===
// TEXT 20,630,"2",0,2,2,"${r.typeuse}"
// TEXT 600,670,"2",0,2,2,"${r.department}"
//
// PRINT 1
// ''';
//
//       await PrinterManager.instance.send(
//         type: PrinterType.bluetooth,
//         bytes: tspl.codeUnits,
//       );
//
//       _setStatus('✅ Label printed successfully!');
//     } catch (e) {
//       _setStatus('❌ Print error: $e');
//     } finally {
//       setState(() => _printing = false);
//     }
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────────────────
//   void _setStatus(String msg) {
//     debugPrint('[PRINT] $msg');
//     if (mounted) setState(() => _printStatus = msg);
//   }
//
//   String _monthName(int month) {
//     const months = [
//       "Jan", "Feb", "Mar", "Apr", "May", "Jun",
//       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
//     ];
//     return months[month - 1];
//   }
//
//   String _formatDate(String inputDate) {
//     try {
//       final parsed = DateTime.parse(inputDate);
//       return "${parsed.day.toString().padLeft(2, '0')}-"
//           "${_monthName(parsed.month)}-"
//           "${parsed.year}";
//     } catch (e) {
//       try {
//         final parts = inputDate.split(" ");
//         final datePart = parts[0];
//         final d = datePart.split("/");
//         final month = int.parse(d[0]);
//         final day = int.parse(d[1]);
//         final year = int.parse(d[2]);
//         return "${day.toString().padLeft(2, '0')}-"
//             "${_monthName(month)}-"
//             "$year";
//       } catch (_) {
//         return inputDate;
//       }
//     }
//   }
// }
import 'dart:io';
import 'dart:async';

import 'package:IMS/ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roolModelClass.dart';
import 'package:IMS/services/NardanaApis/NardanaApi.dart';
import 'package:IMS/services/visa_apis/visa_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../../Color/Colorclass.dart';
import '../../../Visa/Loom/PrintPreview.dart';
import '../../../services/Bluetooth_services.dart';
import 'NaradanaModelLami.dart';


class LamRollPrintScreennaradan extends StatefulWidget {
  /// Title shown in AppBar — e.g. "Loom Rolls", "Lamination Out"
  final String title;

  /// Pass already-saved rolls if you pre-load them; else start empty
  final List<NewBarcodeNardanaModel> initialRolls;

  const LamRollPrintScreennaradan({
    super.key,
    required this.title,
    this.initialRolls = const [],
  });

  @override
  State<LamRollPrintScreennaradan> createState() => _LamRollPrintScreennaradanState();

  // ── Static helper — call this after a successful save ──────────────────────
  /// Adds a new roll to the list. Works if screen is already open.
  static final _notifier = ValueNotifier<NewBarcodeNardanaModel?>(null);

  static void addRoll(NewBarcodeNardanaModel data) {
    _notifier.value = data;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LamRollPrintScreennaradanState extends State<LamRollPrintScreennaradan> {
  // ── Theme ──
  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Color(0xFF6B7A9F);
  final today =
      "${DateTime.now().year}-"
      "${DateTime.now().month.toString().padLeft(2, '0')}-"
      "${DateTime.now().day.toString().padLeft(2, '0')}";
  int? _selectedIndex;
  List<NewBarcodeNardanaModel> _rolls = [];
  bool isLoading = false;
  // Print state
  final _storage = GetStorage();
  bool _printing = false;
  String _printStatus = '';
  StreamSubscription<BTStatus>? _btSub;

  @override
  void initState() {
    super.initState();
    _rolls.addAll(widget.initialRolls);
    _loadApiData(); //
    // Listen for new rolls added from outside (after save)
    LamRollPrintScreennaradan._notifier.addListener(_onNewRoll);
  }

  @override
  void dispose() {
    LamRollPrintScreennaradan._notifier.removeListener(_onNewRoll);
    _btSub?.cancel();
    super.dispose();
  }

  Future<void> _loadApiData() async {
    setState(() => isLoading = true);

    try {
      final List<NewBarcodeNardanaModel> mapped =
      await NaradanaApiService.getLaminationSavedRolls(
        date: today,
      );

      setState(() {
        _rolls = mapped;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _setStatus("❌ API Error: $e");
    }
  }

  void _onNewRoll() {
    final r = LamRollPrintScreennaradan._notifier.value;
    if (r != null && mounted) {
      setState(() {
        _rolls.insert(0, r); // naya roll top pe
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
                ? const Center(child: CircularProgressIndicator())
                : _rolls.isEmpty
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
      backgroundColor: C.appBar1,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 15, color: C.textHigh),
          ),
        ],
      ),
      actions: [
        // Bluetooth settings
        IconButton(
          icon: const Icon(Icons.bluetooth_rounded, size: 28,color: C.secondaryDark,),
          tooltip: "Printer",
          onPressed: () => Get.to(() => const BluetoothDeviceListScreen()),
        ),
        // Roll count badge
        Container(
          // margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: C.bg.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.layers_rounded, color: C.textHigh, size: 13),
              const SizedBox(width: 4),
              Text(
                "${_rolls.length} Rolls",
                style: const TextStyle(color: C.textHigh, fontSize: 11),
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
            child: CircularProgressIndicator(strokeWidth: 2),
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
        Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey.shade300),
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
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 16,

          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.green.withOpacity(0.2);
              }
              return null;
            },
          ),

          columns: const [
            DataColumn(label: Text("SrNo")),
            DataColumn(label: Text("RollCode")),
            DataColumn(label: Text("Barcode")),
            DataColumn(label: Text("Supervisor")),
            // DataColumn(label: Text("Operator")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Time")),
            DataColumn(label: Text("Party")),
            DataColumn(label: Text("Work Order")),
            DataColumn(label: Text("Container")),
            // DataColumn(label: Text("Req KG")),
            // DataColumn(label: Text("Req MTR")),
            DataColumn(label: Text("Loom No")),
            DataColumn(label: Text("Loom Type")),
            DataColumn(label: Text("Fabric Type")),
            DataColumn(label: Text("Fabric Const")),
            DataColumn(label: Text("Color")),
            DataColumn(label: Text("Width")),
            DataColumn(label: Text("GSM")),
            DataColumn(label: Text("Lamination")),
            DataColumn(label: Text("Cut Type")),
            DataColumn(label: Text("Special ID")),
            // DataColumn(label: Text("Roll WT")),
            // DataColumn(label: Text("Roll MTR")),
            // DataColumn(label: Text("AVG GM")),
            // DataColumn(label: Text("Tare WT")),
            // DataColumn(label: Text("Gross WT")),
            // DataColumn(label: Text("Remark")),
            DataColumn(label: Text("Department")),
            DataColumn(label: Text("Fabric Code")),
            // DataColumn(label: Text("Issue To")),
            // DataColumn(label: Text("Status")),
            // DataColumn(label: Text("InStock")),
            // DataColumn(label: Text("Location")),
            // DataColumn(label: Text("Hold")),
            DataColumn(label: Text("Action")),
          ],

          rows: _rolls.asMap().entries.map((entry) {
            int index = entry.key;
            var r = entry.value;

            return DataRow(
              selected: _selectedIndex == index,

              onSelectChanged: (val) {
                setState(() {
                  _selectedIndex = index;
                });
              },

              color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selectedIndex == index) {
                    return Colors.lightGreen.withOpacity(0.2);
                  }
                  return Colors.transparent;
                },
              ),

              cells: [

                DataCell(Text(r.srNo.toString())),
                DataCell(Text(r.rollCode ?? "")),
                DataCell(Text(r.barcode ?? "")),
                DataCell(Text(r.supervisorName ?? "")),
                // DataCell(Text(r.operatorName ?? "")),
                DataCell(Text(r.date ?? "")),
                DataCell(Text(r.time ?? "")),
                DataCell(Text(r.partyName ?? "")),
                DataCell(Text(r.workOrderNo ?? "")),
                DataCell(Text(r.contNo ?? "")),
                // DataCell(Text(r.requiredQuantityKg ?? "")),
                // DataCell(Text(r.requiredQuantityMtr ?? "")),
                DataCell(Text(r.loomNo ?? "")),
                DataCell(Text(r.loomType ?? "")),
                DataCell(Text(r.fabricType ?? "")),
                DataCell(Text(r.fabricConstruction ?? "")),
                DataCell(Text(r.color ?? "")),
                DataCell(Text(r.fabricWidth ?? "")),
                DataCell(Text(r.gsm ?? "")),
                DataCell(Text(r.laminationType ?? "")),
                DataCell(Text(r.cutType ?? "")),
                DataCell(Text(r.specialIdentification ?? "")),
                // DataCell(Text(r.rollWeightKg ?? "")),
                // DataCell(Text(r.rollLengthMtr ?? "")),
                // DataCell(Text(r.avgWeightGm ?? "")),
                // DataCell(Text(r.tareWeightKg ?? "")),
                // DataCell(Text(r.grossWeightKg ?? "")),
                // DataCell(Text(r.remark ?? "")),
                DataCell(Text(r.department ?? "")),
                DataCell(Text(r.fabricCode ?? "")),
                // DataCell(Text(r.issueToDept ?? "")),
                // DataCell(Text(r.status ?? "")),
                // DataCell(Text(r.inStock ?? "")),
                // DataCell(Text(r.location ?? "")),
                // DataCell(Text(r.hold ?? "")),

                DataCell(
                  ElevatedButton(
                    onPressed: _printing ? null : () => _printSingle(r),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    child: const Text(
                      "Print",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
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

  Widget _typeBadge(String type) {
    final color = type == 'LOOM'
        ? Colors.indigo
        : type == 'LAMINATION'
        ? Colors.teal
        : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Info text
        Expanded(
          child: Text(
            _selectedIndex != null
                ? "Roll #${_rolls[_selectedIndex!].rollCode} selected"
                : "Select",
            style: TextStyle(
              fontSize: 12,
              color: _selectedIndex != null ? _primary : _labelColor,
            ),
          ),
        ),
        // const SizedBox(width: 12),
        // // Print Button
        // SizedBox(
        //   height: 44,
        //   child: ElevatedButton.icon(
        //     // onPressed: (_selectedIndex != null && !_printing) ? _onPrint : null,
        //     onPressed: (_selectedIndex != null && !_printing)
        //         ? _confirmAndPrint
        //         : null,
        //     icon: _printing
        //         ? const SizedBox(
        //             width: 14,
        //             height: 14,
        //             child: CircularProgressIndicator(
        //               strokeWidth: 2,
        //               color: Colors.white,
        //             ),
        //           )
        //         : const Icon(
        //             Icons.print_rounded,
        //             size: 16,
        //             color: Colors.white,
        //           ),
        //     label: Text(
        //       _printing ? "Printing..." : "Print Label",
        //       style: const TextStyle(
        //         fontSize: 13,
        //         fontWeight: FontWeight.w600,
        //         color: Colors.white,
        //       ),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: _primary,
        //       disabledBackgroundColor: _primary.withOpacity(0.4),
        //       elevation: 0,
        //       padding: const EdgeInsets.symmetric(horizontal: 20),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  PRINT LOGIC
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _confirmAndPrint() async {
    if (_selectedIndex == null) return;

    final roll = _rolls[_selectedIndex!];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirm Issue"),
        content: Text(
          "Are you sure you want to issue barcode?\n\n${roll.barcode}",
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

    // 🔥 STEP 2: API CALL
    _setStatus("⏳ Issuing barcode...");

    // final success = await VisaApiService.lamination_issueBarcode(
    //   barcode: roll.barcode,
    //   type: roll.department.toUpperCase(),
    // );

    // if (!success) {
    //   _setStatus("❌ Issue failed");
    //   return;
    // }

    // ✅ STEP 3: Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Issued Successfully ✅"),
        backgroundColor: Colors.green,
      ),
    );

    // 🔥 STEP 4: Print
    // 🔥 STEP 4: SAVE PRINT API
    _setStatus("⏳ Saving print data...");

    final printSaved = await NaradanaApiService.printBarcode(
      barcode: roll.barcode,
      forwardDepartment: "RMD",
      hold: "",
      id: roll.srNo.toString(),
    );

    if (!printSaved) {
      _setStatus("❌ Print API failed");
      return;
    }

// 🔥 STEP 5: Print
    await _onPrint();
  }

  Future<void> _onPrint() async {
    if (_selectedIndex == null) return;
    final roll = _rolls[_selectedIndex!];

    final address = _storage.read<String>('printer_address');
    final name = _storage.read<String>('printer_name') ?? 'Printer';

    if (address == null) {
      _setStatus('❌ Connect with printer first');
      return;
    }

    _setStatus('🔗 Connecting $name...');

    if (Platform.isIOS) {
      await _iosPrint(address, roll);
    } else {
      await _androidPrint(address, name, roll);
    }
  }

  // ── Android ────────────────────────────────────────────────────────────────
  Future<void> _androidPrint(
      String address,
      String name,
      NewBarcodeNardanaModel roll,
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
        await _executePrint(roll);
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
  Future<void> _iosPrint(String address, NewBarcodeNardanaModel roll) async {
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
      await _executePrint(roll);
    } catch (e) {
      _setStatus('❌ iOS error: $e');
    }
  }

  // ── Execute ────────────────────────────────────────────────────────────────
  Future<void> _executePrint(NewBarcodeNardanaModel r) async {
    if (_printing) return;
    setState(() => _printing = true);

    try {
      _setStatus('🖨️ Sending label...');

      // ── TSPL — matches the label in the image exactly ──────────────────
      // Label: 100mm × 100mm
      // Layout (left col + right col split like image):
      //   Left:  Machine, GSM, Party Name, WO No, Date, QR Code
      //   Right: Roll No, Size, Mesh, GW, TR, NET, MTR
      //   Bottom center: Operators, Barcode ID, Fabric Code, Label Type
      //       final String tspl =
      //       '''
      // SIZE 100 mm,100 mm
      // GAP 3 mm,0 mm
      // DIRECTION 1
      // CLS
      //
      // REM === LEFT COLUMN ===
      // TEXT 20,20,"2",0,1,2,"${r.machineLabel}"
      // TEXT 20,65,"2",0,1,2,"GSM:${r.gsm}"
      // TEXT 20,110,"2",0,1,2,"Party Name:${r.partyName}"
      // TEXT 20,155,"2",0,1,2,"WO.No:${r.woNo}"
      // TEXT 20,200,"2",0,1,2,"Date:${r.date}"
      //
      // REM === QR CODE (left, below date) ===
      // QRCODE 20,260,L,7,A,0,"${r.barcodeId}"
      //
      // REM === BARCODE ID below QR ===
      // TEXT 20,490,"2",0,1,1,"${r.barcodeId}"
      //
      // REM === RIGHT COLUMN ===
      // TEXT 430,20,"2",0,1,2,"ROLL NO:${r.rollNo}"
      // TEXT 430,65,"2",0,1,2,"SIZE:${r.size}"
      //
      // REM --- MESH small ---
      // TEXT 430,108,"2",0,1,1,"MESH:${r.mesh}"
      //
      // REM --- GW large/bold ---
      // TEXT 390,140,"2",0,2,2,"GW Wt(Kg):${r.gwKg}"
      //
      // TEXT 390,200,"2",0,1,2,"TR Wt(Kg):${r.trKg}"
      // TEXT 390,245,"2",0,1,2,"NET Wt(Kg):${r.netKg}"
      // TEXT 390,290,"2",0,1,2,"MTR:${r.mtr}"
      //
      // REM === OPERATOR NAME (right side, below MTR) ===
      // TEXT 390,340,"2",0,1,2,"${r.operators}"
      //
      // REM === FABRIC CODE (bottom left, large) ===
      // TEXT 20,540,"2",0,2,2,"${r.fabricCode}"
      //
      // REM === LABEL TYPE (bottom right) ===
      // TEXT 620,575,"2",0,1,1,"${r.labelType}"
      //
      // PRINT 1
      // ''';
      final String tspl =
      '''
SIZE 100 mm,100 mm
GAP 2 mm,1 mm
DIRECTION 1
CLS

REM === LEFT COLUMN ===
TEXT 20,20,"2",0,2,2,"${r.loomNo}"
TEXT 20,80,"2",0,2,2,"GSM:${r.gsm}"
TEXT 20,140,"2",0,2,2,"Party Name:${r.contNo}"

REM === GAP after PartyName (extra space before QR zone) ===
TEXT 20,220,"2",0,2,2,"WO.No:${r.workOrderNo}"
TEXT 20,280,"2",0,2,2,"Date:${r.date}"

REM === QR CODE (left, below date — more gap) ===
QRCODE 20,370,L,9,A,0,"${r.barcode}"

REM === BARCODE ID below QR ===
TEXT 20,590,"2",0,2,2,"${r.barcode}"

REM === RIGHT COLUMN ===
TEXT 430,20,"2",0,2,2,"ROLL NO:${r.rollCode}"
TEXT 430,80,"2",0,2,2,"SIZE:${r.rollLength}"



REM --- GW ---
TEXT 380,340,"2",0,2,2,"GW Wt(Kg):${r.grossWeight}"

REM === TR / NET / MTR ===
TEXT 380,390,"2",0,2,2,"TR Wt(Kg):${r.tareWeight}"
TEXT 380,450,"2",0,2,2,"NET Wt(Kg):${r.avgWeight}"
TEXT 380,510,"2",0,2,2,"MTR:${r.rollWeight}"

REM === OPERATOR NAME ===
TEXT 380,560,"2",0,2,2,"${r.operatorName}"
REM === FABRIC CODE (bottom, font size kam) ===
TEXT 20,650,"2",0,2,2,"${r.fabricCode}"

REM === LABEL TYPE (bilkul bottom-right) ===
TEXT 610,690,"2",0,2,2,"${r.department}"

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
      // Case 1: ISO format (API standard)
      final parsed = DateTime.parse(inputDate);

      return "${parsed.day.toString().padLeft(2, '0')}-"
          "${_monthName(parsed.month)}-"
          "${parsed.year}";
    } catch (e) {
      try {
        // Case 2: Format like "3/30/2026 12:00:00 AM"
        final parts = inputDate.split(" ");
        final datePart = parts[0]; // 3/30/2026

        final d = datePart.split("/");

        final month = int.parse(d[0]);
        final day = int.parse(d[1]);
        final year = int.parse(d[2]);

        return "${day.toString().padLeft(2, '0')}-"
            "${_monthName(month)}-"
            "$year";
      } catch (e) {
        // fallback (safe)
        return inputDate;
      }
    }
  }

  Future<void> _printSingle(NewBarcodeNardanaModel roll) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Print Label"),
        content: Text("Print barcode ${roll.barcode}?"),
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

    _selectedIndex = _rolls.indexOf(roll);

    await _confirmAndPrint(); // reuse your logic
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  LABEL PREVIEW WIDGET  (optional - tap karo kisi card pe preview dekho)
// ══════════════════════════════════════════════════════════════════════════════

// roll_list_print_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reusable screen:
//   1. Saved rolls ki list dikhata hai
//   2. Row select karne pe Print button enable hota hai
//   3. Print tap → BarcodeLabelScreen pe TSPL label print hota hai
//      (exact format: image wali labels jaisi)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:async';

import 'package:IMS/services/visa_apis/visa_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../Color/Colorclass.dart';
import '../../services/Bluetooth_services.dart';
import 'PrintPreview.dart'; // BluetoothDeviceListScreen

class RollLabelData implements BaseRollData {
  final String rollNo;
  final String machineLabel;
  final String gsm;
  final String size;
  final String partyName;
  final String woNo;
  final String date;
  final String mesh;
  final String gwKg;
  final String trKg;
  final String netKg;
  final String mtr;
  final String operators;
  final String barcodeId;
  final String fabricCode;
  final String labelType;

  // ✅ NEW FIELDS
  final String color;
  final String laminationType;
  final String supervisor;

  const RollLabelData({
    required this.rollNo,
    required this.machineLabel,
    required this.gsm,
    required this.size,
    required this.partyName,
    required this.woNo,
    required this.date,
    required this.mesh,
    required this.gwKg,
    required this.trKg,
    required this.netKg,
    required this.mtr,
    required this.operators,
    required this.barcodeId,
    required this.fabricCode,
    required this.labelType,

    // ✅ new
    required this.color,
    required this.laminationType,
    required this.supervisor,
  });

  /// 🔥 Smart factory (API safe + fallback handling)
  factory RollLabelData.fromMap(Map<String, dynamic> m) {
    double gw = double.tryParse(m['gwKg']?.toString() ?? '') ?? 0;
    double net = double.tryParse(m['netKg']?.toString() ?? '') ?? 0;

    return RollLabelData(
      rollNo: m['rollNo']?.toString() ?? '',

      machineLabel: m['machineLabel']?.toString() ??
          "LOOM:${m['loomNo'] ?? ''}",

      gsm: m['gsm']?.toString() ?? '',
      size: m['size']?.toString() ?? m['fabricWidth']?.toString() ?? '',
      partyName: m['partyName']?.toString() ?? '',
      woNo: m['woNo']?.toString() ?? m['workOrderNo']?.toString() ?? '',

      date: m['date']?.toString() ?? '',

      // ✅ mesh fallback
      mesh: (m['mesh']?.toString().isNotEmpty ?? false)
          ? m['mesh'].toString()
          : (m['mash']?.toString() ?? ''),

      gwKg: m['gwKg']?.toString() ??
          m['grossWeight']?.toString() ??
          '0',

      // ✅ auto TR calculation if missing
      trKg: (m['trKg'] != null && m['trKg'].toString().isNotEmpty)
          ? m['trKg'].toString()
          : (gw - net).toStringAsFixed(2),

      netKg: m['netKg']?.toString() ??
          m['netWeight']?.toString() ??
          '0',

      mtr: m['mtr']?.toString() ??
          m['rollLength']?.toString() ??
          '0',

      // ✅ operator fallback
      operators: (m['operators']?.toString().isNotEmpty ?? false)
          ? m['operators'].toString()
          : (m['operator']?.toString() ??
          m['loomOperator1']?.toString() ??
          ''),

      barcodeId: m['barcodeId']?.toString() ??
          m['barcode']?.toString() ??
          '',

      fabricCode: m['fabricCode']?.toString() ??
          m['mesh']?.toString() ??
          '',

      labelType: m['labelType']?.toString() ??
          m['department']?.toString() ??
          'LOOM',

      // ✅ NEW fields mapping
      color: m['color']?.toString() ?? '',
      laminationType: m['laminationType']?.toString() ?? '',
      supervisor: m['supervisor']?.toString() ?? '',
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class RollListPrintScreen extends StatefulWidget {
  /// Title shown in AppBar — e.g. "Loom Rolls", "Lamination Out"
  final String title;

  /// Pass already-saved rolls if you pre-load them; else start empty
  final List<RollLabelData> initialRolls;

  const RollListPrintScreen({
    super.key,
    required this.title,
    this.initialRolls = const [],
  });

  @override
  State<RollListPrintScreen> createState() => _RollListPrintScreenState();

  // ── Static helper — call this after a successful save ──────────────────────
  /// Adds a new roll to the list. Works if screen is already open.
  static final _notifier = ValueNotifier<RollLabelData?>(null);

  static void addRoll(RollLabelData data) {
    _notifier.value = data;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RollListPrintScreenState extends State<RollListPrintScreen> {
  // ── Theme ──
  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Color(0xFF6B7A9F);

  final List<RollLabelData> _rolls = [];
  int? _selectedIndex;
  bool isIssued = false;
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
    RollListPrintScreen._notifier.addListener(_onNewRoll);
  }

  @override
  void dispose() {
    RollListPrintScreen._notifier.removeListener(_onNewRoll);
    _btSub?.cancel();
    super.dispose();
  }

  Future<void> _loadApiData() async {
    try {
      final list = await VisaApiService.getLoomSavedList();

      final mapped = list.map((e) {
        return RollLabelData(
          rollNo: e.rollCode?.toString() ?? '',

          // 👇 MACHINE (loomNo se)
          machineLabel: "LOOM:${e.loomNo ?? ''}",

          gsm: e.gsm ?? '',
          size: e.fabricWidth ?? '',
          partyName: e.partyName ?? '',
          woNo: e.workOrderNo ?? 'N/A',

          // 👇 DATE format fix
          date: _formatDate(e.date ?? ''),

          // ⚠️ IMPORTANT: mesh kabhi empty aa raha hai → fallback use karo
          mesh: (e.mesh != null && e.mesh.toString().isNotEmpty)
              ? e.mesh
              : (e.mesh ?? ''),

          gwKg: e.grossWeight ?? '0',

          // ⚠️ TR API me nahi hai → approx calculate ya blank
          trKg: "0",

          netKg: e.netWeight ?? '0',
          mtr: e.rollLength ?? '0',

          // 👇 operator fallback (2 jagah se aa raha hai)
          operators: (e.operator != null && e.operator!.isNotEmpty)
              ? e.operator!
              : (e.operator  ?? ''),

          barcodeId: e.barcode ?? '',

          // 👇 FABRIC CODE fallback
          fabricCode: (e.fabricCode != null && e.fabricCode!.isNotEmpty)
              ? e.fabricCode!
              : (e.fabricCode  ?? ''),

          labelType: e.loomType ?? 'LOOM',
          color: e.color ?? '',
          laminationType: e.laminationType ?? '',
          supervisor: e.supervisor ?? '',
        );
      }).toList();

      setState(() {

        _rolls.clear();
        _rolls.addAll(mapped);
      });
    } catch (e) {
      _setStatus("❌ API Error: $e");
    }
  }




  void _onNewRoll() {
    final r = RollListPrintScreen._notifier.value;
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
          // Print status bar
          if (_printStatus.isNotEmpty) _statusBar(),

          // List
          Expanded(child: _rolls.isEmpty ? _emptyState() : _buildList()),

          // Bottom bar with Print button
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
        // Roll count badge
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
              const Icon(Icons.layers_rounded, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text(
                "${_rolls.length} Rolls",
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(_primary.withOpacity(0.1)),
          columns: const [
            DataColumn(label: Text("Select")),
            DataColumn(label: Text("Roll No")),
            DataColumn(label: Text("Machine")),
            DataColumn(label: Text("Party")),
            DataColumn(label: Text("GSM")),
            DataColumn(label: Text("Size")),
            DataColumn(label: Text("Mesh")),
            DataColumn(label: Text("Color")),       // ✅ NEW
            DataColumn(label: Text("Lami Type")),   // ✅ NEW
            DataColumn(label: Text("GW")),
            DataColumn(label: Text("Net Wt")),
            DataColumn(label: Text("MTR")),
            DataColumn(label: Text("Operator")),
            DataColumn(label: Text("Supervisor")),  // ✅ NEW
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Barcode")),
          ],
          rows: List.generate(_rolls.length, (index) {
            final r = _rolls[index];
            final selected = _selectedIndex == index;

            return DataRow(
              selected: selected,
              color: MaterialStateProperty.resolveWith<Color?>((states) {
                if (selected) return _primary.withOpacity(0.1);
                return null;
              }),
              onSelectChanged: (_) {
                setState(() {
                  _selectedIndex = index;
                });

                showDialog(
                  context: context,
                  builder: (_) => Dialog(child: RollLabelPreview(data: r)),
                );
              },
              cells: [
                DataCell(Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? _primary : Colors.grey,
                )),

                DataCell(Text(r.rollNo)),
                DataCell(Text(r.machineLabel)),
                DataCell(Text(r.partyName)),
                DataCell(Text(r.gsm)),
                DataCell(Text(r.size)),
                DataCell(Text(r.mesh)),

                DataCell(Text(r.color ?? "")),          // ✅ NEW
                DataCell(Text(r.laminationType ?? "")), // ✅ NEW

                DataCell(Text(r.gwKg)),
                DataCell(Text(r.netKg)),
                DataCell(Text(r.mtr)),

                DataCell(Text(r.operators)),
                DataCell(Text(r.supervisor ?? "")),     // ✅ NEW

                DataCell(Text(r.date)),

                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.barcodeId,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            );
          }),
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
                ? "Roll #${_rolls[_selectedIndex!].rollNo} selected"
                : "Select",
            style: TextStyle(
              fontSize: 12,
              color: _selectedIndex != null ? _primary : _labelColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Print Button
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            // onPressed: (_selectedIndex != null && !_printing) ? _onPrint : null,
            onPressed: (_selectedIndex != null && !_printing)
                ? _confirmAndPrint
                : null,
            icon: _printing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: C.appBar3,
                    ),
                  )
                : const Icon(
                    Icons.print_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
            label: Text(
              _printing ? "Printing..." : "Print / Issue",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withOpacity(0.4),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Confirm Issue"),
        content: Text(
          "Are you sure you want to issue barcode?\n\n${roll.barcodeId}",
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

    final type = roll.labelType.toUpperCase().contains("LAMINATION")
        ? "LAMINATION"
        : "LOOM";

    final success = await VisaApiService.issueBarcode(
      barcode: roll.barcodeId,
      type: type,
    );debugPrint("TYPE SENT: $type");
    debugPrint("BARCODE: ${roll.barcodeId}");

    if (!success) {
      _setStatus("❌ Issue failed");
      return;
    }


    // ✅ STEP 3: Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Issued Successfully ✅"),
        backgroundColor: Colors.green,
      ),
    );

    // 🔥 STEP 4: Print
    await _onPrint();
  }
  Future<void> _onPrint() async {
    if (_selectedIndex == null) return;
    final roll = _rolls[_selectedIndex!];

    final address = _storage.read<String>('printer_address');
    final name = _storage.read<String>('printer_name') ?? 'Printer';

    if (address == null) {
      _setStatus('❌ Printer not connected');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer is not selected or not connected'),
          backgroundColor: Colors.orange,
        ),
      );

      return; // print skip
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
    RollLabelData roll,
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
  Future<void> _iosPrint(String address, RollLabelData roll) async {
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
  Future<void> _executePrint(RollLabelData r) async {
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
TEXT 20,20,"2",0,2,2,"${r.machineLabel}"
TEXT 20,80,"2",0,2,2,"GSM:${r.gsm}"
TEXT 20,140,"2",0,2,2,"Party Name:${r.partyName}"

REM === GAP after PartyName (extra space before QR zone) ===
TEXT 20,220,"2",0,2,2,"WO.No:${r.woNo}"
TEXT 20,280,"2",0,2,2,"Date:${r.date}"

REM === QR CODE (left, below date — more gap) ===
QRCODE 20,370,L,9,A,0,"${r.barcodeId}"

REM === BARCODE ID below QR ===
TEXT 20,590,"2",0,2,2,"${r.barcodeId}"

REM === RIGHT COLUMN ===
TEXT 430,20,"2",0,2,2,"ROLL NO:${r.rollNo}"
TEXT 430,80,"2",0,2,2,"SIZE:${r.size}"


REM --- MESH ---
TEXT 430,230,"2",0,1,2,"MESH:${r.mesh}"
REM --- GW ---
TEXT 380,340,"2",0,2,2,"GW Wt(Kg):${r.gwKg}"

REM === TR / NET / MTR ===
TEXT 380,390,"2",0,2,2,"TR Wt(Kg):${r.trKg}"
TEXT 380,450,"2",0,2,2,"NET Wt(Kg):${r.netKg}"
TEXT 380,510,"2",0,2,2,"MTR:${r.mtr}"

REM === OPERATOR NAME ===
TEXT 380,560,"2",0,2,2,"${r.operators}"
REM === FABRIC CODE (bottom, font size kam) ===
TEXT 20,650,"2",0,2,2,"${r.fabricCode}"

REM === LABEL TYPE (bilkul bottom-right) ===
TEXT 660,690,"2",0,2,2,"${r.labelType}"

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
}

// ══════════════════════════════════════════════════════════════════════════════
//  LABEL PREVIEW WIDGET  (optional - tap karo kisi card pe preview dekho)
// ══════════════════════════════════════════════════════════════════════════════

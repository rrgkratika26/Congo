import 'package:IMS/ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Color/Colorclass.dart';
import '../../../Visa/Loom/PrintBarcode.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../services/visa_apis/visa_api.dart';
import '../../../util/sharedpreference/shared_preference.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/Lamination_OutEntry.dart';


class PrintingRollList extends StatefulWidget {
  const PrintingRollList({super.key});

  @override
  State<PrintingRollList> createState() => _PrintingRollListState();
}

class _PrintingRollListState extends State<PrintingRollList> {
  List<Roll> _rolls = [];
  List<Roll> _filtered = [];

  // ── Checkbox selection state ──────────────────────────────────────────────
  final Set<String> _selectedBarcodes = {};
  bool _selectAll = false;
  bool _isFinishing = false;

  bool _loading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRollList();
  }

  Future<void> loadRollList() async {
    final unit = await AppSession.getUnit();
    setState(() {
      _loading = true;
      _error = null;
      _selectedBarcodes.clear();
      _selectAll = false;
    });
    try {
      final data = await InStockService.getRollList(unit: '$unit');
      setState(() {
        _rolls = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      debugPrint("❌ Error: $e");
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _rolls
          .where(
            (r) =>
        r.barcode.toLowerCase().contains(q) ||
            r.fabricCode.toLowerCase().contains(q) ||
            r.rollCode.toLowerCase().contains(q),
      )
          .toList();

      // Reset select-all state when filter changes
      _selectAll =
          _filtered.isNotEmpty &&
              _filtered.every((r) => _selectedBarcodes.contains(r.barcode));
    });
  }

  void _toggleSelectAll(bool? val) {
    setState(() {
      _selectAll = val ?? false;
      if (_selectAll) {
        for (final r in _filtered) {
          _selectedBarcodes.add(r.barcode);
        }
      } else {
        for (final r in _filtered) {
          _selectedBarcodes.remove(r.barcode);
        }
      }
    });
  }

  void _toggleRow(String barcode, bool? val) {
    setState(() {
      if (val == true) {
        _selectedBarcodes.add(barcode);
      } else {
        _selectedBarcodes.remove(barcode);
      }
      _selectAll =
          _filtered.isNotEmpty &&
              _filtered.every((r) => _selectedBarcodes.contains(r.barcode));
    });
  }

  // ── Finish button pressed ─────────────────────────────────────────────────
  Future<void> _onFinish() async {
    if (_selectedBarcodes.isEmpty || _isFinishing) return;

    setState(() => _isFinishing = true);

    final selectedRolls = _rolls
        .where((r) => _selectedBarcodes.contains(r.barcode))
        .toList();

    final result = await VisaApiService.finishLamination(selectedRolls);

    setState(() => _isFinishing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: result.contains("Successfully")
            ? Colors.green
            : Colors.red,
      ),
    );

    if (result.contains("Successfully")) {
      _selectedBarcodes.clear();

      await loadRollList();

      // wait a moment so the user can see the snackbar
      await Future.delayed(const Duration(milliseconds: 700));

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 600;
    final hasSelection = _selectedBarcodes.isNotEmpty;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,

        title: const Text(
          'Roll List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: C.bgColor),
        actions: [
          // 🔹 Total count
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Total: ${_rolls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 🔹 Filtered count (only when searching)
          if (_searchCtrl.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Found: ${_filtered.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // 🔹 Selected count (your existing)
          if (_selectedBarcodes.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${_selectedBarcodes.length} selected',
                  style: const TextStyle(
                    color: C.bg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: loadRollList,
          ),
        ],
      ),

      // ── Finish FAB ──────────────────────────────────────────────────────
      floatingActionButton: hasSelection
          ? FloatingActionButton.extended(
        onPressed: _isFinishing ? null : _onFinish,
        backgroundColor: hasSelection ? C.primary : Colors.grey,
        icon: _isFinishing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.done_all_rounded,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          _isFinishing
              ? 'Finishing...'
              : 'Finish (${_selectedBarcodes.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      )
          : null,

      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                0,
                isWide ? 24 : 16,
                16,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: const TextStyle(color: C.textBody, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search barcode, fabric, roll code…',
                  hintStyle: TextStyle(
                    color: C.primaryDark.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: C.primaryDark.withOpacity(0.7),
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: C.primary.withOpacity(0.7),
                    ),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearch('');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: C.primary.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filtered.length} of ${_rolls.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: C.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(color: C.primary),
            )
                : _error != null
                ? _ErrorView(error: _error!, onRetry: loadRollList)
                : _filtered.isEmpty
                ? const _EmptyView()
                : _RollTable(
              rolls: _filtered,
              selectedBarcodes: _selectedBarcodes,
              selectAll: _selectAll,
              onToggleSelectAll: _toggleSelectAll,
              onToggleRow: _toggleRow,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: C.brand100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: C.brand600,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No rolls found',
            style: TextStyle(
              color: C.textMid,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term',
            style: TextStyle(color: C.textLow, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Roll Table ───────────────────────────────────────────────────────────────

class _RollTable extends StatelessWidget {
  final List<Roll> rolls;
  final Set<String> selectedBarcodes;
  final bool selectAll;
  final ValueChanged<bool?> onToggleSelectAll;
  final void Function(String barcode, bool? val) onToggleRow;

  const _RollTable({
    required this.rolls,
    required this.selectedBarcodes,
    required this.selectAll,
    required this.onToggleSelectAll,
    required this.onToggleRow,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 👉 horizontal scroll
      child: SizedBox(
        width: 900, // 👉 important: give full table width
        child: Column(
          children: [
            _header(),

            Expanded(
              child: ListView.builder(
                itemCount: rolls.length,
                itemBuilder: (context, index) {
                  final r = rolls[index];
                  final selected = selectedBarcodes.contains(r.barcode);

                  return _row(r, index, selected, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: C.border,
      child: Row(
        children: [
          _cell("✅", 40),
          _cell("RollCode", 80),
          _cell("Barcode", 100),
          _cell("Fabric Code", 160),
          _cell("Gross Wt", 80),
          _cell("Tare", 80),
          _cell("Net Wt", 100),
          _cell("RollLength", 100),
          _cell("AvgWeight", 100),
        ],
      ),
    );
  }

  // ── ROW ──

  Widget _row(Roll r, int index, bool selected, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: C.primary.withOpacity(0.2),
        highlightColor: C.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RollEntryForm(roll: r)),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: selected
                ? C.primary.withOpacity(0.15)
                : index.isEven
                ? Colors.white
                : C.brand50,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: C.primary, width: 1.5) : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  activeColor: C.success,
                  value: selected,
                  onChanged: (val) => onToggleRow(r.barcode, val),
                ),
              ),

              _cell(r.rollCode, 80),
              SizedBox(
                width: 100,
                child: Tooltip(
                  message: selected ? "Tap to open barcode" : "",
                  child: _cell(
                    r.barcode,
                    100,
                    color: selected ? Colors.green : C.textHigh,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              _cell(r.fabricCode, 180),
              _cell("${r.grossWeight}", 80),
              _cell("${r.tareWeight}", 80),
              _cell("${r.netWeight} kg", 90),
              _cell("${r.rollLength} m", 100),
              _cell("${r.avgWeight}", 100),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _row(Roll r, int index, bool selected, BuildContext context) {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => RollEntryForm(roll: r)),
  //       );
  //     },
  //     child: Container(
  //       color: selected
  //           ? C.primary.withOpacity(0.1)
  //           : index.isEven
  //           ? Colors.white
  //           : C.brand50,
  //       padding: const EdgeInsets.symmetric(vertical: 4),
  //       child: Row(
  //         children: [
  //           SizedBox(
  //             width: 40,
  //             child: Checkbox(
  //               activeColor: C.success,
  //               value: selected,
  //               onChanged: (val) => onToggleRow(r.barcode, val),
  //             ),
  //           ),
  //           _cell(r.srNo.toString(), 60),
  //           _cell(r.barcode, 100),
  //           _cell(r.fabricCode, 180),
  //           _cell("${r.grossWeight}", 80),
  //           _cell("${r.tareWeight}", 80),
  //           _cell("${r.netWeight} kg", 90),
  //           _cell("${r.rollLength} m", 100),
  //           _cell("${r.avgWeight}", 100),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ── CELL ──
  Widget _cell(
      String text,
      double width, {
        Color color = C.textHigh,
        FontWeight fontWeight = FontWeight.normal,
      }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          style: TextStyle(fontSize: 15, color: color, fontWeight: fontWeight),
        ),
      ),
    );
  }
}

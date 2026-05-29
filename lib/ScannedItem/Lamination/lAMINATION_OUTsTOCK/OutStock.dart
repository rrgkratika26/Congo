


import 'package:IMS/ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Color/Colorclass.dart';
import '../../../Visa/Loom/PrintBarcode.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../services/visa_apis/visa_api.dart';
import '../../../util/sharedpreference/shared_preference.dart';
import 'Lamination_OutEntry.dart';
import 'Lamination_savedListtRolllist.dart';

class RollListScreen extends StatefulWidget {
  const RollListScreen({super.key});

  @override
  State<RollListScreen> createState() => _RollListScreenState();
}

class _RollListScreenState extends State<RollListScreen> {
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
      _filtered = _rolls.where((r) =>
      r.barcode.toLowerCase().contains(q) ||
          r.fabricCode.toLowerCase().contains(q) ||
          r.rollCode.toLowerCase().contains(q)).toList();

      // Reset select-all state when filter changes
      _selectAll = _filtered.isNotEmpty &&
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
      _selectAll = _filtered.isNotEmpty &&
          _filtered.every((r) => _selectedBarcodes.contains(r.barcode));
    });
  }

  // ── Finish button pressed ─────────────────────────────────────────────────
  Future<void> _onFinish() async {
    final ids = _rolls
        .where((r) => _selectedBarcodes.contains(r.barcode))
        .map((r) => r.id.toString()) // ✅ use numeric id
        .toList();

    final result = await VisaApiService.finishLamination(ids);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green, // ✅ green background
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );


    if (result.contains("SUCCESS")) {
      setState(() => _selectedBarcodes.clear());
      await loadRollList();
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
                    color: Colors.white,
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
              strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.done_all_rounded,
            color: Colors.white, size: 20),
        label: Text(
          _isFinishing
              ? 'Finishing...'
              : 'Finish (${_selectedBarcodes.length})',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      )
          : null,

      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Container(

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
                    color: C.primary.withOpacity(0.6), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: C.primary.withOpacity(0.7)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded,
                      color: C.primary.withOpacity(0.7)),
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
                    vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filtered.length} of ${_rolls.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
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
                :_RollTable(
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
              child: const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: Colors.redAccent, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
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
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: C.brand600),
          ),
          const SizedBox(height: 14),
          const Text('No rolls found',
              style: TextStyle(
                  color: C.textMid,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Try a different search term',
              style: TextStyle(color: C.textLow, fontSize: 12)),
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
                  final selected =
                  selectedBarcodes.contains(r.barcode);

                  return _row(r, index, selected,context);
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
      color: C.primary,
      child: Row(
        children: [
          _cell("", 40),
          _cell("Sr", 60),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RollEntryForm(roll: r),
          ),
        );
      },
      child: Container(
        color: selected
            ? C.primary.withOpacity(0.1)
            : index.isEven
            ? Colors.white
            : C.brand50,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: selected,
                onChanged: (val) => onToggleRow(r.barcode, val),
              ),
            ),
            _cell(r.srNo.toString(), 60),
            _cell(r.barcode, 100),
            _cell(r.fabricCode, 180),
            _cell("${r.grossWeight}", 80),
            _cell("${r.tareWeight}", 80),
            _cell("${r.netWeight} kg", 90),
            _cell("${r.rollLength} m", 100),
            _cell("${r.avgWeight}", 100),
          ],
        ),
      ),
    );
  }

  // ── CELL ──
  Widget _cell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.visible, // ✅ NO CUT TEXT
        ),
      ),
    );
  }
}
// ── Table Header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final bool isWide;
  final bool selectAll;
  final ValueChanged<bool?> onToggleSelectAll;

  const _TableHeader({
    required this.isWide,
    required this.selectAll,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [C.primary, C.headerBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: C.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Select-all checkbox
          SizedBox(
            width: 32,
            child: Checkbox(
              value: selectAll,
              onChanged: onToggleSelectAll,
              activeColor: Colors.white,
              checkColor: C.primary,
              side: const BorderSide(color: Colors.white70, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          _hCell('Sr', flex: 2),
          _hCell('Barcode', flex: 5),
          if (isWide) _hCell('Fabric', flex: 3),
          _hCell('Gross', flex: 2),
          _hCell('Tare', flex: 2),
          _hCell('Net Wt', flex: 5),
          _hCell('Length', flex: 3),
        ],
      ),
    );
  }

  Widget _hCell(String text, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  );
}

// ── Roll Row ─────────────────────────────────────────────────────────────────

class _RollRow extends StatelessWidget {
  final Roll roll;
  final bool isEven;
  final bool isWide;
  final bool isSelected;
  final ValueChanged<bool?> onToggle;

  const _RollRow({
    required this.roll,
    required this.isEven,
    required this.isWide,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap on row → next page
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RollEntryForm(roll: roll),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          // Highlight selected rows
          color: isSelected
              ? C.primary.withOpacity(0.08)
              : isEven
              ? C.cardBg
              : C.brand50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? C.primary.withOpacity(0.4) : C.borderLight,
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: C.brand200.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox — tap doesn't navigate
            SizedBox(
              width: 32,
              child: GestureDetector(
                onTap: () => onToggle(!isSelected),
                behavior: HitTestBehavior.opaque,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onToggle,
                  activeColor: C.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

            // Sr No
            Expanded(
              flex: 2,
              child: Text(
                '${roll.srNo}',
                style: const TextStyle(fontSize: 12, color: C.textMid),
              ),
            ),

            // Barcode
            Expanded(
              flex: 5,
              child: Text(
                roll.barcode,
                style: const TextStyle(
                    fontSize: 11,
                    color: C.teal,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Fabric code (wide only)
            if (isWide)
              Expanded(
                flex: 3,
                child: Text(
                  roll.fabricCode,
                  style: const TextStyle(fontSize: 10, color: C.textMid),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Gross weight
            Expanded(
              flex: 2,
              child: Text(
                '${roll.grossWeight}',
                style: const TextStyle(fontSize: 12, color: C.textMid),
              ),
            ),

            // Tare weight
            Expanded(
              flex: 2,
              child: Text(
                '${roll.tareWeight}',
                style: const TextStyle(fontSize: 12, color: C.textMid),
              ),
            ),

            // Net weight
            Expanded(
              flex: 5,
              child: Text(
                '${roll.netWeight} kg',
                style: const TextStyle(
                    fontSize: 12,
                    color: C.teal,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Length
            Expanded(
              flex: 3,
              child: Text(
                '${roll.rollLength} m',
                style: const TextStyle(fontSize: 12, color: C.teal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../NARDANA/RmdINReports/StockReportsModel.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';

const _primary = Color(0xFF1565C0);

class RmdStockReportScreen extends StatefulWidget {
  const RmdStockReportScreen({super.key});

  @override
  State<RmdStockReportScreen> createState() => _RmdStockReportScreenState();
}

class _RmdStockReportScreenState extends State<RmdStockReportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  List<RmdStockReportModel> _allReports = [];
  bool _isLoading = false;

  String? _selectedParty;
  String? _selectedSupervisor;
  String? _selectedStatus;

  List<RmdStockReportModel> get _filtered {
    return _allReports.where((r) {
      final q = _query.toLowerCase();
      final matchQ =
          q.isEmpty ||
          r.barcode.toLowerCase().contains(q) ||
          r.supervisorName.toLowerCase().contains(q) ||
          r.partyName.toLowerCase().contains(q) ||
          r.fabricCode.toLowerCase().contains(q) ||
          r.batchNo.toLowerCase().contains(q) ||
          r.workOrderNo.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q);

      // final fromDate = _from != null
      //     ? DateTime(_from!.year, _from!.month, _from!.day)
      //     : null;
      // final toDate = _to != null
      //     ? DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59)
      //     : null;

      // final matchFrom = fromDate == null || !r.date.isBefore(fromDate);
      // final matchTo = toDate == null || !r.date.isAfter(toDate);
      final matchP = _selectedParty == null || r.partyName == _selectedParty;
      final matchS =
          _selectedSupervisor == null ||
          r.supervisorName == _selectedSupervisor;
      final matchSt = _selectedStatus == null || r.status == _selectedStatus;

      // return matchQ && matchFrom && matchTo && matchP && matchS && matchSt;
      return matchQ && matchP && matchS && matchSt;
    }).toList();
  }

  List<String> get _parties =>
      _allReports.map((r) => r.partyName).toSet().toList();
  List<String> get _supervisors =>
      _allReports.map((r) => r.supervisorName).toSet().toList();
  List<String> get _statuses =>
      _allReports.map((r) => r.status).toSet().toList();

  double get _totalNet => _filtered.fold(0, (a, r) => a + r.netWeight);
  double get _totalGross => _filtered.fold(0, (a, r) => a + r.grossWeight);
  double get _totalLength => _filtered.fold(0, (a, r) => a + r.rollLength);

  @override
  void initState() {
    super.initState();
    _from = DateTime.now();
    _to = DateTime.now();
    _fetchData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: (_from != null && _to != null)
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await NaradanaApiService().fetchRmdStock(
        // from: _from!,
        // to: _to!,
        1,
        5000,
      );
      setState(() => _allReports = data);
    } catch (e) {
      debugPrint('UI ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clear() {
    setState(() {
      _query = '';
      _searchCtrl.clear();
      _from = DateTime.now();
      _to = DateTime.now();
      _selectedParty = null;
      _selectedSupervisor = null;
      _selectedStatus = null;
    });
    _fetchData();
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yy').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      // ✅ REAL APP BAR
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 1,
        title: const Text(
          'Stock Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.bg,
          ),
        ),
        // actions: [
        //
        //   IconButton(
        //     onPressed: _pickDateRange,
        //     icon: const Icon(
        //       Icons.calendar_today,
        //       size: 22,
        //       color: Colors.white,
        //     ),
        //   ),
        //   IconButton(
        //     onPressed: _clear,
        //     icon: const Icon(Icons.refresh, size: 22, color: Colors.white),
        //   ),
        // ],
        actions: [CountText(count: _filtered.length)],
        iconTheme: IconThemeData(color: C.bg),
      ),

      body: Column(
        children: [

          _summaryBar(),
          _searchBar(),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filtered.isEmpty
              ? Expanded(child: _emptyState())
              : Expanded(
                  child: Column(
                    children: [Expanded(child: _table(_filtered))],
                  ),
                ),
        ],
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _summaryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // _box("Records", "$totalRecords", Colors.blue),
          _box("Roll Weight(Kg)", _totalNet.toStringAsFixed(2), Colors.green),
          _box("Roll Length(mtr)", _totalLength.toStringAsFixed(2), Colors.orange),
        ],
      ),
    );
  }

  Widget _box(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ── Table ────────────FStock ──────────────────────────────────────────────────────

  Widget _table(List<RmdStockReportModel> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10,
              horizontalMargin: 12,
              headingRowHeight: 42,
              dataRowHeight: 38,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
              columns: [
                DataColumn(label: _head('Sr')),
                DataColumn(label: _head('Roll Code')),
                DataColumn(label: _head('Barcode')),
                DataColumn(label: _head('Batch')),
                DataColumn(label: _head('Loom Type')),
                DataColumn(label: _head('Loom No')),

                DataColumn(label: _head('Fabric')),
                DataColumn(label: _head('GSM')),
                DataColumn(label: _head('Gross (kg)')),
                DataColumn(label: _head('Net (kg)')),
                DataColumn(label: _head('Tare (kg)')),
                DataColumn(label: _head('Len (m)')),
                DataColumn(label: _head('Avg Wt')),
                DataColumn(label: _head('Operator')),
                DataColumn(label: _head('Loom Op')),
                DataColumn(label: _head('Supervisor')),
                DataColumn(label: _head('Party Name')),
                DataColumn(label: _head('Work Order')),
                DataColumn(label: _head('Status')),
                DataColumn(label: _head('Date')),
                DataColumn(label: _head('Time')),
              ],
              rows: List.generate(data.length, (i) {
                final r = data[i];
                return DataRow(
                  color: WidgetStateProperty.all(
                    i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                  ),
                  cells: [
                    DataCell(_cell('${r.srNo}', isBold: true)),
                    DataCell(_cell('${r.rollCode}')),
                    DataCell(_cell(r.barcode, mono: true)),
                    DataCell(_cell(r.batchNo)),
                    DataCell(_cell('${r.loomType}')),
                    DataCell(_cell('${r.loomNo}')),

                    DataCell(_cell(r.fabricCode, width: 140)),
                    DataCell(_cell(r.gsm)),
                    DataCell(
                      _cell(
                        r.grossWeight.toStringAsFixed(1),
                        color: Colors.orange.shade700,
                      ),
                    ),
                    DataCell(
                      _cell(
                        r.netWeight.toStringAsFixed(1),
                        color: Colors.green.shade700,
                        isBold: true,
                      ),
                    ),
                    DataCell(
                      _cell(
                        (r.grossWeight - r.netWeight).toStringAsFixed(1),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    DataCell(_cell(r.rollLength.toStringAsFixed(0))),
                    DataCell(
                      _cell(
                        r.avgWeight.toStringAsFixed(1),
                        color: Colors.blue.shade700,
                      ),
                    ),
                    DataCell(_cell(r.operatorName, width: 80)),
                    DataCell(_cell(r.loomOperator1, width: 80)),
                    DataCell(_cell(r.supervisorName, width: 80)),
                    DataCell(_cell(r.partyName, width: 100)),
                    DataCell(_cell(r.workOrderNo, width: 80)),
                    // ✅ FIXED: _statusBadge sirf Container return karta hai
                    // DataCell usse yahan wrap karta hai — double DataCell nahi
                    DataCell(_statusBadge(r.status)),
                    DataCell(_cell(DateFormat('dd-MM-yy').format(r.date))),
                    DataCell(_cell(r.time)),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _emptyState() => const Center(child: Text('No records found'));

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _head(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _primary,
    ),
  );

  Widget _cell(
    String text, {
    double? width,
    bool isBold = false,
    bool mono = false,
    Color? color,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text.isEmpty ? '-' : text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          fontFamily: mono ? 'monospace' : null,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  // ✅ FIXED: DataCell hataya — sirf Container return karta hai
  // _table mein DataCell(_statusBadge(...)) se wrap hoga
  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    final Color bg;
    final Color fg;

    if (s == 'approved') {
      bg = const Color(0xFFE8F5E9);
      fg = Colors.green.shade700;
    } else if (s == 'pending') {
      bg = const Color(0xFFFFF8E1);
      fg = Colors.orange.shade700;
    } else if (s == 'rejected') {
      bg = const Color(0xFFFFEBEE);
      fg = Colors.red.shade700;
    } else {
      bg = const Color(0xFFECEFF1);
      fg = Colors.blueGrey.shade600;
    }

    return Container(
      // ✅ sirf Container, DataCell nahi
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ================= SEARCH BAR METHOD ADD THIS =================
  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search Barcode / Party / Fabric / Batch",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: _primary,
          ),

          suffixIcon: _query.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _query = '';
              });
            },
          )
              : null,

          filled: true,
          fillColor: const Color(0xFFF5F7FA),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: _primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

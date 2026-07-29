import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../util/widget/CountRecords/CountRecords.dart';
import '../modelClass/tapeStockModel.dart';


class TapeStockScreen extends StatefulWidget {
  const TapeStockScreen({super.key});

  @override
  State<TapeStockScreen> createState() => _TapeStockScreenState();
}

class _TapeStockScreenState extends State<TapeStockScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  List<TapeStockReportModel> _allReports = [];
  bool _isLoading = false;

  String? _selectedParty;
  String? _selectedSupervisor;
  String? _selectedStatus;

  List<TapeStockReportModel> get _filtered {
    return _allReports.where((r) {
      final q = _query.toLowerCase();

      return q.isEmpty ||
          r.party.toLowerCase().contains(q) ||
          r.po.toLowerCase().contains(q) ||
          r.articleNo.toLowerCase().contains(q) ||
          r.code.toLowerCase().contains(q) ||
          r.recipeType.toLowerCase().contains(q) ||
          r.tapePlant.toLowerCase().contains(q) ||
          r.supervisor.toLowerCase().contains(q);
    }).toList();
  }

  List<String> get _parties =>
      _allReports.map((r) => r.party).toSet().toList();
  List<String> get _supervisors =>
      _allReports.map((r) => r.supervisor).toSet().toList();
  List<String> get _statuses =>
      _allReports.map((r) => r.tapePlant).toSet().toList();

  double get _totalQty =>
      _filtered.fold(0, (a, b) => a + b.totalQty);

  double get _issueQty =>
      _filtered.fold(0, (a, b) => a + b.issueQty);

  double get _balanceQty =>
      _filtered.fold(0, (a, b) => a + b.balance);

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
      final data = await InStockService.fetchTapeStock(
        page: 1,
        pageSize: 50,
      );

      setState(() {
        _allReports = data;
      });
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

  String _fmt(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      // ✅ REAL APP BAR
      appBar: AppBar(
        backgroundColor: C.appBar1,
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
            child: Column(children: [Expanded(child: _table(_filtered))]),
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
          _box(
            "Total Qty",
            _totalQty.toStringAsFixed(2),
            Colors.blue,
          ),
          _box(
            "Issue Qty",
            _issueQty.toStringAsFixed(2),
            Colors.orange,
          ),
          _box(
            "Balance",
            _balanceQty.toStringAsFixed(2),
            Colors.green,
          ),
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

  Widget _table(List<TapeStockReportModel> data) {
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
              columnSpacing: 12,
              horizontalMargin: 12,
              headingRowColor:
              WidgetStateProperty.all(const Color(0xffEAF2FF)),
              columns: const [

                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Party")),
                DataColumn(label: Text("PO")),
                DataColumn(label: Text("Article")),
                DataColumn(label: Text("Code")),
                DataColumn(label: Text("Recipe")),
                DataColumn(label: Text("Total Qty")),
                DataColumn(label: Text("Issue Qty")),
                DataColumn(label: Text("Balance")),
                DataColumn(label: Text("Denier")),
                DataColumn(label: Text("Width")),
                DataColumn(label: Text("Tape Plant")),
                DataColumn(label: Text("Supervisor")),
              ],

              rows: _filtered.map((r) {

                return DataRow(cells: [

                  DataCell(_cell(r.date)),
                  DataCell(_cell(r.party)),
                  DataCell(_cell(r.po)),
                  DataCell(_cell(r.articleNo)),
                  DataCell(_cell(r.code, width: 180)),
                  DataCell(_cell(r.recipeType)),
                  DataCell(_cell(r.totalQty.toString())),
                  DataCell(_cell(r.issueQty.toString())),
                  DataCell(
                    _cell(
                      r.balance.toString(),
                      color: Colors.green,
                      isBold: true,
                    ),
                  ),
                  DataCell(_cell(r.diner.toString())),
                  DataCell(_cell("${r.widthMM} mm")),
                  DataCell(_cell(r.tapePlant)),
                  DataCell(_cell(r.supervisor)),
                ]);

              }).toList(),
            )
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
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: C.textHigh,
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
          fontSize: 12,
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
          hintText:
          "Search Party / PO / Article / Code / Supervisor",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),

          prefixIcon: const Icon(Icons.search, size: 20, color: C.actionOrange),

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
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.actionOrange, width: 1.2),
          ),
        ),
      ),
    );
  }
}

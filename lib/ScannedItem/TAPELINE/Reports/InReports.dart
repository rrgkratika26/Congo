import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../util/widget/CountRecords/CountRecords.dart';
import '../modelClass/InReportmodel.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class TapeInReports extends StatefulWidget {
  const TapeInReports({super.key});

  @override
  State<TapeInReports> createState() => _TapeInReportsState();
}

class _TapeInReportsState extends State<TapeInReports> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  List<TapelineInReportModel> _allReports = [];
  bool _isLoading = false;

  int currentPage = 1;
  static const int pageSize = 10;

  int get totalPages => (_filtered.length / pageSize).ceil().clamp(1, 99999);
  List<TapelineInReportModel> get _pagedData {
    if (_filtered.isEmpty) {
      return [];
    }

    final start = (currentPage - 1) * pageSize;

    if (start >= _filtered.length) {
      return [];
    }

    final end = (start + pageSize > _filtered.length)
        ? _filtered.length
        : start + pageSize;

    return _filtered.sublist(start, end);
  }
  List<TapelineInReportModel> get _filtered {
    return _allReports.where((r) {
      final q = _query.toLowerCase();

      final matchQ =
          q.isEmpty ||
          r.code.toLowerCase().contains(q) ||
          r.party.toLowerCase().contains(q) ||
          r.supervisor.toLowerCase().contains(q) ||
          r.recipeType.toLowerCase().contains(q) ||
          r.qualityStatus.toLowerCase().contains(q);

      final fromDate = _from != null
          ? DateTime(_from!.year, _from!.month, _from!.day)
          : null;

      final toDate = _to != null
          ? DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59)
          : null;

      final matchFrom = fromDate == null || !r.date.isBefore(fromDate);
      final matchTo = toDate == null || !r.date.isAfter(toDate);

      return matchQ && matchFrom && matchTo;
    }).toList();
  }
  // ====================== USE IN YOUR SCREEN ======================

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.net);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filtered, (e) => e.balanceKg);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);
  // CountText(count: _filtered.length);

  @override
  void initState() {
    super.initState();
    _from = DateTime.now();
    _to = DateTime.now();
    _fetchData();
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

  Future<void> _fetchData({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await InStockService().fetchTapelineInReport(
        from: _from,
        to: _to,
      );

      if (!mounted) return;

      setState(() {
        _allReports = data;
        currentPage = 1;
      });
    } catch (e) {
      debugPrint('Tapeline In API ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load data'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted && showLoader) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // String _fmt(DateTime d) => DateFormat('dd MMM yy').format(d);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text("Tapeline In Reports", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        iconTheme: const IconThemeData(color: C.bg),
      ),
      body: Column(
        children: [
          _topBar(),

          // Small loading indicator.
          // Existing data remains visible while API loads.
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: C.appBar3,
            ),

          Expanded(
            child: _filtered.isEmpty
                ? _isLoading
                ? const Center(
              child: Text(
                'Loading reports...',
                style: TextStyle(
                  color: C.textMid,
                  fontSize: 13,
                ),
              ),
            )
                : _emptyState()
                : Column(
              children: [
                Expanded(
                  child: _table(_pagedData),
                ),

                _paginationBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar (Search + Calendar + Clear) ─────────────────────────────────────

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      color: C.bg,

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(fontSize: 14, color: C.bg),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: C.border),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: 'Search barcode, party, supervisor…',
                    hintStyle: const TextStyle(color: C.brand700, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: C.brand700,
                      size: 20,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: C.textHigh,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _query = '';
                                _searchCtrl.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white12,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: _pickDateRange,
                icon: const Icon(
                  Icons.calendar_today,
                  size: 22,
                  color: C.primary,
                ),
              ),
            ],
          ),

          _summaryBar(),
        ],
      ),
    );
  }

  Widget _summaryBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          _box("Total Records", "$_totalRecords", C.bg),
          _box("Roll Weight(Kg)", _totalNet.toStringAsFixed(2), C.bg),
          _box("Roll Len(mtr)", _totalLength.toStringAsFixed(2), C.bg),
        ],
      ),
    );
  }

  Widget _box(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.primary,
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

  Widget _table(List<TapelineInReportModel> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 2),
      child: Card(
        elevation: 2,
        shadowColor: C.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 14,
              horizontalMargin: 12,
              headingRowHeight: 42,
              dataRowMinHeight: 38,
              headingRowColor: WidgetStateProperty.all(
                C.brand200
              ),

              columns: [
                DataColumn(label: _head("ID")),
                DataColumn(label: _head("Code")),
                DataColumn(label: _head("Party")),
                DataColumn(label: _head("Supervisor")),
                DataColumn(label: _head("Recipe")),
                DataColumn(label: _head("DNR")),
                DataColumn(label: _head("Width")),
                DataColumn(label: _head("Gross")),
                DataColumn(label: _head("Tare")),
                DataColumn(label: _head("Net")),
                DataColumn(label: _head("Balance")),
                DataColumn(label: _head("Quality")),
                DataColumn(label: _head("Plant")),
                DataColumn(label: _head("Date")),
                DataColumn(label: _head("Time")),
              ],

              rows: List.generate(data.length, (i) {
                final r = data[i];

                return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                        return i.isEven
                            ? Colors.white
                            : const Color(0xFFF7F9FC);
                      },
                    ),
                  cells: [
                    DataCell(_cell("${r.id}")),
                    DataCell(_cell(r.code)),
                    DataCell(_cell(r.party)),
                    DataCell(_cell(r.supervisor)),
                    DataCell(_cell(r.recipeType)),
                    DataCell(_cell("${r.dnr}")),
                    DataCell(_cell("${r.widthMM}")),
                    DataCell(_cell(r.gross.toStringAsFixed(2))),
                    DataCell(_cell(r.tare.toStringAsFixed(2))),
                    DataCell(
                      _cell(
                        r.net.toStringAsFixed(2),
                        color: Colors.green,
                        isBold: true,
                      ),
                    ),
                    DataCell(
                      _cell(
                        r.balanceKg.toStringAsFixed(2),
                        color: Colors.blue,
                        isBold: true,
                      ),
                    ),
                    DataCell(_statusBadge(r.qualityStatus)),
                    DataCell(_cell(r.plant)),
                    DataCell(_cell(DateFormat("dd-MM-yyyy").format(r.date))),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _head(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: C.primaryDark,
      ),
    );
  }

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

  /// PAGINATION
  Widget _paginationBar() {
    return Container(
      color: C.bg,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page $currentPage / $totalPages"),
          Row(
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
                child: const Text("Prev"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
                child: const Text("Next", style: TextStyle(color: C.textMid)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

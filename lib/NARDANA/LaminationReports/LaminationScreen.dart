import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'LaminationReports.dart';

class LamInReportScreen extends StatefulWidget {
  const LamInReportScreen({Key? key}) : super(key: key);

  @override
  State<LamInReportScreen> createState() => _LamInReportScreenState();
}

class _LamInReportScreenState extends State<LamInReportScreen> {
  static const int pageSize = 10;
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  List<LaminationReportModel> _allData = [];
  bool _isLoading = false;
  int currentPage = 1;
  int get totalPages => (_filtered.length / pageSize).ceil().clamp(1, 99999);

  bool _isTodaySelected() {
    final now = DateTime.now();

    return _from?.year == now.year &&
        _from?.month == now.month &&
        _from?.day == now.day &&
        _to?.year == now.year &&
        _to?.month == now.month &&
        _to?.day == now.day;
  }

  // ====================== USE IN YOUR SCREEN ======================

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);

  List<LaminationReportModel> get _filtered {
    return _allData.where((r) {
      final q = _query.toLowerCase();

      final matchQ =
          q.isEmpty ||
          r.barcode.toLowerCase().contains(q) ||
          r.batchNo.toLowerCase().contains(q) ||
          r.partyName.toLowerCase().contains(q) ||
          r.operatorName.toLowerCase().contains(q) ||
          r.loomType.toLowerCase().contains(q) ||
          r.supervisorName.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q);

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

  @override
  void initState() {
    super.initState();
    _from = DateTime.now().subtract(const Duration(days: 6));
    _to = DateTime.now();
    _fetchData();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _from ?? DateTime.now().subtract(const Duration(days: 6)),
        end: _to ?? DateTime.now(),
      ),
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
      final data = await NaradanaApiService().fetchLaminationReport(
        from: _from!,
        to: _to!,
      );
      setState(() => _allData = data);
    } catch (e) {
      debugPrint('UI ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Lam IN Reports", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        // C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: C.actionOrange,
                        strokeWidth: 5,
                      ),
                    ),
                  )
                : _filtered.isEmpty
                ? Expanded(child: _emptyState())
                : Expanded(child: _table(_filtered)),

            _paginationBar(),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
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
                  color: C.primaryDark,
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
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Records", "$_totalRecords", C.bg),

          _box("Net Wt(Kg)", _totalNet.toStringAsFixed(2), C.bg),

          _box("Roll Len(Mtr)", _totalLength.toStringAsFixed(2), C.bg),
        ],
      ),
    );
  }

  Widget _box(String title, String value, Color color) {
    return Expanded(
      child: Container(
        // color: C.primaryDark,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.primaryDark,
          // color: color.withOpacity(.08),
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

  // ── Table ──────────────────────────────────────────────────────────────────

  Widget _table(List<LaminationReportModel> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 14,
              horizontalMargin: 12,
              headingRowHeight: 42,
              dataRowHeight: 38,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFEAF2FF),
              ),
              columns: [
                DataColumn(label: _head('Sr')),
                DataColumn(label: _head('RollCode')),
                DataColumn(label: _head('Bom NO')),

                DataColumn(label: _head('Barcode')),

                DataColumn(label: _head('Date')),
                DataColumn(label: _head('Time')),
                DataColumn(label: _head('Batch No')),
                DataColumn(label: _head('Party Name')),
                DataColumn(label: _head('Loom Type')),

                DataColumn(label: _head('Loom No')),
                DataColumn(label: _head('Fabric Code')),
                DataColumn(label: _head('Fab Width')),

                DataColumn(label: _head('Fab.GSM')),
                DataColumn(label: _head('Lam Type')),
                DataColumn(label: _head('Clr')),
                DataColumn(label: _head('Mash')),
                DataColumn(label: _head('Gross Wt(kg)')),
                DataColumn(label: _head('Net Wt(Kg)')),
                DataColumn(label: _head('Tare Wt')),
                DataColumn(label: _head('Roll Len')),
                DataColumn(label: _head('Avg Wt(gm)')),
                DataColumn(label: _head('Operator')),
                DataColumn(label: _head('Loom Op1')),
                DataColumn(label: _head('Supervisor')),
                DataColumn(label: _head('WO')),
                DataColumn(label: _head('Cont No')),
                DataColumn(label: _head('Req Qty(Kg)')),
                DataColumn(label: _head('Req Qty(Mtr)')),
                DataColumn(label: _head('Dept')),
                DataColumn(label: _head('Issue To Dept')),
                DataColumn(label: _head('Entry In')),
                DataColumn(label: _head('Entry Out')),
                DataColumn(label: _head('Fab Type/Use')),
                DataColumn(label: _head('Spec Id')),
                DataColumn(label: _head('FAb Type/Baffale')),
                DataColumn(label: _head('Cut type')),

                DataColumn(label: _head('Status')),
              ],
              rows: List.generate(data.length, (i) {
                final r = data[i];
                return DataRow(
                  color: MaterialStateProperty.all(
                    i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                  ),
                  cells: [
                    DataCell(_cell(r.id, isBold: true)),
                    DataCell(_cell(r.rollCode, isBold: true)),

                    DataCell(_cell(r.bomNo, isBold: true)),
                    DataCell(_cell(r.barcode, mono: true)),
                    DataCell(_cell(DateFormat('dd-MM-yy').format(r.date))),
                    DataCell(_cell(r.time)),

                    DataCell(_cell(r.batchNo)),
                    DataCell(_cell(r.partyName, width: 120)),
                    DataCell(_cell('${r.loomType}')),
                    DataCell(_cell('${r.loomNo}')),

                    DataCell(_cell(r.fabricCode, width: 170)),
                    DataCell(_cell(r.fabricWidth)),

                    DataCell(_cell(r.fabricGsm.toStringAsFixed(2))),
                    DataCell(_cell(r.laminationType)),
                    DataCell(_cell(r.color)),
                    DataCell(_cell(r.mash)),
                    DataCell(_cell(r.grossWeight.toStringAsFixed(1))),
                    DataCell(
                      _cell(
                        r.netWeight.toStringAsFixed(1),
                        color: Colors.green.shade700,
                        isBold: true,
                      ),
                    ),
                    DataCell(_cell(r.tareWeight.toStringAsFixed(1))),
                    DataCell(_cell(r.rollLength.toStringAsFixed(0))),
                    DataCell(_cell(r.avgWeight.toStringAsFixed(1))),
                    DataCell(_cell(r.operatorName)),
                    DataCell(_cell(r.loomOperator1)),
                    DataCell(_cell(r.supervisorName)),
                    DataCell(_cell(r.workOrderNo)),
                    DataCell(_cell(r.contNo)),
                    DataCell(_cell(r.requiredQuantity.toStringAsFixed(2))),
                    DataCell(_cell(r.requiredQuantityMtr.toStringAsFixed(2))),
                    DataCell(_cell(r.department)),
                    DataCell(_cell(r.issueToDept)),
                    DataCell(_cell(r.entryIn)),
                    DataCell(_cell(r.entryOut)),
                    DataCell(_statusBadge(r.status)),
                    DataCell(_statusBadge(r.fabricType)),
                    DataCell(_statusBadge(r.fabricType)),

                    DataCell(_statusBadge(r.specialIdentification)),

                    DataCell(_statusBadge(r.cutSlipType)),
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

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isTodaySelected()
              ? "Today's data is not available"
              : "No data found",
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickDateRange,
          child: const Text(
            "Select Date Range",
            style: TextStyle(color: C.textHigh),
          ),
        ),
      ],
    ),
  );

  // ── Status Badge ───────────────────────────────────────────────────────────

  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    final Color bg;
    final Color fg;

    if (s == 'receive') {
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _head(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1565C0),
    ),
  );

  Widget _cell(
    String text, {
    double? width,
    bool isBold = false,
    bool mono = false,
    Color? color,
  }) => SizedBox(
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

  /// PAGINATION
  Widget _paginationBar() {
    return Container(
      color: Colors.white,
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
                child: const Text("Next", style: TextStyle(color: C.textHigh)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

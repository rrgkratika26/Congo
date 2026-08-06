import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'RmdOutReportModel.dart';

const _primary = Color(0xFF1565C0);

class RmdOutReportScreen extends StatefulWidget {
  const RmdOutReportScreen({super.key});

  @override
  State<RmdOutReportScreen> createState() => _RmdOutReportScreenState();
}

class _RmdOutReportScreenState extends State<RmdOutReportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  List<RmdOutReport> _all = [];
  bool _loading = false;
  int currentPage = 1;
  static const int pageSize = 10;

  int get totalPages => (_filtered.length / pageSize).ceil().clamp(1, 99999);

  // ====================== USE IN YOUR SCREEN ======================

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);

  List<RmdOutReport> get _filtered {
    return _all.where((r) {
      final q = _query.toLowerCase();

      return q.isEmpty ||
          r.barcode.toLowerCase().contains(q) ||
          r.partyName.toLowerCase().contains(q) ||
          r.fabricCode.toLowerCase().contains(q) ||
          r.supervisorName.toLowerCase().contains(q) ||
          r.batchNo.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await NaradanaApiService().fetchRmdOutReport(
        from: _from,
        to: _to,
      );
      setState(() => _all = data);
    } catch (e) {
      debugPrint('UI ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RMD Out Reports", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        // C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _loading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: C.appBar3),
                    ),
                  )
                : _filtered.isEmpty
                ? Expanded(child: _emptyState())
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _table(_filtered)),

                        _paginationBar(),
                      ],
                    ),
                  ),
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

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _summaryBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Total Records", '$_totalRecords', C.bg),
          _box("Roll Wt(Kg)", _totalNet.toStringAsFixed(2), C.bg),
          _box("Roll Len(mtr)", _totalLength.toStringAsFixed(2), C.bg),
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
                child: const Text("Next", style: TextStyle(color: C.textMid)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Table ──────────────────────────────────────────────────────────────────
  Widget _table(List<RmdOutReport> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 8, // 🔥 reduced
              horizontalMargin: 8, // 🔥 reduced
              headingRowHeight: 36,
              dataRowMinHeight: 34,
              dataRowMaxHeight: 36,
              dividerThickness: 0.3,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF1F5FB),
              ),

              columns: [
                _col('Sr'),
                _col('RollCode'),
                _col('Barcode'),

                // _col('Batch No'),
                // _col('Loom Type'),
                // _col('Loom No'),
                _col('Fabric code'),
                _col('Fab Width'),
                _col('Fab GSM'),

                // _col('Clr'),
                _col('Gross Wt(Kg)'),
                _col('NetWt(Kg)'),
                _col('TareWt'),
                // _col('Roll Len'),
                _col('AvgWt'),

                _col('Operator'),
                // _col('Loom Op1'),
                _col('Supervisor'),
                // _col('Issue dept'),        // ✅ NEW
                _col('Party name'),
                _col('PO No'),
                _col('Department'),        // ✅ NEW

                // _col('ReqQty Kg'),         // ✅ NEW
                // _col('ReqQty Mtr'),        // ✅ NEW

                // _col('Dept'),
                // _col('Issue To Dept.'),
                _col('Status'),

                // _col('In'),
                // _col('Out'),

                // _col('Mash'),
                // _col('Lam Type'),
                // _col('Fab Type/Use'),       // ✅ NEW
                // _col('Sp.Id'),         // ✅ NEW
                // _col('Fab Type/baffle'),            // ✅ NEW
                // _col('Cut type'),           // ✅ NEW
                _col('Date'),
                _col('Time'),
              ],

              rows: List.generate(data.length, (i) {
                final r = data[i];

                return DataRow(
                  color: MaterialStateProperty.all(
                    i.isEven ? Colors.white : const Color(0xFFF9FBFF),
                  ),
                  cells: [
                    DataCell(_cell('${r.srNo}', bold: true)),
                    DataCell(_cell('${r.rollCode}', bold: true)),
                    DataCell(_cell(r.barcode, mono: true, w: 70)),
                    // DataCell(_cell(r.batchNo, w: 90)),
                    // DataCell(_cell('${r.loomType}', w: 35)),
                    // DataCell(_cell('${r.loomNo}', w: 35)),
                    DataCell(_cell(r.fabricCode, w: 175)),
                    DataCell(_cell(r.fabricWidth, w: 45)),
                    DataCell(_cell(r.fabricGsm, w: 55)),

                    // DataCell(_cell(r.color, w: 45)),
                    DataCell(_cell(r.grossWeight.toString(), w: 55)),

                    DataCell(
                      _cell(
                        r.netWeight.toString(),
                        color: Colors.green.shade700,
                        bold: true,
                        w: 55,
                      ),
                    ),
                    DataCell(_cell(r.tareWeight.toString(), w: 50)),
                    // DataCell(_cell(r.rollLength.toString(), w: 65)),
                    DataCell(_cell(r.avgWeight.toString(), w: 55)),
                    DataCell(_cell(r.operatorName, w: 90)),
                    // DataCell(_cell(r.loomOperator, w: 90)),
                    DataCell(_cell(r.supervisorName, w: 100)),
                    // DataCell(_cell(r.rmdSupervisor, w: 100)),   // ✅ NEW
                    DataCell(_cell(r.partyName, w: 80)),
                    DataCell(_cell(r.workOrderNo, w: 60)),

                    DataCell(_cell('${r.rmdSupervisor}', w: 80)),      // ✅ NEW
                    // DataCell(_cell(r.reqQtyKg.toString(), w: 80)),   // ✅ NEW
                    // DataCell(_cell(r.reqQtyMtr.toString(), w: 80)),  // ✅ NEW

                    // DataCell(_cell(r.department, w: 70)),
                    // DataCell(_cell(r.issueToDept, w: 70)),
                    DataCell(_statusBadge(r.status),),

                    // DataCell(_cell(r.entryIn, w: 40)),
                    // DataCell(_cell(r.entryOut, w: 45)),

                    // DataCell(_cell(r.mash, w: 55)),
                    // DataCell(_cell(r.laminationType, w: 45)),

                    // DataCell(_cell(r.fabricType, w: 60)),          // ✅ NEW
                    // DataCell(_cell(r.fabricConstruction, w: 60)),  // ✅ NEW
                    // DataCell(_cell(r.cutType, w: 60)),             // ✅ NEW
                    // DataCell(_cell(r.specialId, w: 50)),           // ✅ NEW
                    DataCell(
                      _cell(DateFormat('dd-MM-yyyy').format(r.date), w: 70),
                    ),
                    DataCell(_cell(r.time, w: 70)),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String text) {
    return DataColumn(
      label: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }

  // ── Status Badge ───────────────────────────────────────────────────────────
  Widget _cell(
    String text, {
    double? w,
    bool bold = false,
    bool mono = false,
    Color? color,
  }) {
    return SizedBox(
      width: w,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          fontFamily: mono ? 'monospace' : null,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

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

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _emptyState() => const Center(child: Text('No records found'));
}

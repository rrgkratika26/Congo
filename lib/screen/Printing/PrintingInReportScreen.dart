import 'dart:ffi';

import 'package:IMS/services/Visa_SmallbagAPIS/VISA_SApis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'ModelClass/InReportModelClass.dart';
import 'ModelClass/PrintOutReport.dart';


// ── Screen ───────────────────────────────────────────────────────────────────

class PrintingInReportScreen extends StatefulWidget {
  const PrintingInReportScreen({super.key});

  @override
  State<PrintingInReportScreen> createState() => _PrintingInReportScreenState();
}

class _PrintingInReportScreenState extends State<PrintingInReportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final now = DateTime.now();

  late DateTime _to = now;
  late DateTime _from = now.subtract(const Duration(days: 5));
  List<PrintingInReportData> _allReports = [];
  bool _isLoading = false;
String unitName ='';
  int currentPage = 1;
  static const int pageSize = 10;

  int get totalPages => (_filtered.length / pageSize).ceil().clamp(1, 99999);
  List<PrintingInReportData> get _pagedData {
    final start = (currentPage - 1) * pageSize;
    var end = start + pageSize;

    if (end > _filtered.length) {
      end = _filtered.length;
    }

    return _filtered.sublist(start, end);
  }
  List<PrintingInReportData> get _filtered {
    return _allReports.where((r) {
      final q = _query.toLowerCase();

      final matchQ =
          q.isEmpty ||
              r.barcode.toLowerCase().contains(q) ||
              r.supervisor.toLowerCase().contains(q) ||
              r.partyName.toLowerCase().contains(q) ||
              r.fabricCode.toLowerCase().contains(q) ||
              r.status.toLowerCase().contains(q);

      final fromDate = DateTime(_from.year, _from.month, _from.day);

      final toDate = DateTime(_to.year, _to.month, _to.day, 23, 59, 59);

      final reportDate = r.date;

      final matchFrom =
          (reportDate != null && !reportDate.isBefore(fromDate));

      final matchTo =
          (reportDate != null && !reportDate.isAfter(toDate));

      return matchQ && matchFrom && matchTo;
    }).toList();
  }
  // ====================== USE IN YOUR SCREEN ======================

  // double get _totalNet =>
  //     ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);
  //
  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);
  // CountText(count: _filtered.length);

  @override
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _to = now;
    _from = now.subtract(const Duration(days: 5));

    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    unitName = prefs.getString('unit') ?? 'UNIT';

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

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final response = await VisaSmallBagApiService().fetchPrintingInReport(
        unit: unitName,
        fromDate: _from!,
        toDate: _to!,
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      setState(() {
        _allReports = response.data;
      });
    } catch (e) {
      debugPrint('UI ERROR: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load data')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text("Printing In Reports", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        // C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: Column(
        children: [
          _topBar(),

          _isLoading
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
                Expanded(child: _table(_pagedData)),

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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      color: C.bg,

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    setState(() {
                      _query = v;
                      currentPage = 1;
                    });
                  },
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
          _box("Total Records", "$_totalRecords", C.bg),
          // _box("Roll Weight(Kg)", _totalNet.toStringAsFixed(2), C.bg),
          // _box("Roll Len(mtr)", _totalLength.toStringAsFixed(2), C.bg),
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

  Widget _table(List<PrintingInReportData> data) {
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
                DataColumn(label: _head('Roll Code')),
                DataColumn(label: _head('Barcode')),
                DataColumn(label: _head('Fabric Code')),
                DataColumn(label: _head('Fab width')),
                DataColumn(label: _head('GSM mtr/gm')),
                DataColumn(label: _head('Net Wt(Kg)')),
                // DataColumn(label: _head('Avg Wt(gm)')),
                DataColumn(label: _head('Party name')),
                // DataColumn(label: _head('PO No.')),
                // DataColumn(label: _head('Date')),
                DataColumn(label: _head('Time')),







                // DataColumn(label: _head('Loom Type')),
                // DataColumn(label: _head('Loom No')),
                // DataColumn(label: _head('Roll Len(mtr)')),
                // DataColumn(label: _head('Cont No.')),
                // DataColumn(label: _head('Issue to Dept')),
                // DataColumn(label: _head('Status')),
                // DataColumn(label: _head('Entry In')),
                // DataColumn(label: _head('Entry Out')),
                // DataColumn(label: _head('Mash')),






                // DataColumn(label: _head('Batch')),

                // DataColumn(label: _head('Clr')),
                // DataColumn(label: _head('Gross Wt(Kg)')),
                // DataColumn(label: _head('Tare')),

                // DataColumn(label: _head('Op Name')),
                // DataColumn(label: _head('Loom Op1')),
                // DataColumn(label: _head('Supervisor Name')),
                // DataColumn(label: _head('Req.Qty(Kg)')),
                // DataColumn(label: _head('Req.Qty(Mtr)')),

                // DataColumn(label: _head('Dept')),

                // DataColumn(label: _head('Fab Type/use')),

                // DataColumn(label: _head('Lam Type')),
                // DataColumn(label: _head('Cut Type')),
                // DataColumn(label: _head('Sp Id')),
                // DataColumn(label: _head('Fab Type/Baffle')),

                // DataColumn(label: _head('From')),

              ],

              rows: List.generate(data.length, (i) {
                final r = data[i];

                return DataRow(
                  color: MaterialStateProperty.all(
                    i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                  ),
                  cells: [
                    DataCell(_cell('${r.srNo}', isBold: true)),
                    DataCell(_cell('${r.rollCode}', isBold: true)),
                    DataCell(_cell(r.barcode, mono: true)),
                    DataCell(_cell(r.fabricCode, width: 150)),
                    DataCell(_cell('${r.fabricWidth}')),
                    DataCell(_cell('${r.fabricGsm}')),





                    // DataCell(_cell(r.batchNo)),
                    // DataCell(_cell('${r.loomType}')),
                    // DataCell(_cell('${r.loomNo}')),
                    DataCell(
                      _cell(
                        r.netWeight.toStringAsFixed(2),
                        color: Colors.green.shade700,
                        isBold: true,
                      ),
                    ),
                    // DataCell(_cell(r.)),
                    DataCell(_cell(r.partyName)),
                    // DataCell(_cell(r.workOrderNo)),
                    // DataCell(_cell(DateFormat('dd-MM-yyyy').format(r.date))),
                    DataCell(_cell(r.time)),


                    // DataCell(_cell(r.color)),

                    // DataCell(_cell(r.grossWeight.toStringAsFixed(1))),



                    // DataCell(_cell(r.tareWeight.toStringAsFixed(1))),


                    // DataCell(_cell(r.issueToDept)),
                    // DataCell(_cell('${r.contNo}')),
                    // DataCell(_cell(r.rollLength.toStringAsFixed(0))),
                    //
                    // DataCell(_statusBadge(r.status)),
                    //
                    // DataCell(_cell(r.entryIn)),
                    // DataCell(_cell(r.entryOut)),
                    //
                    // DataCell(_cell(r.mash)),






                    // DataCell(_cell(r.operatorName)),
                    // DataCell(_cell(r.loomOperator)),

                    // DataCell(_cell(r.supervisorName)),

                    // DataCell(_cell('${r.reqQtKg}')),
                    // DataCell(_cell('${r.reqQtMtr}')),

                    // DataCell(_cell(r.department)),



                    // DataCell(_cell(r.fabTypeuse)),

                    // DataCell(_cell(r.spId)),
                    // DataCell(_cell(r.laminationType)),
                    // DataCell(_cell(r.fabTypeBaffle)),
                    // DataCell(_cell(r.cutType)),

                    // DataCell(_cell(r.fromRoll)),

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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1565C0),
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
}


import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'LoomReportModelClass.dart';
import 'ManualPlanningModel.dart';

class ManualPlanningReports extends StatefulWidget {
  const ManualPlanningReports({super.key});

  @override
  State<ManualPlanningReports> createState() => _ManualPlanningReportsState();
}

class _ManualPlanningReportsState extends State<ManualPlanningReports> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  String _unit = AppGlobals.unit;
  List<ManualPlanningModel> _allReports = [];
  bool _isLoading = false;

  List<ManualPlanningModel> get _filtered => _allReports.where((r) {
    final q = _query.toLowerCase();
    final matchQ =
        q.isEmpty ||
        r.bomNo.toLowerCase().contains(q) ||
        r.customerName.toLowerCase().contains(q) ||
        r.fabricCode.toLowerCase().contains(q) ||
        r.poNum.toLowerCase().contains(q);

    // final matchFrom = fromDate == null || !r.cr.isBefore(fromDate);
    // final matchTo = toDate == null || !r.date.isAfter(toDate);
    return matchQ;
  }).toList();

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);

  double get totalRequiredKg =>
      _filtered.fold(0.0, (sum, e) => sum + e.requiredKg);

  double get totalRequiredMtr =>
      _filtered.fold(0.0, (sum, e) => sum + e.requiredMtr);
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _from = DateTime(now.year, now.month, now.day); // 00:00
    _to = DateTime(now.year, now.month, now.day, 23, 59, 59); // end of day

    _fetchData();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,

      // ✅ Allow wide range (almost any date)
      firstDate: DateTime(1900),
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
      final data = await InStockService().fetchManualPlanning(
        from: _from,
        to: _to,
        unit: _unit,
      );

      setState(() {
        _allReports = data;
      });
    } catch (e) {
      debugPrint("UI ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load data")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clear() {
    final now = DateTime.now();

    setState(() {
      _query = '';
      _searchCtrl.clear();

      _from = DateTime(now.year, now.month, now.day);
      _to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });

    _fetchData(); // 🔥 IMPORTANT
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yy').format(d);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Loom Report',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.calendar_today, color: Colors.white),
        //     onPressed: _pickDateRange,
        //   ),
        //   if (_from != null || _to != null || _query.isNotEmpty)
        //     IconButton(
        //       icon: const Icon(Icons.close, size: 20),
        //       onPressed: _clear,
        //       tooltip: 'Clear',
        //     ),
        //   const SizedBox(width: 4),
        // ],
        actions: [
          /// SIMPLE TEXT COUNT
          CountText(count: _filtered.length),

          IconButton(
            icon: const Icon(Icons.calendar_today, color: C.bg, size: 18),
            onPressed: _pickDateRange,
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search barcode, operator, fabric…',
                hintStyle: const TextStyle(color: C.bg, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: C.bg, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 18,
                        ),
                        onPressed: () => setState(() {
                          _query = '';
                          _searchCtrl.clear();
                        }),
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
        ),
      ),
      body: (!_isLoading && _filtered.isEmpty)
          ? _emptyState()
          : Column(
              children: [
                _summaryBar(),

                Expanded(child: _table(_filtered)),
              ],
            ),
    );
  }

  // ── Paginated Table ────────────────────────────────────────────────────────

  Widget _table(List<ManualPlanningModel> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Theme(
        data: Theme.of(context).copyWith(
          dataTableTheme: DataTableThemeData(
            headingRowColor: WidgetStateProperty.all(C.cardOrange),
            headingTextStyle: const TextStyle(
              color: C.textHigh,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF333333),
            ),
          ),
        ),
        child: PaginatedDataTable(
          rowsPerPage: 10,
          availableRowsPerPage: const [6, 10, 20],
          columnSpacing: 16,
          horizontalMargin: 14,
          columns: const [
            DataColumn(label: Text("Sr")),
            DataColumn(label: Text("Order No")),
            DataColumn(label: Text("BOM No")),
            DataColumn(label: Text("Customer")),
            DataColumn(label: Text("PO No")),
            DataColumn(label: Text("Fabric Code")),
            DataColumn(label: Text("Req Mtr")),
            DataColumn(label: Text("Req Kg")),
            DataColumn(label: Text("Extra Mtr")),
            DataColumn(label: Text("Extra Kg")),
            DataColumn(label: Text("Actual Mtr")),
            DataColumn(label: Text("Actual Kg")),
            DataColumn(label: Text("Created")),
            DataColumn(label: Text("Forward By")),
          ],
          source: _LoomDataSource(data),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.tab_unselected_sharp, color: C.textHigh),
          label: const Text(
            'Select First Date range ',
            style: TextStyle(color: C.textHigh),
          ),
        ),
      ],
    ),
  );

  Widget _summaryBar() {
    return Container(
      color: C.bg,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Records", '$_totalRecords', C.bg),

          _box("Req. Kg", totalRequiredKg.toStringAsFixed(2), C.bg),
          _box("Req. Mtr", totalRequiredMtr.toStringAsFixed(2), C.bg),
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
}

// ── Data Source ───────────────────────────────────────────────────────────────

class _LoomDataSource extends DataTableSource {
  final List<ManualPlanningModel> _data;
  _LoomDataSource(this._data);

  @override
  DataRow getRow(int i) {
    final r = _data[i];
    // final isLohia = r.loomType.startsWith('LOHIA');

    return DataRow(
      cells: [
        DataCell(Text("${r.sr}")),
        DataCell(Text("${r.orderNo}")),
        DataCell(Text(r.bomNo)),
        DataCell(Text(r.customerName)),
        DataCell(Text(r.poNum)),

        DataCell(SizedBox(width: 180, child: Text(r.fabricCode))),

        DataCell(Text("${r.requiredMtr}")),
        DataCell(Text("${r.requiredKg}")),
        DataCell(Text("${r.extraMtr}")),
        DataCell(Text("${r.extraKg}")),
        DataCell(Text("${r.actualRequiredMtr}")),
        DataCell(Text("${r.actualRequiredKg}")),
        DataCell(Text(r.createDate)),
        DataCell(Text(r.forwardBy)),
      ],
    );
  }

  Widget _badge(String type, bool isLohia) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: isLohia ? const Color(0xFFF3E5F5) : const Color(0xFFE3F2FD),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      type,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: isLohia ? Colors.purple.shade700 : Colors.blue.shade700,
      ),
    ),
  );

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}

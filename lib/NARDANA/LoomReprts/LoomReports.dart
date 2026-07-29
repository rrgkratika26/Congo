import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'LoomReportModelClass.dart';


class LoomReportScreen extends StatefulWidget {
  const LoomReportScreen({super.key});

  @override
  State<LoomReportScreen> createState() => _LoomReportScreenState();
}

class _LoomReportScreenState extends State<LoomReportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  List<LoomReport> _allReports = [];
  bool _isLoading = false;

  List<LoomReport> get _filtered => _allReports.where((r) {
    final q = _query.toLowerCase();
    final matchQ =
        q.isEmpty ||
        r.barcode.toLowerCase().contains(q) ||
        r.operatorName.toLowerCase().contains(q) ||
        r.fabricCode.toLowerCase().contains(q);
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

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);

  double get _totalNetWeight =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  // double get _totalNetWeight {
  //   return _filtered.fold(0.0, (sum, item) => sum + (item.netWeight ?? 0));
  // }

  double get _totalRollLength {
    return _filtered.fold(0.0, (sum, item) => sum + (item.rollLength ?? 0));
  }
  @override
  void initState() {
    super.initState();



    _to = DateTime.now();
    _from = _to!.subtract(const Duration(days: 6)); // Last 7 days (today included)

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
      final data = await NaradanaApiService().fetchLoomData(
        from: _from,
        to: _to,
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
      _to   = DateTime(now.year, now.month, now.day, 23, 59, 59);
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
            icon: const Icon(Icons.calendar_today, color: C.bg,size: 18,),
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
                prefixIcon: const Icon(
                  Icons.search,
                  color: C.bg,
                  size: 20,
                ),
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
      body:  (!_isLoading && _filtered.isEmpty)
          ? _emptyState()
          : Column(children: [

            _summaryBar(),

            Expanded(child: _table(_filtered))]),
    );
  }

  // ── Paginated Table ────────────────────────────────────────────────────────

  Widget _table(List<LoomReport> data) {
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
            DataColumn(label: Text('Sr')),
            DataColumn(label: Text('Roll Code')),
            DataColumn(label: Text('Barcode')),

            DataColumn(label: Text('Bom No')),
            DataColumn(label: Text('Batch No')),
            // DataColumn(label: Text('Loom Type')),
            // DataColumn(label: Text('Loom No')),
            DataColumn(label: Text('Fabric Code')),
            DataColumn(label: Text('Gross Wt(kg)'), numeric: true),
            DataColumn(label: Text('Net Wt(kg)'), numeric: true),
            DataColumn(label: Text('Roll Length(m)'), numeric: true),
            DataColumn(label: Text('Avg Wt(gm)'), numeric: true),
            DataColumn(label: Text('Operator')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Loom OP1')),
            DataColumn(label: Text('Gsm(mtr/gm)')),
            DataColumn(label: Text('Sup Name.')),
            DataColumn(label: Text('Party Name')),
            DataColumn(label: Text('Wo No')),
            DataColumn(label: Text('Oreder No')),
            DataColumn(label: Text('Req.Qty(Kg)')),
            DataColumn(label: Text('Req.Qty(mtr)')),
            DataColumn(label: Text('tare(Kg)')),
            // DataColumn(label: Text('Dept')),
            DataColumn(label: Text('Issue to Dept')),
            DataColumn(label: Text('Status')),
            // DataColumn(label: Text('Entry In')),
            // DataColumn(label: Text('Entry Out')),
            // DataColumn(label: Text('Mash')),
            // DataColumn(label: Text('Fab Type/Use')),
            // DataColumn(label: Text('Cut Type')),
            // DataColumn(label: Text('CLR')),
            // DataColumn(label: Text('Fab Width')),
            // DataColumn(label: Text('Fab GSM')),
            // DataColumn(label: Text('Lam Type')),
            // DataColumn(label: Text('Fab Type/Baffle')),
            // DataColumn(label: Text('Sp. Id')),

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
          label: const Text('Select First Date range ', style: TextStyle(color: C.textHigh)),
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
          _box("Roll Weight(Kg)", _totalNetWeight.toStringAsFixed(2), C.bg),
          _box("Roll Length(mtr)", _totalRollLength.toStringAsFixed(2), C.bg),
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
  final List<LoomReport> _data;
  _LoomDataSource(this._data);

  @override
  DataRow getRow(int i) {
    final r = _data[i];
    final isLohia = r.loomType.startsWith('LOHIA');

    return DataRow(
      color: WidgetStateProperty.all(
        i.isEven ? Colors.white : const Color(0xFFF8FAFF),
      ),
      cells: [
        DataCell(
          Text(
            '${r.srNo}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: C.primaryDark,
            ),
          ),
        ),
        DataCell(
          Text(
            '${r.rollCode}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: C.primaryDark,
            ),
          ),
        ),
        DataCell(
          Text(r.barcode, style: const TextStyle(fontFamily: 'monospace')),
        ),
        DataCell(Text(r.bomNo)),
        DataCell(Text(r.batchNo)),

        // DataCell(_badge(r.loomType, isLohia)),
        // DataCell(Text('${r.loomNo}')),

        DataCell(
          SizedBox(
            width: 190,
            child: Text(
              r.fabricCode,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),

        DataCell(Center(child: Text('${r.grossWeight}'))),
        DataCell(
          Center(
            child: Text(
              '${r.netWeight}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Center(child: Text('${r.rollLength}'))),
        DataCell(Center(child: Text('${r.avgWeight}'))),

        DataCell(Text(r.operatorName)),
        DataCell(
          Text(
            DateFormat('dd MMM yy').format(r.date),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        DataCell(Text(r.time)),


        DataCell(Text(r.loomOperator1)),

        DataCell(Text(r.fabricGsm)),

        DataCell(Text(r.supervisorName)),
        DataCell(Text(r.machineNo)), // Order No (you mapped wrong earlier)
        DataCell(Text(r.workOrderNo)), // WO No
        DataCell(Text(r.partyName)),

        DataCell(Text('${r.requiredQty}')),
        DataCell(Text('${r.requiredQtyMtr}')),
        DataCell(Text('${r.tareWeight}')),

        DataCell(Text(r.department)),
        DataCell(Text(r.issueToDept)),
        // DataCell(Text(r.status)),
        //
        // DataCell(Text(r.entryIn)),
        // DataCell(Text(r.entryOut)),
        //
        // DataCell(Text(r.mesh)),
        // DataCell(Text(r.fabricType)),
        // DataCell(Text(r.specialIdentification)),
        //
        // DataCell(Text(r.color)),
        // DataCell(Text(r.fabricWidth)),
        // DataCell(Text(r.fabricGsm)),
        //
        // DataCell(Text(r.laminationType)),
        // DataCell(Text(r.fabricConstruction)), // Lam/Baffle (better fit)
        // DataCell(Text(r.cutSlipType)),

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

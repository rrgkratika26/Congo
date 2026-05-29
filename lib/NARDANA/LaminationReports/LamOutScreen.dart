import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/laminationOut_model.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'LamOutModelClass.dart';

class LamOutScreen extends StatefulWidget {
  const LamOutScreen({super.key});

  @override
  State<LamOutScreen> createState() => _LamOutScreenState();
}

class _LamOutScreenState extends State<LamOutScreen> {
  final _searchCtrl = TextEditingController();
  static const int pageSize = 10;
  String _query = '';
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  int currentPage = 1;
  int get totalPages => (_filtered.length / pageSize).ceil().clamp(1, 99999);
  bool _isTodaySelected() {
    final now = DateTime.now();

    return _from.year == now.year &&
        _from.month == now.month &&
        _from.day == now.day &&
        _to.year == now.year &&
        _to.month == now.month &&
        _to.day == now.day;
  }

  List<LamNardanaOutModel> _allData = [];
  bool _isLoading = false;
  // ====================== USE IN YOUR SCREEN ======================

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filtered);
  List<LamNardanaOutModel> get _filtered {
    return _allData.where((r) {
      final q = _query.toLowerCase();

      return q.isEmpty ||
          r.barcode.toLowerCase().contains(q) ||
          r.batchNo.toLowerCase().contains(q) ||
          r.partyName.toLowerCase().contains(q) ||
          r.operatorName.toLowerCase().contains(q) ||
          r.supervisorName.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final data = await NaradanaApiService().fetchLamOut(from: _from, to: _to);

      setState(() => _allData = data);
    } catch (e) {
      debugPrint("ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load data")));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );

    if (picked != null) {
      _from = picked.start;
      _to = picked.end;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      body: Column(
        children: [
          _searchBar(),

          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filtered.isEmpty
              ? Expanded(
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
                        child: const Text("Select Date Range",style: TextStyle(color: C.textHigh),),
                      ),
                    ],
                  )
                )
              : Expanded(child: _table(_filtered)),

          _paginationBar(),
        ],
      ),
    );
  }

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

  // SEARCH BAR
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      color: C.primary,
      child: Column(
        children: [
          Row(
            children: [
              // 🔍 Search Field
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                            onPressed: () => setState(() {
                              _query = '';
                              _searchCtrl.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 5),

              // 📅 Calendar Icon
              IconButton(
                onPressed: _pickDateRange,
                icon: const Icon(
                  Icons.calendar_today,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          _summaryBar(),
        ],
      ),
    );
  }
  // ====================== SUMMARY BAR ======================

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

  // TABLE
  Widget _table(List<LamNardanaOutModel> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 2,
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

              // ✅ ALL COLUMNS
              columns: [
                DataColumn(label: _head('Sr')),
                DataColumn(label: _head('Date')),
                DataColumn(label: _head('Time')),
                DataColumn(label: _head('Barcode')),
                DataColumn(label: _head('Batch')),
                DataColumn(label: _head('Party')),
                DataColumn(label: _head('Loom')),
                DataColumn(label: _head('Fabric Code')),
                DataColumn(label: _head('Width')),
                DataColumn(label: _head('GSM')),
                DataColumn(label: _head('Fabric GSM')),
                DataColumn(label: _head('Lam Type')),
                DataColumn(label: _head('Color')),
                DataColumn(label: _head('Mash')),
                DataColumn(label: _head('Gross')),
                DataColumn(label: _head('Net')),
                DataColumn(label: _head('Tare')),
                DataColumn(label: _head('Length')),
                DataColumn(label: _head('Avg Wt')),
                DataColumn(label: _head('Operator')),
                DataColumn(label: _head('Supervisor')),
                DataColumn(label: _head('Work Order')),
                DataColumn(label: _head('Cont No')),
                DataColumn(label: _head('Req Qty')),
                DataColumn(label: _head('Req Mtr')),
                DataColumn(label: _head('Dept')),
                DataColumn(label: _head('Issue To')),
                DataColumn(label: _head('Entry In')),
                DataColumn(label: _head('Entry Out')),
                DataColumn(label: _head('Status')),
              ],

              // ✅ ROW DATA
              rows: List.generate(data.length, (i) {
                final r = data[i];

                return DataRow(
                  color: MaterialStateProperty.all(
                    i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                  ),
                  cells: [
                    DataCell(_cell('${r.id}', isBold: true)),
                    DataCell(_cell(DateFormat('dd-MM-yy').format(r.date))),
                    DataCell(_cell(r.time)),
                    DataCell(_cell(r.barcode, mono: true)),
                    DataCell(_cell(r.batchNo)),
                    DataCell(_cell(r.partyName, width: 120)),
                    DataCell(_cell('${r.loomType}-${r.loomNo}')),
                    DataCell(_cell(r.fabricCode, width: 130)),
                    DataCell(_cell(r.fabricWidth)),
                    DataCell(_cell(r.gsm.toStringAsFixed(2))),
                    DataCell(_cell(r.fabricGsm.toStringAsFixed(2))),
                    DataCell(_cell(r.laminationType)),
                    DataCell(_cell(r.color)),
                    DataCell(_cell(r.mash)),
                    DataCell(_cell(r.grossWeight.toStringAsFixed(1))),
                    DataCell(
                      _cell(
                        r.netWeight.toStringAsFixed(1),
                        color: Colors.green,
                        isBold: true,
                      ),
                    ),
                    DataCell(_cell(r.tareWeight.toStringAsFixed(1))),
                    DataCell(_cell(r.rollLength.toStringAsFixed(0))),
                    DataCell(_cell(r.avgWeight.toStringAsFixed(1))),
                    DataCell(_cell(r.operatorName)),
                    DataCell(_cell(r.supervisorName)),
                    DataCell(_cell(r.workOrderNo)),
                    DataCell(_cell(r.contNo)),
                    DataCell(_cell(r.requiredQuantity.toStringAsFixed(2))),
                    DataCell(_cell(r.requiredQuantityMtr.toStringAsFixed(2))),
                    DataCell(_cell(r.department)),
                    DataCell(_cell(r.issueToDept)),
                    DataCell(_cell(r.entryIn)),
                    DataCell(_cell(r.entryOut)),
                    DataCell(_cell(r.status)),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:IMS/services/NardanaApis/NardanaApi.dart';
import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/StockLedger/WebStockLedgerApis.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'LedgerInQtyScreen.dart';
import 'OpenFabricDetailScreen.dart';
import 'Web_StockModelClass.dart';

class StockLedgerScreen extends StatefulWidget {
  const StockLedgerScreen({super.key});

  @override
  State<StockLedgerScreen> createState() => _StockLedgerScreenState();
}

class _StockLedgerScreenState extends State<StockLedgerScreen> {
  static const int pageSize = 50;

  final TextEditingController _searchCtrl = TextEditingController();

  List<StockLedgerModel> _all = [];
  List<StockLedgerModel> _filtered = [];

  bool _loading = true;
  String _error = '';

  int _currentPage = 1;

  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();

  // ── Totals ────────────────────────────────────────────────
  double get _totalOpeningWt =>
      _filtered.fold(0.0, (s, e) => s + e.openingWt);
  double get _totalInWt =>
      _filtered.fold(0.0, (s, e) => s + e.inWt);
  double get _totalClosingWt =>
      _filtered.fold(0.0, (s, e) => s + e.closingWt);

  // ── Pagination ────────────────────────────────────────────
  int get _totalPages =>
      (_filtered.length / pageSize).ceil().clamp(1, 99999);

  List<StockLedgerModel> get _pageData {
    final start = (_currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _apiDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await LedgerApiService().fetchStockLedger(
        _apiDate(_from),
        _apiDate(_to),
        1,
        500,
      );

      _all = data;
      _filtered = data;
      _currentPage = 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Search ────────────────────────────────────────────────
  void _onSearch(String value) {
    setState(() {
      _filtered = _all
          .where((r) =>
          r.fabricCode.toLowerCase().contains(value.toLowerCase()))
          .toList();
      _currentPage = 1;
    });
  }

  // ── Date picker ───────────────────────────────────────────


  // ── UI ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.primary),
        ),
        title: const Text(
          'Stock Ledger',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          // Date range icon on appbar
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _pickDateRange,
          ),
          CountText(count: _filtered.length),
        ],
        iconTheme: const IconThemeData(color: C.bgColor),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : Column(
        children: [
          _summaryBar(),
          _searchBar(),
          Expanded(child: _tableView()),
          _paginationBar(),
        ],
      ),
    );
  }

  // ── Date Filter Bar ───────────────────────────────────────
  // ── Date Filter Bar ───────────────────────────────────────
  Widget _dateFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: GestureDetector(
        onTap: _pickDateRange,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: C.primary),
              const SizedBox(width: 8),
              Text(
                "${_apiDate(_from)}  →  ${_apiDate(_to)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: C.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _from = picked.start;
      _to = picked.end;
    });

    _fetch(); // auto-fetch on selection
  }


  // ── Summary Bar ───────────────────────────────────────────
  Widget _summaryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          _box("Opening Wt(kg)", _totalOpeningWt.toStringAsFixed(2),
              Colors.blue),
          _box("In Wt(kg)", _totalInWt.toStringAsFixed(2), Colors.green),
          _box("Closing Wt(kg)", _totalClosingWt.toStringAsFixed(2),
              Colors.orange),
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
            Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search By Fabric Code",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          prefixIcon:
          const Icon(Icons.search, size: 20, color: C.primary),
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
            borderSide: const BorderSide(color: C.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────
  Widget _tableView() {
    final rows = _pageData;
    final offset = (_currentPage - 1) * pageSize;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 15,
            horizontalMargin: 12,
            headingRowHeight: 42,
            dataRowHeight: 38,
            headingRowColor: WidgetStateProperty.all(
                C.brand100),
            columns: const [
              DataColumn(label: Text("SNo")),
              DataColumn(label: Text("Fabric Code")),
              DataColumn(label: Text("Open Qty")),
              DataColumn(label: Text("Open Kg")),
              DataColumn(label: Text("In Qty")),
              DataColumn(label: Text("In Kg")),
              DataColumn(label: Text("Out Qty")),
              DataColumn(label: Text("Close Qty")),
              DataColumn(label: Text("Close Wt")),
            ],
            rows: List.generate(rows.length, (i) {
              final r = rows[i];
              return DataRow(cells: [
                DataCell(Text("${offset + i + 1}")),
                // DataCell(Text(
                //   r.fabricCode,
                //   style: const TextStyle(
                //       color: C.primaryBlue,
                //       fontWeight: FontWeight.w500),
                // )),
                DataCell(
                  InkWell(
                    onTap: () => _openFabricDetails(r.fabricCode),

                    child: Text(
                      r.fabricCode,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () => _openFabricDetails(r.fabricCode),
                    child: Text(
                      r.openingQty.toString(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                DataCell(
                  InkWell(
                    onTap: () => _openFabricDetails(r.fabricCode),
                    child: Text(
                      r.openingWt.toString(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                DataCell(
                  InkWell(
                    onTap: () => _openInQtyDetails(r.fabricCode),
                    child: Text(
                      r.inQty.toString(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                DataCell(
                  InkWell(
                    onTap: () => _openInQtyDetails(r.fabricCode),
                    child: Text(
                      r.inWt.toString(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  r.outQty.toString(),
                  style: const TextStyle(color: Colors.red),
                )),
                DataCell(Text(
                  r.closingQty.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )),
                DataCell(Text(
                  r.closingWt.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────
  Widget _paginationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page $_currentPage / $_totalPages"),
          Row(
            children: [
              ElevatedButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                child: const Text("Prev"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                child:
                const Text("Next", style: TextStyle(color: C.textMid)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _openFabricDetails(String fabricCode) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenFabricDetailsScreen(
          fabricCode: fabricCode,
          date: _apiDate(_to),
        ),
      ),
    );
  }
  Future<void> _openInQtyDetails(String fabricCode) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LedgerInQtyScreen(
          fabricCode: fabricCode,
          date: _apiDate(_to),
        ),
      ),
    );
  }

}
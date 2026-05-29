import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'OutModelClass.dart';
import 'StockGrouping/WebStockGrouping.dart';

class WebNardanaStockScreen extends StatefulWidget {
  const WebNardanaStockScreen({super.key});

  @override
  State<WebNardanaStockScreen> createState() => _WebNardanaStockScreenState();
}

class _WebNardanaStockScreenState extends State<WebNardanaStockScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int currentPage = 1;
  static const int pageSize = 50;
  DateTime? _from;
  DateTime? _to;
  String? selectedFabric;
  bool _isLoading = false;

  List<WebOutReportModel> _all = [];


  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);




  @override
  void initState() {
    super.initState();
    _from = DateTime.now();
    _to = DateTime.now();
    _fetch();
  }






  // API DATE FORMAT
  String _apiDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";


  List<WebOutReportModel> get _paginatedData {
    final list = _filtered;

    final start = (currentPage - 1) * pageSize;
    int end = start + pageSize;

    if (end > list.length) end = list.length;

    return list.sublist(start, end);
  }

  int get totalPages {
    if (_filtered.isEmpty) return 1;
    return (_filtered.length / pageSize).ceil();
  }


  Future<void> _fetch() async {
    setState(() => _isLoading = true);

    try {
      final data = await NaradanaApiService().fetchWebbingStock(
        // _apiDate(_from!),
        // _apiDate(_to!),
        1,
        500,
      );

      setState(() => _all = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load data")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // FILTER (same logic as RMD)
  List<WebOutReportModel> get _filtered {
    return _all.where((r) {
      final q = _query.toLowerCase();

      final matchQ =
          q.isEmpty ||
          r.barcode.toLowerCase().contains(q) ||
          r.partyName.toLowerCase().contains(q) ||
          r.fabricCode.toLowerCase().contains(q) ||
          r.supervisorName.toLowerCase().contains(q);

      return matchQ;
    }).toList();
  }

  // DATE PICKER
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from!, end: _to!),
    );

    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _fetch();
    }
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yy').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
          children: [
            _topBar(),

            _isLoading
                ? const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : _filtered.isEmpty
                ? const Expanded(
              child: Center(
                child: Text("No Data"),
              ),
            )
                : Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _table(_paginatedData),
                  ),

                  _paginationBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── TOP BAR ─────────────────

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 12, 5, 2),
      color: C.bg,
      child: Column(
        children: [
          _summaryBar(),   // ✅ full width

          const SizedBox(height: 6),

          _searchBar(),    // ✅ full width
        ],
      ),
    );
  }
  // ───────────────── TABLE ─────────────────

  Widget _table(List<WebOutReportModel> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  columnSpacing: isMobile ? 8 : 16,
                  horizontalMargin: isMobile ? 6 : 12,
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 42,
                  headingRowHeight: 38,
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFFEAF2FF),
                  ),

                  columns: [
                    _col("Sr"),
                    _col("Roll Code"),
                    _col("Barcode"),
                    _col("Lot No"),
                    _col("Fabric Code"),
                    _col("Wt(Kg)"),
                    _col("Len"),
                    _col("Party"),
                    _col("WO"),
                    _col("Machine Type"),
                    _col("Machine No"),
                    _col("Mesh"),
                    _col("Belt"),
                    _col("Material"),
                    _col("Dept"),
                    _col("Supervisor"),
                    _col("Operator"),
                    _col("Week"),
                    _col("Order"),
                    _col("Color"),
                    _col("Width"),
                    _col("GSM"),
                    _col("Req(KG)"),
                    _col("Req(Mtr)"),
                    _col("Loom1"),
                    _col("Loom2"),
                    _col("Hold"),
                    _col("Location"),
                    _col("Remark"),
                    _col("Date"),
                    _col("Time"),
                  ],

                  rows: List.generate(data.length, (i) {
                    final r = data[i];

                    return DataRow(
                      color: MaterialStateProperty.all(
                        i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                      ),
                      cells: [
                        _cell(r.id.toString(), bold: true),
                        _cell(r.rollCode),
                        _cell(r.barcode),
                        _cell(r.lotNo),
                        _cell(r.fabricCode, maxWidth: 140),


                        _cell(r.rollWeight.toString()),
                        _cell(r.rollLength.toString()),
                        _cell(r.partyName, maxWidth: 120),
                        _cell(r.workOrderNo),
                        _cell(r.machineType),
                        _cell(r.machineNo),
                        _cell(r.mesh),
                        _cell(r.beltType),
                        _cell(r.materialtype),
                        _cell(r.department),
                        _cell(r.supervisorName, maxWidth: 120),
                        _cell(r.operatorName, maxWidth: 120),
                        _cell(r.weekNo),
                        _cell(r.orderType),
                        _cell(r.color),
                        _cell(r.beltWidth),
                        _cell(r.gsm),

                        _cell(
                          r.requiredQty.toStringAsFixed(1),
                          color: Colors.green,
                          bold: true,
                        ),
                        _cell(
                          r.requiredQtyMtr.toStringAsFixed(1),
                          color: Colors.green,
                          bold: true,
                        ),

                        _cell(r.loomOp1),
                        _cell(r.loom2),
                        _cell(r.hold),
                        _cell(r.location, maxWidth: 120),
                        _cell(r.remark, maxWidth: 150),
                        _cell(r.date),
                        _cell(r.time),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _col(String t) =>
      DataColumn(label: Text(t, style: const TextStyle(fontSize: 11)));

  DataCell _cell(
      String t, {
        double? maxWidth,
        bool bold = false,
        Color? color,
      }) {
    return DataCell(
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: Text(
          t.isEmpty ? '-' : t,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: color ?? Colors.black87,
          ),
        ),
      ),
    );
  }


  Widget _paginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page $currentPage of $totalPages",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          Row(
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () {
                  setState(() {
                    currentPage--;
                  });
                }
                    : null,
                child: const Text("Previous"),
              ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: currentPage < totalPages
                    ? () {
                  setState(() {
                    currentPage++;
                  });
                }
                    : null,
                child: const Text("Next"),
              ),
            ],
          ),
        ],
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
            color: C.primary,
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
              color: C.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }


  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Total Records", "$_totalRecords", Colors.blue),
          _box("Net Wt(Kg)", _totalNet.toStringAsFixed(2), Colors.green),
          // _box("Roll Len", _totalLength.toStringAsFixed(2), Colors.orange),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

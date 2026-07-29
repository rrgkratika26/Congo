import 'package:flutter/material.dart';

import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'WebInReportModel.dart';

class WebbingInReportScreen extends StatefulWidget {
  const WebbingInReportScreen({super.key});

  @override
  State<WebbingInReportScreen> createState() => _WebbingInReportScreenState();
}

class _WebbingInReportScreenState extends State<WebbingInReportScreen> {
  final NaradanaApiService _service = NaradanaApiService();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  int _pageNumber = 1;
  final int _pageSize = 500000;

  bool _isFetchingMore = false;
  bool _hasMore = true;

  final ScrollController _vCtrl = ScrollController();
  bool _loading = true;
  String? _error;

  List<WeBNardanaReportModel> _data = [];
  List<WeBNardanaReportModel> _filtered = [];

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _hCtrl = ScrollController();

  // ── Column widths ──────────────────────────────────────────────────────────
  static const double _colSrNo       = 55;
  static const double _colBarcode    = 90;
  static const double _colDate       = 100;
  static const double _colTime       = 70;
  static const double _colParty      = 140;
  static const double _colLot        = 105;
  static const double _colWorkOrder  = 110;
  static const double _colPurchaseNo = 110;
  static const double _colMachine    = 85;
  static const double _colModelNo    = 90;
  static const double _colFlatTube   = 100;
  static const double _colOperator   = 105;
  static const double _colSuper      = 105;
  static const double _colQty        = 75;
  static const double _colNetWt      = 80;
  // ✅ TOTALS
  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netwt);

  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);


  double get _totalWidth =>
      _colSrNo + _colBarcode + _colDate + _colTime + _colParty +
          _colLot + _colWorkOrder + _colPurchaseNo + _colMachine +
          _colModelNo + _colFlatTube + _colOperator + _colSuper +
          _colQty + _colNetWt;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, now.day);
    _toDate   = DateTime(now.year, now.month, now.day);

    _load();
  }
  @override
  void dispose() {
    _searchCtrl.dispose();
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _service.fetchReport(
        _apiDate(_fromDate),
        _apiDate(_toDate),
        pageNumber: 1,
        pageSize: _pageSize,
      );

      setState(() {
        _data = res;
        _filtered = res;
        _pageNumber = 1;
        _hasMore = res.length == _pageSize;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_mon(d.month)} ${d.year}';

  String _mon(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];

  String _formatApiDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')} ${_mon(dt.month)} ${dt.year}';
    } catch (_) {
      return raw.contains('T') ? raw.split('T')[0] : raw;
    }
  }


  // ── Search ─────────────────────────────────────────────────────────────────
  List<WeBNardanaReportModel> _applyFilter(
      List<WeBNardanaReportModel> source, String val) {
    final q = val.toLowerCase().trim();
    if (q.isEmpty) return source;
    return source.where((e) {
      return e.barcode.toLowerCase().contains(q) ||
          e.partyname.toLowerCase().contains(q) ||
          e.lotno.toLowerCase().contains(q) ||
          e.workorderno.toLowerCase().contains(q) ||
          e.purchaseNo.toLowerCase().contains(q) ||
          e.machine.toLowerCase().contains(q) ||
          e.modelno.toLowerCase().contains(q) ||
          e.supervisor.toLowerCase().contains(q) ||
          e.operator.toLowerCase().contains(q) ||
          e.flattubegusset.toLowerCase().contains(q);
    }).toList();
  }

  void _onSearch(String val) {
    setState(() { _filtered = _applyFilter(_data, val); });
  }

  // ── Date Picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   Color(0xFF1565C0),
            onPrimary: Colors.white,
            surface:   Colors.white,
            onSurface: Color(0xFF212121),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { _fromDate = picked.start; _toDate = picked.end; });
      _load();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      body: Column(
        children: [
          _buildFilterBar(),
          // _buildSummaryBar(),
          _summaryBar(),
          Expanded(child: _buildBody()),

        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────


  // ── Filter Bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by barcode, party, lot, machine, model...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF1565C0), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFE3F2FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF90CAF9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF90CAF9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF1565C0), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Bar ────────────────────────────────────────────────────────────
  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF1565C0),
      child: Row(
        children: [
          const Icon(Icons.wrap_text_outlined,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Total Records: ${_filtered.length}'
                '${_searchCtrl.text.isNotEmpty ? ' (filtered)' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,


            ),
          ),

        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_filtered.isEmpty) {

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? 'No results for "${_searchCtrl.text}".'
                  : 'No records found for the selected date range.',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _hCtrl,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _hCtrl,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalWidth,
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _vCtrl,
                  physics: const BouncingScrollPhysics(), // 🔥 smooth scroll
                  itemCount: _filtered.length + (_isFetchingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i < _filtered.length) {
                      return _buildTableRow(_filtered[i], i);
                    } else {
                      /// 🔄 Loader at bottom
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Table Header ───────────────────────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF1565C0),
      child: Row(
        children: [
          _headerCell('SR\nNo',        _colSrNo),
          _headerCell('BARCODE',       _colBarcode),
          _headerCell('DATE',          _colDate),
          _headerCell('TIME',          _colTime),
          _headerCell('PARTY NAME',    _colParty),
          _headerCell('LOT NO',        _colLot),
          _headerCell('WORK\nORDER',   _colWorkOrder),
          _headerCell('PURCHASE\nNO',  _colPurchaseNo),
          _headerCell('MACHINE',       _colMachine),
          _headerCell('MODEL NO',      _colModelNo),
          _headerCell('FLAT/TUBE\nGUSSET', _colFlatTube),
          _headerCell('OPERATOR',      _colOperator),
          _headerCell('SUPERVISOR',    _colSuper),
          _headerCell('QTY',           _colQty),
          _headerCell('NET WT',        _colNetWt),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
            right: BorderSide(color: Colors.white24, width: 0.8)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }

  // ── Table Row ──────────────────────────────────────────────────────────────
  Widget _buildTableRow(WeBNardanaReportModel item, int index) {
    final Color rowBg =
    index.isEven ? Colors.white : const Color(0xFFF5F9FF);

    return Container(
      color: rowBg,
      child: Row(
        children: [
          _dataCell((index + 1).toString(), _colSrNo,
              textColor: Colors.grey.shade600),
          _dataCell(item.barcode,      _colBarcode,
              textColor: const Color(0xFF1565C0), bold: true),
          _dataCell(_formatApiDate(item.date), _colDate,
              textColor: const Color(0xFF37474F)),
          _dataCell(item.time,         _colTime),
          _dataCell(item.partyname,    _colParty, bold: true),
          _dataCell(item.lotno,        _colLot,
              textColor: const Color(0xFF6A1B9A)),
          _dataCell(item.workorderno,  _colWorkOrder),
          _dataCell(item.purchaseNo.isEmpty ? '-' : item.purchaseNo,
              _colPurchaseNo,
              textColor: const Color(0xFF37474F)),
          _dataCell(item.machine,      _colMachine),
          _dataCell(item.modelno.isEmpty ? '-' : item.modelno,
              _colModelNo,
              textColor: const Color(0xFF00695C)),
          _dataCell(item.flattubegusset.isEmpty ? '-' : item.flattubegusset,
              _colFlatTube),
          _dataCell(item.operator.isEmpty ? '-' : item.operator,
              _colOperator),
          _dataCell(item.supervisor.isEmpty ? '-' : item.supervisor,
              _colSuper),
          _dataCell(item.quantity.toStringAsFixed(0), _colQty,
              textColor: const Color(0xFF1565C0), bold: true),
          _dataCell(item.netwt.toStringAsFixed(2),    _colNetWt,
              textColor: const Color(0xFF2E7D32), bold: true),
        ],
      ),
    );
  }

  Widget _dataCell(
      String text,
      double width, {
        Color? textColor,
        bool bold = false,
      }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          right:  BorderSide(color: Colors.grey.shade200, width: 0.8),
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: textColor ?? const Color(0xFF212121),
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
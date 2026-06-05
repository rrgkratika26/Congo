import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'baleStockModel/BaleStockModel.dart';

class StockReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const StockReportScreen({Key? key, this.startDate, this.endDate})
    : super(key: key);

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  final _service = InStockService();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 31));
  DateTime _toDate = DateTime.now();

  bool _isLoading = true;
  String? _error;
  List<BaleStockReportModel> _reports = [];
  // ====================== USE IN YOUR SCREEN ======================

  // int get _totalBagQty =>
  //     _filteredReports.fold(0, (sum, e) => sum + (e.bagQty ?? 0));



  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filteredReports, (e) => e.bagNwt);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filteredReports, (e) => e.grossWt);

  int get _totalRecords => ReportTotalHelper.totalRecords(_filteredReports);
  List<BaleStockReportModel> _filteredReports = [];
  final ScrollController _horizCtrl = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // ── Column widths ─────────────────────────────────────────────────────────
  static const double _colSrNo = 60;
  static const double _colDate = 100; // ← NEW
  static const double _colParty = 140;
  static const double _colBaleNo = 80;
  static const double _colArticle = 100;
  static const double _colBom = 90;
  static const double _colBagType = 90;
  static const double _colQty = 100;
  static const double _colNwt = 90;
  static const double _colGrossWt = 100;
  static const double _colShift = 65;
  static const double _colSupervisor = 120;
  static const double _colBaleAge = 90;
  static const double _colTime = 90;
  static const double _colPrintStatus = 120;
  static const double _colBagWtGm = 90;
  static const double _colBagSize = 120;
  static const double _colPalletSize = 110;
  static const double _colSubmittedBy = 120;
  static const double _colCheckedBy = 140;
  static const double _colRemark = 150;

  double get _totalWidth =>
      _colSrNo +
      _colDate +
      _colTime +
      _colParty +
      _colBaleNo +
      _colArticle +
      _colBom +
      _colPrintStatus +
      _colBagType +
      _colBagSize +
      _colPalletSize +
      _colQty +
      _colBagWtGm +
      _colNwt +
      _colGrossWt +
      _colShift +
      _colSupervisor +
      _colSubmittedBy +
      _colCheckedBy +
      _colRemark +
      _colBaleAge;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.startDate != null) _fromDate = widget.startDate!;
    if (widget.endDate != null) _toDate = widget.endDate!;
    _loadReport();
  }

  @override
  void dispose() {
    _horizCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_mon(d.month)} ${d.year}';

  String _mon(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.fetchStockReport(
        fromDate: _apiDate(_fromDate),
        toDate: _apiDate(_toDate),
      );

      setState(() {
        _reports = data;
        _filteredReports = data; // ✅ IMPORTANT
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Date Range Picker ──────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: C.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF212121),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: C.bg),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadReport();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F2),
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

  // ====================== SUMMARY BAR ======================
  Widget _summaryBar() {
    return Container(
      color: C.primary,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Records", "$_totalRecords", C.bg),
          // _box("Bag Qty", "$_totalBagQty", C.bg),
          _box("Bag Nwt(Kg)", _totalNet.toStringAsFixed(2), C.bg),
          _box("Gross Wt(Kg)", _totalLength.toStringAsFixed(2), C.bg),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText:
                          'Search by barcode, party, BOM, article, bale...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF1565C0),
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                          color: Color(0xFF1565C0),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10),

              child: const Icon(
                Icons.calendar_month,
                color: C.primary,
                size: 25,
              ),
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
      // color: C.headerTop,
      child: Row(
        children: [
          Text(
            'Total Bales: ${_reports.length}',
            style: const TextStyle(
              color: C.textBody,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${_displayDate(_fromDate)}  →  ${_displayDate(_toDate)}',
            style: const TextStyle(color: C.textBody, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: C.appBar3,));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReport,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No stock records found for the selected date range.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _horizCtrl,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _horizCtrl,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalWidth,
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  // itemCount: _reports.length,
                  // itemBuilder: (_, i) => _buildTableRow(_reports[i], i),
                  itemCount: _filteredReports.length,
                  itemBuilder: (_, i) => _buildTableRow(_filteredReports[i], i),
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
      color: C.primary,
      child: Row(
        children: [
          _headerCell('Sr.No', _colSrNo),
          _headerCell('DATE', _colDate),
          _headerCell('TIME', _colTime),
          _headerCell('PARTY NAME', _colParty),
          _headerCell('BALE NO', _colBaleNo),
          _headerCell('ARTICLE NO', _colArticle),
          _headerCell('BOM No', _colBom),
          _headerCell('PRINT', _colPrintStatus),
          _headerCell('BAG TYPE', _colBagType),
          _headerCell('BAG SIZE', _colBagSize),
          _headerCell('PALLET', _colPalletSize),
          _headerCell('QTY', _colQty),
          _headerCell('WT(GM)', _colBagWtGm),
          _headerCell('NET WT', _colNwt),
          _headerCell('GROSS WT', _colGrossWt),
          _headerCell('SHIFT', _colShift),
          _headerCell('SUPERVISOR', _colSupervisor),
          _headerCell('SUBMITTED', _colSubmittedBy),
          _headerCell('CHECKED', _colCheckedBy),
          _headerCell('REMARK', _colRemark),
          _headerCell('AGE', _colBaleAge),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white24, width: 0.8)),
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
  Widget _buildTableRow(BaleStockReportModel item, int index) {
    final int age = item.baleAge;
    final bool isOld = age >= 7;

    final Color rowBg = isOld
        ? const Color(0xFFFFEBEE)
        : (index.isEven ? Colors.white : const Color(0xFFF1F8F2));

    return Container(
      color: rowBg,
      child: Row(
        children: [
          _dataCell(item.srNo, _colSrNo),
          _dataCell(item.dateDisplay, _colDate),
          _dataCell(item.time, _colTime),

          _dataCell(item.partyName, _colParty, bold: true),
          _dataCell(
            item.baleNo,
            _colBaleNo,
            textColor: const Color(0xFF1565C0),
            bold: true,
          ),

          _dataCell(item.articleNo, _colArticle),
          _dataCell(item.bomNo, _colBom),
          _dataCell(item.printStatus, _colPrintStatus),

          _dataCell(item.bagType, _colBagType),
          _dataCell(item.bagSize, _colBagSize),
          _dataCell(item.palletSize, _colPalletSize),

          _dataCell(item.bagQty, _colQty, bold: true),

          _dataCell(item.bagWtGm.toStringAsFixed(2), _colBagWtGm),
          _dataCell(item.bagNwt.toStringAsFixed(2), _colNwt),
          _dataCell(item.grossWt.toStringAsFixed(2), _colGrossWt),

          _dataCell(item.shift, _colShift),

          _dataCell(item.supervisor, _colSupervisor),
          _dataCell(item.submittedBy, _colSubmittedBy),
          _dataCell(item.checkedBy, _colCheckedBy),

          _dataCell(item.remark, _colRemark),

          _dataCell(
            item.baleAge.toString(),
            _colBaleAge,
            textColor: item.baleAge >= 7 ? Colors.red : const Color(0xFF2E7D32),
            bold: item.baleAge >= 7,
          ),
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
          right: BorderSide(color: Colors.grey.shade200, width: 0.8),
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

  void _onSearch(String value) {
    final query = value.toLowerCase().trim();
    setState(() {
      _filteredReports = query.isEmpty
          ? _reports
          : _reports.where((item) {
              return item.barcode.toLowerCase().contains(query) ||
                  item.partyName.toLowerCase().contains(query) ||
                  item.bomNo.toLowerCase().contains(query) ||
                  item.articleNo.toLowerCase().contains(query) ||
                  item.baleNo.toLowerCase().contains(query);
            }).toList();
    });
  }
}

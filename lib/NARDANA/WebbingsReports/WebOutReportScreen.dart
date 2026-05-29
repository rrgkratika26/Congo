import 'package:flutter/material.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'OutModelClass.dart';

class WebbingOutReportScreen extends StatefulWidget {
  const WebbingOutReportScreen({super.key});

  @override
  State<WebbingOutReportScreen> createState() =>
      _WebbingOutReportScreenState();
}

class _WebbingOutReportScreenState
    extends State<WebbingOutReportScreen> {

  final NaradanaApiService _service = NaradanaApiService();

  DateTime _fromDate =
  DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  bool _loading = true;
  String? _error;

  List<WebOutReportModel> _data = [];
  List<WebOutReportModel> _filtered = [];

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _hCtrl = ScrollController();

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);




  @override
  void initState() {
    super.initState();
    _load();
  }

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day}-${d.month}-${d.year}';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _service.fetchWebbingOutReport(
        _apiDate(_fromDate),
        _apiDate(_toDate),
      );

      setState(() {
        _data = res;
        _filtered = res;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch(String val) {
    final q = val.toLowerCase();

    setState(() {
      _filtered = _data.where((e) {
        return e.barcode.toLowerCase().contains(q) ||
            e.partyName.toLowerCase().contains(q) ||
            e.lotNo.toLowerCase().contains(q) ||
            e.workOrderNo.toLowerCase().contains(q) ||
            e.machineNo.toLowerCase().contains(q) ||
            e.operatorName.toLowerCase().contains(q) ||
            e.supervisorName.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange:
      DateTimeRange(start: _fromDate, end: _toDate),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _filterBar(),
          _summaryBar(),
          // _summaryBar(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFE3F2FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month,
                  color: Colors.white),
            ),
          ),
        ],
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

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_filtered.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return Scrollbar(
      controller: _hCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _hCtrl,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width, // ✅ FIX
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                ...List.generate(
                  _filtered.length,
                      (i) => _row(_filtered[i], i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: const Color(0xFF1565C0),
      child: Row(
        children: [
          _headCell("Sr", 40),
          _headCell("Barcode", 80),
          _headCell("Date", 100),
          _headCell("Time", 70),
          _headCell("Party", 140),
          _headCell("Lot", 140),
          _headCell("Fabric", 180),
          _headCell("WO", 130),
          _headCell("TYPE", 80),
          _headCell("Machine", 70),
          _headCell("Oper.", 70),
          _headCell("Super.", 100),
          _headCell("LOOM1", 120),
          _headCell("LOOM2", 120),
          _headCell("CLR", 80),
          _headCell("Width", 60),
          _headCell("GSM", 50),
          _headCell("WEEK", 60),
          _headCell("QTY", 60),
          _headCell("NET", 60),
        ],
      ),
    );
  }

  Widget _row(WebOutReportModel r, int i) {
    return Container(
      color: i.isEven ? Colors.white : const Color(0xFFF5F9FF),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cell("${r.id}", 40),
          _cell(r.barcode, 80),
          _cell(r.date, 100),
          _cell(r.time, 70),
          _cell(r.partyName, 140),
          _cell(r.lotNo, 140),
          _cell(r.fabricCode, 180),
          _cell(r.workOrderNo, 130),
          _cell(r.orderType, 80),
          _cell(r.machineNo, 70),
          _cell(r.operatorName, 70),
          _cell(r.supervisorName, 100),
          _cell(r.loom1, 120),
          _cell(r.loom2, 120),
          _cell(r.color, 80),
          _cell(r.beltWidth, 60),
          _cell(r.gsm, 50),
          _cell(r.weekNo, 60),
          _cell(r.quantity.toStringAsFixed(2), 60),
          _cell(
            r.netWeight.toStringAsFixed(2),
            60,
            color: Colors.green,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _headCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cell(String text, double width,
      {Color? color, bool bold = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      child: Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
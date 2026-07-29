import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../Color/Colorclass.dart';
import '../../services/Bluetooth_services.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'BalingPreviewLabel.dart';
import 'baleStockModel/BaleReportModel.dart';

class BailingReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const BailingReportScreen({Key? key, this.startDate, this.endDate})
    : super(key: key);

  @override
  State<BailingReportScreen> createState() => _BailingReportScreenState();
}

class _BailingReportScreenState extends State<BailingReportScreen> {
  final _service = InStockService();
  final GetStorage _storage = GetStorage();
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  List printers = [];
  bool isScanning = false;
  bool _isLoading = true;
  String? _error;
  List<BailingReportModel> _reports = [];
  List<BailingReportModel> _filteredReports = [];

  final ScrollController _horizCtrl = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBarcode;
  // final Set<String> _selectedBarcodes = {};

  int get _totalRecords => ReportTotalHelper.totalRecords(_filteredReports);

  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filteredReports, (e) => e.netWt);

  double get _totalLength =>
      ReportTotalHelper.totalRollLength(_filteredReports, (e) => e.grossWt);

  // ── Column widths ────────────────────────────────────────────────────────────
  static const double _colBarcode = 80;
  static const double _colSrNo = 70;
  static const double _colDate = 155;
  static const double _colTime = 85;
  static const double _colParty = 130;
  static const double _colBom = 90;
  static const double _colArticle = 100;
  static const double _colPrintStatus = 105;
  static const double _colBagType = 90;
  static const double _colShift = 60;
  static const double _colBaleNo = 80;
  static const double _colBagQty = 105;
  static const double _colBagNwt = 90;
  static const double _colGrossWt = 100;
  static const double _colCheck = 55;

  double get _totalWidth =>
      _colCheck +
      _colBarcode +
      _colSrNo +
      _colBom +
      _colParty +
      _colArticle +
      _colPrintStatus +
      _colBagType +
      _colShift +
      _colBaleNo +
      _colBagQty +
      _colBagNwt +
      _colGrossWt +
      _colDate +
      _colTime;



  // ── Lifecycle ────────────────────────────────────────────────────────────────
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
    _searchController.dispose();
    super.dispose();
  }
  Future scanPrinters() async {
    setState(() {
      isScanning = true;
      printers.clear();
    });

    try {
      final result = await PrintBluetoothThermal.pairedBluetooths;

      setState(() {
        printers = result;
        isScanning = false;
      });

      if (printers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No paired printers found")),
        );
      }
    } catch (e) {
      setState(() {
        isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Future<void> showPrinterList() async {
    await scanPrinters();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [

              const SizedBox(height: 15),

              const Text(
                "Select Printer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

              if (isScanning)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (_, index) {
                      final p = printers[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.print,
                          color: Colors.blue,
                        ),
                        title: Text(p.name ?? "Unknown"),
                        subtitle: Text(p.macAdress ?? ""),
                        onTap: () async {

                          _storage.write("printer_name", p.name);
                          _storage.write("printer_address", p.macAdress);

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Connected : ${p.name}",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  // ── Helpers ──────────────────────────────────────────────────────────────────
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

  // ── Load ─────────────────────────────────────────────────────────────────────
  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchBailingReport(
        fromDate: _apiDate(_fromDate),
        toDate: _apiDate(_toDate),
      );
      setState(() {
        _reports = data;
        _filteredReports = data;
        _isLoading = false;
      });
      // Re-apply any active search after reload
      if (_searchController.text.isNotEmpty) {
        _onSearch(_searchController.text);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────────
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

  // ── Date Range Picker ─────────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF212121),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
            ),
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

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text("Baling Reports", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        // C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      floatingActionButton:  _selectedBarcode == null
          ? null
          : FloatingActionButton.extended(
        backgroundColor: C.primary,
        icon: const Icon(Icons.print, color: C.bg),
        label: const Text(
          "Print",
          style: TextStyle(color: C.bg),
        ),
        onPressed: () async {
          final item = _filteredReports.firstWhere(
                (e) => e.barcode == _selectedBarcode,
          );

          await showPrintPreview(item);
        },
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _summaryBar(),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _summaryBar() {
    return Container(
      color: C.bg,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Total Records", "$_totalRecords", C.bg),
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

  // ── Filter Bar ───────────────────────────────────────────────────────────────
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
          // ── Search Field ────────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by barcode, party, BOM, article, bale...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
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

          const SizedBox(width: 10),

          // ── Calendar icon (date filter still accessible) ──────────────────
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

  // ── Body ─────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: C.actionOrange),
      );
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
    if (_filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No results for "${_searchController.text}".'
                  : 'No records found for the selected date range.',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
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

  // ── Table Header ─────────────────────────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      color: C.primary,
      child: Row(
        children: [
          _headerCell("", _colCheck),

          _headerCell('BARCODE', _colBarcode),
          _headerCell('SR No', _colSrNo),
          _headerCell('BOM No', _colBom),
          _headerCell('PARTY NAME', _colParty),

          _headerCell('ARTICLE NO', _colArticle),
          _headerCell('PRINT STATUS', _colPrintStatus),
          _headerCell('BAG TYPE', _colBagType),
          _headerCell('SHIFT', _colShift),
          _headerCell('BALE NO', _colBaleNo),
          _headerCell('BAG QTY\n(IN PCS)', _colBagQty),
          _headerCell('BAG NWT', _colBagNwt),
          _headerCell('GROSS WT', _colGrossWt),

          // _headerCell('Pallet', _colGrossWt),
          _headerCell('Date', _colDate),
          _headerCell('Time', _colTime),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: C.primaryLight, width: 0.8)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: C.bg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }

  // ── Table Row ─────────────────────────────────────────────────────────────────
  Widget _buildTableRow(BailingReportModel item, int index) {
    final bool zeroWt = item.netWt == '0.00' || item.netWt == '0';

    final Color rowBg = zeroWt
        ? const Color(0xFFFFF176)
        : (index.isEven ? Colors.white : const Color(0xFFF5F9FF));

    final Color barcodeColor = index == 0
        ? Colors.red
        : const Color(0xFF212121);

    return Container(
      color: rowBg,
      child: Row(
        children: [
          Container(
            width: _colCheck,
            alignment: Alignment.center,
            child: Checkbox(
              value: _selectedBarcode == item.barcode,
              activeColor: C.primary,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedBarcode = item.barcode;
                  } else {
                    _selectedBarcode = null;
                  }
                });
              },
            ),
          ),
          _dataCell(
            item.barcode,
            _colBarcode,
            textColor: barcodeColor,
            bold: index == 0,
          ),
          _dataCell(item.srNo ?? '-', _colSrNo),
          _dataCell(item.bomNo, _colBom),
          _dataCell(item.partyName, _colParty),

          _dataCell(item.articleNo, _colArticle),
          _dataCell(item.printStatus, _colPrintStatus),
          _dataCell(item.bagType, _colBagType),
          _dataCell(item.shift, _colShift),
          _dataCell(item.baleNo, _colBaleNo),
          _dataCell(
            item.bagQty,
            _colBagQty,

            bold: true,
            textColor: const Color(0xFF1A237E),
          ),
          _dataCell(
            item.netWt.toStringAsFixed(2),
            _colBagNwt,
            bold: zeroWt,
            textColor: zeroWt ? Colors.black87 : null,
          ),
          _dataCell(
            item.grossWt.toStringAsFixed(2),
            _colGrossWt,
            bold: zeroWt,
            textColor: zeroWt ? Colors.black87 : null,
          ),

          _dataCell(item.date, _colDate),
          _dataCell(item.time, _colTime),
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
  Future<void> showPrintPreview(BailingReportModel data) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            String printerName =
                _storage.read<String>('printer_name') ?? "No Printer Selected";

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                width: 430,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// Bluetooth Button
                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              printerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.bluetooth,
                              color: Colors.blue,
                              size: 28,
                            ),
                            onPressed: () async {

                              await showPrinterList();

                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),

                      const Divider(),

                      /// Preview
                      BailingLabelPreview(data: data),


                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _printSingleBarcode(BailingReportModel data) async {
    final address = _storage.read('printer_address');

    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select printer first")),
      );
      return;
    }

    bool connected = await PrintBluetoothThermal.connectionStatus ?? false;

    if (!connected) {
      connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );
    }

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Printer connection failed")),
      );
      return;
    }

    String tspl = '''
SIZE 100 mm,100 mm
GAP 3 mm,0 mm
CLS

TEXT 20,30,"3",0,1,1,"PARTY NAME :"
TEXT 160,30,"3",0,1,1,"${data.partyName}"

TEXT 20,70,"3",0,1,1,"ARTICLE NO :"
TEXT 160,70,"3",0,1,1,"${data.articleNo}"

TEXT 20,110,"3",0,1,1,"BAG SIZE :"
TEXT 160,110,"3",0,1,1,"${data.bagType}"

TEXT 20,160,"3",0,1,1,"BALE # : ${data.baleNo}"

TEXT 260,160,"3",0,1,1,"BAG/PC : ${data.bagQty}"

QRCODE 100,240,L,8,A,0,"${data.barcode}"

TEXT 70,520,"3",0,2,2,"${data.barcode}"

PRINT 1
''';

    await PrintBluetoothThermal.writeBytes(
      utf8.encode(tspl),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Printed Successfully")),
    );
  }
}

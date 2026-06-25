import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'ComponentReportmodel.dart';


class ComponentReportScreen extends StatefulWidget {
  const ComponentReportScreen({Key? key}) : super(key: key);

  @override
  State<ComponentReportScreen> createState() =>
      _ComponentReportScreenState();
}

class _ComponentReportScreenState
    extends State<ComponentReportScreen> {

  DateTimeRange? selectedRange;
  List<Comp_NardanaReportModel> reportList = [];
  DateTime get from =>
      selectedRange?.start ?? DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime get to =>
      selectedRange?.end ?? DateTime.now();
  bool isLoading = false;
  int currentPage = 1;
  int pageSize = 50;
  bool hasNextPage = true;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  /// ================= FETCH =================
  Future<void> fetchReport() async {
    setState(() => isLoading = true);

    final fromDate = _formatDate(from);
    final toDate = _formatDate(to);

    print("👉 FROM: $fromDate");
    print("👉 TO: $toDate");

    try {
      final data = await InStockService().getComponentReport(
        fromDate: fromDate,
        toDate: toDate,
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      setState(() {
        reportList = data;
        hasNextPage = data.length == pageSize;
      });

    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    }

    setState(() => isLoading = false);
  }

  /// ================= DATE PICKER =================
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
        currentPage = 1;
      });
      fetchReport();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /// ================= TOTALS =================
  int get totalRecords => reportList.length;
  double get totalPcs =>
      reportList.fold(0, (sum, e) => sum + e.pcs);
  int get totalPending =>
      reportList.fold(0, (sum, e) => sum + e.pending);

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text("Component Wise Report",
            style: TextStyle(color: C.bg)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.calendar_month, color: C.bg),
          )
        ],
        iconTheme: IconThemeData(color: C.bg),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _summaryBar(),
            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
                  : reportList.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("No Data Found"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: fetchReport,
                    child: const Text("Retry"),
                  )
                ],
              )
                  : _buildTable(),
            ),

            const SizedBox(height: 10),
            _paginationControls(),
          ],
        ),
      ),
    );
  }



  /// ================= SUMMARY =================
  Widget _summaryBar() {
    return Row(
      children: [
        _box("Records", totalRecords.toString(), Colors.blue),
        _box("Total PCS", totalPcs.toStringAsFixed(2), Colors.orange),
        _box("Pending", totalPending.toString(), Colors.red),
      ],
    );
  }

  Widget _box(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              /// HEADER
              Container(
                color: C.primary,
                child: Row(
                  children: const [
                    _HeaderCell("PO No", 140),
                    _HeaderCell("Article", 140),
                    _HeaderCell("WO No", 100),
                    _HeaderCell("Party", 160),
                    _HeaderCell("Component", 120),
                    _HeaderCell("WO Qty", 100),
                    _HeaderCell("Roll Size", 100),
                    _HeaderCell("PCS", 100),
                    _HeaderCell("Cut PCS", 100),
                    _HeaderCell("Wastage", 100),
                    _HeaderCell("Pending", 100),
                  ],
                ),
              ),

              /// DATA
              ...reportList.asMap().entries.map((entry) {
                int index = entry.key;
                var e = entry.value;

                return Container(
                  color: index % 2 == 0
                      ? Colors.white
                      : Colors.grey.shade50, // zebra effect
                  child: Row(
                    children: [
                      _DataCell(e.pono, 140),
                      _DataCell(e.articleNo, 140),
                      _DataCell(e.woNo, 100),
                      _DataCell(e.partyName, 160),
                      _DataCell(e.compName, 120),
                      _DataCell(e.woQty, 100),
                      _DataCell(e.rollSize, 100),
                      _DataCell(e.pcs?.toStringAsFixed(2), 100),
                      _DataCell(e.noOfPcs, 100),
                      _DataCell(e.wastage?.toStringAsFixed(2), 100),
                      _DataCell(e.pending, 100),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  /// ================= PAGINATION =================
  Widget _paginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1
              ? () {
            setState(() => currentPage--);
            fetchReport();
          }
              : null,
          child: const Text("Previous"),
        ),

        const SizedBox(width: 20),
        Text("Page $currentPage"),
        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: hasNextPage
              ? () {
            setState(() => currentPage++);
            fetchReport();
          }
              : null,
          child: const Text("Next"),
        ),
      ],
    );
  }
}

/// ================= CELLS =================
class _DataCell extends StatelessWidget {
  final dynamic value;
  final double width;

  const _DataCell(this.value, this.width);

  String get displayText {
    if (value == null) return "-";
    if (value.toString().trim().isEmpty) return "-";
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        displayText,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: value == null ? Colors.grey : Colors.black,
          fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}


class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'RollWiseReportModel.dart';


/// ================= SCREEN =================
class RollWiseReportScreen extends StatefulWidget {
  const RollWiseReportScreen({Key? key}) : super(key: key);

  @override
  State<RollWiseReportScreen> createState() =>
      _RollWiseReportScreenState();
}

class _RollWiseReportScreenState
    extends State<RollWiseReportScreen> {
  DateTimeRange? selectedRange;

  List<RollWiseReportModel> reportList = [];
  bool isLoading = false;
  int currentPage = 1;
  int pageSize = 100;
  bool hasNextPage = true;

  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );

    fetchReport();
  }

  /// ================= FETCH =================
  Future<void> fetchReport({bool showLoader = true}) async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;

      if (showLoader) {
        isLoading = true;
      }
    });

    try {
      final data = await InStockService().getRollWiseReport(
        fromDate: _formatDate(selectedRange!.start),
        toDate: _formatDate(selectedRange!.end),
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        reportList = data;
        hasNextPage = data.length >= pageSize;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });

      _showSnack(
        e.toString(),
        Colors.red,
      );
    }
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

  /// ================= HELPERS =================
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /// ================= TOTALS =================
  double get totalMtr =>
      reportList.fold(0, (sum, e) => sum + e.rollMtr);

  double get totalWt =>
      reportList.fold(0, (sum, e) => sum + e.netWt);

  int get totalRecords => reportList.length;

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text("Roll Wise Report",style: TextStyle(color: C.bg),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.calendar_month,color: C.bg,),
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
                  ? const Center(child: Text("No Data Found"))
                  : _buildTable(),
            ),

            const SizedBox(height: 10),
            _paginationControls(),
          ],
        ),
      ),
    );
  }

  /// ================= TABLE =================
  /// ================= TABLE =================
  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
        constraints.maxWidth < 1900 ? 1900 : constraints.maxWidth;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(60),
                      1: FixedColumnWidth(110),
                      2: FixedColumnWidth(80),
                      3: FixedColumnWidth(140),
                      4: FixedColumnWidth(100),
                      5: FixedColumnWidth(80),
                      6: FixedColumnWidth(80),
                      7: FixedColumnWidth(110),
                      8: FixedColumnWidth(150),
                      9: FixedColumnWidth(100),
                      10: FixedColumnWidth(100),
                      11: FixedColumnWidth(100),
                      12: FixedColumnWidth(100),
                      13: FixedColumnWidth(100),
                      14: FixedColumnWidth(110),
                      15: FixedColumnWidth(100),
                      16: FixedColumnWidth(100),
                      17: FixedColumnWidth(90),
                      18: FixedColumnWidth(150),
                      19: FixedColumnWidth(110),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                      verticalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                    ),
                    children: [
                      /// ================= HEADER =================
                      TableRow(
                        decoration: BoxDecoration(
                          color: C.headerBlue,
                        ),
                        children: const [
                          _HeaderCell("SrNo"),
                          _HeaderCell("Article"),
                          _HeaderCell("BOM"),
                          _HeaderCell("Customer"),
                          _HeaderCell("PO No"),
                          _HeaderCell("Width"),
                          _HeaderCell("GSM"),
                          _HeaderCell("Roll No"),
                          _HeaderCell("Party"),
                          _HeaderCell("MTR"),
                          _HeaderCell("Roll Size"),
                          _HeaderCell("Gross"),
                          _HeaderCell("Tare"),
                          _HeaderCell("Net"),
                          _HeaderCell("Used Net"),
                          _HeaderCell("Wastage"),
                          _HeaderCell("Balance"),
                          _HeaderCell("Cut PCS"),
                          _HeaderCell("Remark"),
                          _HeaderCell("Date"),
                        ],
                      ),

                      /// ================= DATA =================
                      ...reportList.map(
                            (e) => TableRow(
                          decoration: BoxDecoration(
                            color: reportList.indexOf(e).isEven
                                ? Colors.white
                                : Colors.grey.shade50,
                          ),
                          children: [
                            _DataCell(e.srno),
                            _DataCell(e.articleNo),
                            _DataCell(e.bom),
                            _DataCell(e.customerName),
                            _DataCell(e.pono),
                            _DataCell(e.fabricWidth),
                            _DataCell(e.fabricGsm),
                            _DataCell(e.rollNo),
                            _DataCell(e.partyName),

                            _DataCell(
                              e.rollMtr,
                              formatter: (value) =>
                                  value.toStringAsFixed(0),
                            ),

                            _DataCell(e.rollSize),

                            _DataCell(
                              e.grossWt,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(
                              e.tareWt,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(
                              e.netWt,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(
                              e.usedNetWt,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(
                              e.usedWastage,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(
                              e.balance,
                              formatter: (value) =>
                                  value.toStringAsFixed(2),
                            ),

                            _DataCell(e.cutPcs),

                            _DataCell(e.remark),

                            _DataCell(
                              e.cutDate,
                              formatter: (value) {
                                try {
                                  return DateFormat('dd-MM-yyyy')
                                      .format(value);
                                } catch (_) {
                                  return '---';
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  /// ================= SUMMARY =================
  Widget _summaryBar() {
    return Row(
      children: [
        _box("Records", totalRecords.toString(), C.bg),
        // _box("Total MTR", totalMtr.toStringAsFixed(0), Colors.orange),
        _box("Total Wt", totalWt.toStringAsFixed(2), C.bg),
      ],
    );
  }

  Widget _box(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:C.primary,
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
  final String Function(dynamic value)? formatter;

  const _DataCell(
      this.value, {
        this.formatter,
      });

  bool get isNullValue {
    if (value == null) return true;

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty || text.toLowerCase() == 'null') {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isNull = isNullValue;

    String text = '---';

    if (!isNull) {
      try {
        text = formatter != null
            ? formatter!(value)
            : value.toString();
      } catch (_) {
        text = '---';
      }
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          isNull ? FontWeight.w600 : FontWeight.normal,
          color: isNull ? Colors.red : Colors.black87,
        ),
      ),
    );
  }
}
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: C.bg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
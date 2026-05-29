import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/CountRecords/CountRecords.dart';
import '../ReportmodelClass/ReportModelClass.dart';
import '../ReportmodelClass/WebbInReportModelClass.dart';

class WebbingInReport extends StatefulWidget {
  const WebbingInReport({Key? key}) : super(key: key);

  @override
  State<WebbingInReport> createState() => _WebbingInReportState();
}

class _WebbingInReportState extends State<WebbingInReport> {
  DateTimeRange? selectedRange;

  bool isLoading = false;
  List<WebbingInReportModel> reportList = [];

  // ✅ FILTER (IMPORTANT FOR TOTALS)
  List<WebbingInReportModel> get _filtered => reportList;

  // ✅ TOTALS
  double get _totalNet =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.rollWeightKg);

  // double get _totalLength =>
  //     ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);

  // ================= FETCH REPORT =================

  Future<void> fetchReport() async {
    if (selectedRange == null) {
      _showSnack("Please select date range", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final reports = await InStockService().getWebbingInReport(
        dateFrom: _formatDate(selectedRange!.start),
        dateTo: _formatDate(selectedRange!.end),
      );

      setState(() {
        reportList = reports;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Report Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() => selectedRange = picked);
      await fetchReport(); // auto apply filter
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 DATE RANGE FILTER
            InkWell(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedRange == null
                          ? "Select Date Range"
                          : "${DateFormat('dd-MM-yyyy').format(selectedRange!.start)}  →  ${DateFormat('dd-MM-yyyy').format(selectedRange!.end)}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.date_range),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 TABLE SECTION
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportList.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : _buildTable(),
            ),

            /// SUMMARY BAR
            _summaryBar(),

          ],
        ),
      ),
    );
  }

  // ================= DATE FIELD =================

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          date == null ? "Select Date" : DateFormat('dd-MM-yyyy').format(date),
        ),
      ),
    );
  }

  // ================= TABLE =================

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,

            child: Column(
              children: [

                /// 🔹 HEADER
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: const [
                      _HeaderCell("SR No", 80),
                      _HeaderCell("Barcode", 120),
                      _HeaderCell("Lot No", 120),
                      _HeaderCell("Net Wt", 90),
                      _HeaderCell("Qty", 80),
                      _HeaderCell("Party", 140),
                      _HeaderCell("Supervisor", 140),
                      _HeaderCell("Operator", 100),
                      _HeaderCell("Machine", 100),
                      _HeaderCell("Dept", 100),
                      _HeaderCell("Date", 120),
                    ],
                  ),
                ),

                /// 🔹 VERTICAL SCROLL ONLY FOR DATA
                SizedBox(
                  height: constraints.maxHeight - 50, // header space adjust
                  child: SingleChildScrollView(
                    child: Column(
                      children: reportList.map((item) {
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: Row(
                            children: [
                              _DataCell(item.srNo.toString(), 80),
                              _DataCell(item.barcode, 120),
                              // _DataCell(item.lotNo, 120),
                              // _DataCell(item.netWt.toString(), 90),
                              // _DataCell(item.quantity.toString(), 80),
                              // _DataCell(item.partyName, 140),
                              // _DataCell(item.supervisor, 140),
                              // _DataCell(item.operator, 100),
                              // _DataCell(item.machine, 100),
                              // _DataCell(item.department, 100),
                              _DataCell(
                                DateFormat('dd-MM-yyyy').format(item.date),
                                120,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Records", "$_totalRecords", Colors.blue),
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

class _DataCell extends StatelessWidget {
  final String text;
  final double width;

  const _DataCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

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
  int pageSize = 3000;
  bool hasNextPage = true;

  /// ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  /// ================= FETCH =================
  Future<void> fetchReport() async {
    setState(() => isLoading = true);

    try {
      /// 🔥 Dynamic page size
      pageSize = selectedRange == null ? 3000 : 50;

      final data = await InStockService().getRollWiseReport(
        fromDate: selectedRange != null
            ? _formatDate(selectedRange!.start)
            : null,
        toDate: selectedRange != null
            ? _formatDate(selectedRange!.end)
            : null,
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      setState(() {
        reportList = data;

        /// 🔥 pagination logic
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
      // appBar: AppBar(
      //   backgroundColor: C.primaryBlue,
      //   title: const Text("Roll Wise Report",style: TextStyle(color: C.bg),),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       onPressed: _pickDateRange,
      //       icon: const Icon(Icons.calendar_month,color: C.bg,),
      //     )
      //   ],
      //   iconTheme: IconThemeData(color: C.bg),
      // ),
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
  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              color: Colors.grey.shade200,
              child: Row(
                children: const [
                  _HeaderCell("SrNo", 70),
                  _HeaderCell("Article", 120),
                  _HeaderCell("BOM", 100),
                  _HeaderCell("Customer", 150),
                  _HeaderCell("PO No", 150),
                  _HeaderCell("Width", 80),
                  _HeaderCell("GSM", 80),
                  _HeaderCell("Roll No", 100),
                  _HeaderCell("Party", 150),
                  _HeaderCell("MTR", 100),
                  _HeaderCell("Roll Size", 100),
                  _HeaderCell("Gross", 100),
                  _HeaderCell("Tare", 100),
                  _HeaderCell("Net", 100),
                  _HeaderCell("Used Net", 120),
                  _HeaderCell("Wastage", 100),
                  _HeaderCell("Balance", 100),
                  _HeaderCell("Cut PCS", 100),
                  _HeaderCell("Remark", 100),
                  _HeaderCell("Date", 120),
                ],
              ),
            ),

            /// DATA
            ...reportList.map((e) {
              return Row(
                children: [
                  _DataCell(e.srno, 70),
                  _DataCell(e.articleNo, 120),
                  _DataCell(e.bom, 100),
                  _DataCell(e.customerName, 150),
                  _DataCell(e.pono, 150),
                  _DataCell(e.fabricWidth, 80),
                  _DataCell(e.fabricGsm, 80),
                  _DataCell(e.rollNo, 100),
                  _DataCell(e.partyName, 150),
                  _DataCell(e.rollMtr.toStringAsFixed(0), 100),
                  _DataCell(e.rollSize, 100),
                  _DataCell(e.grossWt.toStringAsFixed(2), 100),
                  _DataCell(e.tareWt.toStringAsFixed(2), 100),
                  _DataCell(e.netWt.toStringAsFixed(2), 100),
                  _DataCell(e.usedNetWt.toStringAsFixed(2), 120),
                  _DataCell(e.usedWastage.toStringAsFixed(2), 100),
                  _DataCell(e.balance.toStringAsFixed(2), 100),
                  _DataCell(e.cutPcs.toString(), 100),
                  _DataCell(e.remark, 100),
                  _DataCell(
                    DateFormat('dd-MM-yyyy').format(e.cutDate),
                    120,
                  ),
                ],
              );
            }),
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
        // _box("Total MTR", totalMtr.toStringAsFixed(0), Colors.orange),
        _box("Total Wt", totalWt.toStringAsFixed(2), Colors.green),
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
  final String text;
  final double width;

  const _DataCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      child: Text(text, overflow: TextOverflow.ellipsis),
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
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
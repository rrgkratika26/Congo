import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'CuttingReport_Model.dart';
import 'RollWiseReportModel.dart';


/// ================= SCREEN =================
class Cutting_InReportSCreen extends StatefulWidget {
  const Cutting_InReportSCreen({Key? key}) : super(key: key);

  @override
  State<Cutting_InReportSCreen> createState() =>
      _Cutting_InReportSCreenState();
}

class _Cutting_InReportSCreenState
    extends State<Cutting_InReportSCreen> {
  DateTimeRange? selectedRange;

  List<CuttingReportModel> reportList = [];
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
  Future<void> fetchReport({DateTimeRange? range}) async {
    setState(() => isLoading = true);

    final usedRange = range ?? selectedRange;

    final fromDate = _formatDate(
      usedRange?.start ?? DateTime.now(),
    );

    final toDate = _formatDate(
      (usedRange?.end ?? DateTime.now()).add(const Duration(days: 1)),
    );

    print("👉 FINAL FROM: $fromDate");
    print("👉 FINAL TO: $toDate");

    try {
      final data = await InStockService().getCuttingReport(
        fromDate: fromDate,
        toDate: toDate,
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        reportList = data;
        hasNextPage = data.length == pageSize;
      });

    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    }

    if (mounted) {
      setState(() => isLoading = false);
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
        reportList.clear(); // IMPORTANT: avoid showing old data
      });

      await fetchReport(); // IMPORTANT: wait for fresh data
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
      reportList.fold(0, (sum, e) => sum + e.rollSize);

  // double get totalWt =>
  //     reportList.fold(0, (sum, e) => sum + e.);

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
                  _HeaderCell("PO No", 120),
                  _HeaderCell("Article", 120),
                  _HeaderCell("WO No", 100),
                  _HeaderCell("Party", 180),
                  _HeaderCell("Component", 120),
                  _HeaderCell("WO Qty", 100),
                  _HeaderCell("Roll Size", 100),
                  _HeaderCell("PCS", 100),
                  _HeaderCell("No Of PCS", 120),
                  _HeaderCell("Wastage", 100),
                  _HeaderCell("Pending", 100),
                ],
              ),
            ),

            /// DATA
            ...reportList.map((e) {
              return Row(
                children: [
                  _DataCell(e.pono, 120),
                  _DataCell(e.articleNo, 120),
                  _DataCell(e.woNo, 100),
                  _DataCell(e.partyName, 180),
                  _DataCell(e.compName, 120),
                  _DataCell(e.woQty.toString(), 100),
                  _DataCell(e.rollSize as String, 100),
                  _DataCell(e.pcs.toStringAsFixed(2), 100),
                  _DataCell(e.noOfPcs.toString(), 120),
                  _DataCell(e.wastage.toStringAsFixed(2), 100),
                  _DataCell(e.pending.toString(), 100),
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
        _box("Total MTR", totalMtr.toStringAsFixed(0), Colors.orange),
        // _box("Total Wt", totalWt.toStringAsFixed(2), Colors.green),
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
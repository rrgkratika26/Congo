import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/CountRecords/CountRecords.dart';
import 'InReportModel.dart';


class CuttingInReport extends StatefulWidget {
  const CuttingInReport({Key? key}) : super(key: key);

  @override
  State<CuttingInReport> createState() => _CuttingInReportState();
}

class _CuttingInReportState extends State<CuttingInReport> {
  DateTimeRange? selectedRange;

  bool isLoading = false;
  List<CuttingInReportModel> reportList = [];

  /// ✅ FILTER
  List<CuttingInReportModel> get _filtered => reportList;
  int currentPage = 1;
  final int pageSize= 50000000;
  bool hasNextPage = true;
  /// ✅ TOTALS
  double get _totalRollWt =>
      ReportTotalHelper.totalNetWeight(_filtered, (e) => e.netWeight);

  double get _totalRollMtr =>
      ReportTotalHelper.totalRollLength(_filtered, (e) => e.rollLength);

  int get _totalRecords =>
      ReportTotalHelper.totalRecords(_filtered);

  // ================= FETCH REPORT =================
  @override
  void initState() {
    super.initState();

    /// 🔥 DEFAULT DATE RANGE (LAST 5 DAYS)
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 4)),
      end: now,
    );

    fetchReport(); // auto load
  }
  Future<void> fetchReport() async {
    if (selectedRange == null) {
      _showSnack("Please select date range", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final reports = await InStockService().getCuttingInReport(
        dateFrom: _formatDate(selectedRange!.start),
        dateTo: _formatDate(selectedRange!.end),
        pageNumber: currentPage,   // ✅ ADD
        pageSize: pageSize,
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
      await fetchReport();
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.primary,

        title: const Text("In Reports",style: TextStyle(color: C.bg),),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.calendar_month,color: C.bg,),
          ),
        ],
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // /// 🔹 DATE RANGE
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       selectedRange == null
              //           ? "Select Date"
              //           : "${DateFormat('dd MMM').format(selectedRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedRange!.end)}",
              //       style: const TextStyle(fontWeight: FontWeight.w500),
              //     ),
              //     IconButton(
              //       onPressed: _pickDateRange,
              //       icon: const Icon(Icons.calendar_month),
              //     ),
              //   ],
              // ),
              /// 🔹 SUMMARY
              _summaryBar(),
              const SizedBox(height: 20),

              /// 🔹 TABLE
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: C.appBar3,),
                )
                    : reportList.isEmpty
                    ? const Center(
                  child: Text("No Data Found"),
                )
                    : _buildTable(),
              ),

              const SizedBox(height: 10),
              _paginationControls(),
            ],
          ),
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
                      _HeaderCell("ID", 70),
                      _HeaderCell("Roll Code", 100),
                      _HeaderCell("Barcode", 120),
                      _HeaderCell("Batch No", 120),
                      _HeaderCell("Loom Type", 110),
                      _HeaderCell("Loom No", 90),
                      _HeaderCell("Fabric Code", 180),
                      _HeaderCell("Gross Wt", 100),
                      _HeaderCell("Net Wt", 100),
                      _HeaderCell("Roll Length", 110),
                      _HeaderCell("Avg Wt", 100),
                      _HeaderCell("Operator", 140),
                      _HeaderCell("Time", 90),
                      _HeaderCell("Loom Operator", 140),
                      _HeaderCell("GSM/Mtr", 100),
                      _HeaderCell("Supervisor", 140),
                      _HeaderCell("Party", 120),
                      _HeaderCell("WO No", 170),
                      _HeaderCell("Cont No", 170),
                      _HeaderCell("Req Qty Kg", 110),
                      _HeaderCell("Req Qty Mtr", 120),
                      _HeaderCell("Tare Weight", 140),
                      _HeaderCell("Department", 120),
                      _HeaderCell("Issue Dept", 120),
                      _HeaderCell("Status", 100),
                      _HeaderCell("Entry In", 100),
                      _HeaderCell("Entry Out", 100),
                      _HeaderCell("Mash", 90),
                      _HeaderCell("Fabric Use", 120),
                      _HeaderCell("Fabric Const", 130),
                      _HeaderCell("Color", 90),
                      _HeaderCell("Fabric Width", 120),
                      _HeaderCell("Fabric GSM", 110),
                      _HeaderCell("Lamination", 120),
                      _HeaderCell("Cut Slip", 110),
                      _HeaderCell("Special ID", 120),
                      _HeaderCell("Date", 120),
                    ],
                  ),
                ),

                /// 🔹 DATA
                SizedBox(
                  height: constraints.maxHeight - 50,
                  child: SingleChildScrollView(
                    child: Column(
                      children: reportList.map((item) {
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _DataCell(item.id.toString(), 70),

                              _DataCell(item.rollCode, 100),

                              _DataCell(item.barcode, 120),

                              _DataCell(item.batchNo, 120),

                              _DataCell(item.loomType, 110),

                              _DataCell(item.loomNo, 90),

                              _DataCell(item.fabricCode, 180),

                              _DataCell(
                                item.grossWeight.toStringAsFixed(2),
                                100,
                              ),

                              _DataCell(
                                item.netWeight.toStringAsFixed(2),
                                100,
                              ),

                              _DataCell(
                                item.rollLength.toStringAsFixed(0),
                                110,
                              ),

                              _DataCell(
                                item.avgWeight.toStringAsFixed(2),
                                100,
                              ),

                              _DataCell(item.operatorName, 140),

                              _DataCell(item.time, 90),

                              _DataCell(item.loomOperator1, 140),

                              _DataCell(
                                item.gsmMtrGm.toStringAsFixed(2),
                                100,
                              ),

                              _DataCell(item.supervisorName, 140),

                              _DataCell(item.partyName, 120),

                              _DataCell(item.workOrderNo, 170),

                              _DataCell(item.contNo, 170),

                              _DataCell(
                                item.requiredQuantityKg
                                    .toStringAsFixed(2),
                                110,
                              ),

                              _DataCell(
                                item.requiredQuantityMtr
                                    .toStringAsFixed(2),
                                120,
                              ),

                              _DataCell(item.tareWeight, 140),

                              _DataCell(item.department, 120),

                              _DataCell(item.issueToDept, 120),

                              _DataCell(item.status, 100),

                              _DataCell(item.entryIn, 100),

                              _DataCell(item.entryOut, 100),

                              _DataCell(item.mash, 90),

                              _DataCell(
                                item.fabricTypeFabricUse,
                                120,
                              ),

                              _DataCell(
                                item.fabricConstruction,
                                130,
                              ),

                              _DataCell(item.color, 90),

                              _DataCell(item.fabricWidth, 120),

                              _DataCell(item.fabricGsm, 110),

                              _DataCell(item.laminationType, 120),

                              _DataCell(item.cutSlipType, 110),

                              _DataCell(
                                item.specialIdentification,
                                120,
                              ),

                              _DataCell(
                                DateFormat('dd-MM-yyyy')
                                    .format(item.date),
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

  // ================= SUMMARY =================

  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _box("Records", "$_totalRecords", Colors.blue),
          _box(
            "Roll Wt(Kg)",
            _totalRollWt.toStringAsFixed(2),
            Colors.green,
          ),
          _box(
            "Roll Mtr",
            _totalRollMtr.toString(),
            Colors.orange,
          ),
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

        Text(
          "Page $currentPage",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: hasNextPage
              ? () {
            setState(() => currentPage++);
            fetchReport();
          }
              : null,
          child: const Text("Next",style: TextStyle(color: C.textHigh),),
        ),
      ],
    );
  }
}

// ================= DATA CELL =================

class _DataCell extends StatelessWidget {
  final String text;
  final double width;

  const _DataCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

// ================= HEADER CELL =================

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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
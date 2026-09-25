import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'CuttingOutReportModel.dart';

class CuttingOutReport extends StatefulWidget {
  const CuttingOutReport({Key? key}) : super(key: key);

  @override
  State<CuttingOutReport> createState() => _CuttingOutReportState();
}

class _CuttingOutReportState extends State<CuttingOutReport> {
  bool isLoading = false;

  List<CuttingOutReportModel> reportList = [];

  int currentPage = 1;

  final int pageSize = 50;

  bool hasNextPage = true;

  // ============================================================
  // TOTALS
  // ============================================================

  int get _totalRecords {
    return reportList.length;
  }

  int get _totalPcs {
    return reportList.fold(0, (sum, item) => sum + item.pcs);
  }

  double get _totalNetWeight {
    return reportList.fold(0.0, (sum, item) => sum + item.netWt);
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> fetchReport() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final reports = await InStockService().getCuttingOutReport(
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        reportList = reports;

        // If API returns less than pageSize,
        // there is no next page.
        hasNextPage = reports.length >= pageSize;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        reportList = [];
        hasNextPage = false;
      });

      _showSnack('Report Error: $e', Colors.red);
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshReport() async {
    currentPage = 1;
    hasNextPage = true;

    await fetchReport();
  }

  // ============================================================
  // GO TO PAGE
  // ============================================================

  Future<void> _goToPage(int page) async {
    if (page < 1) return;

    if (isLoading) return;

    setState(() {
      currentPage = page;
    });

    await fetchReport();
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isNarrow = screenWidth < 380;

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 1,

        iconTheme: const IconThemeData(color: C.bg),

        title: const Text(
          'Cutting Out Report',
          style: TextStyle(color: C.bg, fontWeight: FontWeight.w600),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: 'Refresh',

            onPressed: isLoading ? null : _refreshReport,

            icon: const Icon(Icons.refresh, color: C.bg),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isNarrow ? 10 : 16),

          child: Column(
            children: [
              // ==================================================
              // SUMMARY
              // ==================================================
              _summaryBar(isNarrow),

              const SizedBox(height: 15),

              // ==================================================
              // TABLE
              // ==================================================
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: C.appBar3),
                      )
                    : reportList.isEmpty
                    ? _emptyView()
                    : _buildTable(isNarrow),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PAGINATION
              // ==================================================
              _paginationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_cut_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 10),

          Text(
            'No Cutting Out Data Found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: _refreshReport,

            icon: const Icon(Icons.refresh),

            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable(bool isNarrow) {
    // Slightly reduce column widths on narrow screens.
    final scale = isNarrow ? 0.85 : 1.0;

    double w(double base) {
      return base * scale;
    }

    final columns = <_ColumnSpec>[
      _ColumnSpec('S.No', w(60)),

      _ColumnSpec('Party Name', w(180)),

      _ColumnSpec('BOM No', w(100)),

      _ColumnSpec('Component', w(120)),

      _ColumnSpec('Cut Length', w(110)),

      _ColumnSpec('Cut Width', w(110)),

      _ColumnSpec('PCS', w(90)),

      _ColumnSpec('Net Wt (Kg)', w(110)),

      _ColumnSpec('Wt/Pcs', w(110)),

      _ColumnSpec('Issue Department', w(160)),

      _ColumnSpec('Issue Date', w(150)),
    ];

    // ==========================================================
    // TABLE SCROLL
    // ==========================================================

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),

        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisSize: MainAxisSize.min,

            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,

                  border: Border.all(color: Colors.black12),
                ),

                padding: const EdgeInsets.symmetric(vertical: 12),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: columns
                      .map((column) => _HeaderCell(column.label, column.width))
                      .toList(),
                ),
              ),

              // ==================================================
              // DATA
              // ==================================================
              Column(
                mainAxisSize: MainAxisSize.min,

                children: List.generate(reportList.length, (index) {
                  final item = reportList[index];

                  final values = <String>[
                    // S.NO
                    '${((currentPage - 1) * pageSize) + index + 1}',

                    // PARTY
                    item.partyName,

                    // BOM
                    item.bomNo,

                    // COMPONENT
                    item.component,

                    // CUT LENGTH
                    item.cutLength.toStringAsFixed(2),

                    // CUT WIDTH
                    item.cutWidth.toStringAsFixed(2),

                    // PCS
                    item.pcs.toString(),

                    // NET WT
                    item.netWt.toStringAsFixed(3),

                    // WT / PCS
                    item.weightPerPcs.toStringAsFixed(3),

                    // ISSUE DEPARTMENT
                    item.issueDepartment,

                    // ISSUE DATE
                    _formatDateTime(item.issueDate),
                  ];

                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black12),

                        right: BorderSide(color: Colors.black12),

                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: List.generate(
                        columns.length,
                        (i) => _DataCell(values[i], columns[i].width),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY BAR
  // ============================================================

  Widget _summaryBar(bool isNarrow) {
    final boxes = [
      _SummaryData('Records', _totalRecords.toString(), C.primary),

      _SummaryData('Total PCS', _totalPcs.toString(), C.warning),

      _SummaryData(
        'Net Wt (Kg)',
        _totalNetWeight.toStringAsFixed(2),
        C.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const minBoxWidth = 100.0;

        final canFitAllInRow =
            constraints.maxWidth >= minBoxWidth * boxes.length + 24;

        // ======================================================
        // NORMAL WIDTH
        // ======================================================

        if (canFitAllInRow) {
          return Row(
            children: boxes
                .map(
                  (box) =>
                      Expanded(child: _box(box.title, box.value, box.color)),
                )
                .toList(),
          );
        }

        // ======================================================
        // NARROW WIDTH
        // ======================================================

        return Wrap(
          spacing: 8,
          runSpacing: 8,

          children: boxes
              .map(
                (box) => SizedBox(
                  width: (constraints.maxWidth - 8) / 2,

                  child: _box(box.title, box.value, box.color),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ============================================================
  // SUMMARY BOX
  // ============================================================

  Widget _box(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        border: Border.all(color: color),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // ====================================================
          // TITLE
          // ====================================================
          FittedBox(
            fit: BoxFit.scaleDown,

            child: Text(
              title,

              maxLines: 1,

              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ====================================================
          // VALUE
          // ====================================================
          FittedBox(
            fit: BoxFit.scaleDown,

            child: Text(
              value,

              maxLines: 1,

              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIMPLE PAGINATION BAR
  // ============================================================

  Widget _paginationBar() {
    final startRecord = reportList.isEmpty
        ? 0
        : ((currentPage - 1) * pageSize) + 1;

    final endRecord = reportList.isEmpty
        ? 0
        : ((currentPage - 1) * pageSize) + reportList.length;

    return Container(
      color: Colors.white,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      child: Row(
        children: [
          // ====================================================
          // SHOWING RECORDS
          // ====================================================
          Expanded(
            child: Text(
              reportList.isEmpty
                  ? '0 records'
                  : 'Showing $startRecord - $endRecord',

              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ====================================================
          // PAGE NUMBER
          // ====================================================
          Text(
            'Page $currentPage',

            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(width: 4),

          // ====================================================
          // PREVIOUS BUTTON
          // ====================================================
          IconButton(
            tooltip: 'Previous',

            visualDensity: VisualDensity.compact,

            onPressed: (!isLoading && currentPage > 1)
                ? () {
                    _goToPage(currentPage - 1);
                  }
                : null,

            icon: const Icon(Icons.chevron_left),
          ),

          // ====================================================
          // NEXT BUTTON
          // ====================================================
          IconButton(
            tooltip: 'Next',

            visualDensity: VisualDensity.compact,

            onPressed: (!isLoading && hasNextPage)
                ? () {
                    _goToPage(currentPage + 1);
                  }
                : null,

            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SUMMARY DATA
// ================================================================

class _SummaryData {
  final String title;
  final String value;
  final Color color;

  _SummaryData(this.title, this.value, this.color);
}

// ================================================================
// COLUMN SPECIFICATION
// ================================================================

class _ColumnSpec {
  final String label;
  final double width;

  _ColumnSpec(this.label, this.width);
}

// ================================================================
// HEADER CELL
// ================================================================

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

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// ================================================================
// DATA CELL
// ================================================================

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

        maxLines: 1,

        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

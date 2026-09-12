import 'package:flutter/material.dart';

import 'package:IMS/services/DashboardApiServices.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

import 'BagDesignScreen.dart';

import 'ModelFIBCBag/BagComponent.dart';
import 'ModelFIBCBag/BagModel.dart' as bagModel;

class InquiryMarketingReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String inquiryNo;

  const InquiryMarketingReportScreen({
    Key? key,
    this.startDate,
    this.endDate,
    required this.inquiryNo,
  }) : super(key: key);

  @override
  State<InquiryMarketingReportScreen> createState() =>
      _InquiryMarketingReportScreenState();
}

class _InquiryMarketingReportScreenState
    extends State<InquiryMarketingReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  Map<String, dynamic>? report;

  bool isLoading = false;
  bool isOpeningDesign = false;

  @override
  void initState() {
    super.initState();

    _fromDate =
        widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));

    _toDate = widget.endDate ?? DateTime.now();

    loadInquiryReport();
  }

  // ============================================================
  // API DATE
  // ============================================================

  String _apiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> loadInquiryReport() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await NaradanaApiService().fetchInquiryReport(
        fromDate: _apiDate(_fromDate),
        toDate: _apiDate(_toDate),
        pageNumber: 1,
        pageSize: 50,
      );

      final match = result.firstWhere((e) {
        final apiInquiry = e["inquirY_NO_main"]?.toString().trim() ?? "";

        return apiInquiry == widget.inquiryNo.trim();
      }, orElse: () => <String, dynamic>{});

      if (!mounted) return;

      setState(() {
        report = match.isEmpty ? null : match;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        report = null;
        isLoading = false;
      });

      _showSnackBar("Unable to load inquiry details", isError: true);
    }
  }
// ============================================================
// OPEN BAG DESIGN
// ============================================================

  Future<void> _openBagDesign() async {
    final item = report;

    if (item == null) {
      _showSnackBar(
        "Inquiry data not found",
        isError: true,
      );
      return;
    }

    final inquiryNo = _text(
      item["inquirY_NO_main"],
    );

    if (inquiryNo == "-") {
      _showSnackBar(
        "Inquiry number not found",
        isError: true,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      isOpeningDesign = true;
    });

    try {
      print('------------------------------------------');
      print('Opening FIBC Bag Design');
      print('Inquiry No: $inquiryNo');
      print('Unit: UNIT-CONGO');
      print('------------------------------------------');

      final detail =
      await DashboardService().getFibcBagSpecification(
        inquiryNo: inquiryNo,
        unit: 'UNIT-CONGO',
      );

      if (!mounted) return;

      setState(() {
        isOpeningDesign = false;
      });

      if (detail == null) {
        _showSnackBar(
          "FIBC specification not found",
          isError: true,
        );
        return;
      }

      print('------------------------------------------');
      print('FIBC BAG DETAILS');
      print('Length: ${detail.length}');
      print('Width: ${detail.width}');
      print('Height: ${detail.height}');
      print('Loop Free Height: ${detail.loopFreeHeight}');
      print('Loop LL: ${detail.longLegHeight}');
      print('Loop SL: ${detail.shortLegHeight}');
      print('F/S Diameter: ${detail.fillingSpoutDiameter}');
      print('F/S Height: ${detail.fillingSpoutHeight}');
      print('D/S Diameter: ${detail.dischargeSpoutDiameter}');
      print('D/S Height: ${detail.dischargeSpoutHeight}');
      print('Construction: ${detail.construction}');
      print('Bag Type: ${detail.bagType}');
      print('SWL: ${detail.safeWorkingLoad}');
      print('Total: ${detail.total}');
      print('SF: ${detail.safetyFactor}');
      print('Components: ${detail.components.length}');
      print('------------------------------------------');

      final specification = _mapToDrawingSpec(
        detail,
        inquiryNo,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: C.bg,
            appBar: AppBar(
              backgroundColor: C.primary,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const Text(
                "Bag Design",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: StaticFibcBagCard(
                  specification: specification,
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isOpeningDesign = false;
      });

      print('OPEN BAG DESIGN ERROR: $e');

      _showSnackBar(
        "Unable to load bag design",
        isError: true,
      );
    }
  }


  FibcBagSpecification _mapToDrawingSpec(
      DashboardBagSpecification d,
      String inquiryId,
      ) {
    return FibcBagSpecification(
      inquiryId: inquiryId,

      // BAG SIZE
      length: d.length,
      width: d.width,
      height: d.height,

      // LOOP
      loopFreeHeight: d.loopFreeHeight,
      longLegHeight: d.longLegHeight,
      shortLegHeight: d.shortLegHeight,

      // FILLING SPOUT
      fillingSpoutDiameter: d.fillingSpoutDiameter,
      fillingSpoutHeight: d.fillingSpoutHeight,

      // DISCHARGE SPOUT
      dischargeSpoutDiameter: d.dischargeSpoutDiameter,
      dischargeSpoutHeight: d.dischargeSpoutHeight,

      // BAG INFORMATION
      construction: d.construction,
      bagType: d.bagType,

      // SAFETY / WEIGHT
      safeWorkingLoad: d.safeWorkingLoad,
      total: d.total,
      safetyFactor: d.safetyFactor,

      // LOOP COLOR
      loopColor: d.loopColor,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Inquiry Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              widget.inquiryNo,
              style: TextStyle(
                color: Colors.white.withOpacity(.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final item = report;

    if (item == null) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: loadInquiryReport,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(14),

        children: [

          _buildCustomerHeader(item),

          const SizedBox(height: 14),

          _buildTableSection(
            title: "Inquiry Details",
            icon: Icons.description_outlined,
            rows: [
              _row("Customer Name", item["customeR_NAME"]),

              _row("Inquiry No.", item["inquirY_NO_main"]),

              _row("Inquiry Date", _formatDate(_text(item["date"]))),

              _row("Employee", item["employee"]),

              _row("Grade", item["fG_NON_FG"]),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // BAG DETAILS
          // ==================================================
          _buildTableSection(
            title: "Bag Details",
            icon: Icons.inventory_2_outlined,
            rows: [
              _row("Bag Type", item["baG_TYPE"]),

              _row("Article No.", item["articlE_NO"]),

              _row("Quantity", item["qty"]),

              _row("Total", item["total"]),

              _row(
                "Total Ton",
                _text(item["totaL_TON"]) == "-"
                    ? "-"
                    : "${_text(item["totaL_TON"])} T",
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // WORK ORDER
          // ==================================================
          _buildTableSection(
            title: "Work Order",
            icon: Icons.assignment_outlined,
            rows: [
              _row("WO No.", item["wo"]),

              _row("WO Date", _formatDate(_text(item["wO_DATE"]))),

              _row("WO Employee", item["wO_EMPLOYEE"]),

              _row("PO No.", item["po_num"]),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // SAMPLE / QC
          // ==================================================
          _buildTableSection(
            title: "Sample & QC",
            icon: Icons.fact_check_outlined,
            rows: [
              _row("SR WO No.", item["sR_WO_NUM"]),

              _row("SR WO Date", _formatDate(_text(item["sR_WO_DATE"]))),

              _row("SR WO User", item["sR_WO_USER_NAME"]),

              _row("Issued to QC", item["issuE_TO_QC"]),

              _row("QC Person", item["issuE_PERSON"]),

              _row("Issued to Sample", item["issuE_TO_SAMPLE"]),

              _row("Sample Person", item["samplE_PERSON"]),

              _row(
                "Sample Date",
                _formatDate(_text(item["samplE_PROCESSING_DATE"])),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // BOM
          // ==================================================
          _buildTableSection(
            title: "BOM",
            icon: Icons.inventory_outlined,
            rows: [
              _row("BOM Date", _formatDate(_text(item["boM_DATE"]))),

              _row("BOM to Production", item["boM_TO_PRODUCTION"]),
            ],
          ),

          // ==================================================
          // STATUS
          // ==================================================
          if (_hasStatus(item)) ...[
            const SizedBox(height: 14),

            _buildTableSection(
              title: "Status & Remarks",
              icon: Icons.info_outline,
              rows: [
                _row("Status", item["status"]),

                _row("Status Reason", item["statuS_REASON"]),

                _row("Complaint", item["complain"]),
              ],
            ),
          ],

          const SizedBox(height: 10),

          _buildDesignButton(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER HEADER
  // ============================================================

  Widget _buildCustomerHeader(Map<String, dynamic> item) {
    final customer = _text(item["customeR_NAME"]);

    final inquiryNo = _text(item["inquirY_NO_main"]);

    final grade = _text(item["fG_NON_FG"]);

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border(left: BorderSide(color: C.primary, width: 4)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: C.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(Icons.business_outlined, color: C.primary, size: 25),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  inquiryNo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: C.primary,
                  ),
                ),
              ],
            ),
          ),

          if (grade != "-")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                grade,
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE SECTION
  // ============================================================

  Widget _buildTableSection({
    required String title,
    required IconData icon,
    required List<_InfoTableRow> rows,
  }) {
    // Remove empty rows completely.
    final visibleRows = rows.where((row) => row.value != "-").toList();

    // Don't display an empty section.
    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ----------------------------------------------
          // SECTION TITLE
          // ----------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),

            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,

                  decoration: BoxDecoration(
                    color: C.primary.withOpacity(.09),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Icon(icon, size: 16, color: C.primary),
                ),

                const SizedBox(width: 9),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252525),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // ----------------------------------------------
          // VERTICAL TABLE
          // ----------------------------------------------
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),

            child: Column(
              children: List.generate(visibleRows.length, (index) {
                final row = visibleRows[index];

                return _buildTableRow(row, index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildTableRow(_InfoTableRow row, int index) {
    final isLast = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFC),

        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: isLast ? 0 : 1,
          ),
        ),
      ),

      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // ------------------------------------------
            // LABEL
            // ------------------------------------------
            Container(
              width: 145,

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

              color: C.primary.withOpacity(.035),

              alignment: Alignment.centerLeft,

              child: Text(
                row.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            // ------------------------------------------
            // VERTICAL DIVIDER
            // ------------------------------------------
            Container(width: 1, color: Colors.grey.shade200),

            // ------------------------------------------
            // VALUE
            // ------------------------------------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),

                child: Text(
                  row.value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  _InfoTableRow _row(String label, dynamic value) {
    return _InfoTableRow(label: label, value: _text(value));
  }

  Widget _buildDesignButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton.icon(
        onPressed: isOpeningDesign ? null : _openBagDesign,

        style: ElevatedButton.styleFrom(
          backgroundColor: C.primary,

          disabledBackgroundColor: C.primary.withOpacity(.55),

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),

        icon: isOpeningDesign
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.view_in_ar_rounded, color: Colors.white),

        label: Text(
          isOpeningDesign ? "Loading Bag Design..." : "View Bag Design",

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _hasStatus(Map<String, dynamic> item) {
    return _text(item["status"]) != "-" ||
        _text(item["statuS_REASON"]) != "-" ||
        _text(item["complain"]) != "-";
  }

  String _text(dynamic value) {
    if (value == null) {
      return "-";
    }

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == "null") {
      return "-";
    }

    return text;
  }

  String _formatDate(String value) {
    if (value == "-" || value.isEmpty) {
      return "-";
    }

    try {
      final date = DateTime.parse(value);

      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];

      return "${date.day.toString().padLeft(2, '0')} "
          "${months[date.month - 1]} "
          "${date.year}";
    } catch (_) {
      return value;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          const Text(
            "No inquiry data found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: loadInquiryReport,

            icon: const Icon(Icons.refresh),

            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: isError ? Colors.red.shade700 : C.primary,

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _InfoTableRow {
  final String label;
  final String value;

  const _InfoTableRow({required this.label, required this.value});
}
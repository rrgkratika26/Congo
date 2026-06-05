import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class InquiryMarketingReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const InquiryMarketingReportScreen({Key? key, this.startDate, this.endDate})
    : super(key: key);

  @override
  State<InquiryMarketingReportScreen> createState() => _InquiryMarketingReportScreenState();
}

class _InquiryMarketingReportScreenState extends State<InquiryMarketingReportScreen> {
  // ───────────────── DATE ─────────────────
  final ScrollController _listController = ScrollController();

  bool isLoadingMore = false;
  bool hasMoreData = true;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));

  DateTime _toDate = DateTime.now();

  final ScrollController _horizCtrl = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  // ───────────────── STATIC DATA ─────────────────

  String? selectedParty;

  List<String> partyList = [];
  bool isPartyLoading = false;
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];

  bool isLoading = false;
  int pageNumber = 1;

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  // ───────────────── COLUMN WIDTHS ─────────────────

  static const double _colSrNo = 70;
  static const double _colDate = 100;
  static const double _colParty = 200;
  static const double _colInquiry = 170;
  static const double _colEmployee = 170;
  static const double _colBagType = 170;
  static const double _colArticle = 150;
  static const double _colFg = 160;
  static const double _colWo = 100;
  static const double _colWoDate = 190;
  static const double _colWoEmployee = 180;
  static const double _colPo = 200;
  static const double _colSrWo = 150;
  static const double _colSrWoDate = 170;
  static const double _colSrWoUser = 180;

  static const double _colIssueQc = 180;
  static const double _colIssuePerson = 180;

  static const double _colBomDate = 180;
  static const double _colBomProd = 180;

  static const double _colIssueSample = 180;
  static const double _colSamplePerson = 180;
  static const double _colSampleDate = 180;

  static const double _colComplaint = 180;
  static const double _colStatusReason = 180;
  static const double _colStatus = 150;

  double get _totalWidth =>
      _colSrNo +
      _colDate +
      _colParty +
      _colInquiry +
      _colEmployee +
      _colBagType +
      _colArticle +
      _colFg +
      _colWo +
      _colWoDate +
      _colWoEmployee +
      _colPo +
      _colSrWo +
      _colSrWoDate +
      _colSrWoUser +
      _colIssueQc +
      _colIssuePerson +
      _colBomDate +
      _colBomProd +
      _colIssueSample +
      _colSamplePerson +
      _colSampleDate +
      _colComplaint +
      _colStatusReason +
      _colStatus;

  // ───────────────── INIT ─────────────────

  @override
  void initState() {
    super.initState();

    if (widget.startDate != null) {
      _fromDate = widget.startDate!;
    }

    if (widget.endDate != null) {
      _toDate = widget.endDate!;
    }

    _listController.addListener(_scrollListener);
    loadParties(); // add this
    loadInquiryReport();
  }

  void _scrollListener() {
    if (_listController.position.pixels >=
            _listController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      loadMoreData();
    }
  }

  String _apiDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadParties() async {
    try {
      setState(() {
        isPartyLoading = true;
      });

      final result = await NaradanaApiService().fetchCustomerNames();

      setState(() {
        partyList = result;
        isPartyLoading = false;
      });
    } catch (e) {
      setState(() {
        isPartyLoading = false;
      });

      print(e);
    }
  }

  Future<void> loadMoreData() async {
    try {
      setState(() {
        isLoadingMore = true;
      });

      pageNumber++;

      final result = await NaradanaApiService().fetchInquiryReport(
        fromDate: _apiDate(_fromDate),
        toDate: _apiDate(_toDate),
        pageNumber: pageNumber,
        pageSize: 50,
      );

      setState(() {
        reports.addAll(result);

        _filterData();

        isLoadingMore = false;

        if (result.isEmpty || result.length < 50) {
          hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredReports = reports.where((item) {
        final matchesSearch =
            item["customeR_NAME"].toString().toLowerCase().contains(query) ||
            item["articlE_NO"].toString().toLowerCase().contains(query) ||
            item["inquirY_NO_main"].toString().toLowerCase().contains(query) ||
            item["baG_TYPE"].toString().toLowerCase().contains(query);

        final matchesParty =
            selectedParty == null || item["customeR_NAME"] == selectedParty;

        return matchesSearch && matchesParty;
      }).toList();
    });
  }

  Future<void> loadInquiryReport() async {
    try {
      pageNumber = 1;
      hasMoreData = true;

      setState(() {
        isLoading = true;
      });

      final result = await NaradanaApiService().fetchInquiryReport(
        fromDate: _apiDate(_fromDate),
        toDate: _apiDate(_toDate),
        pageNumber: pageNumber,
        pageSize: 50,
      );

      setState(() {
        reports = result;
        filteredReports = result;

        isLoading = false;

        if (result.length < 50) {
          hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearch(String value) {
    _filterData();
  }

  @override
  void dispose() {
    _horizCtrl.dispose();
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────── DATE PICKER ─────────────────

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });

      loadInquiryReport();
    }
  }

  // ───────────────── BUILD ─────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      // ───────────── APP BAR ─────────────
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 78,
        automaticallyImplyLeading: true,

        flexibleSpace: Container(color: C.primary),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ───────── TITLE ─────────
            const Text(
              "Inquiry Report",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: .4,
              ),
            ),

            const SizedBox(height: 4),

            // ───────── DATE RANGE ─────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_formatDate(_fromDate)}  →  ${_formatDate(_toDate)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        actions: [
          // ───────── DATE FILTER BUTTON ─────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(.15)),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          _buildFilterBar(),
          // _summaryBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
  // ───────────────── FILTER BAR ─────────────────

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ───────── SEARCH BAR ─────────
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: "Search inquiry, article, party...",
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF1A4A8A),
              ),
              filled: true,
              fillColor: const Color(0xFFF4F7FC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ───────── PARTY DROPDOWN ─────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParty,
                isExpanded: true,

                hint: Text(
                  isPartyLoading ? "Loading parties..." : "Select Party Name",
                ),

                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text("All Parties"),
                  ),

                  ...partyList.map(
                    (party) => DropdownMenuItem<String>(
                      value: party,
                      child: Text(party, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    selectedParty = value;
                  });

                  _filterData();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── SUMMARY ─────────────────

  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E2458), Color(0xFF1A4A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: "Total Records",
              value: filteredReports.length.toString(),
              icon: Icons.inventory_2_rounded,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              title: "Food Grade",
              value: filteredReports
                  .where((e) => e["fgNonFg"].toString().contains("FOOD"))
                  .length
                  .toString(),
              icon: Icons.check_circle_rounded,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              title: "Industrial",
              value: filteredReports
                  .where((e) => e["fgNonFg"].toString().contains("INDUSTRIAL"))
                  .length
                  .toString(),
              icon: Icons.factory_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── BODY ─────────────────

  Widget _buildBody() {
    if (filteredReports.isEmpty) {
      return const Center(child: Text("No inquiry report found"));
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
                  controller: _listController,
                  itemCount: filteredReports.length + (isLoadingMore ? 1 : 0),

                  itemBuilder: (_, index) {
                    if (index == filteredReports.length) {
                      return const Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return _buildTableRow(filteredReports[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  // ───────────────── HEADER ─────────────────

  Widget _buildTableHeader() {
    return Container(
      color: C.bg,
      child: Row(
        children: [
          _headerCell("SR", _colSrNo),
          _headerCell("DATE", _colDate),
          _headerCell("PARTY NAME", _colParty),
          _headerCell("INQUIRY", _colInquiry),
          _headerCell("EMPLOYEE", _colEmployee),
          _headerCell("BAG TYPE", _colBagType),
          _headerCell("ARTICLE", _colArticle),
          _headerCell("HYGIENE", _colFg),

          _headerCell("WO", _colWo),
          _headerCell("WO DATE", _colWoDate),
          _headerCell("WO EMPLOYEE", _colWoEmployee),

          _headerCell("PO NO", _colPo),

          _headerCell("SR WO", _colSrWo),
          _headerCell("SR WO DATE", _colSrWoDate),
          _headerCell("SR WO USER", _colSrWoUser),

          _headerCell("ISSUE QC", _colIssueQc),
          _headerCell("ISSUE PERSON", _colIssuePerson),

          _headerCell("BOM DATE", _colBomDate),
          _headerCell("BOM PROD", _colBomProd),

          _headerCell("ISSUE SAMPLE", _colIssueSample),
          _headerCell("SAMPLE PERSON", _colSamplePerson),
          _headerCell("SAMPLE DATE", _colSampleDate),

          _headerCell("COMPLAINT", _colComplaint),
          _headerCell("STATUS REASON", _colStatusReason),
          _headerCell("STATUS", _colStatus),
        ],
      ),
    );
  }

  Widget _headerCell(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: C.border)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: C.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ───────────────── ROW ─────────────────

  Widget _buildTableRow(Map<String, dynamic> item, int index) {
    final bool isFood = item["fG_NON_FG"].toString().toUpperCase().contains(
      "FOOD",
    );

    return Container(
      color: index.isEven ? Colors.white : const Color(0xFFF7F9FC),

      child: Row(
        children: [
          _dataCell("${index + 1}", _colSrNo),

          _dataCell(item["date"] ?? "", _colDate),

          _dataCell(item["customeR_NAME"] ?? "", _colParty, bold: true),

          _dataCell(
            item["inquirY_NO_main"] ?? "",
            _colInquiry,
            textColor: Colors.blue,
            bold: true,
          ),

          _dataCell(item["employee"] ?? "", _colEmployee),

          _dataCell(item["baG_TYPE"] ?? "", _colBagType),

          _dataCell(item["articlE_NO"] ?? "", _colArticle),

          // Hygiene badge
          Container(
            width: _colFg,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isFood ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item["fG_NON_FG"] ?? "",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isFood
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ),
          ),

          _dataCell(item["wo"] ?? "", _colWo),

          _dataCell(item["wO_DATE"] ?? "", _colWoDate),

          _dataCell(item["wO_EMPLOYEE"] ?? "", _colWoEmployee),

          _dataCell(item["po_num"] ?? "", _colPo),

          _dataCell(item["sR_WO_NUM"] ?? "", _colSrWo),

          _dataCell(item["sR_WO_DATE"] ?? "", _colSrWoDate),

          _dataCell(item["sR_WO_USER_NAME"] ?? "", _colSrWoUser),

          _dataCell(item["issuE_TO_QC"] ?? "", _colIssueQc),

          _dataCell(item["issuE_PERSON"] ?? "", _colIssuePerson),

          _dataCell(item["boM_DATE"] ?? "", _colBomDate),

          _dataCell(item["boM_TO_PRODUCTION"] ?? "", _colBomProd),

          _dataCell(item["issuE_TO_SAMPLE"] ?? "", _colIssueSample),

          _dataCell(item["samplE_PERSON"] ?? "", _colSamplePerson),

          _dataCell(item["samplE_PROCESSING_DATE"] ?? "", _colSampleDate),

          _dataCell(item["complain"] ?? "", _colComplaint),

          _dataCell(item["statuS_REASON"] ?? "", _colStatusReason),

          _dataCell(item["status"] ?? "", _colStatus),
        ],
      ),
    );
  }
  // ───────────────── DATA CELL ─────────────────

  Widget _dataCell(
    String text,
    double width, {
    Color? textColor,
    bool bold = false,
  }) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Text(
        text.isEmpty ? "-" : text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? const Color(0xFF212121),
        ),
      ),
    );
  }
}

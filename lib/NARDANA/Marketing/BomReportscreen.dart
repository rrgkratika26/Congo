import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class BomReportScreen extends StatefulWidget {
  const BomReportScreen({super.key});

  @override
  State<BomReportScreen> createState() => _BomReportScreenState();
}

class _BomReportScreenState extends State<BomReportScreen> {
  // ───────────────── CONTROLLERS ─────────────────

  final ScrollController _horizCtrl = ScrollController();
  String? _unitTitle;
  final TextEditingController _searchController = TextEditingController();
  List<String> partyList = [];
  bool isPartyLoading = false;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));

  DateTime toDate = DateTime.now();

  String? selectedParty;

  // ───────────────── STATIC DATA ─────────────────

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];

  bool isLoading = false;

  // ───────────────── PARTY LIST ─────────────────

  // ───────────────── INIT ─────────────────

  @override
  void initState() {
    super.initState();
    _loadUnit();
    loadParties();
    loadBomReport();
  }

  // ───────────────── DATE FORMAT ─────────────────

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  // ───────────────── FILTER ─────────────────

  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredReports = reports.where((item) {
        final matchesSearch =
            item["customer_name"].toString().toLowerCase().contains(query) ||
            item["articlE_NO"].toString().toLowerCase().contains(query) ||
            item["wo_no_series"].toString().toLowerCase().contains(query);

        final matchesParty =
            selectedParty == null || item["customer_name"] == selectedParty;

        return matchesSearch && matchesParty;
      }).toList();
    });
  }

  Future<void> loadParties() async {
    try {
      setState(() {
        isPartyLoading = true;
      });

      final result = await NaradanaApiService().fetchPartyNames();

      print("Dropdown Data : $result");

      if (!mounted) return;

      setState(() {
        partyList = result;
        isPartyLoading = false;
      });
    } catch (e) {
      print("loadParties Error : $e");

      if (!mounted) return;

      setState(() {
        isPartyLoading = false;
      });
    }
  }

  Future<void> loadBomReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await NaradanaApiService().fetchBomInquiryReport(
        unitName: "NARDANA",

        // unitName: "SILVASSA",
        pageNumber: 1,
        pageSize: 500,
      );

      setState(() {
        reports = result;
        filteredReports = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }
  // ───────────────── DATE PICKER ─────────────────

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  // ───────────────── WIDTHS ─────────────────

  static const double colWo = 90;
  static const double colCustomer = 220;
  static const double colArticle = 260;
  static const double colPo = 200;
  static const double colBag = 170;
  static const double colHygiene = 170;
  static const double colBomDate = 170;
  static const double colMaker = 170;
  static const double colCont = 120;
  static const double colLiner = 120;
  static const double colPrint = 120;
  static const double colComplaint = 200;

  double get totalWidth =>
      colWo +
      colCustomer +
      colArticle +
      colPo +
      colBag +
      colHygiene +
      colBomDate +
      colMaker +
      colCont +
      colLiner +
      colPrint +
      colComplaint;

  // ───────────────── BUILD ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ───────────────── APP BAR ─────────────────
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: C.primary,
        iconTheme: IconThemeData(color: C.bg),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "BOM Report",
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_formatDate(fromDate)} → ${_formatDate(toDate)}",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range_rounded, color: Colors.white),
          ),

          const SizedBox(width: 10),
        ],
      ),

      // ───────────────── BODY ─────────────────
      body: Column(
        children: [
          _buildTopFilters(),

          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  // ───────────────── TOP FILTER ─────────────────

  Widget _buildTopFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade200,
      child: Column(
        children: [
          // ───────── SEARCH + DROPDOWN ─────────
          Column(
            children: [
              // ───────── SEARCH FIELD ─────────
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterData(),

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),

                  decoration: InputDecoration(
                    hintText: "Search customer, article, WO...",

                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),

                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4A8A).withOpacity(.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1A4A8A),
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ───────── PARTY DROPDOWN ─────────
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedParty,
                    isExpanded: true,

                    hint: Text(
                      isPartyLoading ? "Loading Parties..." : "Select Party",
                      style: const TextStyle(
                        color: Color(0xFF0B1A3F),
                        fontWeight: FontWeight.w600,
                      ),
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
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              "TOTAL",
              filteredReports.length.toString(),
              Icons.inventory,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              "FOOD",
              filteredReports
                  .where((e) => e["hygiene"].toString().contains("FOOD"))
                  .length
                  .toString(),
              Icons.check_circle,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              "INDUSTRIAL",
              filteredReports
                  .where((e) => e["hygiene"].toString().contains("INDUSTRIAL"))
                  .length
                  .toString(),
              Icons.factory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ───────────────── TABLE ─────────────────

  Widget _buildTable() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredReports.isEmpty) {
      return const Center(child: Text("No BOM Report Found"));
    }

    return Scrollbar(
      controller: _horizCtrl,
      thumbVisibility: true,

      child: SingleChildScrollView(
        controller: _horizCtrl,

        scrollDirection: Axis.horizontal,

        child: SizedBox(
          width: totalWidth,

          child: Column(
            children: [
              _tableHeader(),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredReports.length,

                  itemBuilder: (_, index) {
                    return _tableRow(filteredReports[index], index);
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

  Widget _tableHeader() {
    return Container(
      color: C.bg,

      child: Row(
        children: [
          _headerCell("W.O #", colWo),
          _headerCell("CUSTOMER NAME", colCustomer),
          _headerCell("ARTICLE NO", colArticle),
          _headerCell("PO NUM", colPo),
          _headerCell("BAG TYPE", colBag),
          _headerCell("HYGIENE", colHygiene),
          _headerCell("BOM DATE", colBomDate),
          _headerCell("BOM MAKERS", colMaker),
          _headerCell("CONT NO", colCont),
          _headerCell("LINER", colLiner),
          _headerCell("PRINTING", colPrint),
          _headerCell("COMPLAINT", colComplaint),
        ],
      ),
    );
  }

  Widget _headerCell(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      alignment: Alignment.center,

      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade400)),
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

  Widget _tableRow(Map<String, dynamic> item, int index) {
    final bool isFood = item["fG_NON_FG"].toString().contains("FOOD");

    return Container(
      color: isFood ? const Color(0xFFCFF3CB) : Colors.white,

      child: Row(
        children: [
          _cell(item["wo_no_series"]?.toString() ?? "", colWo),

          _cell(item["customer_name"]?.toString() ?? "", colCustomer),

          _cell(item["articlE_NO"]?.toString() ?? "", colArticle),

          _cell(item["extrA13"]?.toString() ?? "", colPo),

          _cell(item["typee"]?.toString() ?? "", colBag),

          _cell(item["fG_NON_FG"]?.toString() ?? "", colHygiene),

          _cell(item["todaY_DATE"]?.toString().split("T")[0] ?? "", colBomDate),

          _cell(item["boM_MAKER"]?.toString() ?? "", colMaker),

          _cell(item["cont_no"]?.toString() ?? "", colCont),

          _cell(item["lineR_TYPE"]?.toString() ?? "", colLiner),

          _cell(item["prinT_Y_N"]?.toString() ?? "", colPrint),

          _cell(item["complain"]?.toString() ?? "", colComplaint),
        ],
      ),
    );
  }

  // ───────────────── CELL ─────────────────

  Widget _cell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),

      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

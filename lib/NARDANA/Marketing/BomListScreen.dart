import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class BomListScreen extends StatefulWidget {
  const BomListScreen({super.key});

  @override
  State<BomListScreen> createState() => _BomListScreenState();
}

class _BomListScreenState extends State<BomListScreen> {
  final ScrollController _horizCtrl = ScrollController();

  final ScrollController _listController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> reports = [];

  List<Map<String, dynamic>> filteredReports = [];

  List<String> partyList = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isPartyLoading = false;

  int pageNumber = 1;
  int totalRecords = 0;

  String? selectedParty;

  @override
  void initState() {
    super.initState();

    loadParties();
    loadBomList();

    _listController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizCtrl.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_listController.position.pixels >=
            _listController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      loadMoreData();
    }
  }

  Future<void> loadParties() async {
    try {
      setState(() {
        isPartyLoading = true;
      });

      final result = await NaradanaApiService().fetchPartyNames();

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

  Future<void> loadBomList() async {
    try {
      pageNumber = 1;
      hasMoreData = true;

      setState(() {
        isLoading = true;
      });

      final result = await NaradanaApiService().fetchBomList(
        pageNumber: pageNumber,
        pageSize: 50,
      );

      setState(() {
        reports = result;
        filteredReports = result;

        totalRecords = result.length;

        isLoading = false;

        if (result.length < 50) {
          hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
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

      final result = await NaradanaApiService().fetchBomList(
        pageNumber: pageNumber,
        pageSize: 50,
      );

      setState(() {
        reports.addAll(result);

        _filterData();

        totalRecords = reports.length;

        isLoadingMore = false;

        if (result.length < 50) {
          hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });

      print(e);
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredReports = reports.where((item) {
        final searchMatch =
            item["cusT_ID"].toString().toLowerCase().contains(query) ||
            item["baG_REF"].toString().toLowerCase().contains(query) ||
            item["inquirY_NO"].toString().toLowerCase().contains(query);

        final partyMatch =
            selectedParty == null || item["cusT_ID"] == selectedParty;

        return searchMatch && partyMatch;
      }).toList();
    });
  }

  static const double colWo = 80;
  static const double colCustomer = 220;
  static const double colBagRef = 150;
  static const double colBagType = 100;
  static const double colInquiry = 150;
  static const double colUser = 150;
  static const double colStatus = 130;
  static const double colIssueDate = 180;
  static const double colCont = 100;
  static const double colUnit = 100;
  static const double colPo = 180;
  static const double colDispatch = 180;

  double get totalWidth =>
      colWo +
      colCustomer +
      colBagRef +
      colBagType +
      colInquiry +
      colUser +
      colStatus +
      colIssueDate +
      colCont +
      colUnit +
      colPo +
      colDispatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        // elevation: 0,
        // toolbarHeight: 80,
        backgroundColor: C.primary,
        iconTheme: const IconThemeData(color: Colors.white),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              "BOM List",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),

            // const SizedBox(width: 55),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Total Records : $totalRecords",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildFilters(),

          const SizedBox(height: 10),

          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: C.primary.withOpacity(.25), width: 1.3),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: TextField(
          controller: _searchController,
          onChanged: (_) => _filterData(),

          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

          decoration: InputDecoration(
            hintText: "Search Customer / Inquiry / Bag",

            hintStyle: TextStyle(color: Colors.grey.shade500),

            prefixIcon: Container(
              margin: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: C.primary.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(Icons.search, color: C.primary),
            ),

            border: InputBorder.none,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  controller: _listController,

                  itemCount: filteredReports.length + (isLoadingMore ? 1 : 0),

                  itemBuilder: (_, index) {
                    if (index == filteredReports.length) {
                      return const Padding(
                        padding: EdgeInsets.all(15),

                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return _tableRow(filteredReports[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: C.brand200,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),

      child: Row(
        children: [
          _headerCell("WO", colWo),

          _headerCell("PARTY NAME", colCustomer),

          _headerCell("BAG REF", colBagRef),

          _headerCell("BAG TYPE", colBagType),

          _headerCell("INQUIRY", colInquiry),

          _headerCell("USER", colUser),

          _headerCell("STATUS", colStatus),

          _headerCell("ISSUE DATE", colIssueDate),

          _headerCell("CONT", colCont),

          _headerCell("UNIT", colUnit),

          _headerCell("PO DATE", colPo),

          _headerCell("DISPATCH", colDispatch),
        ],
      ),
    );
  }

  Widget _headerCell(String title, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),

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

  Widget _tableRow(Map<String, dynamic> item) {
    bool isProduction = item["status"].toString().toUpperCase().contains(
      "PRODUCTION",
    );

    return Container(
      color: filteredReports.indexOf(item).isEven
          ? Colors.white
          : const Color(0xFFF8FAFD),

      child: Row(
        children: [
          _cell(item["wO_NO"] ?? "", colWo),

          _cell(item["cusT_ID"] ?? "", colCustomer),

          _cell(item["baG_REF"] ?? "", colBagRef),

          _cell(item["baG_TYPE"] ?? "", colBagType),

          _cell(item["inquirY_NO"] ?? "", colInquiry),

          _cell(item["useR_ID"] ?? "", colUser),

          // Status Chip
          Container(
            width: colStatus,
            alignment: Alignment.center,

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

              decoration: BoxDecoration(
                color: isProduction
                    ? Colors.green.shade100
                    : Colors.orange.shade100,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                item["status"] ?? "",

                style: TextStyle(
                  color: isProduction
                      ? Colors.green.shade800
                      : Colors.orange.shade800,

                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          _cell(
            item["issuE_DATE"]?.toString().split("T")[0] ?? "",
            colIssueDate,
          ),

          _cell(item["conT_NO"] ?? "", colCont),

          _cell(item["unit"] ?? "", colUnit),

          _cell(item["pO_DATE"]?.toString().split("T")[0] ?? "", colPo),

          _cell(
            item["requesT_DISPATCH_DATE"]?.toString().split("T")[0] ?? "",
            colDispatch,
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, double width) {
    return Container(
      width: width,

      alignment: Alignment.center,

      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),

      // decoration: BoxDecoration(
      //   border: Border(
      //     right: BorderSide(color: Colors.grey),
      //     bottom: BorderSide(color: Colors.grey),
      //   ),
      // ),

      child: Text(
        text.isEmpty ? "-" : text,

        textAlign: TextAlign.center,

        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

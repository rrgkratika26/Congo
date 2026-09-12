import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

import 'InquiryReportScreen.dart';

class InquiryListScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const InquiryListScreen({Key? key, this.startDate, this.endDate})
      : super(key: key);

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  final ScrollController _listController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int pageNumber = 1;

  @override
  void initState() {
    super.initState();

    if (widget.startDate != null) _fromDate = widget.startDate!;
    if (widget.endDate != null) _toDate = widget.endDate!;

    _listController.addListener(_scrollListener);
    loadInquiryReport();
  }

  @override
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
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

  String _apiDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> loadInquiryReport() async {
    try {
      pageNumber = 1;
      hasMoreData = true;

      setState(() => isLoading = true);

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
        if (result.length < 50) hasMoreData = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadMoreData() async {
    try {
      setState(() => isLoadingMore = true);
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
        if (result.isEmpty || result.length < 50) hasMoreData = false;
      });
    } catch (e) {
      setState(() => isLoadingMore = false);
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredReports = reports.where((item) {
        final party = item["customeR_NAME"]?.toString().toLowerCase() ?? "";
        final inquiry =
            item["inquirY_NO_main"]?.toString().toLowerCase() ?? "";
        return party.contains(query) || inquiry.contains(query);
      }).toList();
    });
  }

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

  void _openDetail(Map<String, dynamic> item) {
    final inquiryNo = item['inquirY_NO_main']?.toString().trim() ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InquiryMarketingReportScreen(
          startDate: _fromDate,
          endDate: _toDate,
          inquiryNo: inquiryNo, // <-- filters to this inquiry only
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 78,
        flexibleSpace: Container(color: C.primary),
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Inquiries",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: .4,
              ),
            ),
            const SizedBox(height: 4),
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterData(),
              decoration: InputDecoration(
                hintText: "Search inquiry no or party...",
                prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF1A4A8A)),
                filled: true,
                fillColor: const Color(0xFFF4F7FC),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredReports.isEmpty) {
      return const Center(child: Text("No inquiries found"));
    }

    return ListView.separated(
      controller: _listController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filteredReports.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        if (index == filteredReports.length) {
          return const Padding(
            padding: EdgeInsets.all(15),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = filteredReports[index];
        final inquiryNo = item["inquirY_NO_main"]?.toString() ?? "-";
        final party = item["customeR_NAME"]?.toString() ?? "-";
        final date = item["date"]?.toString() ?? "";

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDetail(item),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: C.primary, width: 3.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inquiryNo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          party,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        if (date.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: C.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
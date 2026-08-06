import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class IssueToQualityScreen extends StatefulWidget {
  const IssueToQualityScreen({super.key});

  @override
  State<IssueToQualityScreen> createState() => _IssueToQualityScreenState();
}

class _IssueToQualityScreenState extends State<IssueToQualityScreen> {
  final ScrollController _horizontalCtrl = ScrollController();

  final ScrollController _listCtrl = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filtered = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  int page = 1;
  int totalRecords = 0;

  @override
  void initState() {
    super.initState();

    loadData();

    _listCtrl.addListener(() {
      if (_listCtrl.position.pixels >=
              _listCtrl.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        loadMore();
      }
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        page = 1;
      });

      final result = await NaradanaApiService().fetchIssueToQuality(
        pageNumber: page,
        pageSize: 50,
      );

      setState(() {
        reports = result;
        filtered = result;
        totalRecords = result.length;

        isLoading = false;

        if (result.length < 50) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  Future<void> loadMore() async {
    try {
      setState(() {
        isLoadingMore = true;
      });

      page++;

      final result = await NaradanaApiService().fetchIssueToQuality(
        pageNumber: page,
        pageSize: 50,
      );

      setState(() {
        reports.addAll(result);

        totalRecords = reports.length;

        _filter();

        isLoadingMore = false;

        if (result.length < 50) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void _filter() {
    String q = _searchController.text.toLowerCase();

    setState(() {
      filtered = reports.where((e) {
        return e["cusT_ID"].toString().toLowerCase().contains(q) ||
            e["wO_NO"].toString().toLowerCase().contains(q) ||
            e["inquirY_NO"].toString().toLowerCase().contains(q);
      }).toList();
    });
  }

  static const colCheck = 50.0;
  static const colWo = 70.0;
  static const colCustomer = 70.0;
  static const colBagRef = 120.0;
  static const colBagType = 130.0;
  static const colInquiry = 130.0;
  static const colUnit = 70.0;
  // static const colPoDate = 100.0;
  // static const colDispatch = 100.0;

  // static const colStatus = 90.0;

  double get totalWidth =>
      colCheck +
      colWo +
      colCustomer +
      colBagRef +
      colBagType +
      colInquiry +
      colUnit +
      // colPoDate +
      // colDispatch +
      10;

  // colStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        backgroundColor: C.appBar1,
        elevation: 0,

        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: [
        //         C.appBar2,
        //         C.appBar3, // lighter shade
        //       ],
        //     ),
        //   ),
        // ),
        iconTheme: const IconThemeData(color: Colors.white),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              "Issue To Quality",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                "Records : $totalRecords",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller: _searchController,

              onChanged: (_) => _filter(),

              decoration: InputDecoration(
                hintText: "Search WO / Customer",

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Scrollbar(
                    controller: _horizontalCtrl,

                    thumbVisibility: true,

                    child: SingleChildScrollView(
                      controller: _horizontalCtrl,

                      scrollDirection: Axis.horizontal,

                      child: SizedBox(
                        width: totalWidth,

                        child: Column(
                          children: [
                            _header(),

                            Expanded(
                              child: ListView.builder(
                                controller: _listCtrl,

                                itemCount:
                                    filtered.length + (isLoadingMore ? 1 : 0),

                                itemBuilder: (_, index) {
                                  if (index == filtered.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(15),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  return _row(filtered[index]);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        color: C.bg,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          head("✓", colCheck),
          head("WO", colWo),
          head("WO Sr.", colCustomer),
          head("Customer Name", colBagRef),
          head("BAG Ref.", colBagType),
          head("INQUIRY No.", colInquiry),
          head("Bag type", colUnit),
          // head("PO DATE", colPoDate),
          // head("DISPATCH", colDispatch),
        ],
      ),
    );
  }

  Widget head(String text, double width) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: .7),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: C.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> item) {
    bool checked = item["active"].toString().toLowerCase() == "true";

    bool quality = item["status"].toString().toUpperCase() == "QUALITY";

    return Container(
      decoration: BoxDecoration(
        color: quality ? const Color(0xFFF0B9A3) : Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: .7),
          right: BorderSide(color: Colors.grey.shade300, width: .7),
          bottom: BorderSide(color: Colors.grey.shade300, width: .7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: colCheck,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: .7),
              ),
            ),
            child: Checkbox(
              value: checked,
              onChanged: null,
              visualDensity: VisualDensity.compact,
            ),
          ),

          cell(item["wO_NO"], colWo),
          cell(item["wO_NO_SERIES"], colCustomer),
          cell(item["customeR_NAME"], colBagRef),
          cell(item["baG_REF"], colBagType),
          cell(item["inquirY_NO"], colInquiry),
          cell(item["baG_TYPE"], colUnit),

          // cell(
          //   item["pO_DATE"]
          //       ?.toString()
          //       .split("T")[0],
          //   colPoDate,
          // ),
          //
          // cell(
          //   item["requesT_DISPATCH_DATE"]
          //       ?.toString()
          //       .split("T")[0],
          //   colDispatch,
          // ),
        ],
      ),
    );
  }

  Widget cell(dynamic text, double width) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: .7),
        ),
      ),
      child: Text(
        text?.toString() ?? "-",
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

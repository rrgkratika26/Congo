import 'dart:async';

import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'PackingEntryScreen.dart';
import 'PackingReportModel.dart';

class PackingBagReportScreen extends StatefulWidget {
  const PackingBagReportScreen({super.key});

  @override
  State<PackingBagReportScreen> createState() => _PackingBagReportScreenState();
}

class _PackingBagReportScreenState extends State<PackingBagReportScreen> {
  List<PackingBagReportModel> reportList = [];
  bool loading = true;
  Timer? _timer;
  TextEditingController searchController = TextEditingController();
  List<PackingBagReportModel> filteredList = [];
  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    searchController.dispose(); // 👈 add this
    super.dispose();
  }


  void filterSearch(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredList = reportList.where((item) {
        final party = item.partyname?.toLowerCase() ?? '';
        final wo = item.workOrderNo?.toLowerCase() ?? '';

        return party.contains(lowerQuery) || wo.contains(lowerQuery);
      }).toList();
    });
  }


  Future<void> fetchData() async {
    try {
      final data = await JblApiService.getPackingBagReport();

      setState(() {
        reportList = data;
        filteredList = data; // 👈 important
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }
  Widget cell(num width, dynamic value) {
    return SizedBox(
      width: width.toDouble(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(value?.toString() ?? ""),
      ),
    );
  }

  Widget header(num width, String text) {
    return SizedBox(
      width: width.toDouble(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      appBar: AppBar(
        title: const Text(
          "Packing Bag Report",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: C.appBar1,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reportList.isEmpty
          ? const Center(child: Text("No Data Found"))
          : RefreshIndicator(
              onRefresh: fetchData,

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: SizedBox(
                  width: 1330, // total table width

                  child: Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: searchController,
                          onChanged: filterSearch,
                          decoration: InputDecoration(
                            hintText: "Search by Party Name or WO Number",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                filterSearch('');
                              },
                            )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      /// HEADER
                      Container(
                        color: C.appBar1,
                        child: Row(
                          children: [
                            header(160, "Party Name"),
                            header(100, "WO No"),
                            header(200, "Article"),
                            header(120, "Bag Type"),
                            header(120, "Bag Size"),
                            header(100, "BagGWtGM"),
                            header(60, "Order"),
                            header(130, "Total\nManufactured"),
                            header(100, "Packed"),
                            header(100, "Balance"),
                          ],
                        ),
                      ),

                      /// DATA LIST
                      Flexible(

                        child: ListView.builder(
                          shrinkWrap: true,
                            itemCount: filteredList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final e = filteredList[index];

                            return InkWell(
                              onTap: () {
                                if ((e.totalManf ?? 0) < 1) {
                                  // Show alert if condition met
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Alert"),
                                      content: const Text(
                                        "Please contact the Quality Control Department",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Navigate normally if condition not met
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PackingEntryBag(data: e),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                color: index % 2 == 0 ? Colors.white : C.appBar1,
                                child: Row(
                                  children: [
                                    cell(160, e.partyname),
                                    cell(100, e.workOrderNo),
                                    cell(200, e.articleNo),
                                    cell(120, e.bagtype),
                                    cell(120, e.bagsize),
                                    cell(120, e.baggwtgm),
                                    cell(60, e.orderQty),
                                    cell(130, e.totalManf),
                                    cell(100, e.packedBags),
                                    cell(100, e.balanceBag),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

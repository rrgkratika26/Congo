// cutting_code_wise_screen.dart
// FULL CORRECTED CODE

import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../Color/Colorclass.dart';
import 'FabCodeDetailscreen.dart';
import 'StockModel.dart';

class CuttingStockScreen extends StatefulWidget {
  final String fabricCode;
  final int id;

  const CuttingStockScreen({
    super.key,
    required this.fabricCode,
    required this.id,
  });

  @override
  State<CuttingStockScreen> createState() => _CuttingStockScreenState();
}

class _CuttingStockScreenState extends State<CuttingStockScreen> {
  static const int pageSize = 10;

  List<CuttingFabricSummaryModel> allData = [];
  List<CuttingFabricSummaryModel> filteredData = [];

  bool loading = true;
  String error = '';

  int currentPage = 1;

  double totalWeight = 0;
  double totalLength = 0;

  final TextEditingController searchCtrl = TextEditingController();

  int get totalPages => (filteredData.length / pageSize).ceil().clamp(1, 99999);

  List<CuttingFabricSummaryModel> get pageData {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filteredData.length);
    return filteredData.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> fetchData() async {
    try {
      final result = await NaradanaApiService.getCuttingFabricSummary(
        page: 1,
        pageSize: 50,
      );

      allData = result;
      filteredData = result;

      calculateSummary();

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  void calculateSummary() {
    totalWeight = filteredData.fold(0.0, (sum, e) => sum + e.totalNetWeightKg);

    totalLength = filteredData.fold(
      0.0,
      (sum, e) => sum + e.totalRollLengthMtr,
    );
  }

  void onSearch(String value) {
    filteredData = allData.where((e) {
      return e.fabricCode.toLowerCase().contains(value.toLowerCase());
    }).toList();

    currentPage = 1;
    calculateSummary();

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // appBar: AppBar(
      //   backgroundColor: C.primary,
      //   title: const Text(
      //     "Roll Stock",
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      // Replace your AppBar with this
      appBar: AppBar(
        backgroundColor: C.headerBlue,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Roll Stock",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              "Total Records: ${filteredData.length}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : error.isNotEmpty
          ? Center(child: Text(error))
          : Column(
              children: [
                _summaryBar(),
                _searchBar(),
                Expanded(child: _tableView()),
                _paginationBar(),
              ],
            ),
    );
  }

  ////////////////////////////////////////////////////////////////
  /// SUMMARY
  ////////////////////////////////////////////////////////////////

  Widget _summaryBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          // _box("Records", "${filteredData.length}", Colors.blue),
          _box("Weight", totalWeight.toStringAsFixed(2), Colors.green),
          _box("Length", totalLength.toStringAsFixed(2), Colors.orange),
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
            const SizedBox(height: 5),
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


// ================= SEARCH BAR METHOD ADD THIS =================
  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: TextField(
        controller: searchCtrl,
        onChanged: onSearch,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search By Fabric Code",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: C.primary,
          ),



          filled: true,
          fillColor: const Color(0xFFF5F7FA),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: C.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
  ////////////////////////////////////////////////////////////////
  /// TABLE
  ////////////////////////////////////////////////////////////////

  Widget _tableView() {
    final rows = pageData;
    final offset = (currentPage - 1) * pageSize;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(C.primary),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text("Sr")),
          DataColumn(label: Text("Fabric Code")),
          DataColumn(label: Text("Weight")),
          DataColumn(label: Text("Length")),
          DataColumn(label: Text("Count")),
        ],
        rows: List.generate(rows.length, (index) {
          final e = rows[index];

          return DataRow(
            cells: [
              DataCell(Text("${offset + index + 1}")),

              /// FABRIC CLICK
              DataCell(
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CutFabricDetailScreen(fabricCode: e.fabricCode),
                      ),
                    );
                  },
                  child: Text(
                    e.fabricCode,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataCell(Text(e.totalNetWeightKg.toStringAsFixed(2))),
              DataCell(Text(e.totalRollLengthMtr.toStringAsFixed(2))),
              DataCell(Text("${e.totalCount}")),
            ],
          );
        }),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////
  /// PAGINATION
  ////////////////////////////////////////////////////////////////

  Widget _paginationBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page $currentPage / $totalPages"),
          Row(
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
                child: const Text("Prev"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// DETAIL SCREEN
////////////////////////////////////////////////////////////////

class CutFabricDetailScreen extends StatefulWidget {
  final String fabricCode;

  const CutFabricDetailScreen({super.key, required this.fabricCode});

  @override
  State<CutFabricDetailScreen> createState() => _CutFabricDetailScreenState();
}

class _CutFabricDetailScreenState extends State<CutFabricDetailScreen> {
  static const Color primary = Color(0xFF1565C0);

  List data = [];
  List filteredData = [];

  bool loading = true;

  double totalWeight = 0;
  double totalQty = 0;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final result = await NaradanaApiService.getFabricCodeWiseReport(
      fabricCode: widget.fabricCode,
      page: 1,
      pageSize: 100,
    );

    data = result;
    filteredData = List.from(data);

    calculateTotals();

    setState(() => loading = false);
  }

  void calculateTotals() {
    totalWeight = filteredData.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item["netwt"].toString()) ?? 0),
    );

    totalQty = filteredData.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item["quantity"].toString()) ?? 0),
    );
  }

  void searchData(String value) {
    if (value.trim().isEmpty) {
      filteredData = List.from(data);
    } else {
      filteredData = data.where((item) {
        return item["fabriC_CODE"].toString().toLowerCase().contains(
          value.toLowerCase(),
        );
      }).toList();
    }

    calculateTotals();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: primary,
      //   foregroundColor: Colors.white,
      //   title: Text(widget.fabricCode, style: const TextStyle(
      //     fontWeight: FontWeight.bold,
      //     fontSize: 15,
      //   ),),
      // ),
      // Replace your AppBar with this
      appBar: AppBar(
        backgroundColor: C.headerBlue,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fabricCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              "Total Records: ${filteredData.length}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // _StatBox(
                      //   label: "Records",
                      //   value: "${filteredData.length}",
                      //   color: primary,
                      // ),
                      _StatBox(
                        label: "Roll Weight(kg)",
                        value: totalWeight.toStringAsFixed(2),
                        color: Colors.green,
                      ),
                      _StatBox(
                        label: "Roll Length(mtr)",
                        value: totalQty.toStringAsFixed(0),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchData,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 10,
                      headingRowColor: MaterialStateProperty.all(primary),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text("SNo.")),
                        DataColumn(label: Text("Fabric Code")),
                        DataColumn(label: Text("NetWt(Kg)")),
                        DataColumn(label: Text("Roll Length(Mtr)")),
                        DataColumn(label: Text("Width(cm)")),
                      ],
                      rows: List.generate(filteredData.length, (index) {
                        final e = filteredData[index];

                        return DataRow(
                          cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FabCode_Detaild(
                                        fabricCode: e["fabriC_CODE"],
                                        id: int.tryParse(e["id"].toString()),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "${e["fabriC_CODE"]}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text("${e["netwt"]}")),
                            DataCell(Text("${e["quantity"]}")),
                            DataCell(Text("${e["fabricwidth"]}")),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// STAT BOX
////////////////////////////////////////////////////////////////

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(label, style: TextStyle(color: color, fontSize: 11)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

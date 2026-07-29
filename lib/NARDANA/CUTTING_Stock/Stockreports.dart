// cutting_code_wise_screen.dart

import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../Color/Colorclass.dart';
import '../../util/widget/CountRecords/CountRecords.dart';
import 'CutFabricDetailScreen.dart';
import 'StockModel.dart';

class CuttingStockScreen extends StatefulWidget {
  const CuttingStockScreen({super.key});

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
  int totalRecords = 0;
  double totalWeight = 0;
  double totalLength = 0;

  final TextEditingController searchCtrl = TextEditingController();

  /// TOTAL PAGE
  int get totalPages => (filteredData.length / pageSize).ceil().clamp(1, 99999);

  /// CURRENT PAGE DATA
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

  /// API CALL
  Future<void> fetchData() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await NaradanaApiService.getCuttingFabricSummary(
        page: 1,
        pageSize: 500000,
      );

      allData = result;
      filteredData = result;

      totalRecords = result.length;

      totalWeight = result.fold(0.0, (sum, e) => sum + e.totalNetWeightKg);

      totalLength = result.fold(0.0, (sum, e) => sum + e.totalRollLengthMtr);

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  /// SEARCH
  void onSearch(String value) {
    setState(() {
      filteredData = allData.where((e) {
        return e.fabricCode.toLowerCase().contains(value.toLowerCase());
      }).toList();

      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.primary),
        ),
        title: const Text(
          'Roll Stock',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        actions: [CountText(count: filteredData.length)],
        iconTheme: const IconThemeData(color: C.bgColor),
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

  /// SUMMARY
  Widget _summaryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // _box("Records", "$totalRecords", Colors.blue),
          _box("Roll Weight(kg)", totalWeight.toStringAsFixed(2), Colors.green),
          _box("Roll Length(mtr)", totalLength.toStringAsFixed(2), Colors.orange),
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

  /// TABLE
  Widget _tableView() {
    final rows = pageData;
    final offset = (currentPage - 1) * pageSize;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10,
              horizontalMargin: 12,
              headingRowHeight: 42,
              dataRowHeight: 38,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
              columns: const [
                DataColumn(label: Text("SNo")),
                DataColumn(label: Text("Fabric Code")),
                DataColumn(label: Text("NetWt(Kg)")),
                DataColumn(label: Text("Length(Mtr)")),
                DataColumn(label: Text("Count")),
              ],
              rows: List.generate(rows.length, (index) {
                final e = rows[index];

                return DataRow(
                  cells: [
                    DataCell(Text("${offset + index + 1}")),
                    DataCell(
                      GestureDetector(
                        onTap: () => openDetail(e.fabricCode),
                        child: Text(
                          e.fabricCode,
                          style: const TextStyle(
                            color: C.primary,
                            fontWeight: FontWeight.w400,
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
          ),
        ),
      ),
    );
  }

  /// PAGINATION
  Widget _paginationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
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
                child: const Text("Next", style: TextStyle(color: C.textHigh)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void openDetail(String fabricCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CutFabricDetailScreen(fabricCode: fabricCode),
      ),
    );
  }
}

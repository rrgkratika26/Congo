// bale_stock_screen.dart

import 'package:flutter/material.dart';
import '../../../../services/NardanaApis/NardanaApi.dart';
import '../../../Color/Colorclass.dart';
import 'BaleModel.dart';

class BaleStockGroupScreen extends StatefulWidget {
  const BaleStockGroupScreen({super.key});

  @override
  State<BaleStockGroupScreen> createState() => _BaleStockGroupScreenState();
}

class _BaleStockGroupScreenState extends State<BaleStockGroupScreen> {
  static const int pageSize = 10;

  List<BaleStockModel> allData = [];
  List<BaleStockModel> filteredData = [];

  bool loading = true;
  String error = '';

  int currentPage = 1;
  int totalRecords = 0;
  double totalWeight = 0;
  double totalQty = 0;

  final TextEditingController searchCtrl = TextEditingController();

  int get totalPages => (filteredData.length / pageSize).ceil().clamp(1, 99999);




  List<BaleStockModel> get pageData {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filteredData.length);

    return filteredData.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// API
  Future<void> fetchData() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await NaradanaApiService.getBailingStock(
        page: 1,
        pageSize: 500000,
      );

      allData = result;
      filteredData = result;

      totalRecords = result.length;

      // totalWeight = result.fold(
      //   0.0,
      //       (sum, e) =>
      //   sum + e.totalWeight,
      // );

      totalQty = result.fold(0.0, (sum, e) => sum + e.totalQty);

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
      final query = value.toLowerCase().trim();

      filteredData = allData.where((e) {
        return e.bomNo.toLowerCase().contains(query) ||
            e.partyName.toLowerCase().contains(query) ||
            e.articleNo.toLowerCase().contains(query) ||
            e.totalQty.toString().contains(query) ||
            e.totalBale.toString().contains(query) ;
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
          "Bale Overall Stock Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          _box("Total Records", "$totalRecords", Colors.blue),
          // _box("Total Wt(kg)", totalWeight.toStringAsFixed(2), Colors.green),
          _box("Total Qty", totalQty.toStringAsFixed(0), Colors.orange),
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

  /// SEARCH
  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: searchCtrl,
        onChanged: onSearch,
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
    );
  }

  /// TABLE
  Widget _tableView() {
    final rows = pageData;
    final offset = (currentPage - 1) * pageSize;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            headingRowColor: MaterialStateProperty.all(C.primary),
            headingTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            columns: const [
              DataColumn(label: Text("SNo")),

              DataColumn(label: Text("BOM")),
              DataColumn(label: Text("Party")),

              DataColumn(label: Text("Article")),
              DataColumn(label: Text("Bag Qty")),
              DataColumn(label: Text("Bag Prodct.")),
              DataColumn(label: Text("Total Bale")),
              DataColumn(label: Text("BaleQty")),

              DataColumn(label: Text("Dispatch Qty")),

              DataColumn(label: Text("Balance Qty")),
            ],
            rows: List.generate(rows.length, (index) {
              final e = rows[index];

              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(e.bomNo)),

                  DataCell(Text(e.partyName)),

                  DataCell(Text(e.articleNo)),

                  DataCell(Text(e.totalQty.toStringAsFixed(1))),
                  DataCell(Text(e.bagProduction.toStringAsFixed(2))),
                  DataCell(Text(e.totalBale.toStringAsFixed(2))),
                  DataCell(Text(e.baleQty.toStringAsFixed(2))),

                  DataCell(Text(e.dispatchQty.toStringAsFixed(2))),
                  DataCell(Text(e.balanceQty.toStringAsFixed(2))),



                ],
              );
            }),
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
                child: Text("Next", style: TextStyle(color: C.textHigh)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

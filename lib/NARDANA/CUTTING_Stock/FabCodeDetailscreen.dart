// =======================================
// fab_code_detaild.dart
// Updated with Model Class
// =======================================

import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../Color/Colorclass.dart';
import 'CutStockModel.dart';

class FabCode_Detaild extends StatefulWidget {
  final String fabricCode;
  final int? id;

  const FabCode_Detaild({
    super.key,
    required this.fabricCode,
    required this.id,
  });

  @override
  State<FabCode_Detaild> createState() => _FabCode_DetaildState();
}

class _FabCode_DetaildState extends State<FabCode_Detaild> {
  // static const Color primary =
  // Color(0xFF1565C0);

  List<CuttingStockModel> data = [];
  List<CuttingStockModel> filteredData = [];

  bool loading = true;
  String error = '';

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// LOAD DATA
  Future<void> loadData() async {
    try {
      final result = await NaradanaApiService.getCutFabricWiseDetail(
        fabricCode: widget.fabricCode,
        id: widget.id,
      );

      data = CuttingStockModel.fromList(result);
      filteredData = List.from(data);

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  /// SEARCH
  void search(String value) {
    if (value.trim().isEmpty) {
      filteredData = List.from(data);
    } else {
      filteredData = data
          .where(
            (item) =>
                item.barcode.toLowerCase().contains(value.toLowerCase()) ||
                item.flattubegusset.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                item.department.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    }

    setState(() {});
  }

  /// COLUMN
  List<DataColumn> buildColumns() {
    return const [
      DataColumn(label: Text("S.No")),
      DataColumn(label: Text("Barcode")),
      DataColumn(label: Text("Fabric Code")),
      DataColumn(label: Text("Net WT")),
      DataColumn(label: Text("Qty")),
      DataColumn(label: Text("Dept")),
      DataColumn(label: Text("Req NetWt")),
      DataColumn(label: Text("Req Qty(Mtr)")),
    ];
  }

  /// ROWS
  List<DataRow> buildRows() {
    return List.generate(filteredData.length, (index) {
      final row = filteredData[index];

      return DataRow(
        cells: [
          DataCell(Text("${index + 1}")),
          DataCell(Text(row.barcode)),
          DataCell(Text(row.flattubegusset)),
          DataCell(Text(row.netwt.toString())),
          DataCell(Text(row.quantity.toString())),
          DataCell(Text(row.department)),
          DataCell(Text(row.requirednewt.toString())),
          DataCell(Text(row.requiredqtymtr.toString())),
        ],
      );
    });
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              "Total Records: ${filteredData.length}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
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


                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(3),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: search,
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
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 18,
                        headingRowColor: MaterialStateProperty.all(
                          C.headerBlue,
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: buildColumns(),
                        rows: buildRows(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// BOX
  Widget _box(String title, String value, Color color) {
    return Container(
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
    );
  }
}

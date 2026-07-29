// ===================== REPLACE ONLY DETAIL SCREEN =====================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../CUTTING_Stock/FabCodeDetailscreen.dart';

class StockFabricDetailScreen extends StatefulWidget {
  final String fabricCode;
  final int id;

  const StockFabricDetailScreen({
    super.key,
    required this.fabricCode,
     required this.id
  });

  @override
  State<StockFabricDetailScreen> createState() =>
      _StockFabricDetailScreenState();
}

class _StockFabricDetailScreenState
    extends State<StockFabricDetailScreen> {
  static const Color primary = Color(0xFF1565C0);

  List data = [];
  List filteredData = [];

  bool loading = true;

  double totalWeight = 0;
  double totalLength = 0;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final result = await NaradanaApiService.getWebStockFabric(
      fabricCode: widget.fabricCode,
      page: 1,
      pageSize: 500,
    );

    data = result["data"] ?? [];
    filteredData = data;

    calculateTotals(filteredData);

    setState(() {
      loading = false;
    });
  }

  void calculateTotals(List list) {
    totalWeight = list.fold(
      0.0,
          (sum, item) =>
      sum +
          double.tryParse(
            item["rollWeightKg"].toString(),
          )!,
    );

    totalLength = list.fold(
      0.0,
          (sum, item) =>
      sum +
          double.tryParse(
            item["rollLengthMtr"].toString(),
          )!,
    );
  }

  void searchData(String value) {
    filteredData = data.where((item) {
      final fabric =
      item["fabricCode"].toString().toLowerCase();

      return fabric.contains(value.toLowerCase());
    }).toList();

    calculateTotals(filteredData);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.fabricCode,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [


          /// SUMMARY
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StatBox(
                  label: 'Records',
                  value:
                  '${filteredData.length}',
                  color: primary,
                ),
                _StatBox(
                  label: 'Weight(Kg)',
                  value: totalWeight
                      .toStringAsFixed(2),
                  color: Colors.green,
                ),
              ],
            ),
          ),
          /// SEARCH BAR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: searchData,
              decoration: InputDecoration(
                hintText: "Search Fabric Code",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          /// TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,
              child:
              SingleChildScrollView(
                child: DataTable(
                  headingRowColor:
                  MaterialStateProperty.all(
                      primary),

                  headingTextStyle:
                  const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),

                  columnSpacing: 10,

                  columns: const [
                    DataColumn(
                      label:
                      Text("SNo."),
                    ),
                    DataColumn(
                      label: Text(
                          "Fabric Code"),
                    ),
                    DataColumn(
                      label:
                      Text("Net WT"),
                    ),
                    // DataColumn(
                    //   label: Text(
                    //       "Roll Length"),
                    // ),
                  ],

                  rows: List.generate(
                    filteredData.length,
                        (index) {
                      final e =
                      filteredData[index];

                      return DataRow(
                        color:
                        MaterialStateProperty
                            .all(
                          index.isEven
                              ? Colors.white
                              : const Color(
                              0xFFF8FAFF),
                        ),
                        cells: [
                          DataCell(
                            Text(
                                "${index + 1}"),
                          ),
                          // DataCell(
                          //   Text(
                          //     "${e["fabricCode"]}",
                          //     style:
                          //     const TextStyle(
                          //       color: Colors
                          //           .blueAccent,
                          //       fontWeight:
                          //       FontWeight
                          //           .w600,
                          //     ),
                          //   ),
                          // ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FabCode_Detaild(   // replace with your screen name
                                      fabricCode: "${e["fabricCode"]}",
                                      id: int.tryParse("${e["id"]}") ?? 0,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "${e["fabricCode"]}",
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${e["rollWeightKg"]}",
                              style:
                              const TextStyle(
                                color: Colors
                                    .green,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),
                          // DataCell(
                          //   Text(
                          //     "${e["rollLengthMtr"]}",
                          //     style:
                          //     const TextStyle(
                          //       color: Colors
                          //           .orange,
                          //       fontWeight:
                          //       FontWeight
                          //           .w600,
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// STAT BOX
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
        margin:
        const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
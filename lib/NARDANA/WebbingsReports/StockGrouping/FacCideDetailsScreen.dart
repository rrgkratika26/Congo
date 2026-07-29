// =======================================
// fab_code_detaild.dart
// Updated Screen Using Service API
// =======================================

import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';

class FabCode_Detaild extends StatefulWidget {
  final String fabricCode;
  final int? id;

  const FabCode_Detaild({
    super.key,
    required this.fabricCode,
    required this.id,
  });

  @override
  State<FabCode_Detaild> createState() =>
      _FabCode_DetaildState();
}

class _FabCode_DetaildState
    extends State<FabCode_Detaild> {
  static const Color primary =
  Color(0xFF1565C0);

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  bool loading = true;
  String error = '';

  final TextEditingController searchCtrl =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// LOAD DATA FROM SERVICE
  //////////////////////////////////////////////////////
  Future<void> loadData() async {
    try {
      final result =
      await NaradanaApiService
          .getFabricWiseDetail(
        fabricCode: widget.fabricCode,
        id: widget.id,
      );

      data = result;
      filteredData = result;

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }


  /// SEARCH
  //////////////////////////////////////////////////////
  void search(String value) {
    if (value.trim().isEmpty) {
      filteredData = List.from(data);
    } else {
      filteredData = data.where((row) {
        final map =
        row as Map<String, dynamic>;

        return map.values.any(
              (val) => val
              .toString()
              .toLowerCase()
              .contains(
            value.toLowerCase(),
          ),
        );
      }).toList();
    }

    setState(() {});
  }


  /// TABLE
  //////////////////////////////////////////////////////
  List<DataColumn> buildColumns() {
    if (filteredData.isEmpty) return [];

    final first =
    filteredData.first
    as Map<String, dynamic>;

    return first.keys
        .map(
          (key) => DataColumn(
        label: Text(
          key.toUpperCase(),
        ),
      ),
    )
        .toList();
  }

  List<DataRow> buildRows() {
    return List.generate(
      filteredData.length,
          (index) {
        final row =
        filteredData[index]
        as Map<String, dynamic>;

        return DataRow(
          cells: row.keys.map((key) {
            return DataCell(
              Text(
                row[key].toString(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor:
        Colors.white,
        title:
        Text(widget.fabricCode),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : error.isNotEmpty
          ? Center(
        child:
        Text(error),
      )
          : Column(
        children: [
          Container(
            color:
            Colors.white,
            padding:
            const EdgeInsets
                .all(10),
            child: Row(
              children: [
                Expanded(
                  child: _box(
                    "Records",
                    filteredData
                        .length
                        .toString(),
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          Container(
            color:
            Colors.white,
            padding:
            const EdgeInsets
                .all(10),
            child: TextField(
              controller:
              searchCtrl,
              onChanged:
              search,
              decoration:
              InputDecoration(
                hintText:
                "Search...",
                prefixIcon:
                const Icon(
                  Icons.search,
                ),
                filled:
                true,
                fillColor:
                Colors.grey
                    .shade100,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child:
            SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,
              child:
              SingleChildScrollView(
                child:
                DataTable(
                  columnSpacing:
                  18,
                  headingRowColor:
                  MaterialStateProperty.all(
                    primary,
                  ),
                  headingTextStyle:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),
                  columns:
                  buildColumns(),
                  rows:
                  buildRows(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// BOX
  //////////////////////////////////////////////////////
  Widget _box(
      String title,
      String value,
      Color color,
      ) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      padding:
      const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
        color.withOpacity(.08),
        borderRadius:
        BorderRadius.circular(
          8,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(
              height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
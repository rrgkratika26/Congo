import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'Reports/BalingDetailModel.dart';

class BalingDetailsScreen extends StatefulWidget {
  final String bomNo;
  final DateTime? fromDate;
  final DateTime? toDate;

  const BalingDetailsScreen({
    super.key,
    required this.bomNo,
    this.fromDate,
    this.toDate,
  });

  @override
  State<BalingDetailsScreen> createState() => _BalingDetailsScreenState();
}

class _BalingDetailsScreenState extends State<BalingDetailsScreen> {
  List<BalingDetailsModel> list = [];
  bool isLoading = true;

  String format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await JblApiService().getBalingDetails(
        bomNo: widget.bomNo,
        fromDate: format(
          widget.fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
        ),
        toDate: format(widget.toDate ?? DateTime.now()),
      );

      setState(() {
        list = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details - ${widget.bomNo}")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : list.isEmpty
          ? const Center(child: Text("No Data Found"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.blue.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text("Packing No")),
                    DataColumn(label: Text("Article No")),
                    DataColumn(label: Text("Net Wt")),
                    DataColumn(label: Text("Diff Wt")),
                  ],
                  rows: list.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.packingNo)),
                        DataCell(Text(item.articleNo)),
                        DataCell(Text(item.netWt.toString())),
                        DataCell(Text(item.diffWt.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

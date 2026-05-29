import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/visa_apis/visa_api.dart';
import 'LoomFormENtry.dart';
import 'PrintBarcode.dart';
import 'modelClass/FIBCmodel.dart';

class VisaLOOMList extends StatefulWidget {
  const VisaLOOMList({super.key});
  @override
  State<VisaLOOMList> createState() => _VisaLOOMListState();
}

class _VisaLOOMListState extends State<VisaLOOMList> {
  List<LoomProcessModel> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final result = await VisaApiService.getLoomProcess();
      setState(() {
        list = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ UI ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.headerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "FIBC Requires  Process",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, size: 20),
            tooltip: "Saved Rolls",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RollListPrintScreen(title: "Loom Rolls"),
              ),
            ),
          ),

        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : _buildTable(),
    );
  }

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.brand200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(C.headerBlue),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) return C.brand100;
                  return null; // uses alternating via decoration below
                }),
                border: TableBorder(
                  horizontalInside: BorderSide(color: C.brand100, width: 0.5),
                  verticalInside: BorderSide(color: C.brand100, width: 0.5),
                ),
                columnSpacing: 24,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 44,
                columns: _buildColumns(),
                rows: list.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return _buildRow(item, i.isEven);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    const labels = [
      "Order No",
      "Party Name",
      "PO No",
      "Article No",
      "Fabric Code",
      "Req Kg",
      "Req Mtr",
      "Bal Kg",
      "Bal Mtr",
      "Prod Fabric",
      "Status",
      "Finish",
      "Action",
    ];
    return labels.map((l) => DataColumn(label: Text(l.toUpperCase()))).toList();
  }

  DataRow _buildRow(LoomProcessModel item, bool isEven) {
    final bool isDone = item.balanceKg <= 0;
    final Color rowBg = isEven ? Colors.white : C.brand50;

    return DataRow(
      color: WidgetStateProperty.all(rowBg),
      cells: [
        _cell(item.orderNo),
        _cell(item.customerName),
        _cell(item.poNo),
        _cell(item.articleNo),
        _cell(item.fabricCode),
        _cell(item.requiredKg.toString()),
        _cell(item.requiredMtr.toString()),
        _numCell(item.balanceKg),
        _numCell(item.balanceMtr),
        _cell(item.flatTubeGusset),
        _pillCell(isDone),
        _pillCell(isDone),
        _actionCell(item),
      ],
    );
  }

  DataCell _cell(String text) => DataCell(
    Text(text, style: const TextStyle(fontSize: 13, color: C.textHigh)),
  );

  DataCell _numCell(double val) => DataCell(
    Text(
      val.toString(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: val < 0 ? C.warning : C.textHigh,
      ),
    ),
  );

  DataCell _pillCell(bool isDone) => DataCell(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? "Done" : "Pending",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDone ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
        ),
      ),
    ),
  );

  DataCell _actionCell(LoomProcessModel item) => DataCell(
    InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VisaLoomForm(production: item)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: C.borderLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: C.brand300),
        ),
        child: const Text(
          "Open",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: C.primary,
          ),
        ),
      ),
    ),
  );
}

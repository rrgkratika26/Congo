import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class OpenFabricDetailsScreen extends StatefulWidget {
  final String fabricCode;
  final String date;

  const OpenFabricDetailsScreen({
    super.key,
    required this.fabricCode,
    required this.date,
  });

  @override
  State<OpenFabricDetailsScreen> createState() =>
      _OpenFabricDetailsScreenState();
}

class _OpenFabricDetailsScreenState
    extends State<OpenFabricDetailsScreen> {
  bool _loading = true;
  String _error = '';

  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await NaradanaApiService().fetchOpenQty(
        fabricCode: widget.fabricCode,
        date: widget.date,
      );

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
        title: Text(
          widget.fabricCode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: C.primary),
      )
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _data.isEmpty
          ? const Center(child: _EmptyState())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
            WidgetStateProperty.all(C.primary),
            columnSpacing: 14,
            horizontalMargin: 10,
            dataRowHeight: 44,
            headingRowHeight: 48,
            dividerThickness: 0.5,

            columns: const [
              DataColumn(
                label: Text("SNo",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Roll Code",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Barcode",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Lot No",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Weight",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Length",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Supervisor",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Operator",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Machine",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Color",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Department",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Date",
                    style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text("Time",
                    style: TextStyle(color: Colors.white)),
              ),
            ],

            rows: List.generate(_data.length, (index) {
              final r = _data[index];

              return DataRow(
                cells: [
                  DataCell(Text("${index + 1}")),

                  DataCell(Text(r.rollCode?.toString() ?? "-")),
                  DataCell(Text(r.barcode?.toString() ?? "-")),
                  DataCell(Text(r.lotNo?.toString() ?? "-")),

                  DataCell(Text(r.rollWeightKg?.toString() ?? "-")),
                  DataCell(Text(r.rollLengthMtr?.toString() ?? "-")),

                  DataCell(Text(r.supervisorName?.toString() ?? "-")),
                  DataCell(Text(r.operatorName?.toString() ?? "-")),

                  DataCell(Text(r.machineNo?.toString() ?? "-")),

                  DataCell(Text(r.color?.toString() ?? "-")),
                  DataCell(Text(r.department?.toString() ?? "-")),

                  DataCell(
                    Text(
                      (r.date ?? "-").toString().split("T").first,
                    ),
                  ),

                  DataCell(Text(r.time?.toString() ?? "-")),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text("No Records Found"),
      ],
    );
  }
}
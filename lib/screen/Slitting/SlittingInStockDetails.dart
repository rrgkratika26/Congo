import 'package:IMS/services/DashboardApiServices.dart';
import 'package:IMS/services/Visa_SmallbagAPIS/VISA_SApis.dart';
import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';

class SlittingInStockDetail extends StatelessWidget {
  final String date;
  SlittingInStockDetail({Key? key, required this.date}) : super(key: key);

  final VisaSmallBagApiService _service = VisaSmallBagApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.appBar1,
        title: const Text(
          'Slitting InStock Report',
          style: TextStyle(color: C.bg),
        ),
        iconTheme: IconThemeData(color: C.bg),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _service.SlittingScannedItemsDetails(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text("No data found"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(C.brand200),
                headingTextStyle: const TextStyle(
                  color: C.textHead,
                  fontWeight: FontWeight.bold,
                ),
                dataRowMinHeight: 20,
                dataRowMaxHeight: 45,
                columnSpacing: 20,
                border: TableBorder.all(color: Colors.grey.shade300),

                columns: const [
                  DataColumn(label: Text("Barcode")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Supervisor")),
                  DataColumn(label: Text("Operator")),
                  DataColumn(label: Text("Location")),
                  DataColumn(label: Text("Department")),
                  DataColumn(label: Text("Tare")),
                  DataColumn(label: Text("Party")),
                  DataColumn(label: Text("Work Order")),
                  DataColumn(label: Text("Job Work")),
                  DataColumn(label: Text("Machine")),
                  DataColumn(label: Text("Net Wt")),
                  DataColumn(label: Text("Qty")),
                  DataColumn(label: Text("Req KG")),
                  DataColumn(label: Text("Req MTR")),
                  DataColumn(label: Text("Fabric Width")),
                  DataColumn(label: Text("GSM")),
                  DataColumn(label: Text("Color")),
                  DataColumn(label: Text("Lamination")),
                  DataColumn(label: Text("Cut Type")),
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("SID")),
                  DataColumn(label: Text("Baffle")),
                  DataColumn(label: Text("Fabric Code")),
                  DataColumn(label: Text("RM Status")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Time")),
                ],

                rows: items.map<DataRow>((item) {
                  final isIn = item['activein'] == 'IN';

                  return DataRow(
                    cells: [
                      DataCell(Text(item['barcode'] ?? '')),

                      DataCell(
                        Chip(
                          label: Text(
                            item['activein'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: isIn ? Colors.green : Colors.red,
                        ),
                      ),
                      DataCell(Text(item['laminatioN_SUPERVISOR1'] ?? '')),
                      DataCell(Text(item['laminatioN_OPERATOR1'] ?? '')),
                      DataCell(Text(item['laminatioN_LOCATION1'] ?? '')),
                      DataCell(Text(item['department'] ?? '')),
                      DataCell(Text(item['weekno']?.toString() ?? '')),
                      DataCell(Text(item['partyname'] ?? '')),
                      DataCell(Text(item['workorderno'] ?? '')),
                      DataCell(Text(item['jobwork'] ?? '')),
                      DataCell(Text(item['machineno'] ?? '')),
                      DataCell(Text(item['netwt']?.toString() ?? '')),
                      DataCell(Text(item['quantity']?.toString() ?? '')),
                      DataCell(Text(item['requirednewt']?.toString() ?? '')),
                      DataCell(Text(item['requiredqtymtr']?.toString() ?? '')),
                      DataCell(Text(item['fabricwidth'] ?? '')),
                      DataCell(Text(item['gsm'] ?? '')),
                      DataCell(Text(item['color'] ?? '')),
                      DataCell(Text(item['lamination'] ?? '')),
                      DataCell(Text(item['cuttype'] ?? '')),
                      DataCell(Text(item['typeuse'] ?? '')),
                      DataCell(Text(item['sid'] ?? '')),
                      DataCell(Text(item['buffle'] ?? '')),
                      DataCell(Text(item['flattubegusset'] ?? '')),
                      DataCell(Text(item['rM_STATUS'] ?? '')),
                      DataCell(Text(_formatDate(item['laminatioN_DATE1']))),
                      DataCell(Text(item['laminatioN_TIME1'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    return date.toString().split('T').first;
  }
}

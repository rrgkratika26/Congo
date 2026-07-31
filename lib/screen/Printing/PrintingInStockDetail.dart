
import 'package:IMS/screen/Printing/ModelClass/scanReportModel.dart';
import 'package:flutter/material.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../services/Visa_SmallbagAPIS/VISA_SApis.dart';

class PrintingInDetailScreen extends StatelessWidget {
  final String date;
  final String plant;

  PrintingInDetailScreen({Key? key, required this.date, required this.plant})
      : super(key: key);

  final InStockService _service = InStockService();

  @override
  Widget build(BuildContext context) {
    // debugPrint("Selected Plant 👉 $plant");
    // debugPrint("Selected Date 👉 $date");
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: C.bg),
        title: Text('Printing InStock', style: TextStyle(color: C.bg)),

        centerTitle: true,
        backgroundColor: C.appBar1,
      ),
      body: FutureBuilder<List<PrintingReportModel>>(
        future: VisaSmallBagApiService().getPrintingReport(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('No Lamination data found'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(C.brand200),
                columns: const [
                  DataColumn(
                    label: Text(
                      "RollCode",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Barcode",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Fabric Code",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text("Party", style: TextStyle(color: C.textHead)),
                  ),
                  DataColumn(
                    label: Text(
                      "Supervisor",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Operator",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Location",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Net Wt",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Gross Wt",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Roll Length",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Department",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Issue To",
                      style: TextStyle(color: C.textHead),
                    ),
                  ),
                  DataColumn(
                    label: Text("Time", style: TextStyle(color: C.textHead)),
                  ),
                ],
                rows: items.map((e) {
                  return DataRow(
                    cells: [
                      DataCell(Text(e.rollcode)),

                      DataCell(Text(e.barcode)),
                      DataCell(Text(e.fabricCode)),
                      DataCell(Text(e.partyName)),
                      DataCell(Text(e.supervisor)),
                      DataCell(Text(e.operatorName)),
                      DataCell(Text(e.location)),
                      DataCell(Text(e.netWeight)),
                      DataCell(Text(e.grossWeight)),
                      DataCell(Text(e.rollLength)),
                      DataCell(Text(e.status)),
                      DataCell(Text(e.department)),
                      DataCell(Text(e.issueToDept)),
                      DataCell(Text(e.time)),
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
}
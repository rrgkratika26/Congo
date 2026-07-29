import 'package:IMS/services/DashboardApiServices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/getSupervisors/getSupervisors.dart';
import '../../Color/Colorclass.dart';
import '../../JBL/JBLWebbing/Reports_model/outReportModel.dart';
import 'ReportmodelClass/ReportModelClass.dart';
import 'ReportmodelClass/WebOutDetailsclass.dart' hide WebbingOutReportModel;

class WebbOutReportDetailsScreen extends StatelessWidget {
  final String date;

  const WebbOutReportDetailsScreen({Key? key, required this.date})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text("Webbing Out Stock",style: TextStyle(color: C.bg),),
        centerTitle: true,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: FutureBuilder<WebbingOutDetailsModel?>(
        future: DashboardService.fetchWebbingScannedOutItems(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final items = snapshot.data!.items;

          if (items.isEmpty) {
            return const Center(child: Text("No Items Found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Barcode : ${item.barcode}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "OUT",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),

                      const Divider(height: 25),

                      _infoRow("SR No", item.srNo.toString()),
                      _infoRow("Roll Code", item.rollCode),
                      _infoRow("BOM No", item.weekNo),
                      _infoRow("Lot No", item.lotNo),
                      _infoRow("Fabric Code", item.fabricCode),
                      _infoRow("Roll Weight", item.rollWeight.toString()),
                      _infoRow("Roll Length", item.rollLength.toString()),

                      _infoRow("Party Name", item.partyName),
                      _infoRow("Work Order", item.workOrderNo),
                      _infoRow("Order Type", item.orderType),
                      
                      _infoRow("Belt Type", item.beltType),


                      _infoRow("Belt Width", item.beltWidth),
                      _infoRow("Belt GSM", item.beltGSM),


                      _infoRow(
                        "Date",
                        DateFormat("dd-MM-yyyy").format(item.date),
                      ),
                      _infoRow("Time", item.time),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}
Widget _infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            "$title :",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DataCell extends StatelessWidget {
  final String text;
  final double width;

  const _DataCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text.isEmpty ? "-" : text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}



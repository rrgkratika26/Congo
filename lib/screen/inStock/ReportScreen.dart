import 'package:IMS/services/DashboardApiServices.dart';
import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';

class ReportRMDDetailScreen extends StatelessWidget {
  final String date;
  ReportRMDDetailScreen({Key? key, required this.date}) : super(key: key);

  final InStockService _service = InStockService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.appBar1,
        title: const Text(
          'In Stock Report',style: TextStyle(color: C.bg),
        ),
        iconTheme: IconThemeData(color: C.bg),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _service.getScannedItems(date),
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

          // return Column(
          //   children: [
          //
          //     Container(
          //       width: double.infinity,
          //       margin: const EdgeInsets.all(12),
          //       padding: const EdgeInsets.all(15),
          //       decoration: BoxDecoration(
          //         color: Colors.blue.shade50,
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(color: Colors.blue),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           const Text(
          //             "Total Items Scanned",
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           CircleAvatar(
          //             radius: 22,
          //             backgroundColor: Colors.blue,
          //             child: Text(
          //               "${items.length}",
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //
          //     Expanded(
          //       child: ListView.builder(
          //         padding: const EdgeInsets.symmetric(horizontal: 12),
          //         itemCount: items.length,
          //         itemBuilder: (context, index) {
          //           final item = items[index];
          //
          //           final isIn = item["inStock"] == "IN";
          //
          //           return Card(
          //             elevation: 4,
          //             margin: const EdgeInsets.only(bottom: 12),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //             child: Padding(
          //               padding: const EdgeInsets.all(12),
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //
          //                       Expanded(
          //                         child: Text(
          //                           item["barcode"] ?? "",
          //                           style: const TextStyle(
          //                             fontWeight: FontWeight.bold,
          //                             fontSize: 16,
          //                           ),
          //                         ),
          //                       ),
          //
          //                       Container(
          //                         padding: const EdgeInsets.symmetric(
          //                             horizontal: 10, vertical: 5),
          //                         decoration: BoxDecoration(
          //                           color: isIn ? Colors.green : Colors.red,
          //                           borderRadius: BorderRadius.circular(20),
          //                         ),
          //                         child: Text(
          //                           item["inStock"] ?? "",
          //                           style: const TextStyle(
          //                             color: Colors.white,
          //                             fontWeight: FontWeight.bold,
          //                           ),
          //                         ),
          //                       )
          //
          //                     ],
          //                   ),
          //
          //                   const Divider(),
          //
          //                   _infoRow("Roll Code", item["rollCode"].toString()),
          //                   _infoRow("Fabric Code", item["fabricCode"] ?? ""),
          //                   _infoRow("Party", item["partyName"] ?? ""),
          //                   _infoRow("Supervisor", item["supervisorName"] ?? ""),
          //                   _infoRow("Operator", item["operatorName"] ?? ""),
          //                   _infoRow("Location", item["location"] ?? ""),
          //                   _infoRow("Department", item["department"] ?? ""),
          //                   _infoRow("Component", item["component"] ?? ""),
          //                   _infoRow("Loom No", item["loomNo"] ?? ""),
          //                   _infoRow("Work Order", item["workOrderNo"] ?? ""),
          //                   _infoRow(
          //                       "Roll Weight",
          //                       item["rollWeight"].toString()),
          //                   _infoRow(
          //                       "Roll Length",
          //                       item["rollLength"].toString()),
          //                   _infoRow(
          //                       "Required Qty (KG)",
          //                       item["requiredQuantityKg"].toString()),
          //                   _infoRow(
          //                       "Required Qty (MTR)",
          //                       item["requiredQuantityMtr"].toString()),
          //                   _infoRow("Status", item["status"] ?? ""),
          //                   _infoRow("Date", _formatDate(item["date"] ?? "")),
          //                   _infoRow("Time", item["time"] ?? ""),
          //                   _infoRow("Remark", item["remark"] ?? "-"),
          //
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // );

          // if (items.isEmpty) {
          //   return const Center(child: Text('No data found'));
          // }
          //
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isIn = item['ACTIVEIN'] == 'IN';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Barcode: ${item['BARCODE'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isIn ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isIn ? 'IN' : 'OUT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _infoRow('Fabric Code', item['FABRIC_CODE']),

                      // _infoRow('Roll Code', item.rollCode.toString()),
                      _infoRow(
                        'Net Weight (KG)',
                        item['NET_WEIGHT_KG']?.toString() ?? '',
                      ),

                      _infoRow(
                        'Roll Length (MTR)',
                        item['ROLL_LENGTH_MTR']?.toString() ?? '',
                      ),
                      _infoRow('Supervisor', item['SUPERVISOR'] ?? ''),
                      _infoRow('Location', item['LOCATION'] ?? ''),
                      _infoRow('In Date', _formatDate(item['RMD_DATE'] ?? '')),
                      _infoRow('Out Date', _formatDate(item['RMD_DATE1'] ?? '')),
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
  Widget _infoRow(String title, dynamic value) {
    final text = value?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text.isEmpty ? '-' : text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    return date.toString().split('T').first;
  }
}

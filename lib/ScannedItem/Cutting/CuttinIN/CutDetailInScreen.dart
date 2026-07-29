import 'package:IMS/services/DashboardApiServices.dart';
import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';

class ReportCUTDetailScreen extends StatelessWidget {
  final String date;
  ReportCUTDetailScreen({Key? key, required this.date}) : super(key: key);

  final DashboardService _service = DashboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.appBar1,
        title: const Text('Cut InStock Report', style: TextStyle(color: C.bg)),
        iconTheme: IconThemeData(color: C.bg),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _service.getCuttingScannedItems(date),
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


          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {


              final item = items[index];
              final isIn = item['inStock'] == 'IN';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Barcode: ${item['barcode'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Chip(
                            backgroundColor: isIn ? Colors.green : Colors.red,
                            label: Text(
                              item['inStock'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),

                      const Divider(),

                      _infoRow('Fabric Code', item['fabricCode']),
                      _infoRow('Roll Weight', item['rollWeight']),
                      _infoRow('Roll Length', item['rollLength']),
                      _infoRow('Supervisor', item['supervisorName']),
                      _infoRow('Operator', item['operatorName']),
                      _infoRow('Location', item['location']),
                      _infoRow('Department', item['department']),
                      _infoRow('Component', item['component']),
                      _infoRow('Work Order', item['workOrderNo']),
                      _infoRow('Required KG', item['requiredQuantityKg']),
                      _infoRow('Required MTR', item['requiredQuantityMtr']),
                      _infoRow('Status', item['status']),
                      _infoRow('Date', _formatDate(item['date'])),
                      _infoRow('Time', item['time']),
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

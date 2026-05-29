import 'package:flutter/material.dart';
import '../../services/getSupervisors/getSupervisors.dart';

class ReportDetailScreen extends StatelessWidget {
  final String date;
  ReportDetailScreen({Key? key, required this.date}) : super(key: key);

  final InStockService _service = InStockService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ''
          'Scanned Items Report',
        ),
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
            return const Center(child: Text('No data found'));
          }

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
                            'Barcode: ${item['BARCODE']}',
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
                        item['NET_WEIGHT_KG'].toString(),
                      ),
                      _infoRow(
                        'Roll Length (MTR)',
                        item['ROLL_LENGTH_MTR'].toString(),
                      ),
                      _infoRow('Supervisor', item['SUPERVISOR']),
                      _infoRow('Location', item['LOCATION']),
                      _infoRow('In Date', _formatDate(item['RMD_DATE'])),
                      _infoRow('Out Date', _formatDate(item['RMD_DATE1'])),
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

  Widget _infoRow(String title, String value) {
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
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
    return date.split('T').first;
  }
}

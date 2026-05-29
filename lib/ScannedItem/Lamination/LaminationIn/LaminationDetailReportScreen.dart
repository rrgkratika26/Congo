import 'package:flutter/material.dart';

import '../../../services/getSupervisors/getSupervisors.dart';

class LaminationDetailScreen extends StatelessWidget {
  final String date;
  final String plant;

  LaminationDetailScreen({Key? key, required this.date, required this.plant})
    : super(key: key);

  final InStockService _service = InStockService();

  @override
  Widget build(BuildContext context) {
    debugPrint("Selected Plant 👉 $plant");
    debugPrint("Selected Date 👉 $date");
    return Scaffold(
      appBar: AppBar(
        title: Text('Lamination Report'),

        centerTitle: true,
        backgroundColor: Colors.orange.shade100,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.getLaminationScannedItems(date: date, plant: plant),
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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

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
                            'Barcode: ${item['BARCODE'] ?? 'N/A'}',
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
                              color: Colors.orange.shade500,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'LAMINATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _infoRow(
                        'Fabric Code',
                        item['FABRIC_CODE']?.toString() ?? '-',
                      ),
                      _infoRow(
                        'Roll Code',
                        item['ROLL CODE']?.toString() ?? '-',
                      ),
                      _infoRow(
                        'Net Weight (Kg)',
                        item['NET_WEIGHT (Kg)']?.toString() ?? '-',
                      ),
                      _infoRow(
                        'Roll Length (Mtr)',
                        item['ROLL_LENGTH (Mtr)']?.toString() ?? '-',
                      ),
                      _infoRow(
                        'Supervisor',
                        item['SUPERVISOR']?.toString() ?? '-',
                      ),
                      _infoRow('Location', item['LOCATION']?.toString() ?? '-'),
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
            width: 150,
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
}

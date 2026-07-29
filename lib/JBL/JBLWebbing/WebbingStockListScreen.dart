import 'package:flutter/material.dart';

class WebbingStockListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WebbingStockListScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Details"),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? const Center(child: Text("No Data Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return _stockCard(item);
        },
      ),
    );
  }

  Widget _stockCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item["FABRIC CODE"]?.toString() ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item["CODE"]?.toString() ?? "-",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 DETAILS GRID
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _info("Lot No", item["LOT NO"]),
                _info("Roll Code", item["ROLL CODE"]),
                _info("Weight (Kg)", item["ROLL WEIGHT (Kg)"]),
                _info("Length (Mtr)", item["ROLL LENGTH (Mtr)"]),
                _info("Machine", item["MACHINE NO."]),
                _info("Operator", item["OPERATOR NAME"]),
                _info("Supervisor", item["SUPERVISOR NAME"]),
                _info("Location", item["Location"]),
              ],
            ),

            const SizedBox(height: 10),

            // 🔸 DATE + TIME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${_formatDate(item["DATE"])}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "Time: ${item["TIME"] ?? "-"}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return SizedBox(
      width: 150,
      child: Text(
        "$label: ${value?.toString().isNotEmpty == true ? value : "-"}",
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    try {
      final parsed = DateTime.parse(date);
      return "${parsed.day}-${parsed.month}-${parsed.year}";
    } catch (e) {
      return date;
    }
  }
}
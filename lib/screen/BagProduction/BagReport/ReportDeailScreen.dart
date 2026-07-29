import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../modelClass/BagReportModelClass.dart';

class BagReportDetailScreen extends StatelessWidget {
  final BagProductionReport report;

  const BagReportDetailScreen({Key? key, required this.report})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title:    Text(
          report.partyName,
          style: const TextStyle(
            color: C.textBody,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF42A5F6).withOpacity(0.2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            _sectionCard(
              title: "All Details",
              children: [
                _tile(Icons.business, "Party Name", report.partyName),
                _tile(Icons.article, "Article No", report.articleNo ?? 'N/A'),
                _tile(Icons.receipt, "PO Number", report.poNum ?? 'N/A'),
                _tile(Icons.confirmation_number, "BOM No", report.bomNo ?? 'N/A'),

                _tile(Icons.factory, "Production Qty", report.productionQty.toString()),
                _tile(Icons.shopping_bag, "Required Bag", report.requireD_BAG.toString()),
                _tile(Icons.inventory, "Bag Out", report.bagOut.toString()),

                _tile(Icons.access_time, "Shift", report.shift),
                _tile(Icons.line_style, "Line", report.line),

                if (report.contractor != null)
                  _tile(Icons.person, "Contractor", report.contractor!),

                _tile(Icons.calendar_today, "Date",
                    DateFormat('dd-MM-yyyy').format(report.date)),
              ],
            ),

          ],
        ),
      ),
    );
  }



  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value,
      {Color? color, bool isBold = false}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF42A5F6)),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
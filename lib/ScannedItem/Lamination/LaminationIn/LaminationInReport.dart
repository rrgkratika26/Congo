// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class LaminationReportScreen extends StatefulWidget {
//   final DateTime? startDate;
//   final DateTime? endDate;
//
//   const LaminationReportScreen({Key? key, this.startDate, this.endDate})
//       : super(key: key);
//
//   @override
//   State<LaminationReportScreen> createState() =>
//       _LaminationReportScreenState();
// }
//
// class _LaminationReportScreenState extends State<LaminationReportScreen> {
//   String searchQuery = '';
//
//   final List<LaminationItem> laminationItems = [
//     LaminationItem(
//       id: 'LAM001',
//       material: 'PET Film',
//       netWeight: '220 kg',
//       rollLength: '480 m',
//       rolls: 10,
//       machine: 'Machine A',
//       date: DateTime(2026, 1, 20),
//     ),
//     LaminationItem(
//       id: 'LAM002',
//       material: 'BOPP Film',
//       netWeight: '300 kg',
//       rollLength: '620 m',
//       rolls: 14,
//       machine: 'Machine B',
//       date: DateTime(2026, 1, 21),
//     ),
//     LaminationItem(
//       id: 'LAM003',
//       material: 'CPP Film',
//       netWeight: '180 kg',
//       rollLength: '400 m',
//       rolls: 8,
//       machine: 'Machine C',
//       date: DateTime(2026, 1, 19),
//     ),
//   ];
//
//   List<LaminationItem> get filteredItems {
//     return laminationItems.where((item) {
//       final matchesSearch = searchQuery.isEmpty ||
//           item.material
//               .toLowerCase()
//               .contains(searchQuery.toLowerCase()) ||
//           item.id.toLowerCase().contains(searchQuery.toLowerCase());
//
//       final matchesDate =
//           (widget.startDate == null ||
//               item.date.isAfter(
//                   widget.startDate!.subtract(const Duration(days: 1)))) &&
//               (widget.endDate == null ||
//                   item.date.isBefore(
//                       widget.endDate!.add(const Duration(days: 1))));
//
//       return matchesSearch && matchesDate;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSearchBar(),
//           const SizedBox(height: 20),
//           _buildSummaryCards(),
//           const SizedBox(height: 20),
//           _buildLaminationList(),
//         ],
//       ),
//     );
//   }
//
//   // 🔍 Search
//   Widget _buildSearchBar() {
//     return TextField(
//       onChanged: (v) => setState(() => searchQuery = v),
//       decoration: InputDecoration(
//         hintText: 'Search by Lamination ID or Material',
//         prefixIcon: const Icon(Icons.search),
//         suffixIcon: searchQuery.isNotEmpty
//             ? IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () => setState(() => searchQuery = ''),
//         )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
//
//   // 📊 Summary
//   Widget _buildSummaryCards() {
//     final items = filteredItems;
//
//     final totalRolls =
//     items.fold<int>(0, (sum, e) => sum + e.rolls);
//
//     final totalWeight = items.fold<double>(
//       0,
//           (sum, e) =>
//       sum +
//           double.parse(e.netWeight.replaceAll(RegExp(r'[^0-9.]'), '')),
//     );
//
//     return Row(
//       children: [
//         Expanded(
//           child: _summaryCard(
//             'Total Weight',
//             '${totalWeight.toStringAsFixed(0)} kg',
//             Icons.scale,
//             Colors.green,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _summaryCard(
//             'Total Rolls',
//             '$totalRolls',
//             Icons.layers,
//             Colors.orange,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _summaryCard(
//       String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.15),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 6),
//           Text(value,
//               style:
//               const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 2),
//           Text(title, style: TextStyle(color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }
//
//   // 📋 List
//   Widget _buildLaminationList() {
//     final items = filteredItems;
//
//     if (items.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(32),
//           child: Text('No lamination records found'),
//         ),
//       );
//     }
//
//     return Column(
//       children: items.map(_laminationCard).toList(),
//     );
//   }
//
//   Widget _laminationCard(LaminationItem item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6),
//         ],
//       ),
//       child: ListTile(
//         title: Text(item.material,
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Machine: ${item.machine}'),
//             Text('Weight: ${item.netWeight} | Rolls: ${item.rolls}'),
//             Text(
//               DateFormat('dd MMM yyyy').format(item.date),
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//         trailing: Chip(
//           label: Text(item.id),
//           backgroundColor: Colors.green.shade100,
//         ),
//       ),
//     );
//   }
// }
//
// // 📦 Model
// class LaminationItem {
//   final String id;
//   final String material;
//   final String netWeight;
//   final String rollLength;
//   final int rolls;
//   final String machine;
//   final DateTime date;
//
//   LaminationItem({
//     required this.id,
//     required this.material,
//     required this.netWeight,
//     required this.rollLength,
//     required this.rolls,
//     required this.machine,
//     required this.date,
//   });
// }
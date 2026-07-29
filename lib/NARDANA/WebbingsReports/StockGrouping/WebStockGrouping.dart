// fabric_code_wise_screen.dart

import 'package:flutter/material.dart';
import '../../../services/NardanaApis/NardanaApi.dart';

import 'FabCodeWiseModel.dart';
import 'StockFabricDetailScreen.dart';


class FabricCodeWiseReportScreen extends StatefulWidget {
  const FabricCodeWiseReportScreen({super.key});

  @override
  State<FabricCodeWiseReportScreen> createState() =>
      _FabricCodeWiseReportScreenState();
}

class _FabricCodeWiseReportScreenState
    extends State<FabricCodeWiseReportScreen> {
  static const Color primary = Color(0xFF1565C0);
  static const int pageSize = 10;

  List<FabricCodeWiseItem> allData = [];
  List<FabricCodeWiseItem> filteredData = [];

  bool loading = true;
  String error = '';

  int currentPage = 1;
  int totalRecords = 0;
  double totalWeight = 0;
  double totalLength = 0;

  final TextEditingController searchCtrl = TextEditingController();

  // ─── computed ───────────────────────────────────────
  int get totalPages => (filteredData.length / pageSize).ceil().clamp(1, 99999);

  List<FabricCodeWiseItem> get pageData {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filteredData.length);
    return filteredData.sublist(start, end);
  }

  // ─── lifecycle ──────────────────────────────────────
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ─── fetch ──────────────────────────────────────────
  Future<void> fetchData() async {
    setState(() { loading = true; error = ''; });
    try {
      final result = await NaradanaApiService.getFabricCodeWise(
        page: 1, pageSize: 9999,   // fetch everything once
      );
      allData      = result.data.items;
      filteredData = allData;
      totalRecords = filteredData.length;            // from actual data
      totalWeight  = allData.fold(0.0, (s, e) => s + e.totalRollWeightKg);
      totalLength  = allData.fold(0.0, (s, e) => s + e.totalRollLengthMtr);
      setState(() { loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  // ─── search ─────────────────────────────────────────
  void onSearch(String value) {
    setState(() {
      filteredData = allData
          .where((e) => e.fabricCode.toLowerCase().contains(value.toLowerCase()))
          .toList();
      currentPage = 1;
    });
  }

  void openDetail(String fabricCode, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockFabricDetailScreen(fabricCode: fabricCode, id: id),
      ),
    );
  }

  // ─── ui ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error,
          style: const TextStyle(color: Colors.red)))
          : Column(children: [
        _SummaryBar(
          records: totalRecords,
          weight: totalWeight,
          length: totalLength,
        ),
        _SearchBar(controller: searchCtrl, onChanged: onSearch),
        Expanded(child: _buildTable()),
        _PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          totalFiltered: filteredData.length,
          pageSize: pageSize,
          onPrev: currentPage > 1
              ? () => setState(() => currentPage--)
              : null,
          onNext: currentPage < totalPages
              ? () => setState(() => currentPage++)
              : null,
        ),
      ]),
    );
  }

  Widget _buildTable() {
    final rows = pageData;
    final offset = (currentPage - 1) * pageSize;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(primary),
            headingTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            dataTextStyle: const TextStyle(fontSize: 13),
            columnSpacing: 24,
            dividerThickness: 0.5,
            columns: const [
              DataColumn(label: Text('Sr')),
              DataColumn(label: Text('Fabric Code')),
              DataColumn(label: Text('Weight (kg)')),
              DataColumn(label: Text('Length (m)')),
              DataColumn(label: Text('Count')),
            ],
            rows: List.generate(rows.length, (i) {
              final e = rows[i];
              final isEven = i.isEven;
              return DataRow(
                color: MaterialStateProperty.all(
                  isEven ? Colors.white : const Color(0xFFF8FAFF),
                ),
                cells: [
                  DataCell(Text('${offset + i + 1}',
                      style: const TextStyle(color: Colors.grey))),
                  DataCell(
                    GestureDetector(
                      onTap: () => openDetail(e.fabricCode,e.id),
                      child: Text(e.fabricCode,
                          style: const TextStyle(
                              color: primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  DataCell(Text(e.totalRollWeightKg.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Color(0xFF2E7D32), fontWeight: FontWeight.w500))),
                  DataCell(Text(e.totalRollLengthMtr.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Color(0xFFE65100), fontWeight: FontWeight.w500))),
                  DataCell(Text('${e.totalCount}',
                      style: const TextStyle(
                          color: primary, fontWeight: FontWeight.w500))),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// EXTRACTED WIDGETS
// ═══════════════════════════════════════════════════════

class _SummaryBar extends StatelessWidget {
  final int records;
  final double weight, length;
  const _SummaryBar(
      {required this.records, required this.weight, required this.length});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        _StatBox(label: 'Total Records', value: '$records',
            color: const Color(0xFF1565C0)),
        _StatBox(label: 'Weight (kg)', value: weight.toStringAsFixed(2),
            color: const Color(0xFF2E7D32)),
        _StatBox(label: 'Length (m)', value: length.toStringAsFixed(2),
            color: const Color(0xFFE65100)),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: color,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 15, color: color,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search fabric code...',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage, totalPages, totalFiltered, pageSize;
  final VoidCallback? onPrev, onNext;
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalFiltered,
    required this.pageSize,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final start = ((currentPage - 1) * pageSize + 1).clamp(1, totalFiltered);
    final end = (currentPage * pageSize).clamp(1, totalFiltered);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$start–$end of $totalFiltered',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Row(children: [
            _PageBtn(
              label: '← Prev',
              onTap: onPrev,
            ),
            const SizedBox(width: 8),
            Text('$currentPage / $totalPages',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            _PageBtn(
              label: 'Next →',
              onTap: onNext,
            ),
          ]),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PageBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
              color: disabled ? Colors.grey.shade300 : const Color(0xFF1565C0),
              width: 0.8),
          borderRadius: BorderRadius.circular(6),
          color: disabled ? Colors.grey.shade100 : const Color(0xFFE3F2FD),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: disabled ? Colors.grey.shade400 : const Color(0xFF1565C0))),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DETAIL SCREEN (cleaned up)
// ═══════════════════════════════════════════════════════
//
// class StockFabricDetailScreen extends StatefulWidget {
//   final String fabricCode;
//   const StockFabricDetailScreen({super.key, required this.fabricCode});
//
//   @override
//   State<StockFabricDetailScreen> createState() =>
//       _StockFabricDetailScreenState();
// }
//
// class _StockFabricDetailScreenState extends State<StockFabricDetailScreen> {
//   static const Color primary = Color(0xFF1565C0);
//
//   List data = [];
//   bool loading = true;
//   double totalWeight = 0;
//   double totalLength = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDetail();
//   }
//
//   Future<void> fetchDetail() async {
//     final result = await NaradanaApiService.getStockFabric(
//       fabricCode: widget.fabricCode,
//       page: 1,
//       pageSize: 500,
//     );
//     data = result['data'];
//     totalWeight = data.fold(0.0, (s, e) => s + e['rollWeightKg']);
//     totalLength = data.fold(0.0, (s, e) => s + e['rollLengthMtr']);
//     setState(() { loading = false; });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.fabricCode,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.w600)),
//
//           ],
//         ),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(children: [
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(
//               horizontal: 12, vertical: 10),
//           child: Row(children: [
//             _StatBox(label: 'Records',
//                 value: '${data.length}',
//                 color: primary),
//             _StatBox(label: 'Weight (kg)',
//                 value: totalWeight.toStringAsFixed(2),
//                 color: const Color(0xFF2E7D32)),
//             _StatBox(label: 'Length (m)',
//                 value: totalLength.toStringAsFixed(2),
//                 color: const Color(0xFFE65100)),
//           ]),
//         ),
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.all(10),
//             itemCount: data.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 6),
//             itemBuilder: (_, i) {
//               final e = data[i];
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                       color: Colors.grey.shade200, width: 0.5),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('${i + 1}',
//                         style: const TextStyle(
//                             color: Colors.grey, fontSize: 12)),
//                     Text('${e['rollWeightKg']} kg',
//                         style: const TextStyle(
//                             color: Color(0xFF2E7D32),
//                             fontWeight: FontWeight.w500)),
//                     Text('${e['rollLengthMtr']} m',
//                         style: const TextStyle(
//                             color: Color(0xFFE65100),
//                             fontWeight: FontWeight.w500)),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ]),
//     );
//   }
// }
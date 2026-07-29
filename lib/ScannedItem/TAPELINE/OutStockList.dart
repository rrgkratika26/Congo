import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'EntryBarcodeOutStock.dart';

class TapelineOutStockScreen extends StatefulWidget {
  const TapelineOutStockScreen({super.key});

  @override
  State<TapelineOutStockScreen> createState() => _TapelineOutStockScreenState();
}

class _TapelineOutStockScreenState extends State<TapelineOutStockScreen> {
  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOutStockList();
  }

  Future<void> fetchOutStockList() async {
    try {
      final data = await InStockService().getTapelineOutList();

      setState(() {
        allData = data;
        filteredData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredData = allData.where((item) {
        return item['code'].toString().toLowerCase().contains(query) ||
            item['balance'].toString().contains(query) ||
            item['issuekg'].toString().contains(query);
      }).toList();
    });
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text("Tapeline Out Stock", style: TextStyle(color: C.bg)),
        backgroundColor: C.primary,
        iconTheme: IconThemeData(color: C.bg),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: C.bg,
          ),
          onPressed: () => Get.offAll(() => const NewAdminDashboard()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner, size: 25),
        label: const Text("Scan", style: TextStyle(fontSize: 15)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarcodeEntryScreen()),
          );
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3))
          : Column(
              children: [
                // 🔍 SEARCH
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: "Search by Party, Recipe, DNR...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 📦 LIST
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // ✅ horizontal scroll
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 15,
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade200,
                        ),
                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("Code")),
                          DataColumn(label: Text("Balance")),
                          DataColumn(label: Text("Issue Qty")),
                          DataColumn(label: Text("Issue KG")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Remark")),
                        ],
                        rows: filteredData.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item['id'].toString())),
                              DataCell(
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const BarcodeEntryScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(item['code'] ?? ''),
                                ),
                              ),
                              DataCell(Text(item['balance'].toString())),
                              DataCell(Text(item['issueqty'].toString())),
                              DataCell(Text(item['issuekg'].toString())),
                              DataCell(Text(item['statuS_ISSUE'].toString())),
                              DataCell(Text(item['remark']?.trim() ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';

class RecentEntriesScreen extends StatefulWidget {
  const RecentEntriesScreen({super.key});

  @override
  State<RecentEntriesScreen> createState() => _RecentEntriesScreenState();
}

class _RecentEntriesScreenState extends State<RecentEntriesScreen> {
  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecentEntries();
  }

  Future<void> fetchRecentEntries() async {
    try {
      final data = await InStockService().getRecentSavedList();

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
        return item['party']
            .toString()
            .toLowerCase()
            .contains(query) ||
            item['recipetype']
                .toString()
                .toLowerCase()
                .contains(query) ||
            item['dnr'].toString().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Entries",style: TextStyle(color: C.bg),),
        backgroundColor: C.appBar1,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search by Party, Recipe, DNR...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 📊 TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Supervisor")),
                  DataColumn(label: Text("Operator")),
                  DataColumn(label: Text("Party")),
                  DataColumn(label: Text("Cont No")),
                  DataColumn(label: Text("Work Order")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Time")),
                  DataColumn(label: Text("Recipe")),
                  DataColumn(label: Text("DNR")),
                  DataColumn(label: Text("Width")),
                  DataColumn(label: Text("Gross")),
                  DataColumn(label: Text("Tare")),
                  DataColumn(label: Text("Net")),
                  DataColumn(label: Text("PP Lot")),
                  DataColumn(label: Text("Code")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Entry Type")),
                  DataColumn(label: Text("Issue")),
                  DataColumn(label: Text("Remark")),
                ],
                rows: filteredData.map((item) {
                  return DataRow(cells: [
                    DataCell(
                      Text(
                        item['id'].toString(),
                        style: TextStyle(
                          color: C.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(Text(item['supervisor'] ?? '')),

                    // ⚠️ API typo handled here
                    DataCell(Text(item['oparator'] ?? '')),

                    DataCell(Text(item['party'] ?? '')),
                    DataCell(Text(item['contno'] ?? '')),
                    DataCell(Text(item['workorder'] ?? '')),
                    DataCell(
                      Text(
                        (item['date'] ?? '').toString().split(' ').first,
                      ),
                    ),
                    DataCell(Text(item['time']?.trim() ?? '')),
                    DataCell(Text(item['recipetype'] ?? '')),
                    DataCell(Text(item['dnr'] ?? '')),
                    DataCell(Text(item['widthmm'] ?? '')),
                    DataCell(Text(item['gross'] ?? '')),
                    DataCell(Text(item['tare'] ?? '')),
                    DataCell(Text(item['net'] ?? '')),
                    DataCell(Text(item['pplotno'] ?? '')),
                    DataCell(Text(item['code'] ?? '')),

                    // ✅ Status with color
                    DataCell(
                      Text(
                        item['status'] ?? '',
                        style: TextStyle(
                          color: item['status'] == "Pending"
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    DataCell(Text(item['entrytype'] ?? '')),
                    DataCell(Text(item['statuS_ISSUE'] ?? '')),

                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          item['remark']?.trim() ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              )
            ),
          ),
        ],
      ),
    );
  }
}
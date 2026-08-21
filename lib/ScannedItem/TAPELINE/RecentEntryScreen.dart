import 'package:IMS/ScannedItem/TAPELINE/TapeInEnrtyList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../AdminDashBoard/DepartmentDashboard.dart';
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
  String? _error;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchRecentEntries();
  }

  @override
  void dispose() {
    searchController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> fetchRecentEntries() async {
    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      final data = await InStockService().getRecentSavedList();

      setState(() {
        allData = data;
        filteredData = _applySearch(data, searchController.text);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() {
        isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<dynamic> _applySearch(List<dynamic> source, String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((item) {
      return (item['party'] ?? '').toString().toLowerCase().contains(query) ||
          (item['recipetype'] ?? '').toString().toLowerCase().contains(query) ||
          (item['dnr'] ?? '').toString().toLowerCase().contains(query);
    }).toList();
  }

  void filterSearch(String value) {
    setState(() {
      filteredData = _applySearch(allData, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text("Recent Entries", style: TextStyle(color: C.bg)),
        backgroundColor: C.appBar1,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TapeInEnrtyList())),

          icon: const Icon(Icons.arrow_back, color: C.bg),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.white, height: 0.5),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search by Party, Recipe, DNR...",
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    searchController.clear();
                    filterSearch('');
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: C.primary, width: 1.4),
                ),
              ),
            ),
          ),

          // COUNT STRIP
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  '${filteredData.length} of ${allData.length} entries',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // 📊 TABLE
          Expanded(
            child: filteredData.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: fetchRecentEntries,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFEEEEEE), width: 0.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notif) => notif.depth == 1,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DataTable(
                            headingRowColor:
                            WidgetStateProperty.all(const Color(0xFFF7F8FA)),
                            headingTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF444441),
                            ),
                            dataTextStyle: const TextStyle(fontSize: 12.5),
                            dataRowColor:
                            WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                                ) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.blue.withOpacity(0.2);
                              }
                              return null;
                            }),
                            columnSpacing: 18,
                            dividerThickness: 0.6,
                            columns: const [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Supervisor")),
                              DataColumn(label: Text("Operator")),
                              DataColumn(label: Text("Party Name")),
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
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      item['id'].toString(),
                                      style: TextStyle(
                                        color: C.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(item['supervisor'] ?? '')),
                                  DataCell(Text(item['oparator'] ?? '')),
                                  DataCell(Text(item['party'] ?? '')),
                                  DataCell(
                                    Text(
                                      (item['date'] ?? '')
                                          .toString()
                                          .split(' ')
                                          .first,
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
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item['status'] == "Pending"
                                            ? Colors.orange.withOpacity(0.12)
                                            : Colors.green.withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['status'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: item['status'] == "Pending"
                                              ? Colors.orange.shade800
                                              : Colors.green.shade800,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // ListView so RefreshIndicator/pull-to-refresh still works when the
      // filtered list is empty
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Center(
          child: Text(
            allData.isEmpty ? "No entries yet" : "No matching entries",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            allData.isEmpty
                ? "Saved entries will show up here"
                : "Try a different search term",
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchRecentEntries,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
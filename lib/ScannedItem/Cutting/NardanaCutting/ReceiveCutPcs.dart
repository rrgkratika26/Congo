import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'modelclass/CuttingAprrovalModelNardana.dart';

class ReceiveCutPcsNardana extends StatefulWidget {
  const ReceiveCutPcsNardana({super.key});

  @override
  State<ReceiveCutPcsNardana> createState() => _ReceiveCutPcsNardanaState();
}

class _ReceiveCutPcsNardanaState extends State<ReceiveCutPcsNardana> {
  List<CuttingApprovalModelNardan> items = [];  // ✅ correct type

  bool isLoading = true;
  int currentPage = 0;
  int pageSize = 10;
  DateTime? fromDate;
  DateTime? toDate;

  String searchQuery = "";

  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// ───────────────── LOAD API ─────────────────

  Future<void> _loadData() async {
    try {
      final result = await InStockService.getCuttingApprovalList();

      setState(() {
        items = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  /// ───────────────── APPROVE API ─────────────────

  Future<void> _approveCutting() async {
    final selectedItems = items.where((e) => e.isSelected).toList();

    if (selectedItems.isEmpty) return;

    try {
      final success = await InStockService.approveCutting(selectedItems);

      if (success) {
        setState(() {
          items.removeWhere((e) => e.isSelected);
          selectAll = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cutting Approved Successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Approve Error: $e");
    }
  }

  /// ───────────────── FILTER ─────────────────

  List<CuttingApprovalModelNardan> get filteredItems {  // ✅ correct return type
    return items.where((item) {
      final searchMatch =
          searchQuery.isEmpty ||
              item.orderNo.toLowerCase().contains(searchQuery.toLowerCase());

      bool dateMatch = true;

      if (fromDate != null && toDate != null && item.date.isNotEmpty) {
        final itemDate = item.parsedDate;  // ✅ uses safe getter from model

        if (itemDate != null) {
          dateMatch =
              itemDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
                  itemDate.isBefore(toDate!.add(const Duration(days: 1)));
        }
      }

      return searchMatch && dateMatch;
    }).toList();
  }

  int get selectedCount => items.where((e) => e.isSelected).length;

  /// ───────────────── SELECT ALL ─────────────────

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      for (var item in items) {
        item.isSelected = selectAll;
      }
    });
  }

  /// ───────────────── DATE RANGE ─────────────────

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  /// ───────────────── APPROVE DIALOG ─────────────────

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: Row(
          children: [
            Icon(Icons.verified_outlined, color: C.primary),
            const SizedBox(width: 10),
            const Text(
              "Confirm Approval",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        content: Text(
          "Approve $selectedCount item(s)?",
          style: TextStyle(color: C.textHigh ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",style: TextStyle(color: C.textHigh),),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.primary),
            onPressed: () async {
              Navigator.pop(context);
              await _approveCutting();
            },
            child: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final list = filteredItems;

    return Scaffold(
      backgroundColor: C.pageBg,

      appBar: AppBar(
        backgroundColor: C.primary,

        title: const Text(
          "Approval",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: C.bg),

        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _pickDateRange,
          ),

          if (selectedCount > 0)
            TextButton(
              onPressed: _showApproveDialog,
              child: const Text(
                "APPROVE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          _searchField(),
          _selectAllBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? const Center(child: Text("No records found"))
                : Column(
              children: [
                Expanded(child: _table(paginatedList)),
                _paginationControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ───────────────── SEARCH ─────────────────
  List<CuttingApprovalModelNardan> get paginatedList {
    final start = currentPage * pageSize;
    final end = start + pageSize;

    return filteredItems.sublist(
      start,
      end > filteredItems.length ? filteredItems.length : end,
    );
  }
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        // onChanged: (v) => setState(() => searchQuery = v),
        onChanged: (v) {
          setState(() {
            searchQuery = v;
            currentPage = 0;
          });
        },
        decoration: InputDecoration(
          hintText: "Search order...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: C.cardBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  /// ───────────────── SELECT BAR ─────────────────

  Widget _selectAllBar() {
    return Container(
      color: C.brand50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Checkbox(value: selectAll, onChanged: _toggleSelectAll),
          const Text("Select All", style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text("${filteredItems.length} items"),
        ],
      ),
    );
  }

  /// ───────────────── TABLE ─────────────────

  Widget _table(List<CuttingApprovalModelNardan> list) {  // ✅ correct type
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          headingRowColor: WidgetStateProperty.all(C.brand100),

          columns: const [
            DataColumn(label: Text("Select")),
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Order")),
            DataColumn(label: Text("Component")),
            DataColumn(label: Text("NetWt")),
            DataColumn(label: Text("Wastage")),
            DataColumn(label: Text("PCS")),
            DataColumn(label: Text("Width")),
            DataColumn(label: Text("CutLength")),
            DataColumn(label: Text("PerPcWt")),
          ],

          rows: list.map((item) {
            return DataRow(
              selected: item.isSelected,
              cells: [
                DataCell(
                  Checkbox(
                    value: item.isSelected,
                    onChanged: (v) => setState(() => item.isSelected = v ?? false),
                  ),
                ),
                DataCell(
                  Text(
                    item.id.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: C.success, // or your C.primaryBlue
                    ),
                  ),
                ),
                DataCell(                                              // ✅ safe date format
                  Text(
                    item.parsedDate != null
                        ? DateFormat("dd-MMM-yyyy").format(item.parsedDate!)
                        : item.date,
                  ),
                ),
                DataCell(Text(item.orderNo)),
                DataCell(Text(item.component)),
                DataCell(Text(item.netWt.toString())),
                DataCell(Text(item.wastage.toString())),
                DataCell(Text(item.pcs.toString())),
                DataCell(Text(item.width.toString())),
                DataCell(Text(item.cutLength.toString())),
                DataCell(Text(item.perPcsWt.toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _paginationControls() {
    final totalPages = (filteredItems.length / pageSize).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: currentPage > 0
                ? () => setState(() => currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),

          Text(
            "Page ${currentPage + 1} of $totalPages",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          IconButton(
            onPressed: (currentPage + 1) < totalPages
                ? () => setState(() => currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),

          const Spacer(),

          DropdownButton<int>(
            value: pageSize,
            items: const [
              DropdownMenuItem(value: 10, child: Text("10")),
              DropdownMenuItem(value: 20, child: Text("20")),
              DropdownMenuItem(value: 50, child: Text("50")),
            ],
            onChanged: (val) {
              setState(() {
                pageSize = val!;
                currentPage = 0;
              });
            },
          ),
        ],
      ),
    );
  }
}
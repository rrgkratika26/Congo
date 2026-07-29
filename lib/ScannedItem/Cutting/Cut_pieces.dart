import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Color/Colorclass.dart';
import 'CutPcsModel.dart';

class ReceiveCutPcsScreen extends StatefulWidget {
  const ReceiveCutPcsScreen({super.key});

  @override
  State<ReceiveCutPcsScreen> createState() => _ReceiveCutPcsScreenState();
}

class _ReceiveCutPcsScreenState extends State<ReceiveCutPcsScreen> {
  List<CutPcsItem> items = [];
  bool isLoading = true;

  DateTime? fromDate;
  DateTime? toDate;

  String searchQuery = "";
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Data Loading ──────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final result = await JblApiService.fetchCuttingItems();
      setState(() {
        items = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _approveCutting() async {
    final selectedItems = items.where((e) => e.isSelected).toList();
    if (selectedItems.isEmpty) return;

    try {
      final success = await JblApiService.approveCuttingItems(selectedItems);

      if (success) {
        setState(() {
          items.removeWhere((e) => e.isSelected);
          selectAll = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cutting Approved Successfully")),
          );
        }
      } else {

        debugPrint("Approve Failed");
      }
    } catch (e) {
      debugPrint("Approve Error: $e");
    }
  }

  // ── Filtering ─────────────────────────────────────────────

  List<CutPcsItem> get filteredItems {
    return items.where((item) {
      final searchMatch =
          searchQuery.isEmpty ||
          item.orderNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.customerName.toLowerCase().contains(searchQuery.toLowerCase());

      bool dateMatch = true;
      if (fromDate != null && toDate != null) {
        final itemDate = DateFormat("dd-MM-yyyy").parse(item.date);
        dateMatch =
            itemDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(toDate!.add(const Duration(days: 1)));
      }

      return searchMatch && dateMatch;
    }).toList();
  }

  int get selectedCount => items.where((e) => e.isSelected).length;

  // ── Actions ───────────────────────────────────────────────

  void _toggleSelectAll(bool? val) {
    setState(() {
      selectAll = val ?? false;
      for (var i in items) {
        i.isSelected = selectAll;
      }
    });
  }

  void _pickDateRange() async {
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

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        title: Row(
          children: [
            Icon(Icons.verified_outlined, color: C.primary, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Confirm Approval",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to approve",
              style: TextStyle(color: C.textHigh, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: C.brand50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$selectedCount item(s)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: C.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: C.textHigh, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _approveCutting();
            },
            child: const Text(
              "Approve",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final list = filteredItems;

    return Scaffold(
      backgroundColor: C.pageBg,
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text(
          "Receive CutPcs",
          style: TextStyle(fontWeight: FontWeight.w600, color: C.bg),
        ),
        iconTheme: const IconThemeData(color: C.bg),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: C.bg),
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
                ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
                : list.isEmpty
                ? const Center(child: Text("No records found"))
                : _table(list),
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search order, customer...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: C.cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: C.borderLight),
          ),
        ),
      ),
    );
  }

  Widget _selectAllBar() {
    return Container(
      color: C.brand50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            activeColor: C.brand700,
            value: selectAll,
            onChanged: _toggleSelectAll,
          ),
          const Text(
            "Select All",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            "${filteredItems.length} items",
            style: TextStyle(color: C.textHigh),
          ),
        ],
      ),
    );
  }

  Widget _table(List<CutPcsItem> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18,
        headingRowColor: WidgetStateProperty.all(C.brand100),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.lightGreen.shade100;
          }
          return null;
        }),
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
                  activeColor: C.brand700,
                  value: item.isSelected,
                  onChanged: (v) =>
                      setState(() => item.isSelected = v ?? false),
                ),
              ),
              DataCell(Text(item.id.toString())),
              DataCell(Text(item.date)),
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
    );
  }
}

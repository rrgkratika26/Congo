import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Color/Colorclass.dart';
import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';

import 'CutPcsModel.dart';
import 'CuttinIN/Cutt_pieces_issueModel.dart';
import 'componentDropdownScreen.dart' hide CutPieceIssuedModel;

// ── Column definitions ─────────────────────────────────────────
const List<(String, double)> _kColumns = [
  ("ID", 80),
  ("Date", 120),
  ("Order No", 160),
  ("Component", 140),
  ("Net WT", 100),
  ("PCS", 90),
  ("Width", 90),
  ("Cut Length", 110),
  ("Per PCS WT", 110),
  ("Used PCS", 100),
  ("Used KG", 100),
  ("Remaining PCS", 120),
  ("Remaining KG", 120),
];

double get _kTableWidth => _kColumns.fold(0.0, (sum, col) => sum + col.$2);

const List<int> _kRowsPerPageOptions = [10, 25, 50, 100];

class CutPieceIssuedScreen extends StatefulWidget {
  const CutPieceIssuedScreen({super.key});

  @override
  State<CutPieceIssuedScreen> createState() => _CutPieceIssuedScreenState();
}

class _CutPieceIssuedScreenState extends State<CutPieceIssuedScreen> {
  List<CutPieceIssuedModel> data = [];
  bool loading = true;

  DateTime? fromDate;
  DateTime? toDate;

  int? selectedIndex;

  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final result = await JblApiService.fetchCutPieceIssuedList();
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List<CutPieceIssuedModel> get _filtered {
    if (fromDate == null || toDate == null) return data;
    return data.where((e) {
      final d = e.receiveDate;
      if (d == null) return false;

      final end = DateTime(
        toDate!.year,
        toDate!.month,
        toDate!.day,
        23,
        59,
        59,
      );

      return !d.isBefore(fromDate!) && !d.isAfter(end);
    }).toList();
  }

  List<CutPieceIssuedModel> get _pageItems {
    final all = _filtered;
    final start = (_currentPage - 1) * _rowsPerPage;

    if (start >= all.length) return [];

    final end = (start + _rowsPerPage).clamp(0, all.length);

    return all.sublist(start, end);
  }

  int get _totalPages =>
      (_filtered.length / _rowsPerPage).ceil().clamp(1, 999999);

  void _resetPage() => setState(() {
    _currentPage = 1;
    selectedIndex = null;
  });

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: (fromDate != null && toDate != null)
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      _resetPage();
    }
  }

  void clearDateFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
    });
    _resetPage();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filtered;
    final pageItems = _pageItems;
    final isFiltered = fromDate != null && toDate != null;

    final int start =
    filteredList.isEmpty ? 0 : (_currentPage - 1) * _rowsPerPage + 1;

    final int end = (start + _rowsPerPage - 1).clamp(0, filteredList.length);

    return Scaffold(
      backgroundColor: C.pageBg,
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text(
          "Issue Process Cut PCS",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isFiltered)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: clearDateFilter,
            ),
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: isFiltered ? Colors.white : Colors.white70,
            ),
            onPressed: pickDateRange,
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: C.brand600),
      )
          : Column(
        children: [
          if (isFiltered)
            Container(
              width: double.infinity,
              color: C.brand50,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: C.brand600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${DateFormat('dd MMM yyyy').format(fromDate!)}  →  "
                          "${DateFormat('dd MMM yyyy').format(toDate!)}",
                      style: const TextStyle(
                        color: C.brand700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    "${filteredList.length} records",
                    style: const TextStyle(
                      color: C.textMid,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _kTableWidth,
                child: Column(
                  children: [
                    const _TableHeader(columns: _kColumns),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                        itemCount: pageItems.length,
                        itemBuilder: (context, index) {
                          final item = pageItems[index];

                          return _TableRow(
                            item: item,
                            columns: _kColumns,
                            isSelected: selectedIndex == index,
                            onTap: () async {
                              setState(
                                      () => selectedIndex = index);

                              await IssueCutPCSPopup.show(
                                context,
                                item.receiveOrderNo ?? '',
                                item,
                              );

                              setState(() => selectedIndex = null);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          _PaginationBar(
            currentPage: _currentPage,
            totalPages: _totalPages,
            rowsPerPage: _rowsPerPage,
            rowsPerPageOptions: _kRowsPerPageOptions,
            rangeLabel: filteredList.isEmpty
                ? "No records"
                : "$start–$end of ${filteredList.length}",
            onPageChanged: (p) => setState(() {
              _currentPage = p;
              selectedIndex = null;
            }),
            onRowsPerPageChanged: (r) {
              setState(() => _rowsPerPage = r);
              _resetPage();
            },
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final String rangeLabel;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.rowsPerPage,
    required this.rowsPerPageOptions,
    required this.rangeLabel,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Rows per page:",
                style: TextStyle(fontSize: 12, color: C.textMid),
              ),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: rowsPerPage,
                items: rowsPerPageOptions
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text("$e"),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRowsPerPageChanged(v);
                },
              ),
              const Spacer(),
              Text(
                rangeLabel,
                style: const TextStyle(fontSize: 12, color: C.textMid),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Text(
                "Page $currentPage of $totalPages",
                style: const TextStyle(fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ── TABLE HEADER ─────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final List<(String, double)> columns;

  const _TableHeader({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.brand100,
      child: Row(
        children: columns.map((col) {
          return SizedBox(
            width: col.$2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: C.borderLight),
                  bottom: BorderSide(color: C.borderLight),
                ),
              ),
              child: Text(
                col.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: C.textHigh,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── TABLE ROW ─────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final CutPieceIssuedModel item;
  final List<(String, double)> columns;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableRow({
    required this.item,
    required this.columns,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cells = [
      item.id?.toString() ?? "—",
      item.receiveDate != null
          ? DateFormat("dd-MMM-yyyy").format(item.receiveDate!)
          : "—",
      item.receiveOrderNo ?? "—",
      item.component ?? "—",
      item.receivedNetWt?.toStringAsFixed(2) ?? "0",
      item.receivePcs?.toStringAsFixed(0) ?? "0",
      item.receivedWidth?.toStringAsFixed(2) ?? "0",
      item.receivedCutLength?.toStringAsFixed(2) ?? "0",
      item.perPcsWt?.toStringAsFixed(3) ?? "0",
      item.usedPcs?.toStringAsFixed(0) ?? "0",
      item.usedKg?.toStringAsFixed(2) ?? "0",
      item.remainingPcs?.toStringAsFixed(0) ?? "0",
      item.remainingKg?.toStringAsFixed(2) ?? "0",
    ];

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? C.brand200 : Colors.white,
        child: Row(
          children: List.generate(columns.length, (i) {
            return SizedBox(
              width: columns[i].$2,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: C.borderLight),
                    bottom: BorderSide(color: C.borderLight),
                  ),
                ),
                child: Text(
                  cells[i],
                  style: const TextStyle(
                    fontSize: 13,
                    color: C.textHigh,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── EMPTY STATE ─────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, size: 56, color: C.textLow),
          SizedBox(height: 12),
          Text(
            "No records found",
            style: TextStyle(color: C.textMid, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
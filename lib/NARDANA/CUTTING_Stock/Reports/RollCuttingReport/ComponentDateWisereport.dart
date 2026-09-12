import 'package:IMS/services/getSupervisors/RmdService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../Color/Colorclass.dart';

import 'ComponentDetailreport.dart';
import 'ModelComponentWise/ComponentdateWiseModel.dart';

class ComponentDatewiseReport extends StatefulWidget {
  final DateTime selectedDate;

  const ComponentDatewiseReport({super.key, required this.selectedDate});

  @override
  State<ComponentDatewiseReport> createState() =>
      _ComponentDatewiseReportState();
}

class _ComponentDatewiseReportState extends State<ComponentDatewiseReport> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const int pageSize = 10;

  int currentPage = 1;

  String _query = '';

  late DateTime _selectedDate;

  List<ComponentDatewiseModel> _allData = [];

  bool _isLoading = false;

  List<ComponentDatewiseModel> get _filtered {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return _allData;
    }

    return _allData.where((item) {
      return item.searchText.contains(query);
    }).toList();
  }

  int get totalPages {
    if (_filtered.isEmpty) {
      return 1;
    }

    return (_filtered.length / pageSize).ceil();
  }

  List<ComponentDatewiseModel> get _pagedData {
    if (_filtered.isEmpty) {
      return [];
    }

    final int start = (currentPage - 1) * pageSize;

    if (start >= _filtered.length) {
      return [];
    }

    final int end = (start + pageSize).clamp(0, _filtered.length);

    return _filtered.sublist(start, end);
  }

  int get _totalPcs {
    return _filtered.fold(0, (sum, item) => sum + item.pcs);
  }

  double get _totalWeight {
    return _filtered.fold(0.0, (sum, item) => sum + item.weight);
  }

  double get _totalWastage {
    return _filtered.fold(0.0, (sum, item) => sum + item.wastage);
  }

  double get _wastagePercentage {
    if (_totalWeight <= 0) {
      return 0.0;
    }

    return (_totalWastage / _totalWeight) * 100;
  }

  int get _totalRecords {
    return _filtered.length;
  }

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.selectedDate;

    debugPrint(
      'ComponentDatewiseReport received date: '
      '${DateFormat('yyyy/MM/dd').format(_selectedDate)}',
    );

    _load();
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      currentPage = 1;
    });

    try {
      final String apiDate = DateFormat('yyyy/MM/dd').format(_selectedDate);

      debugPrint('');
      debugPrint('====================================================');
      debugPrint('COMPONENT DATEWISE REPORT LOAD');
      debugPrint('SELECTED DATE: $apiDate');
      debugPrint('====================================================');

      final data = await RmdService().fetchComponentDatewise(
        date: _selectedDate,
      );

      debugPrint('COMPONENT RECORDS: ${data.length}');

      if (!mounted) {
        return;
      }

      setState(() {
        _allData = data;
      });
    } catch (e, stackTrace) {
      debugPrint('COMPONENT DATEWISE REPORT ERROR: $e');

      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Component Datewise data\n$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: C.primary)),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      currentPage = 1;
    });

    await _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        titleSpacing: 0,

        title: Row(
          children: [
            const Text(
              'Component Datewise Report',
              style: TextStyle(
                color: C.bg,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_totalRecords',
                style: const TextStyle(
                  color: C.bg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),

        leading: IconButton(
          onPressed: () {
            Get.back(result: true);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        iconTheme: const IconThemeData(color: C.bg),
      ),

      body: Column(
        children: [
          _searchBar(),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filtered.isEmpty)
            Expanded(child: _emptyView())
          else
            Expanded(child: _table(_pagedData)),

          _paginationBar(),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 55, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          Text(
            'No component data found\n'
            '${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: const Text(
              'Select Date',
              style: TextStyle(color: C.textHigh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
      color: C.bg,

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,

                  onChanged: (value) {
                    setState(() {
                      _query = value;
                      currentPage = 1;
                    });
                  },

                  style: const TextStyle(fontSize: 14, color: C.textHigh),

                  decoration: InputDecoration(
                    isDense: true,

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: C.border),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    hintText: 'Search component, PCS, weight, wastage...',

                    hintStyle: const TextStyle(color: C.brand700, fontSize: 13),

                    prefixIcon: const Icon(
                      Icons.search,
                      color: C.brand700,
                      size: 20,
                    ),

                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: C.textHigh,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _query = '';
                                currentPage = 1;
                                _searchCtrl.clear();
                              });
                            },
                          )
                        : null,

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              IconButton(
                tooltip: 'Select Date',
                onPressed: _pickDate,
                icon: const Icon(
                  Icons.calendar_today,
                  size: 21,
                  color: C.primaryDark,
                ),
              ),

              IconButton(
                tooltip: 'Refresh',
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 23, color: C.primaryDark),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Date: '
                '${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: C.brand700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          _summaryBar(),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY BAR
  // ============================================================

  Widget _summaryBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          _box('Total PCS', '$_totalPcs', Colors.brown, Icons.numbers),

          _box(
            'Total Weight',
            '${_totalWeight.toStringAsFixed(2)} Kg',
            C.success,
            Icons.scale,
          ),

          _box(
            'Total Wastage',
            '${_totalWastage.toStringAsFixed(2)} Kg',
            C.warning,
            Icons.delete_outline,
          ),
        ],
      ),
    );
  }

  Widget _box(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),

        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          border: Border.all(color: color.withOpacity(0.55)),
          borderRadius: BorderRadius.circular(9),
        ),

        child: Row(
          children: [
            Icon(icon, size: 19, color: color),

            const SizedBox(width: 6),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _head(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1565C0),
      ),
    );
  }

  Widget _cell(String text, {bool isBold = false, Color? color}) {
    return Text(
      text.isEmpty ? '-' : text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? Colors.black87,
      ),
    );
  }

  Widget _table(List<ComponentDatewiseModel> data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: Colors.grey.shade200),

          child: DataTable(
            columnSpacing: 20,

            horizontalMargin: 14,

            headingRowHeight: 42,

            dataRowMinHeight: 42,

            dataRowMaxHeight: 50,

            headingRowColor: WidgetStateProperty.all(
              const Color(0xFFEAF2FF),
            ),

            columns: [
              DataColumn(label: _head('Sr')),

              DataColumn(label: _head('Component')),

              DataColumn(label: _head('PCS')),

              DataColumn(label: _head('Weight (Kg)')),

              DataColumn(label: _head('Wastage (Kg)')),


            ],

            rows: List.generate(data.length, (index) {
              final r = data[index];

              final globalIndex =
                  ((currentPage - 1) * pageSize) + index + 1;

              return DataRow(
                color: WidgetStateProperty.all(
                  index.isEven ? Colors.white : const Color(0xFFF8FAFF),
                ),

                cells: [
                  DataCell(_cell('$globalIndex', isBold: true)),

                  DataCell(
                    InkWell(
                      onTap: () {
                        _openComponentDetailReport(r);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: _componentCell(r.component),
                    ),
                  ),

                  DataCell(_cell(r.pcs.toString(), isBold: true)),

                  DataCell(
                    _cell(
                      r.weight.toStringAsFixed(2),
                      isBold: true,
                      color: Colors.green.shade700,
                    ),
                  ),

                  DataCell(
                    _cell(
                      r.wastage.toStringAsFixed(2),
                      isBold: true,
                      color: Colors.orange.shade800,
                    ),
                  ),


                ],
              );
            }),
          ),
        ),
      ),
    );
  }


  Widget _componentCell(String component) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

      decoration: BoxDecoration(
        color: C.primary.withOpacity(0.08),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        component.isEmpty ? '-' : component,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: C.primaryDark,
        ),
      ),
    );
  }

  // ============================================================
  // WASTAGE CELL
  // ============================================================

  Widget _wastageCell(double percentage) {
    Color color;

    if (percentage <= 3) {
      color = Colors.green;
    } else if (percentage <= 5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(0.10),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withOpacity(0.35)),
      ),

      child: Text(
        '${percentage.toStringAsFixed(2)}%',

        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _paginationBar() {
    return Container(
      color: Colors.white,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      child: Row(
        children: [

          Expanded(
            child: Text(
              _filtered.isEmpty
                  ? '0 records'
                  : 'Showing '
                        '${((currentPage - 1) * pageSize) + 1}'
                        ' - '
                        '${((currentPage - 1) * pageSize) + _pagedData.length}'
                        ' of '
                        '${_filtered.length}',

              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            'Page $currentPage / $totalPages',

            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(width: 4),

          IconButton(
            tooltip: 'Previous',

            visualDensity: VisualDensity.compact,

            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                    });
                  }
                : null,

            icon: const Icon(Icons.chevron_left),
          ),

          // ====================================================
          // NEXT
          // ====================================================
          IconButton(
            tooltip: 'Next',

            visualDensity: VisualDensity.compact,

            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                    });
                  }
                : null,

            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _openComponentDetailReport(
      ComponentDatewiseModel component,
      ) {
    Get.to(
          () => ComponentDetailReport(
        component: component.component,
        selectedDate: _selectedDate,
      ),
    );
  }
}

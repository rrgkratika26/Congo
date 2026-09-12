import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../Color/Colorclass.dart';
import '../../../../services/getSupervisors/RmdService.dart';
import 'ModelComponentWise/ComponentDetailModel.dart';

class ComponentDetailReport extends StatefulWidget {
  final String component;
  final DateTime selectedDate;

  const ComponentDetailReport({
    super.key,
    required this.component,
    required this.selectedDate,
  });

  @override
  State<ComponentDetailReport> createState() => _ComponentDetailReportState();
}

class _ComponentDetailReportState extends State<ComponentDetailReport> {
  final RmdService _service = RmdService();

  late DateTime _selectedDate;
  late String _component;

  final TextEditingController _searchCtrl = TextEditingController();

  static const int pageSize = 10;

  List<ComponentDetailModel> _allData = [];
  String _query = '';
  int _currentPage = 1;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.selectedDate;
    _component = widget.component;

    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final data = await _service.fetchCuttingDetailDatewise(
        date: _selectedDate,
        component: _component,
      );

      if (!mounted) return;

      setState(() {
        _allData = data;
      });
    } catch (e) {
      debugPrint('ComponentDetailReport error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load component details\n$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ComponentDetailModel> get _filtered {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _allData;

    return _allData.where((item) {
      return item.searchText.contains(query);
    }).toList();
  }

  int get totalPages {
    if (_filtered.isEmpty) return 1;
    return (_filtered.length / pageSize).ceil();
  }

  List<ComponentDetailModel> get _pagedData {
    if (_filtered.isEmpty) return [];

    final start = (_currentPage - 1) * pageSize;
    if (start >= _filtered.length) return [];

    final end = (start + pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int get _totalPcs => _filtered.fold(0, (sum, item) => sum + item.pcs);

  double get _totalRollWeight =>
      _filtered.fold(0.0, (sum, item) => sum + item.rollWeight);

  double get _totalWeight =>
      _filtered.fold(0.0, (sum, item) => sum + item.weight);

  double get _totalWastage =>
      _filtered.fold(0.0, (sum, item) => sum + item.wastage);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: C.primary)),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: Text(
                _component.isEmpty ? 'Component Detail' : _component,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: C.bg,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
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
                '${_filtered.length}',
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
        iconTheme: const IconThemeData(color: C.bg),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
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

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
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
                      _currentPage = 1;
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
                    hintText: 'Search roll code, barcode, BOM...',
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
                                _currentPage = 1;
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
            ],
          ),
          _summaryBar(),
        ],
      ),
    );
  }

  Widget _summaryBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _box('PCS', '${_totalPcs}', C.primary, Icons.inventory_2_outlined),
          _box(
            'Roll Wt(Kg)',
            '${_totalRollWeight.toStringAsFixed(2)}',
            Colors.red,
            Icons.scale_outlined,
          ),
          _box(
            'Cut Wt(Kg)',
            '${_totalWeight.toStringAsFixed(2)}',
            C.success,
            Icons.monitor_weight_outlined,
          ),
          _box(
            'Wastage(Kg)',
            '${_totalWastage.toStringAsFixed(2)}',
            C.warning,
            Icons.delete_outline,
          ),
        ],
      ),
    );
  }

  Widget _box(String title, String value, Color color, IconData icon) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.55)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No component details found\nfor $_component on ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: const Text(
              'Change Date',
              style: TextStyle(color: C.textHigh),
            ),
          ),
        ],
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

  Widget _pillCell(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _table(List<ComponentDetailModel> data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
          child: DataTable(
            columnSpacing: 18,
            horizontalMargin: 12,
            headingRowHeight: 45,
            dataRowMinHeight: 38,
            dataRowMaxHeight: 40,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FF)),
            columns: [
              DataColumn(label: _head('Sr')),
              DataColumn(label: _head('Roll Code')),
              DataColumn(label: _head('Barcode')),
              DataColumn(label: _head('Roll Wt')),
              DataColumn(label: _head('BOM No')),
              DataColumn(label: _head('PCS')),
              DataColumn(label: _head('Weight (Kg)')),
              DataColumn(label: _head('Wastage (Kg)')),
            ],
            rows: List.generate(data.length, (index) {
              final item = data[index];
              final globalIndex = ((_currentPage - 1) * pageSize) + index + 1;

              return DataRow(
                color: WidgetStateProperty.all(
                  index.isEven ? Colors.white : const Color(0xFFF8FAFF),
                ),
                cells: [
                  DataCell(_cell('$globalIndex', isBold: true)),
                  DataCell(
                    _cell(item.rollCode, isBold: true, color: C.primaryDark),
                  ),
                  DataCell(_pillCell(item.barcode, Colors.blue.shade800)),
                  DataCell(
                    _cell(item.rollWeight.toStringAsFixed(2), isBold: true),
                  ),
                  DataCell(_pillCell(item.bomNo, C.primaryDark)),
                  DataCell(_cell('${item.pcs}', isBold: true)),
                  DataCell(
                    _cell(
                      item.weight.toStringAsFixed(2),
                      isBold: true,
                      color: Colors.green.shade700,
                    ),
                  ),
                  DataCell(
                    _cell(
                      item.wastage.toStringAsFixed(2),
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
                        '${((_currentPage - 1) * pageSize) + 1}'
                        ' - '
                        '${((_currentPage - 1) * pageSize) + _pagedData.length}'
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
            'Page $_currentPage / $totalPages',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Previous',
            visualDensity: VisualDensity.compact,
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next',
            visualDensity: VisualDensity.compact,
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

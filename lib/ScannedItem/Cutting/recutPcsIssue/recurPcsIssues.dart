import 'package:IMS/ScannedItem/Cutting/recutPcsIssue/recutModleClass.dart';
import 'package:flutter/material.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'RecutPcsPopup.dart';

class RecutPcsIssueScreen extends StatefulWidget {
  const RecutPcsIssueScreen({super.key});

  @override
  State<RecutPcsIssueScreen> createState() => _RecutPcsIssueScreenState();
}

class _RecutPcsIssueScreenState extends State<RecutPcsIssueScreen> {
  List<ReIssueCutPcsModel> _data = [];
  List<ReIssueCutPcsModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();
  int? rollEntryId;

  @override
  void initState() {
    super.initState();
    _fetchData();
    loadRollId();
  }

  Future<void> loadRollId() async {
    rollEntryId = await JblApiService.getNextRollEntryId();
    setState(() {});
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await JblApiService.getReIssueCutPcsList();
      setState(() {
        _data = list;
        _filtered = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _data.where((item) {
        return (item?.issueToWorkOrder?.toLowerCase().contains(q) ?? false) ||
            (item?.issueToComponent?.toLowerCase().contains(q) ?? false) ||
            (item?.iid?.toString().contains(q) ?? false);
      }).toList();
    });
  }

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: C.primary,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Recut PCS Issue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _fetchData,
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      AddRecutPcsPopup.show(context);
                    },
                    tooltip: 'Add',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────
          // ── Simple Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search WO Number...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── Record Count ──────────────────────────────────────────────
          if (!_isLoading && _error == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: C.border,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: C.brand300),
                    ),
                    child: Text(
                      '${_filtered.length} record${_filtered.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: C.textHigh,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: C.appBar3,),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade300,
                          size: 52,
                        ),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: C.textMid)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: C.brand600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 52, color: C.textLow),
                        const SizedBox(height: 10),
                        const Text(
                          'No records found',
                          style: TextStyle(color: C.textMid, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.borderLight),
          boxShadow: [
            BoxShadow(
              color: C.brand50,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(C.brand700),
            headingTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
            dataRowMinHeight: 48,
            dataRowMaxHeight: 56,
            columnSpacing: 22,
            horizontalMargin: 16,
            dividerThickness: 1,
            columns: const [
              DataColumn(label: Text('IID')),
              DataColumn(label: Text('WO Number')),
              DataColumn(label: Text('Component')),
              DataColumn(label: Text('Issue Date')),
              DataColumn(label: Text('NO OF PCS'), numeric: true),
              DataColumn(label: Text('KG'), numeric: true),
              DataColumn(label: Text('CUT WIDTH'), numeric: true),
              DataColumn(label: Text('CUT LENGTH'), numeric: true),
            ],
            rows: List.generate(_filtered.length, (index) {
              final item = _filtered[index];
              final isEven = index % 2 == 0;

              return DataRow(
                color: WidgetStateProperty.all(isEven ? C.cardBg : C.brand50),
                cells: [
                  // IID
                  DataCell(
                    Text(
                      item.iid?.toString() ?? '—',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.textHigh,
                      ),
                    ),
                  ),

                  // WO Number
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: C.brand100,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: C.brand300),
                      ),
                      child: Text(
                        item.issueToWorkOrder ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: C.brand800,
                        ),
                      ),
                    ),
                  ),

                  // Component
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: C.border),
                      ),
                      child: Text(
                        item.issueToComponent ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: C.primary,
                        ),
                      ),
                    ),
                  ),

                  // Issue Date
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: C.textMid,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(item.issueDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: C.textHigh,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NO OF PCS
                  DataCell(
                    Text(
                      item.noOfPcs?.toString() ?? '—',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: C.brand700,
                      ),
                    ),
                  ),

                  // KG
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.kg != null
                            ? '${item.kg!.toStringAsFixed(2)} kg'
                            : '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                  //CUT width
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.cutWidth != null
                            ? '${item.cutWidth!.toStringAsFixed(2)}'
                            : '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                  //cut length
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.cutLength != null
                            ? '${item.cutLength!.toStringAsFixed(2)} '
                            : '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
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
}

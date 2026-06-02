import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../../util/widget/dateFilterService.dart';
import '../../../util/widget/searchBar.dart';
import '../BagProduction/BadProductionModel.dart';
import '../modelClass/BagReportModelClass.dart';
import 'ReportDeailScreen.dart';

class BagReportScreen extends StatefulWidget {
  const BagReportScreen({Key? key}) : super(key: key);

  @override
  State<BagReportScreen> createState() => _BagReportScreenState();
}

class _BagReportScreenState extends State<BagReportScreen> {
  late Future<List<BagProductionReport>> reportFuture;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  bool _showDateFilter = false;
  final TextEditingController _searchController = TextEditingController();

  List<BagProductionReport> _allData = [];
  List<BagProductionReport> _visibleData = [];
  final int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF42A5F6)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });

      _loadReport(); // 🔥 API call
    }
  }

  void _loadReport() {
    setState(() {
      _allData.clear();
      _visibleData.clear();
      _currentPage = 1;

      reportFuture = InStockService().getBagProductionReport(
        fromDate: DateFormat('yyyy-MM-dd').format(_fromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_toDate),
      );
    });
  }
  // Future<void> _selectDate(BuildContext context, bool isFromDate) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: isFromDate ? _fromDate : _toDate,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(primary: Color(0xFF42A5F6)),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       if (isFromDate) {
  //         _fromDate = picked;
  //       } else {
  //         _toDate = picked;
  //       }
  //     });
  //     _loadReport();
  //   }
  // }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _visibleData = _allData.take(_pageSize * _currentPage).toList();
      });
      return;
    }

    final filtered = _allData.where((item) {
      final lowerQuery = query.toLowerCase();

      return item.articleNo.toLowerCase().contains(lowerQuery) ||
          item.poNum.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _visibleData = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text(
          'Bag Reports',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: C.bg,
          ),
        ),
        backgroundColor: C.appBar1,
        iconTheme: IconThemeData(color: C.bg),
        elevation: 0,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.calendar_month, color: C.bg),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter Section
          InlineSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),

          // Info Banner
          FutureBuilder<List<BagProductionReport>>(
            future: reportFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final count = snapshot.data!.length;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: const Color(0xFF42A5F6).withOpacity(0.2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.list_alt,
                        size: 20,
                        color: Color(0xFF42A5F6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Showing $count of $count entries',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Report List
          Expanded(
            child: FutureBuilder<List<BagProductionReport>>(
              future: reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: C.appBar3),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No entries found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;

                if (_allData.isEmpty) {
                  _allData = data;
                  _visibleData = data.take(_pageSize).toList();
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildReportTable(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF42A5F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF42A5F6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF42A5F6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable() {
    return DataTable(
      columnSpacing: 20,
      headingRowColor: MaterialStateProperty.all(C.primaryLight),
      columns: const [
        DataColumn(label: Text('SrNo')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Shift')),
        DataColumn(label: Text('Party')),
        DataColumn(label: Text('BOM')),
        DataColumn(label: Text('Article')),
        DataColumn(label: Text('PO')),
        DataColumn(label: Text('Print')),
        DataColumn(label: Text('Bag Type')),
        DataColumn(label: Text('Size')),
        DataColumn(label: Text('Weight')),
        DataColumn(label: Text('Line')),
        DataColumn(label: Text('Prod Qty')),
        DataColumn(label: Text('Bag Out')),
        DataColumn(label: Text('Req Bag')),
        DataColumn(label: Text('Contractor')),
        DataColumn(label: Text('Remark')),
      ],
      rows: _visibleData.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item.srno.toString())),
            DataCell(Text(DateFormat('dd-MM-yyyy').format(item.date))),
            DataCell(Text(item.shift)),
            DataCell(Text(item.partyName)),
            DataCell(Text(item.bomNo)),
            DataCell(Text(item.articleNo)),
            DataCell(Text(item.poNum)),
            DataCell(Text(item.printStatus)),
            DataCell(Text(item.bagType)),
            DataCell(Text(item.bagSize)),
            DataCell(Text(item.bagGwtGm.toString())),
            DataCell(Text(item.line)),
            DataCell(Text(item.productionQty.toString())),
            DataCell(Text(item.bagOut.toString())),
            DataCell(
              Text(
                item.requireD_BAG.toString(),
                style: TextStyle(
                  color: item.bagOut < 10 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text(item.contractor ?? "N/A")),
            DataCell(Text(item.remark ?? "N/A")),
          ],
          onSelectChanged: (value) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         BagReportDetailScreen(report: item),
            //   ),
            // );
          },
        );
      }).toList(),
    );
  }
}

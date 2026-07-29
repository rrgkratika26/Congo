import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import 'dispatch/DispatchModel.dart';

class DispatchReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const DispatchReportScreen({Key? key, this.startDate, this.endDate})
    : super(key: key);

  @override
  State<DispatchReportScreen> createState() => DispatchReportScreenState();
}

class DispatchReportScreenState extends State<DispatchReportScreen> {
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  List<DispatchBailRecord> _records = [];

  List<DispatchBailRecord> _filteredRecords = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filterStartDate = widget.startDate;
    _filterEndDate = widget.endDate;
    _loadRecords();
  }

  @override
  void didUpdateWidget(DispatchReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      setState(() {
        _filterStartDate = widget.startDate;
        _filterEndDate = widget.endDate;
      });
      _loadRecords();
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredRecords = _records;
    } else {
      _filteredRecords = _records.where((record) {
        final query = _searchQuery.toLowerCase();
        return record.partyName.toLowerCase().contains(query) ||
            record.srNo.toString().contains(query) ||
            record.barcode.toLowerCase().contains(query) ||
            record.workOrder.toLowerCase().contains(query) ||
            record.articleNo.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);

    final fromDate = _filterStartDate != null
        ? DateFormat('yyyy-MM-dd').format(_filterStartDate!)
        : DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 30)));

    final toDate = _filterEndDate != null
        ? DateFormat('yyyy-MM-dd').format(_filterEndDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await InStockService.fetchDispatchReport(
      fromDate: fromDate,
      toDate: toDate,
    );

    setState(() {
      _records = result;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applySearch();
    });
  }

  List<DispatchBailRecord> get filteredRecords {
    List<DispatchBailRecord> temp = _records;

    // Date filter
    if (_filterStartDate != null) {
      temp = temp
          .where((r) => !r.date.isBefore(_filterStartDate!))
          .toList();
    }

    if (_filterEndDate != null) {
      temp = temp
          .where((r) => !r.date.isAfter(_filterEndDate!))
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      temp = temp.where((r) {
        return r.partyName.toLowerCase().contains(query) ||
            r.srNo.toString().contains(query) ||
            r.barcode.toLowerCase().contains(query) ||
            r.workOrder.toLowerCase().contains(query) ||
            r.articleNo.toLowerCase().contains(query);
      }).toList();
    }

    return temp;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        color: const Color(0xFF2196F3),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: C.appBar3,),
              )
            : filteredRecords.isEmpty
            ? _buildEmptyState()
            : ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 1,
          ),
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildRecordsList(),
          ],
        ),

      ),
    );
  }

  Widget _buildRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            const Text(
              'Dispatch Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${filteredRecords.length} items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),

        Card(
          // elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 15,
              headingRowColor:
              MaterialStateProperty.all(C.brand200),

              columns: const [
                DataColumn(label: Text('SR No.')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('PARTY')),
                DataColumn(label: Text('BARCODE')),
                DataColumn(label: Text('WORK ORDER')),
                DataColumn(label: Text('ARTICLE')),
                // DataColumn(label: Text('TRANSPORT')),
                // DataColumn(label: Text('TRUCK')),
                // DataColumn(label: Text('DRIVER')),
                DataColumn(label: Text('SUPERVISOR')),
                DataColumn(label: Text('OPERATOR')),
                DataColumn(label: Text('SHIFT')),
                DataColumn(label: Text('BALE NO')),
                DataColumn(label: Text('BAG QTY')),
                DataColumn(label: Text('PALLET NWT')),
                DataColumn(label: Text('PALLET GWT')),
              ],

              rows: filteredRecords.map((r) {
                return DataRow(
                  cells: [
                    DataCell(Text(r.srNo.toString())),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(r.date))),
                    DataCell(Text(r.partyName)),
                    DataCell(Text(r.barcode)),
                    DataCell(Text(r.workOrder)),
                    DataCell(Text(r.articleNo)),
                    // DataCell(Text(r.transportName)),
                    // DataCell(Text(r.truckNo)),
                    // DataCell(Text(r.driverContact)),
                    DataCell(Text(r.supervisor)),
                    DataCell(Text(r.operator)),
                    DataCell(Text(r.shift)),
                    DataCell(Text(r.baleNo)),
                    DataCell(Text(r.bagQtyInPcs.toString())),
                    DataCell(Text(r.palletNwt.toString())),
                    DataCell(Text(r.palletGrossWt.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(DispatchBailRecord r) {
    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      color: Colors.white,

      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.partyName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            // row('SR No', r.srNo),
            row('Date', DateFormat('dd-MM-yyyy').format(r.date)),
            row('Barcode', r.barcode),
            row('Work Order', r.workOrder),
            row('Article No', r.articleNo),
            row('Transport', r.transportName),
            row('Truck No', r.truckNo),
            row('Driver Contact', r.driverContact),
            row('Dispatch Dept', r.dispatchDepartment),
            row('Dispatch Person', r.dispatchPerson),
            row('Supervisor', r.supervisor),
            row('Operator', r.operator),
            row('Remark', r.remark),
            row('Print Status', r.printStatus),
            row('Bag Type', r.bagType),
            row('Shift', r.shift),
            row('Bale No', r.baleNo),
            row('Bag Qty (PCS)', r.bagQtyInPcs.toString()),
            row('Bag Pallet NWT', '${r.palletNwt}'),
            row('Bale Pallet GWT', '${r.palletGrossWt}'),
            row('Bag Pallet WT GM', '${r.palletWtGm}'),
            row('Bag Size', r.bagSize),
            row('Pallet Size', r.palletSize),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInfo(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              '${value.toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No dispatch records found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStartDate != null || _filterEndDate != null
                  ? 'Try adjusting your date filter'
                  : 'Start by creating dispatch entries',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: "Search by Party, SR No, Barcode...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchQuery = '';
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

}

// Model class for dispatch records

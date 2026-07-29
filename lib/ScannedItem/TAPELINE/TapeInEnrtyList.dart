import 'package:IMS/ScannedItem/TAPELINE/modelClass/tapeListFIBC.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'TApeline_IN.dart';
import 'TapelineManual/BomFetchscreen.dart';

class TapeInEnrtyList extends StatefulWidget {
  const TapeInEnrtyList({super.key});

  @override
  State<TapeInEnrtyList> createState() => _TapeInEnrtyListState();
}

class _TapeInEnrtyListState extends State<TapeInEnrtyList> {
  late InStockService _service;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  List<TapeFIBCModel> _allEntries = [];
  List<TapeFIBCModel> _filteredEntries = [];

  bool _isLoading = true;
  String? _error;
  List<String> partyList = [];
  String? selectedParty;
  bool isPartyLoading = true;

  @override
  void initState() {
    super.initState();
    _service = InStockService();
    _loadPartyNames();
  }

  Future<void> _loadPartyNames() async {
    try {
      // final data = await _service.fetchPartyNames();
      final data = await _service.fetchPartyNames();

      print("Loaded Party Count = ${data.length}");

      setState(() {
        partyList = data;
        isPartyLoading = false;
      });
      // setState(() {
      //   partyList = data;
      //   isPartyLoading = false;
      //   if (partyList.isNotEmpty) selectedParty = partyList.first;
      // });

      if (selectedParty != null) _loadReports();
    } catch (e) {
      setState(() {
        isPartyLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadReports() async {
    if (selectedParty == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await _service.fetchFibc(selectedParty!);
      setState(() {
        _allEntries = data;
        _filteredEntries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;
    final horizontalPad = isMobile ? 12.0 : (isTablet ? 24.0 : 60.0);
    final labelFontSize = isMobile ? 12.5 : 13.5;
    final valueFontSize = isMobile ? 13.5 : 14.5;

    return Scaffold(
      backgroundColor: C.borderLight,
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: C.bg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tapeline",
          style: TextStyle(
            color: C.bg,
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManualTapeLineEntryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_note, color: Colors.white),
            label: const Text(
              "Manual entry",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
        iconTheme: const IconThemeData(color: C.bg),
      ),
      body: isPartyLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3))
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PARTY SEARCH
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 8),
            child: Autocomplete<String>(
              initialValue: TextEditingValue(text: selectedParty ?? ""),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return partyList.cast<String>();
                }
                return partyList.cast<String>().where(
                      (party) => party
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (String value) {
                setState(() => selectedParty = value);
                _loadReports();
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: isMobile ? 14 : 15),
                  decoration: InputDecoration(
                    hintText: "Search Party Name",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? width - horizontalPad * 2 : 350,
                        maxHeight: 250,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ENTRY COUNT STRIP
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12),
            color: const Color(0xFF42A5F6).withOpacity(0.12),
            child: Row(
              children: [
                const Icon(Icons.list_alt, size: 18, color: Color(0xFF42A5F5)),
                const SizedBox(width: 8),
                Text(
                  'Showing ${_filteredEntries.length} entries',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: C.appBar3))
                : _filteredEntries.isEmpty
                ? const Center(child: Text("No entries found"))
                : buildTable(labelFontSize, valueFontSize),
          ),
        ],
      ),
    );
  }

  // ── Single vertical table: columns on top, one row per entry ──
  Widget buildTable(double labelFontSize, double valueFontSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: labelFontSize,
            color: Colors.grey[800],
          ),
          dataTextStyle: TextStyle(
            fontSize: valueFontSize,
            color: Colors.black87,
          ),
          columnSpacing: 24,
          dividerThickness: 0.6,
          columns: const [
            DataColumn(label: Text("BOM No")),
            DataColumn(label: Text("Customer Name")),
            DataColumn(label: Text("PO No")),

            DataColumn(label: Text("Article No")),
            DataColumn(label: Text("Total MTR"), numeric: true),
            DataColumn(label: Text("Total KG"), numeric: true),
          ],
          rows: _filteredEntries.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TapeLineEntryScreen(
                            inquiryNo: item.inquiryNo,
                            customerName: item.customerName,
                            articleNo: item.articleNo,
                            bomNumber: item.bomNo,
                            extra13: item.extra13,
                            totalMtr: item.totalMtr,
                            totalKg: item.totalKg,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      item.bomNo,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        color: C.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(item.customerName)),
                DataCell(Text(item.articleNo)),

                DataCell(Text(item.extra13)),
                DataCell(Text(item.totalMtr.toStringAsFixed(2))),
                DataCell(Text(item.totalKg.toStringAsFixed(2))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
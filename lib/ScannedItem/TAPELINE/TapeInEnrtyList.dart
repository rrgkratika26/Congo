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

  List<TapeFIBCModel> _allEntries = [];
  List<TapeFIBCModel> _filteredEntries = [];

  bool _isLoading = false;
  String? _error;
  List<String> partyList = [];
  String? selectedParty;
  bool isPartyLoading = true;
  final TextEditingController _partyController = TextEditingController();
  final FocusNode _partyFocusNode = FocusNode();
  @override
  @override
  void initState() {
    super.initState();
    _service = InStockService();

    _loadPartyNames();
    _loadAllReports();
  }
  @override
  void dispose() {
    _partyController.dispose();
    _partyFocusNode.dispose();
    super.dispose();
  }
  Future<void> _loadPartyNames() async {
    try {
      final data = await _service.fetchPartyNames();

      setState(() {
        partyList = data;
        isPartyLoading = false;
      });

      // if (selectedParty != null) {
      //   _loadReports();
      // }
      // else: nothing to load yet, _isLoading is already false — no stuck spinner
    } catch (e) {
      setState(() {
        isPartyLoading = false;
        _isLoading = false; // FIX: make sure loading stops even on failure
        _error = e.toString();
      });
    }
  }

  Future<void> _loadReports() async {
    if (selectedParty == null) {
      await _loadAllReports();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.fetchFibc(selectedParty!);

      if (!mounted) return;

      setState(() {
        _allEntries = data;
        _filteredEntries = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openManualEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManualTapeLineEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;
    final horizontalPad = isMobile ? 12.0 : (isTablet ? 24.0 : 60.0);
    final labelFontSize = isMobile ? 15.0 : 13.5;
    final valueFontSize = isMobile ? 13.5 : 14.5;

    return Scaffold(
      backgroundColor: C.bg,
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
            fontSize: isMobile ? 21 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              // selectedParty == null
              //     ? 'Select a party to view entries'
              //     :
            'Total entries ${_filteredEntries.length}',
              style: TextStyle(
                fontSize: labelFontSize,
                color: C.bg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    16,
                    horizontalPad,
                    8,
                  ),
                  child:Autocomplete<String>(
                    initialValue: TextEditingValue(
                      text: selectedParty ?? "",
                    ),

                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return partyList;
                      }

                      return partyList.where(
                            (party) => party.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },

                    onSelected: (String value) {
                      setState(() {
                        selectedParty = value;
                        _partyController.text = value;
                      });

                      _partyFocusNode.unfocus();
                      _loadReports();
                    },

                    fieldViewBuilder: (
                        context,
                        controller,
                        focusNode,
                        onEditingComplete,
                        ) {
                      // Keep our controller/focus node connected to Autocomplete
                      _partyController.value = controller.value;

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,

                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                        ),

                        decoration: InputDecoration(
                          hintText: "Search Party Name",

                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.clear();

                              setState(() {
                                selectedParty = null;
                              });

                              focusNode.unfocus();

                              // Load all records again
                              _loadAllReports();
                            },
                          )
                              : const Icon(Icons.arrow_drop_down),

                          filled: true,
                          fillColor: Colors.white,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    },

                    optionsViewBuilder: (
                        context,
                        onSelected,
                        options,
                        ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isMobile
                                  ? width - horizontalPad * 2
                                  : 350,
                              maxHeight: 250,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);

                                return ListTile(
                                  title: Text(option),

                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    0,
                    horizontalPad,
                    14,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _openManualEntry,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border(
                            left: BorderSide(color: C.warning, width: 4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: C.headerBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit_note,
                                color: C.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Manual entry",
                                    style: TextStyle(
                                      fontSize: isMobile ? 14.5 : 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Add a tapeline entry without BOM lookup",
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 12.5,
                                      color: C.textHigh,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: C.warning,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: C.appBar3),
                  )
                      : _filteredEntries.isEmpty
                      ? const Center(
                    child: Text("No entries found"),
                  )
                      : buildTable(labelFontSize, valueFontSize),
                ),
              ],
            ),
    );
  }

  Widget buildTable(double labelFontSize, double valueFontSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(C.brand100),
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
            DataColumn(label: Text("Party Name")),
            DataColumn(label: Text("PO No")),
            DataColumn(label: Text("Article No")),
            DataColumn(label: Text("Total MTR"), numeric: true),
            DataColumn(label: Text("Total KG"), numeric: true),
          ],
          rows: _filteredEntries.map((item) {
            return DataRow(
              onSelectChanged: (_) {
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

              // Optional: gives the user visual feedback when selecting the row
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return C.brand100.withOpacity(0.4);
                }
                if (states.contains(WidgetState.pressed)) {
                  return C.brand100;
                }
                return null;
              }),

              cells: [
                DataCell(
                  Text(
                    item.bomNo,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      color: C.success,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
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
  Future<void> _loadAllReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // If your API supports empty party = all data
      final data = await _service.fetchFibc("");

      if (!mounted) return;

      setState(() {
        _allEntries = data;
        _filteredEntries = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}

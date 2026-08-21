import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/DashboardApiServices.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ReportmodelClass/SaveWebbingEntry.dart';
import 'ReportmodelClass/WebbingEntryModel.dart';
import 'WebSaveEntries.dart';


class WebbingEntryScreen extends StatefulWidget {
  const WebbingEntryScreen({Key? key}) : super(key: key);

  @override
  State<WebbingEntryScreen> createState() => _WebbingEntryScreenState();
}

class _WebbingEntryScreenState extends State<WebbingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> bomList = [];
  WebbingMasterDropdownModel? dropdownData;

  String? selectedBom;
  String? selectedMachine;
  String? selectedSid;
  String? selectedComponent;
  final List<String> componentList = ['LLOOP', 'FLOOP', 'TBAND', 'TAITP'];
  String? selectedOperator1;
  String? selectedOperator2;
  String? selectedSupervisor;
  int? lotIdFromApi;
  bool isGeneratingLotNo = false;
  final widthCtrl = TextEditingController();
  final gsmCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final mfLoopCtrl = TextEditingController();
  final extra13Ctrl = TextEditingController();
  final poCtrl = TextEditingController();
  final partyCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final qtyKgCtrl = TextEditingController();
  final articleCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();
  final lotNoCtrl = TextEditingController();
  final requiredKgCtrl = TextEditingController();
  final productionKgCtrl = TextEditingController();
  final balanceKgCtrl = TextEditingController();
  final sidCtrl = TextEditingController();
  String? fabricCode;
  String? batchNo;
  bool isSaving = false;
  String shift = 'A';
  bool _didInit = false;
  bool isLoadingDropdowns = false;




  bool isFormValid() {
    return partyCtrl.text.isNotEmpty &&
        dateCtrl.text.isNotEmpty &&
        shift.isNotEmpty;
  }

  bool isMobile(double w) => w < 700;

  @override
  void initState() {
    super.initState();
    loadUnit();
    productionKgCtrl.addListener(_calculateBalance);
  }

  @override
  void dispose() {
    partyCtrl.dispose();
    poCtrl.dispose();
    colorCtrl.dispose();
    dateCtrl.dispose();
    qtyKgCtrl.dispose();
    sidCtrl.dispose();
    articleCtrl.dispose();
    remarkCtrl.dispose();
    widthCtrl.dispose();
    gsmCtrl.dispose();
    mfLoopCtrl.dispose();
    extra13Ctrl.dispose();
    lotNoCtrl.dispose();
    requiredKgCtrl.dispose();
    productionKgCtrl.dispose();
    balanceKgCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      dateCtrl.text = DateTime.now().toString().split(' ')[0];
      _didInit = true;
      _fetchDropdownData();
    }
  }

  Future<void> _fetchDropdownData() async {
    setState(() => isLoadingDropdowns = true);
    try {
      final results = await Future.wait([
        DashboardService.fetchWebbingMasterDropdown(),
        DashboardService.fetchBomList(),
      ]);
      dropdownData = results[0] as WebbingMasterDropdownModel;
      bomList = results[1] as List<String>;
      setState(() {});
    } finally {
      setState(() => isLoadingDropdowns = false);
    }
  }
  String _buildLotNo(int id) {
    final machine = selectedMachine ?? "";
    final paddedMonth = DateTime.now().month.toString().padLeft(2, '0');
    final month = paddedMonth.startsWith('0')
        ? paddedMonth.substring(1)
        : paddedMonth;    final day = (DateTime.tryParse(dateCtrl.text) ?? DateTime.now())
        .day
        .toString()
        .padLeft(2, '0');

    // return "$shift$machine$month$day0-$id";
    return "$shift$machine$month${day}0-$id";
  }

  Future<void> _generateLotNo() async {
    if (selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Machine first")),
      );
      return;
    }

    setState(() => isGeneratingLotNo = true);
    try {
      final id = await DashboardService.fetchWebbingId();
      setState(() {
        lotIdFromApi = id;
        lotNoCtrl.text = _buildLotNo(id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not generate Lot No: $e")),
      );
    } finally {
      if (mounted) setState(() => isGeneratingLotNo = false);
    }
  }

  Future<void> _loadBomDetails(String bom) async {
    final details = await DashboardService.fetchBomDetails(bom);

    // Fetch production weight
    final productionWeight =
    await DashboardService.fetchProductionWeight(bom);

    setState(() {
      partyCtrl.text =
      details.customerNames.isNotEmpty ? details.customerNames.first : '';

      articleCtrl.text =
      details.articleNos.isNotEmpty ? details.articleNos.first : '';

      extra13Ctrl.text =
      details.extra13.isNotEmpty ? details.extra13.first : '';

      if (details.loopDetails.isNotEmpty) {
        final loop = details.loopDetails.first;

        poCtrl.text = extra13Ctrl.text;
        widthCtrl.text = loop.width;
        gsmCtrl.text = loop.grm;
        colorCtrl.text = loop.colorName;
        mfLoopCtrl.text = loop.mfLoop;

        // Required KG
        requiredKgCtrl.text = loop.extra35;
      }

      // Production KG from API
      productionKgCtrl.text = productionWeight.toString();

      _calculateBalance();
    });
  }

  void _calculateBalance() {
    final required = double.tryParse(requiredKgCtrl.text) ?? 0;
    final production = double.tryParse(productionKgCtrl.text) ?? 0;
    setState(() {
      balanceKgCtrl.text = (required - production).toStringAsFixed(2);
    });
  }
  Future<void> loadUnit() async {
    AppGlobals.unit = await AppSession.getUnit() ?? "";
    setState(() {});
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => dateCtrl.text = picked.toString().split(' ')[0]);
    }
  }

  String generateBatchNumber() {
    final article = articleCtrl.text.trim();
    final day = DateTime.now().day;
    final month = DateTime.now().month.toString().padLeft(2, '0');
    final articleCode =
    article.length >= 3 ? article.substring(0, 3).toUpperCase() : article.toUpperCase();
    return "$articleCode$day$month${shift}WB";
  }

  String generateFabricCode() {
    return [
      widthCtrl.text.trim().replaceAll(" ", ""),
      '${gsmCtrl.text.trim()}GRM',
      selectedComponent ?? "",
      colorCtrl.text.trim(),
      sidCtrl.text.trim(),
    ].join("/");
  }

  void _generateCodes() async {
    if (selectedMachine == null ||
        selectedComponent == null ||
        sidCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Machine, Component and SID")),
      );
      return;
    }
    setState(() {
      batchNo = generateBatchNumber();
      fabricCode = generateFabricCode();
    });

    await _generateLotNo(); // 👈 auto-generate Lot No too
  }

  Future<void> _saveEntry() async {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      // TODO: wire real API — see note below
      final request = WebbingSaveRequest(
        machineNo: selectedMachine ?? "",
        shift: shift,
        supervisor: selectedSupervisor ?? "",
        operator1: selectedOperator1 ?? "",
        operator2: selectedOperator2 ?? "",
        generateCode: fabricCode ?? "",
        beltWidth: widthCtrl.text.replaceAll("MM", "").trim(),
        beltColor: colorCtrl.text,
        idCode: sidCtrl.text.trim(),
        beltGrm: gsmCtrl.text,
        materialType: "",
        remark: remarkCtrl.text,
        partyName: partyCtrl.text,
        poNo: poCtrl.text,
        bomNo: selectedBom ?? "",
        beltType: mfLoopCtrl.text.toLowerCase(),
        newType: "NEW",
        articleNo: articleCtrl.text,
        batchNo: batchNo ?? "",
        plant: AppGlobals.unit ?? "",
        lotNo: lotNoCtrl.text,
        rollWeight: double.tryParse(qtyKgCtrl.text) ?? 0,
      );

      final result = await DashboardService.saveWebbingEntry(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      if (result.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WebSaveEntriesScreen()),
        );
      }
    else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Save failed. Try again.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingDropdowns) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: C.appBar3)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: C.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Webbing Entry',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            Text(dateCtrl.text,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = isMobile(constraints.maxWidth);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        title: 'Production Details',
                        color: C.primary,
                        children: [
                          _responsiveRow(
                            mobile,
                            _dropdown('Supervisor', selectedSupervisor ?? '',
                                dropdownData?.supervisors ?? [],
                                    (v) => setState(() => selectedSupervisor = v)),
                            _dropdown('Shift', shift, ['A', 'B'],
                                    (v) => setState(() => shift = v!)),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown('BOM No', selectedBom ?? '', bomList, (v) async {
                              if (v == null) return;
                              setState(() => selectedBom = v);
                              await _loadBomDetails(v);
                            }),
                            _textField('Purchase Order No', poCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _textField('Party Name', partyCtrl),
                            _textField('Article No', articleCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown('Operator 1', selectedOperator1 ?? '',
                                dropdownData?.operators ?? [],
                                    (v) => setState(() => selectedOperator1 = v)),
                            _dropdown('Operator 2', selectedOperator2 ?? '',
                                dropdownData?.operators ?? [],
                                    (v) => setState(() => selectedOperator2 = v)),
                          ),
                        ],
                      ),

                      _sectionCard(
                        title: 'Material Specs',
                        color: C.appBar3,
                        children: [
                          _responsiveRow(
                            mobile,
                            _dropdown('Machine', selectedMachine ?? '',
                                dropdownData?.machines ?? [],
                                    (v) => setState(() => selectedMachine = v)),
                            _textField('Belt type', mfLoopCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _textField('Belt Width', widthCtrl),
                            _textField('Belt GRM', gsmCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown('Loop Type', selectedComponent ?? '', componentList,
                                    (v) => setState(() => selectedComponent = v)),
                            _textField('Color', colorCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _numberField('Roll WT(Kg)', qtyKgCtrl),
                            _textField(
                              'ID Code',
                              sidCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      _sectionCard(
                        title: 'Quantity Details',
                        color: Colors.teal,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _textField('Lot No', lotNoCtrl, readOnly: true),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: isGeneratingLotNo ? null : _generateLotNo,
                                icon: isGeneratingLotNo
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : Icon(Icons.refresh, color: C.primary),
                                tooltip: "Generate Lot No",
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _quantitySummaryRow(),
                        ],
                      ),

                      _sectionCard(
                        title: 'Remark',
                        color: Colors.grey.shade600,
                        children: [
                          TextFormField(
                            controller: remarkCtrl,
                            maxLines: 3,
                            decoration: _decoration("Remark"),
                          ),
                        ],
                      ),

                      _sectionCard(
                        title: 'Generated Codes',
                        color: C.appBar1,
                        children: [

                            _metricTile('Batch Number', batchNo ?? '--', Colors.green.shade600),
                            _metricTile('Fabric Code', fabricCode ?? '--', C.primary),

                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: C.primary),
                              ),
                              onPressed: _generateCodes,
                              icon: Icon(Icons.qr_code, color: C.primary),
                              label: Text("Generate Code",
                                  style: TextStyle(color: C.primary, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: C.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isSaving ? null : _saveEntry,
                          icon: isSaving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            isSaving ? "Saving..." : "Save Entry",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------------
  /// UI Helpers
  /// ---------------------
  Widget _sectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _responsiveRow(bool mobile, Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

    Widget _textField(
        String label,
        TextEditingController ctrl, {
          bool readOnly = false,
          TextInputType keyboardType = TextInputType.text,
        }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: _decoration(label),
        ),
      );
    }
  Widget _numberField(String label, TextEditingController ctrl) => _textField(label, ctrl);

  Widget _dropdown(
      String label,
      String value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: items.contains(value) ? value : null,
      decoration: _decoration(label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e,style: TextStyle(color: C.primaryDark), overflow: TextOverflow.ellipsis),))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,labelStyle: TextStyle(color: C.textHigh),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: C.appBar3, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      isDense: true,
    );
  }

  Widget _quantitySummaryRow() {
    final required = double.tryParse(requiredKgCtrl.text) ?? 0;
    final production = double.tryParse(productionKgCtrl.text) ?? 0;
    final balance = required - production;
    final balanceColor = balance < 0 ? Colors.red.shade600 : Colors.green.shade600;

    return Row(
      children: [
        Expanded(child: _metricTile('Required KG', required.toStringAsFixed(2), C.primary)),
        const SizedBox(width: 8),
        Expanded(
          child: _textFieldMetric('Production KG', productionKgCtrl, C.appBar3),
        ),
        const SizedBox(width: 8),
        Expanded(child: _metricTile('Balance KG', balance.toStringAsFixed(2), balanceColor)),
      ],
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _textFieldMetric(String label, TextEditingController ctrl, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
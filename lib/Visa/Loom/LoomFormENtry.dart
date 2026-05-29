import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/visa_apis/visa_api.dart';
import 'PrintBarcode.dart';
import 'dropdownWidget.dart';
import 'modelClass/FIBCmodel.dart';
import 'modelClass/LoomMasterModel.dart';
import 'modelClass/LoomTypeModel.dart';

class VisaLoomForm extends StatefulWidget {
  final LoomProcessModel production;
  const VisaLoomForm({super.key, required this.production});

  @override
  State<VisaLoomForm> createState() => _VisaLoomFormState();
}

class _VisaLoomFormState extends State<VisaLoomForm> {
  // ─────────────── Theme ───────────────
  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Colors.black;
  static const _inputBg = Colors.white;
  static const _readOnlyBg = Color(0xFFF4F6FB);

  final _formKey = GlobalKey<FormState>();

  // ── State ──────────────────────────────────────────────────────
  String? _selectedShift;
  final List<String> _shiftOptions = ['A', 'B'];

  List<LoomTypeModel> loomTypes = [];
  bool isLoadingLoom = true;
  List<int> loomNumbers = [];
  int? selectedLoomNo;
  LoomTypeModel? selectedLoomType;
  LoomTypeModel? partyNameType;
  LoomTypeModel? selectedShiftType;

  bool isLoadingLoomNo = false;

  List<LoomMasterModel> operatorList = [];
  List<LoomMasterModel> supervisorList = [];
  String? operator1;
  String? operator2;
  String? selectedSupervisor;
  bool isLoadingOperator = true;
  bool isLoadingSupervisor = true;
  bool isLoading = false;

  // ── Controllers ────────────────────────────────────────────────
  late final TextEditingController _partyNameCtrl;
  late final TextEditingController _poNoCtrl;
  late final TextEditingController _articleNoCtrl;
  late final TextEditingController _bomCtrl;
  late final TextEditingController _reqFabricCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _fabricTypeCtrl;
  late final TextEditingController _reqQtyKgCtrl;
  late final TextEditingController _reqQtyMtrCtrl;
  late final TextEditingController _meshCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _specialIdCtrl;
  late final TextEditingController _fabricGsmCtrl;
  late final TextEditingController _fabricWidthCtrl;
  late final TextEditingController _fabricBaffleCtrl;
  late final TextEditingController _laminationCtrl;
  late final TextEditingController _grossWeightCtrl;
  late final TextEditingController _cutTypeCtrl;
  late final TextEditingController _tareWeightCtrl;
  late final TextEditingController _rollLengthCtrl;
  late final TextEditingController _avgWeightMtrCtrl;
  late final TextEditingController _netWeightCtrl;
  late final TextEditingController _avgWeightMtrGmCtrl;
  late final TextEditingController _batchNoCtrl;
  late final TextEditingController _loomStartCtrl;
  late final TextEditingController _loomEndCtrl;
  late final TextEditingController _remarkCtrl;
  late final TextEditingController _generateCodeCtrl;
  late final TextEditingController _balKgCtrl;
  late final TextEditingController _balMtrCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.production;
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}-${_monthName(now.month)}-${now.year}";
    final h = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
        ? 12
        : now.hour;
    final timeStr =
        "$h:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    _partyNameCtrl = TextEditingController(text: p.customerName);
    _poNoCtrl = TextEditingController(text: p.poNo);
    _articleNoCtrl = TextEditingController(text: p.articleNo);
    _bomCtrl = TextEditingController(text: p.orderNo);
    _reqFabricCtrl = TextEditingController(text: p.fabricCode);
    _dateCtrl = TextEditingController(text: dateStr);
    _timeCtrl = TextEditingController(text: timeStr);
    // _reqQtyKgCtrl = TextEditingController(text: p.requiredKg.toString());
    // _reqQtyMtrCtrl = TextEditingController(text: p.requiredMtr.toString());
    _fabricTypeCtrl = TextEditingController();
    _meshCtrl = TextEditingController();
    _colorCtrl = TextEditingController();
    _specialIdCtrl = TextEditingController();
    _fabricGsmCtrl = TextEditingController();
    _fabricWidthCtrl = TextEditingController();
    _fabricBaffleCtrl = TextEditingController();
    _laminationCtrl = TextEditingController();
    _grossWeightCtrl = TextEditingController();
    _cutTypeCtrl = TextEditingController();
    _tareWeightCtrl = TextEditingController();
    _rollLengthCtrl = TextEditingController(text: '0');
    _avgWeightMtrCtrl = TextEditingController();
    _netWeightCtrl = TextEditingController(text: '0');
    _avgWeightMtrGmCtrl = TextEditingController(text: '0');
    _batchNoCtrl = TextEditingController();
    _loomStartCtrl = TextEditingController();
    _loomEndCtrl = TextEditingController();
    _remarkCtrl = TextEditingController();
    _generateCodeCtrl = TextEditingController();
    _balKgCtrl = TextEditingController(text: p.balanceKg.toString());
    _balMtrCtrl = TextEditingController(text: p.balanceMtr.toString());
    _reqQtyKgCtrl = TextEditingController(text: widget.production.requiredKg.toString());
    _reqQtyMtrCtrl = TextEditingController(text: widget.production.requiredMtr.toString());

    _parseFabricCode(p.fabricCode);
    _grossWeightCtrl.addListener(_calculateValues);
    _tareWeightCtrl.addListener(_calculateValues);
    _rollLengthCtrl.addListener(_calculateValues);
    _fabricWidthCtrl.addListener(_calculateValues);

    _fabricWidthCtrl.addListener(_generateFabricCode);
    _fabricGsmCtrl.addListener(_generateFabricCode);
    _fabricBaffleCtrl.addListener(_generateFabricCode);
    loadLoomTypes();
    loadOperators();
    loadSupervisors();
  }

  String _monthName(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  @override
  void dispose() {
    for (final c in [
      _partyNameCtrl,
      _poNoCtrl,
      _articleNoCtrl,
      _bomCtrl,
      _reqFabricCtrl,
      _dateCtrl,
      _timeCtrl,
      _reqQtyKgCtrl,
      _reqQtyMtrCtrl,
      _fabricTypeCtrl,
      _meshCtrl,
      _colorCtrl,
      _specialIdCtrl,
      _fabricGsmCtrl,
      _fabricWidthCtrl,
      _fabricBaffleCtrl,
      _laminationCtrl,
      _grossWeightCtrl,
      _cutTypeCtrl,
      _tareWeightCtrl,
      _rollLengthCtrl,
      _avgWeightMtrCtrl,
      _netWeightCtrl,
      _avgWeightMtrGmCtrl,
      _batchNoCtrl,
      _loomStartCtrl,
      _loomEndCtrl,
      _remarkCtrl,
      _generateCodeCtrl,
      _balKgCtrl,
      _balMtrCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── API calls ──────────────────────────────────────────────────
  Future<void> loadLoomTypes() async {
    try {
      final data = await VisaApiService.getLoomTypes();
      setState(() {
        loomTypes = data;
        isLoadingLoom = false;
      });
    } catch (_) {
      setState(() => isLoadingLoom = false);
    }
  }

  Future<void> onLoomTypeSelected(LoomTypeModel type) async {
    setState(() {
      isLoadingLoomNo = true;
      loomNumbers = [];
      selectedLoomNo = null;
    });
    try {
      final data = await VisaApiService.getLoomNumbers(
        type: "TYPE",
        machine: type.value.toString(),
      );
      setState(() {
        loomNumbers = data.map((e) => int.parse(e.toString())).toList();
        isLoadingLoomNo = false;
      });
    } catch (_) {
      setState(() => isLoadingLoomNo = false);
    }
  }

  Future<void> loadReading() async {
    if (selectedLoomNo != null && selectedLoomType != null) {
      try {
        final data = await VisaApiService.getLoomReading(
          loom: selectedLoomNo!,
          loomType: selectedLoomType!.value,
        );
        setState(() => _loomStartCtrl.text = data['reading'].toString());
      } catch (_) {}
    }
  }

  void _parseFabricCode(String code) {
    final parts = code.split('-');
    if (parts.length >= 8) {
      _fabricWidthCtrl.text = parts[0];
      _fabricBaffleCtrl.text = parts[1];
      _fabricTypeCtrl.text = parts[2];
      _fabricGsmCtrl.text = parts[3];
      _laminationCtrl.text = parts[4];
      _colorCtrl.text = parts[5];
      _cutTypeCtrl.text = parts[6];
      _specialIdCtrl.text = parts[7];
    }
  }

  void _calculateValues() {
    final gross = double.tryParse(_grossWeightCtrl.text) ?? 0;
    final tare = double.tryParse(_tareWeightCtrl.text) ?? 0;
    final roll = double.tryParse(_rollLengthCtrl.text) ?? 0;
    final width = double.tryParse(_fabricWidthCtrl.text) ?? 0;
    final net = gross - tare;
    _netWeightCtrl.text = net.toStringAsFixed(2);
    final avgMtr = roll > 0 ? (net / roll) * 1000 : 0.0;
    _avgWeightMtrCtrl.text = avgMtr.toStringAsFixed(2);
    _avgWeightMtrGmCtrl.text = width > 0
        ? (avgMtr / (width / 100)).toStringAsFixed(2)
        : '0.00';
  }

  Future<void> loadOperators() async {
    try {
      final data = await VisaApiService.getLoomMaster("OP");
      setState(() {
        operatorList = data;
        isLoadingOperator = false;
      });
    } catch (_) {
      setState(() => isLoadingOperator = false);
    }
  }

  Future<void> loadSupervisors() async {
    try {
      final data = await VisaApiService.getLoomMaster("SP");
      setState(() {
        supervisorList = data;
        isLoadingSupervisor = false;
      });
    } catch (_) {
      setState(() => isLoadingSupervisor = false);
    }
  }

  void _clearForm() {
    for (final c in [
      _meshCtrl,
      _colorCtrl,
      _specialIdCtrl,
      _fabricGsmCtrl,
      _fabricWidthCtrl,
      _fabricBaffleCtrl,
      _laminationCtrl,
      _grossWeightCtrl,
      _cutTypeCtrl,
      _tareWeightCtrl,
      _rollLengthCtrl,
      _avgWeightMtrCtrl,
      _netWeightCtrl,
      _avgWeightMtrGmCtrl,
      _batchNoCtrl,
      _loomStartCtrl,
      _loomEndCtrl,
      _remarkCtrl,
      _generateCodeCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _selectedShift = null;
      selectedLoomType = null;
      selectedLoomNo = null;
      operator1 = null;
      operator2 = null;
      selectedSupervisor = null;
    });
  }

  Future<void> _saveForm() async {
    // ❌ Batch No check
    if (_batchNoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pehle Batch No generate karo"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ❌ Required fields check
    if (selectedLoomType == null ||
        selectedLoomNo == null ||
        _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Loom Type, Loom No aur Shift required hai"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = _buildSavePayload(); // 👈 IMPORTANT

      print("SAVE PAYLOAD: $data"); // DEBUG

      final message = await VisaApiService.saveLoomEntry(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  // DD-Mon-YYYY → yyyy-MM-dd convert karna ho toh
  String _convertDate(String d) {
    const months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12',
    };
    final parts = d.split('-'); // ['03', 'Apr', '2026']
    return "${parts[2]}-${months[parts[1]]}-${parts[0]}"; // 2026-04-03
  }

  // Use karo generateBatchNo call mein:

  void _generateFabricCode() async {
    // 1. Fabric code generate karo (pehle wala logic)
    final code =
        "${_fabricWidthCtrl.text}-${_fabricBaffleCtrl.text}-"
        "${_fabricTypeCtrl.text}-${_fabricGsmCtrl.text}-"
        "${_laminationCtrl.text}-${_colorCtrl.text}-"
        "${_cutTypeCtrl.text}-${_specialIdCtrl.text}";

    setState(() {
      _generateCodeCtrl.text = code;
      _reqFabricCtrl.text = code;
    });

    // 2. Validation - required fields check karo
    if (_partyNameCtrl.text.isEmpty ||
        _dateCtrl.text.isEmpty ||
        _laminationCtrl.text.isEmpty ||
        _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Party Name, Date, Lamination Type aur Shift fill karo",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3. Batch No API call karo
    setState(() => isLoading = true);

    try {
      final batchNo = await VisaApiService.generateBatchNo(
        partyName: _partyNameCtrl.text.trim(), // ✅ EXACT TEXT
        date: _dateCtrl.text.trim(), // ✅ NO CONVERSION
        loomType: selectedLoomType?.value.toString() ?? "", // ✅ CORRECT FIELD
        shift: _selectedShift ?? "", // ✅ SAFE VALUE
      );
      print({
        "partyName": _partyNameCtrl.text,
        "date": _dateCtrl.text,
        "loomType": selectedLoomType?.value.toString(),
        "shift": _selectedShift,
      });
      if (batchNo != null) {
        setState(() => _batchNoCtrl.text = batchNo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Batch No generated: $batchNo"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Batch No generate nahi hua"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final pad = isWide ? 20.0 : 14.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
              child: _buildBody(isWide),
            );
          },
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final d =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.production.customerName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(d, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────
  Widget _buildBody(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section: Job Info ──
        _sectionLabel("Job Info"),
        _card([
          _pair(
            isWide,
            _field("Party Name", _partyNameCtrl, readOnly: true),
            _field("Purchase Order No", _poNoCtrl, readOnly: true),
          ),
          _pair(
            isWide,
            _field("Article No", _articleNoCtrl, readOnly: true),
            _field("BOM", _bomCtrl, readOnly: true),
          ),
          _field("Required Fabric", _reqFabricCtrl, readOnly: true),
        ]),
        _gap,

        // ── Section: Scheduling ──
        _sectionLabel("Scheduling"),
        _card([
          _pair(
            isWide,
            _field("Date", _dateCtrl, readOnly: true),
            _field("Time", _timeCtrl, readOnly: true),
          ),
          _pair(
            isWide,
            _dropdown<LoomMasterModel>(
              label: "Supervisor",
              items: supervisorList,
              value: selectedSupervisor,
              isLoading: isLoadingSupervisor,
              itemLabel: (e) => e.name,
              itemValue: (e) => e.name,
              onChanged: (v) => setState(() => selectedSupervisor = v),
            ),
            _staticDropdown(
              label: "Shift",
              items: _shiftOptions,
              value: _selectedShift,
              onChanged: (v) => setState(() => _selectedShift = v),
            ),
          ),
        ]),
        _gap,

        // ── Section: Quantities ──
        _sectionLabel("Quantities"),
        _card([
          _pair(
            isWide,
            _field(
              "Required Qty (Kg)",
              TextEditingController(
                text: widget.production.balanceKg.toString(),
              ),
              readOnly: true,
              inputType: TextInputType.number,
            ),
            _field(
              "Required Qty (Mtr)",
              TextEditingController(
                text: widget.production.balanceMtr.toString(),
              ),
              readOnly: true,
              inputType: TextInputType.number,
            ),
          ),

          // _pair(isWide,
          //   _field("Balance Qty (Kg)", _balKgCtrl,
          //       inputType: TextInputType.number, highlight: true),
          //   _field("Balance Qty (Mtr)", _balMtrCtrl,
          //       inputType: TextInputType.number, highlight: true),
          // ),
        ]),
        _gap,

        // ── Section: Loom Setup ──
        _sectionLabel("Loom Setup"),
        _card([
          _pair(
            isWide,
            _dropdown<LoomTypeModel>(
              label: "Loom Type",
              items: loomTypes,
              value: selectedLoomType?.value.toString(),
              isLoading: isLoadingLoom,
              itemLabel: (e) => e.value.toString(),
              itemValue: (e) => e.value.toString(),
              onChanged: (v) {
                final sel = loomTypes.firstWhere(
                  (e) => e.value.toString() == v,
                );
                setState(() {
                  selectedLoomType = sel;
                });
                onLoomTypeSelected(sel);
                _loomStartCtrl.clear();
              },
            ),
            _loomNoDropdown(),
          ),
          _pair(
            isWide,
            _dropdown<LoomMasterModel>(
              label: "Operator 1",
              items: operatorList,
              value: operator1,
              isLoading: isLoadingOperator,
              itemLabel: (e) => e.name,
              itemValue: (e) => e.name,
              onChanged: (v) => setState(() => operator1 = v),
            ),
            _dropdown<LoomMasterModel>(
              label: "Operator 2",
              items: operatorList,
              value: operator2,
              isLoading: isLoadingOperator,
              itemLabel: (e) => e.name,
              itemValue: (e) => e.name,
              onChanged: (v) => setState(() => operator2 = v),
            ),
          ),
          _pair(
            isWide,
            _field("Loom Start Reading", _loomStartCtrl),
            _field("Loom End Reading", _loomEndCtrl),
          ),
        ]),
        _gap,

        // ── Section: Fabric Specs ──
        _sectionLabel("Fabric Specs"),
        _card([
          _pair(
            isWide,
            _field("Fabric Type / Use", _fabricTypeCtrl, readOnly: true),
            _field("Mesh", _meshCtrl, inputType: TextInputType.text),
          ),
          _pair(
            isWide,
            _field("Color", _colorCtrl, readOnly: true),
            _field("Special ID", _specialIdCtrl, readOnly: true),
          ),
          _pair(
            isWide,
            _field(
              "Fabric GSM",
              _fabricGsmCtrl,
              inputType: TextInputType.number,
            ),
            _field(
              "Fabric Width (cm)",
              _fabricWidthCtrl,
              inputType: TextInputType.number,
            ),
          ),
          _pair(
            isWide,
            _field("Baffle / Type", _fabricBaffleCtrl),
            _field("Lamination Type", _laminationCtrl, readOnly: true),
          ),
          _pair(
            isWide,
            _field("Cut Type", _cutTypeCtrl, readOnly: true),
            _field("Batch No", _batchNoCtrl),
          ),
        ]),
        _gap,

        // ── Section: Weight & Roll ──
        _sectionLabel("Weight & Roll"),
        _card([
          _pair(
            isWide,
            _field(
              "Gross Weight (Kg)",
              _grossWeightCtrl,
              inputType: TextInputType.number,
            ),
            _field(
              "Tare Weight (Kg)",
              _tareWeightCtrl,
              inputType: TextInputType.number,
            ),
          ),
          _pair(
            isWide,
            _field("Net Weight (Kg)", _netWeightCtrl, readOnly: true),
            _field(
              "Roll Length (Mtr)",
              _rollLengthCtrl,
              inputType: TextInputType.number,
            ),
          ),
          _pair(
            isWide,
            _field("Avg Weight (Mtr)", _avgWeightMtrCtrl, readOnly: true),
            _field("Avg Weight (Mtr/Gm)", _avgWeightMtrGmCtrl, readOnly: true),
          ),
        ]),
        _gap,

        // ── Section: Remarks ──
        _sectionLabel("Remarks & Code"),
        _card([
          _field("Remark", _remarkCtrl, maxLines: 2),
          const SizedBox(height: 4),
          _field("Generated Fabric Code", _generateCodeCtrl, readOnly: true),
          // ✅ ADD THIS
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateFabricCode,
              icon: const Icon(Icons.qr_code_2_rounded, size: 16),
              label: const Text("Generate Fabric Code"),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ]),
        _gap,

        // ── Action Buttons ──
        _buildActionBar(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Section Label ──────────────────────────────────────────────
  Widget _sectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _labelColor,
        letterSpacing: 1.2,
      ),
    ),
  );

  // ── Card wrapper ───────────────────────────────────────────────
  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.expand((w) => [w, const SizedBox(height: 10)]).toList()
        ..removeLast(),
    ),
  );

  static const _gap = SizedBox(height: 14);

  // ── Responsive pair ─────────────────────────────────────────────
  Widget _pair(bool isWide, Widget left, Widget right) => isWide
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 10), right],
        );

  // ── Labeled Text Field ─────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    bool highlight = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    final borderColor = highlight
        ? _primary
        : readOnly
        ? _border
        : const Color(0xFFBCC8E8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: inputType,
          style: TextStyle(
            fontSize: 13,
            color: readOnly ? const Color(0xFF8A97B5) : const Color(0xFF1A2340),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: readOnly ? _readOnlyBg : _inputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor,
                width: highlight ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? _border : _primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Loom No Dropdown ────────────────────────────────────────────
  Widget _loomNoDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        "Loom No.",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      ),
      const SizedBox(height: 4),
      isLoadingLoomNo
          ? _loadingBox()
          : _dropdownBox(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedLoomNo,
                  isExpanded: true,
                  isDense: true,
                  hint: const Text(
                    "Select",
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
                  ),
                  items: loomNumbers
                      .map(
                        (n) => DropdownMenuItem<int>(
                          value: n,
                          child: Text(
                            n.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => selectedLoomNo = v);
                    loadReading();
                  },
                ),
              ),
            ),
    ],
  );

  // ── Static Dropdown ─────────────────────────────────────────────
  Widget _staticDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      ),
      const SizedBox(height: 4),
      _dropdownBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            hint: const Text(
              "Select",
              style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
            ),
            items: items
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );

  // ── Generic Model Dropdown ──────────────────────────────────────
  Widget _dropdown<T>({
    required String label,
    required List<T> items,
    required String? value,
    required bool isLoading,
    required String Function(T) itemLabel,
    required String Function(T) itemValue,
    required ValueChanged<String?> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      ),
      const SizedBox(height: 4),
      isLoading
          ? _loadingBox()
          : _dropdownBox(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  isDense: true,
                  hint: const Text(
                    "Select",
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
                  ),
                  items: items
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: itemValue(e),
                          child: Text(
                            itemLabel(e),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
    ],
  );

  Widget _dropdownBox({required Widget child}) => Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: _inputBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFBCC8E8)),
    ),
    child: child,
  );

  Widget _loadingBox() => Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _readOnlyBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(color: C.appBar3,strokeWidth: 1.5),
        ),
        SizedBox(width: 8),
        Text("Loading...", style: TextStyle(fontSize: 12, color: _labelColor)),
      ],
    ),
  );

  // ── Action Bar ─────────────────────────────────────────────────
  Widget _buildActionBar() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      // _actionBtn("New", Icons.add_rounded, const Color(0xFF546E7A), () {}),
      _actionBtn(
        "Save",
        Icons.check_rounded,
        _primary,
        _saveForm,
        loading: isLoading,
      ),
      // _actionBtn("Update", Icons.edit_rounded, const Color(0xFF00897B), () {}),
      // _actionBtn(
      //   "Clear",
      //   Icons.refresh_rounded,
      //   const Color(0xFFF59E0B),
      //   _clearForm,
      // ),
      // _actionBtn(
      //   "Exit",
      //   Icons.logout_rounded,
      //   const Color(0xFFEF4444),
      //   () => Navigator.maybePop(context),
      // ),
    ],
  );

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool loading = false,
  }) => SizedBox(
    height: 40,
    child: ElevatedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: C.appBar3,
              ),
            )
          : Icon(icon, size: 15, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.6),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  Map<String, dynamic> _buildSavePayload() {
    return {
      "loomType": selectedLoomType?.value.toString(),
      "loomNo": selectedLoomNo?.toString(),
      "operator1": operator1 ?? "",
      "operator2": operator2 ?? "",
      "supervisor": selectedSupervisor ?? "",
      "si": "000",

      "fabricType": _fabricTypeCtrl.text,
      "fabricWidth": _fabricWidthCtrl.text,
      "color": _colorCtrl.text,
      "laminationType": _laminationCtrl.text,
      "gsm": _fabricGsmCtrl.text,
      "cutType": _cutTypeCtrl.text,
      "buffleType": _fabricBaffleCtrl.text,

      "bomNo": _bomCtrl.text,
      "poNo": _poNoCtrl.text,

      "grossWeight": _grossWeightCtrl.text,
      "avgWeight": _avgWeightMtrCtrl.text,

      "requiredFabric": _generateCodeCtrl.text,
      "wastage": "0",
      "productionType": "FIBC",

      "shift": _selectedShift,
      "partyName": _partyNameCtrl.text,
      "generateCode": _meshCtrl.text.isNotEmpty ? _meshCtrl.text : null,

      "netWeight": _netWeightCtrl.text,
      "rollLength": _rollLengthCtrl.text,
      "tareWeight": _tareWeightCtrl.text,

      "reqQtyKg": _reqQtyKgCtrl.text,
      "reqQtyMtr": _reqQtyMtrCtrl.text,

      "avgWeightCalc": _avgWeightMtrGmCtrl.text,

      "batchNo": _batchNoCtrl.text,

      "rollEntry": "LOOM",
      "plant": "FIBC",

      "reading": _loomStartCtrl.text,

      "articleNo": _articleNoCtrl.text,
      "capacity": "100",
      "barcode": "",
    };
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:IMS/ScannedItem/Cutting/NardanaCutting/modelclass/CuttingOutStockNardana.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../../services/visa_apis/visa_api.dart';
import '../cutOutModelClass/ModelClassOutstock.dart';

class CuttingOutStockFormNardana extends StatefulWidget {
  final CuttingOutstockNaradana production;

  const CuttingOutStockFormNardana({super.key, required this.production});

  @override
  State<CuttingOutStockFormNardana> createState() =>
      _CuttingOutStockFormNardanaState();
}

class _CuttingOutStockFormNardanaState
    extends State<CuttingOutStockFormNardana> {
  // ─────────────── Theme ───────────────
  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Colors.black;
  static const _inputBg = Colors.white;
  static const _readOnlyBg = Color(0xFFF4F6FB);
  Timer? _debounce;
  final _apiService = VisaApiService();
  final _inStockService = InStockService();
  final _formKey = GlobalKey<FormState>();
  List<String> _laminationList = [];
  List<String> _baffleList = [];
  String _woType = "WITH_WO"; // default
  String _rollFinish = "NO";
  String? _selectedLamination;
  String? _selectedBaffle;

  bool _isLoadingLamination = false;
  // ── Dropdown state ─────────────────────────────────────────────
  String? _selectedShift;
  final List<String> _shiftOptions = ['A', 'B'];

  List<String> _bomNumbers = [];
  String? _selectedBomNo;

  List<String> _componentList = [];
  String? _selectedComponent;

  List<String> _fabricWidthList = [];
  String? _selectedFabricWidth;

  List<String> _gsmList = [];
  String? _selectedGsm;

  List<_NameValue> _operatorList = [];
  List<_NameValue> _supervisorList = [];
  String? _operator2;
  String? _selectedSupervisor;

  // ── Loading flags ──────────────────────────────────────────────
  bool _isLoadingFabricWidth = false;
  bool _isLoadingGsm = false;
  bool _isLoadingBomComponents = false;
  bool _isLoadingOperator = false;
  bool _isLoadingSupervisor = false;
  bool _isLoading = false;

  // ── Controllers ────────────────────────────────────────────────
  final TextEditingController _partyNameCtrl = TextEditingController();
  final TextEditingController _poNoCtrl = TextEditingController();
  final TextEditingController _articleNoCtrl = TextEditingController();
  final TextEditingController _bomCtrl = TextEditingController();
  final TextEditingController _componentCtrl = TextEditingController();
  final TextEditingController _reqFabricCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final TextEditingController _reqQtyKgCtrl = TextEditingController();
  final TextEditingController _reqQtyMtrCtrl = TextEditingController();
  final TextEditingController _loomWastageCtrl = TextEditingController();
  final TextEditingController _laminationWastageCtrl = TextEditingController();
  final TextEditingController _machineStartCtrl = TextEditingController();
  final TextEditingController _machineEndCtrl = TextEditingController();
  final TextEditingController _cutLengthCtrl = TextEditingController();
  final TextEditingController _baffleCtrl = TextEditingController();
  final TextEditingController _operatorCtrl = TextEditingController();
  // late TextEditingController _grossWeightCtrl;
  final TextEditingController _fabricTypeCtrl = TextEditingController();
  final TextEditingController _colorCtrl = TextEditingController();
  final TextEditingController _specialIdCtrl = TextEditingController();
  final TextEditingController _fabricGsmCtrl = TextEditingController();
  final TextEditingController _fabricWidthCtrl = TextEditingController();
  final TextEditingController _fabricBaffleCtrl = TextEditingController();
  final TextEditingController _laminationCtrl = TextEditingController();
  final TextEditingController _cutTypeCtrl = TextEditingController();
  final TextEditingController _batchNoCtrl = TextEditingController();

  final TextEditingController _grossWeightCtrl = TextEditingController();
  final TextEditingController _tareWeightCtrl = TextEditingController();
  final TextEditingController _rollWeightCtrl = TextEditingController();
  final TextEditingController _rollLengthCtrl = TextEditingController();
  final TextEditingController _avgWeightMtrCtrl = TextEditingController();

  // Weight & Output — separate controllers (no reuse)
  final TextEditingController _cutWidthCtrl = TextEditingController();
  final TextEditingController _cutLengthCmCtrl = TextEditingController();
  final TextEditingController _cutSizeQtyCtrl = TextEditingController();
  final TextEditingController _netWtCtrl = TextEditingController();
  final TextEditingController _wastageCtrl = TextEditingController();
  final TextEditingController _tillRemCtrl = TextEditingController();
  final TextEditingController _useCtrl = TextEditingController();
  final TextEditingController _finalRemCtrl = TextEditingController();

  final TextEditingController _remarkCtrl = TextEditingController();
  final TextEditingController _generateCodeCtrl = TextEditingController();

  final now = DateTime.now();

  // Format date → YYYY-MM-DD
  late final currentDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  // Format time → HH:mm:ss
  late final currentTime =
      "${now.hour.toString().padLeft(2, '0')}:"
      "${now.minute.toString().padLeft(2, '0')}:"
      "${now.second.toString().padLeft(2, '0')}";
  @override
  void initState() {
    super.initState();

    final p = widget.production;


    _rollWeightCtrl.addListener(_onRollWeightChanged);
    // ─── BASIC INFO ───
    _partyNameCtrl.text = p.partyname ?? "";
    _poNoCtrl.text = p.workOrderNo ?? "";
    _articleNoCtrl.text = p.workOrderNo ?? "";

    _bomCtrl.text = "";
    _componentCtrl.text = p.component ?? "";

    _selectedGsm = p.fabricGsm;
    _selectedFabricWidth = p.fabricWidth;
    // _dateCtrl = TextEditingController(
    //     text: formatDate(p.date) // ✅ API date use karo
    // );
    //
    // _timeCtrl = TextEditingController(
    //     text: p.time ?? ""
    // );
    _dateCtrl.text = currentDate;
    _timeCtrl.text = currentTime;

    _reqQtyKgCtrl.text = p.requiredQtyKg.toString();

    _reqQtyMtrCtrl.text = p.requiredQtyMtr.toString();

    // ─── FABRIC ───
    _fabricTypeCtrl.text = p.fabricType ?? "";

    _colorCtrl.text = p.color ?? "";

    _fabricGsmCtrl.text = p.fabricGsm ?? "";

    _fabricWidthCtrl.text = p.fabricWidth ?? "";

    _fabricBaffleCtrl.text = p.cutType ?? "";
    _baffleCtrl.text = " ";

    _laminationCtrl.text = p.laminationType ?? "";

    _cutTypeCtrl.text = p.specialIdentification ?? "";

    _bomCtrl.text = "";

    // ─── FABRIC CODE ───
    _generateCodeCtrl.text = p.fabricCode ?? "";

    _reqFabricCtrl.text = p.fabricCode ?? "";

    // ─── MACHINE ───
    _machineStartCtrl.text = "";
    _machineEndCtrl.text = "";
    _cutLengthCtrl.text = "";

    // ─── WEIGHT ───
    _grossWeightCtrl.text = p.orderType ?? "";
    _tareWeightCtrl.text = p.weekNo ?? "";
    _rollWeightCtrl.text = p.rollWeight.toString();
    _rollLengthCtrl.text = p.rollLength.toString();
    _avgWeightMtrCtrl.text = "";
    // ─── CUT SIZE ───
    _cutWidthCtrl.text = "";
    _cutLengthCmCtrl.text = "";
    _cutSizeQtyCtrl.text = "";

    _netWtCtrl.text = "";
    _wastageCtrl.text = "";
    _tillRemCtrl.addListener(_calculateUseAndFinalRem);
    _useCtrl.text = "";
    _finalRemCtrl.text = "";

    _remarkCtrl.text = "";

    // ─── DEFAULT DROPDOWN VALUES ───
    _operator2 = p.operatorName ?? "";
    _selectedSupervisor = p.supervisorName ?? "";

    // ─── LISTENERS ───
    _machineEndCtrl.addListener(_calculateCutLength);
    // _netWtCtrl.addListener(_calculateUseAndFinalRem);
    // _netWtCtrl.addListener(_calculateUseAndFinalRem);
    _wastageCtrl.addListener(_calculateUseAndFinalRem);
    _grossWeightCtrl.addListener(_calculateRollWeight);
    _tareWeightCtrl.addListener(_calculateRollWeight);
    _rollLengthCtrl.addListener(_calculateAvgWeight);
    _rollWeightCtrl.addListener(_calculateAvgWeight);

    _cutWidthCtrl.addListener(_calculateNetWeight);
    _cutLengthCmCtrl.addListener(_calculateNetWeight);
    _cutSizeQtyCtrl.addListener(_calculateNetWeight);
    _fabricGsmCtrl.addListener(_calculateNetWeight);
    // ─── API CALLS ───
    _initialLoad();
  }

  @override
  void dispose() {
    for (final c in [
      _partyNameCtrl,
      _poNoCtrl,
      _articleNoCtrl,
      _bomCtrl,
      _componentCtrl,
      _reqFabricCtrl,
      _dateCtrl,
      _timeCtrl,
      _reqQtyKgCtrl,
      _reqQtyMtrCtrl,
      _machineStartCtrl,
      _machineEndCtrl,
      _cutLengthCtrl,
      _baffleCtrl,
      _fabricTypeCtrl,
      _colorCtrl,
      _specialIdCtrl,
      _fabricGsmCtrl,
      _fabricWidthCtrl,
      _fabricBaffleCtrl,
      _laminationCtrl,
      _cutTypeCtrl,
      _batchNoCtrl,
      _grossWeightCtrl,
      _tareWeightCtrl,
      _rollWeightCtrl,
      _rollLengthCtrl,
      _avgWeightMtrCtrl,
      _cutWidthCtrl,
      _cutLengthCmCtrl,
      _cutSizeQtyCtrl,
      _netWtCtrl,
      _wastageCtrl,
      _tillRemCtrl,
      _useCtrl,
      _finalRemCtrl,
      _remarkCtrl,
      _generateCodeCtrl,
      _loomWastageCtrl,
      _laminationWastageCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────
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

  // ── Calculations ───────────────────────────────────────────────
  void _calculateCutLength() {
    final start = double.tryParse(_machineStartCtrl.text) ?? 0;
    final end = double.tryParse(_machineEndCtrl.text) ?? 0;
    _cutLengthCtrl.text = (end - start)
        .clamp(0, double.infinity)
        .toStringAsFixed(2);
  }
  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);

    await _loadOperators();
    await _loadSupervisors();
    await _loadLaminationAndBaffle();

    // Important data next
    await _fetchArticleNo(); // includes BOM + cutsize

    // Less important last
    await _loadGsm();
    await _loadFabricWidth();

    setState(() => _isLoading = false);
  }

  void _calculateUseAndFinalRem() {
    final net = double.tryParse(_netWtCtrl.text) ?? 0;
    final wastage = double.tryParse(_wastageCtrl.text) ?? 0;
    final tillRem = double.tryParse(_tillRemCtrl.text) ?? 0;

    final use = net + wastage;

    _useCtrl.text = use.toStringAsFixed(2);

    double finalRem = tillRem - use;

    if (finalRem < 0) {
      finalRem = 0;
    }

    _finalRemCtrl.text = finalRem.toStringAsFixed(2);
  }

  // ── API Calls ──────────────────────────────────────────────────
  Future<void> _loadFabricWidth() async {
    setState(() => _isLoadingFabricWidth = true);
    final data = await VisaApiService.getGsmOrFabricWidth(type: "FW");

    debugPrint("FabricWidth API response: $data"); // ← Ye add karo
    debugPrint("FabricWidth list length: ${data.length}");

    setState(() {
      _fabricWidthList = data;

      if (data.contains(_selectedFabricWidth)) {
        // ✅ keep previous value
      } else {
        _selectedFabricWidth = data.isNotEmpty ? data.first : null;
      }

      _fabricWidthCtrl.text = _selectedFabricWidth ?? '';
      _isLoadingFabricWidth = false;
    });
  }

  Future<void> _loadLaminationAndBaffle() async {
    setState(() => _isLoadingLamination = true);

    final data = await NaradanaApiService.getLaminationAndBaffle();

    setState(() {
      _laminationList = data["laminations"]!;
      _baffleList = data["buffles"]!;

      // ✅ AUTO SELECT FIRST VALUE
      if (_laminationList.isNotEmpty) {
        _selectedLamination = _laminationList.first;
        _laminationCtrl.text = _selectedLamination!;
      }

      if (_baffleList.isNotEmpty) {
        _selectedBaffle = _baffleList.first;
        _baffleCtrl.text = _selectedBaffle!;
      }

      _isLoadingLamination = false;
    });
  }

  Future<void> _loadGsm() async {
    setState(() => _isLoadingGsm = true);
    final data = await VisaApiService.getGsmOrFabricWidth(type: "GSM");
    setState(() {
      _gsmList = data;

      if (data.contains(_selectedGsm)) {
        // ✅ keep previous value
      } else {
        _selectedGsm = data.isNotEmpty ? data.first : null;
      }

      _fabricGsmCtrl.text = _selectedGsm ?? '';
      _isLoadingGsm = false;
    });
  }

  Future<void> _loadOperators() async {
    setState(() => _isLoadingOperator = true);
    try {
      final data = await _inStockService.getCuttingOperators();
      setState(() {
        _operatorList = data.map((e) => _NameValue(e, e)).toList();
        _isLoadingOperator = false;
      });
    } catch (_) {
      setState(() => _isLoadingOperator = false);
    }
  }

  Future<void> _loadSupervisors() async {
    setState(() => _isLoadingSupervisor = true);
    try {
      final data = await _inStockService.getCuttingSupervisors();
      setState(() {
        _supervisorList = data.map((e) => _NameValue(e, e)).toList();
        _isLoadingSupervisor = false;
      });
    } catch (_) {
      setState(() => _isLoadingSupervisor = false);
    }
  }

  Future<void> _fetchArticleNo() async {
    try {
      final id = widget.production.id;

      final result = await NaradanaApiService.getArticleNo(id);

      if (result != null) {
        setState(() {
          _articleNoCtrl.text = result['articleNo'] ?? '';
          _operator2 = result['loomOperator2']; // ✅ operator 2 set
        });

        // ✅ After article → fetch BOM + Components
        await _loadBomAndComponents();
      }
    } catch (e) {
      _showSnack("Article fetch failed: $e", Colors.red);
    }
  }

  Future<void> _loadBomAndComponents() async {
    setState(() => _isLoadingBomComponents = true);

    try {
      final data = await NaradanaApiService.getBomAndComponents(
        po: widget.production.workOrderNo,
        article: _articleNoCtrl.text.trim(),
      );

      if (data != null) {
        final boms = List<String>.from(data['bomNumbers'] ?? []);
        final comps = List<String>.from(data['components'] ?? []);

        setState(() {
          _bomNumbers = boms;
          _componentList = comps;

          if (boms.isNotEmpty) {
            _selectedBomNo = boms.first;
            _bomCtrl.text = boms.first;
          }

          if (comps.isNotEmpty) {
            _selectedComponent = comps.first;
            _componentCtrl.text = comps.first;
          }

          _isLoadingBomComponents = false;
        });

        // ✅ optional
        await _fetchCutSize();
      }
    } catch (e) {
      setState(() => _isLoadingBomComponents = false);
      _showSnack("BOM fetch failed: $e", Colors.red);
    }
  }

  void _calculateNetWeight() {
    final width = double.tryParse(_cutLengthCmCtrl.text) ?? 0;
    final length = double.tryParse(_cutWidthCtrl.text) ?? 0;
    final gsm = double.tryParse(_fabricGsmCtrl.text) ?? 0;
    final qty = double.tryParse(_cutSizeQtyCtrl.text) ?? 0;

    // ✅ Check Baffle Type
    final isDouble =
        _fabricBaffleCtrl.text == "CRF" || _fabricBaffleCtrl.text == "C00";

    double netWt;

    if (isDouble) {
      netWt = (width * 2 * length * gsm * qty) / 10000000;
    } else {
      netWt = (width * length * gsm * qty) / 10000000;
    }

    _netWtCtrl.text = netWt.toStringAsFixed(2);
  }
  // Future<void> _fetchArticleAndThenBom() async {
  //   final sidInt = int.tryParse(widget.production.id);
  // final id = widget.production.id;
  //   if (sidInt == null) {
  //     await _loadBomAndComponents(articleOverride: widget.production.modelno);
  //     return;
  //   }
  //   try {
  //     final result = await _apiService.getArticleNo(sidInt);
  //     // setState(() => _articleNoCtrl.text = result ?? widget.production.modelno);
  //     // await _loadBomAndComponents(
  //       // articleOverride: result ?? widget.production.modelno,
  //     // );
  //   } catch (e) {
  //     // setState(() => _articleNoCtrl.text = widget.production.modelno);
  //     _showSnack("Failed to fetch Article No: $e", Colors.red);
  //     // await _loadBomAndComponents(articleOverride: widget.production.sid);
  //   }
  // }

  // Future<void> _loadBomAndComponents({String? articleOverride}) async {
  //   setState(() => _isLoadingBomComponents = true);
  //   try {
  //     final data = await NaradanaApiService.getBomAndComponents(
  //       po: widget.production.workOrderNo,
  //       article: articleOverride ?? _articleNoCtrl.text.trim(),
  //     );
  //     final boms = List<String>.from(data['bomNumbers'] ?? []);
  //     final comps = List<String>.from(data['components'] ?? []);
  //     setState(() {
  //       _bomNumbers = boms;
  //       _componentList = comps;
  //       if (boms.isNotEmpty) {
  //         _selectedBomNo = boms.first;
  //         _bomCtrl.text = boms.first;
  //       }
  //       if (comps.isNotEmpty) {
  //         _selectedComponent = comps.first;
  //         _componentCtrl.text = comps.first;
  //       }
  //       _isLoadingBomComponents = false;
  //     });
  //     // Auto-fetch cut size once both BOM & Component are ready
  //     await _fetchCutSize();
  //   } catch (e) {
  //     setState(() => _isLoadingBomComponents = false);
  //     _showSnack("Failed to load BOM & Components: $e", Colors.red);
  //   }
  // }

  /// Called when BOM or Component dropdown changes, or after initial load
  Future<void> _fetchCutSize() async {
    if (_selectedBomNo == null ||
        _selectedBomNo!.isEmpty ||
        _selectedComponent == null ||
        _selectedComponent!.isEmpty) {
      return; // ❌ API call mat karo
    }

    try {
      final data = await VisaApiService.getCutSize(
        woNumber: _selectedBomNo!, // ✅ BOM number
        component: _selectedComponent!, // ✅ component
      );

      if (data != null) {
        setState(() {
          _cutWidthCtrl.text = "${data['cutWidth'] ?? ''}";
          _cutLengthCmCtrl.text = "${data['cutLength'] ?? ''}";
        });
      }
    } catch (e) {
      _showSnack("Failed to fetch cut size: $e", Colors.red);
    }
  }

  String _generateBatchNumber() {
    final party = _partyNameCtrl.text.trim(); // ✅ your controller
    final po = _poNoCtrl.text.trim(); // (optional if needed)
    final shift = _selectedShift ?? '';

    final now = DateTime.now();
    final date = now.day.toString(); // 8
    final month = now.month.toString().padLeft(2, '0'); // 05

    String partyCode = '';
    if (party.length >= 3) {
      partyCode = party.substring(0, 3).toUpperCase();
    } else {
      partyCode = party.toUpperCase();
    }

    return "$partyCode$date$month${shift}LO";
  }

  void _setBatchNumber() {
    final batch = _generateBatchNumber();

    setState(() {
      _batchNoCtrl.text = batch;
    });
  }

  // ── Fabric Code & Batch No ─────────────────────────────────────

  void _generateFabricCode() {
    final code =
        "${_fabricWidthCtrl.text}-"
        "${_baffleCtrl.text}-"
        "${_selectedShift ?? ''}-"
        "${_fabricGsmCtrl.text}-"
        "${_laminationCtrl.text}-"
        "${_colorCtrl.text}-"
        "${_cutTypeCtrl.text}-"
        "${_fabricBaffleCtrl.text}";

    setState(() {
      _generateCodeCtrl.text = code;
      _reqFabricCtrl.text = code;
    });

    _loadTillRemaining(); // keep your existing logic
  }

  Future<void> _saveForm() async {
    if (_selectedShift == null) {
      _showSnack("Select Shift", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = _buildCuttingPayload();

      final message = await NaradanaApiService.saveCutting(payload);

      if (message.contains("Success") || message.contains("Successfully")) {
        _showSnack(message, Colors.green);
      } else {
        _showSnack(message, Colors.red);
      }
    } catch (e) {
      print("Error :::::$e");
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Clear ──────────────────────────────────────────────────────
  void _clearForm() {
    for (final c in [
      _specialIdCtrl,
      _laminationCtrl,
      _grossWeightCtrl,
      _tareWeightCtrl,
      // _rollLengthCtrl,
      // _avgWeightMtrCtrl,
      _batchNoCtrl,
      _machineStartCtrl,
      _machineEndCtrl,
      _remarkCtrl,
      _generateCodeCtrl,
      _cutWidthCtrl,
      _cutLengthCmCtrl,
      _cutSizeQtyCtrl,
      _netWtCtrl,
      _wastageCtrl,
      _tillRemCtrl,
      _useCtrl,
      _finalRemCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _selectedShift = null;
      _operator2 = null;
      _selectedSupervisor = null;
      // _rollWeightCtrl.text = '0.00';
      // _cutLengthCtrl.text = '0.00';
    });
  }

  Map<String, dynamic> _buildCuttingPayload() {
    return {
      "generateCode": _generateCodeCtrl.text,
      "spName": widget.production.loomNo,
      "supervisor": _selectedSupervisor ?? "",
      "shift": _tareWeightCtrl.text ?? "",
      "realShift": _selectedShift,
      "articleno": _articleNoCtrl.text,
      "ordertype": widget.production.orderType,

      "operatorName": _operator2 ?? "",

      "partyNamebom": _bomCtrl.text,
      // "partyname": _partyNameCtrl.text,
      "partyname": widget.production.component,

      "orderno": widget.production.partyname,
      // "poNum": widget.production.component,
      "poNum": _componentCtrl.text,
      "poNUMBER": _poNoCtrl.text,
      "fabricType": _fabricTypeCtrl.text,

      // "opName": _colorCtrl.text,

      // "articleNo": _articleNoCtrl.text,
      // "bomNo": _bomCtrl.text,
      // "componentName": _componentCtrl.text,

      // "fabricType": _fabricTypeCtrl.text,
      "opName": _operatorCtrl.text.isNotEmpty
          ? _operatorCtrl.text
          : (_operator2 ?? ""),
      "color": _colorCtrl.text,
      "fabricConstruction": _baffleCtrl.text,
      "fabricGsm": _fabricGsmCtrl.text,
      "fabricWidth": _fabricWidthCtrl.text,
      "fabricBaffleType": _cutTypeCtrl.text,
      "laminationType": _laminationCtrl.text,
      "grossWeight": _grossWeightCtrl.text,

      // "grossWeight": widget.production.requiredQtyMtr.toString(),
      "tareWeight": _tareWeightCtrl.text,
      "rollWeight": _rollWeightCtrl.text,
      "rollLength": _rollLengthCtrl.text,
      "avgWeight": _avgWeightMtrCtrl.text,

      "remark": _remarkCtrl.text,
      "avgweightgm": _avgWeightMtrCtrl.text,

      "batchNo": _batchNoCtrl.text,
      "cutWidth": _cutLengthCmCtrl.text,
      "cutLength": _cutWidthCtrl.text,
      "cutlengthcm": _cutLengthCmCtrl.text,
      // "cutWidth": _cutWidthCtrl.text,
      // "cutLength": _cutLengthCmCtrl.text,
      // "cutlengthcm": _cutLengthCmCtrl.text,
      "loomtype": widget.production.loomType, // using your WO type
      "netwt": _netWtCtrl.text,
      "tillrem": _tillRemCtrl.text,
      "finalrem": _finalRemCtrl.text,

      "cutSizeQty": widget.production.requiredQtyKg.toString(),
      "cutSIZEQUANTITY": _cutSizeQtyCtrl.text,

      "cutType": _fabricBaffleCtrl.text,
      "loomwastage": _loomWastageCtrl.text,
      "lamiwastage": _laminationWastageCtrl.text,
      // "unit": "UNIT-SILVASSA", // or KG depending on your system

      "unit": "UNIT-NARDANA", // or KG depending on your system
    };
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
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
            final pad = constraints.maxWidth > 600 ? 20.0 : 14.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
              child: _buildBody(),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final d =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return AppBar(
      backgroundColor: C.appBar1,
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
            widget.production.component,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(d, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.content_cut_rounded,
                color: Colors.white70,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                widget.production.department,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Job Info ──────────────────────────────────────────────
        _sectionLabel("Job Info"),
        _card([
          _row([
            _field("Article No", _articleNoCtrl, readOnly: true),
            _field("Purchase Order No", _poNoCtrl, readOnly: true),
          ]),
          _row([
            _isLoadingBomComponents
                ? _loadingLabelBox("BOM")
                : _genericDropdownStr(
                    label: "BOM",
                    items: _bomNumbers,
                    value: _selectedBomNo,
                    onChanged: (v) {
                      setState(() {
                        _selectedBomNo = v;
                        _bomCtrl.text = v ?? '';
                      });
                      _fetchCutSize();
                    },
                  ),
            _staticDropdown(
              label: "Shift",
              items: _shiftOptions,
              value: _selectedShift,
              onChanged: (v) => setState(() => _selectedShift = v),
            ),
          ]),
        ]),
        _gap,

        // ── Scheduling ────────────────────────────────────────────
        _sectionLabel("Scheduling"),
        _card([
          _row([
            _field("Date", _dateCtrl, readOnly: true),
            _field("Time", _timeCtrl, readOnly: true),
          ]),
          _row([
            _genericDropdown(
              label: "Supervisor",
              items: _supervisorList.map((e) => e.label).toList(),
              value: _selectedSupervisor,
              isLoading: _isLoadingSupervisor,
              onChanged: (v) => setState(() => _selectedSupervisor = v),
            ),
            _genericDropdown(
              label: "Operator",
              items: _operatorList.map((e) => e.label).toList(),
              value: _operator2,
              isLoading: _isLoadingOperator,
              onChanged: (v) => setState(() => _operator2 = v),
            ),
          ]),
        ]),
        _gap,

        // ── Fabric Specs ──────────────────────────────────────────
        _sectionLabel("Fabric Specs"),
        _card([
          _row([
            _field("Fabric Type / Use", _fabricTypeCtrl, readOnly: true),
            _isLoadingLamination
                ? _loadingLabelBox("Fabric Construction")
                : _genericDropdown(
                    label: "Fabric Construction",
                    items: _baffleList,
                    value: _selectedBaffle,
                    isLoading: false,
                    onChanged: (val) {
                      setState(() {
                        _selectedBaffle = val;
                        _baffleCtrl.text = val ?? "";
                      });
                    },
                  ),
          ]),
          _row([
            _field("Color", _colorCtrl, readOnly: true),
            _isLoadingBomComponents
                ? _loadingLabelBox("Component")
                : _genericDropdownStr(
                    label: "Component",
                    items: _componentList,
                    value: _selectedComponent,
                    onChanged: (v) {
                      setState(() {
                        _selectedComponent = v;
                        _componentCtrl.text = v ?? '';
                      });
                      _fetchCutSize();
                    },
                  ),
          ]),
          _row([
            _isLoadingGsm
                ? _loadingLabelBox("Fabric GSM")
                : _genericDropdownStr(
                    label: "Fabric GSM",
                    items: _gsmList,
                    value: _selectedGsm,
                    onChanged: (v) {
                      setState(() {
                        _selectedGsm = v;
                        _fabricGsmCtrl.text = v ?? '';
                      });

                      _fetchCutSize();

                      // ✅ Dono call karo
                      // _loadFabricWidth();
                      _loadGsm();
                    },
                  ),
            _isLoadingFabricWidth
                ? _loadingLabelBox("Fabric Width")
                : _genericDropdownStr(
                    label: "Fabric Width (cm)",
                    items: _fabricWidthList,
                    value: _selectedFabricWidth,
                    onChanged: (v) {
                      setState(() {
                        _selectedFabricWidth = v;
                        _fabricWidthCtrl.text = v ?? '';
                      });

                      _fetchCutSize();

                      // ✅ Dono call karo
                      _loadFabricWidth();
                      // _loadGsm();
                    },
                  ),
          ]),
          _row([
            _field("Baffle / Type", _fabricBaffleCtrl, readOnly: true),
            _isLoadingLamination
                ? _loadingLabelBox("Lamination Type")
                : _genericDropdown(
                    label: "Lamination Type",
                    items: _laminationList,
                    value: _selectedLamination,
                    isLoading: false,
                    onChanged: (val) {
                      setState(() {
                        _selectedLamination = val;
                        _laminationCtrl.text = val ?? "";
                      });
                    },
                  ),
          ]),
          _row([
            _field("Cut Type", _cutTypeCtrl, readOnly: true),
            _field("OP Name", _operatorCtrl,),
          ]),
        ]),
        _gap,

        // ── Weight & Output ───────────────────────────────────────
        _sectionLabel("Weight & Output"),
        _card([
          _row([
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
          ]),
          _row([
            _field("Roll Weight (Kg)", _rollWeightCtrl, readOnly: true),
            _field(
              "Roll Length (Mtr)",
              _rollLengthCtrl,
              inputType: TextInputType.number,
            ),
          ]),
          _row([_field("Avg Weight /gm", _avgWeightMtrCtrl, readOnly: true),
            _field("Batch No", _batchNoCtrl, readOnly: true),
          ]),
          const Divider(height: 20, thickness: 0.5),
          _row([
            _field("Cut Length(cm)", _cutWidthCtrl),//318
            _field("Cut Width(cm)", _cutLengthCmCtrl),//98
          ]),
          _row([
            _field(
              "Cut Size Qty",
              _cutSizeQtyCtrl,
              inputType: TextInputType.number,
            ),
            _field("Net Wt", _netWtCtrl, inputType: TextInputType.number),
            _field("Wastage", _wastageCtrl, inputType: TextInputType.number),
          ]),
          _row([
            // _field("Till Rem.", _tillRemCtrl, readOnly: true),
            // _field("USE", _useCtrl, readOnly: true),
            // _field("Final Rem.", _finalRemCtrl, readOnly: true),
            _field("Till Rem.", _tillRemCtrl, ),
            _field("USE", _useCtrl, readOnly: true),
            _field("Final Rem.", _finalRemCtrl, readOnly: true),
          ]),
        ]),
        _gap,

        // ── Remarks & Code ────────────────────────────────────────
        _sectionLabel("Remarks & Code"),
        _card([
          _row([_field("Remark", _remarkCtrl, maxLines: 2)]),
          const SizedBox(height: 4),
          _field("Generated Fabric Code", _generateCodeCtrl, readOnly: true),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      _generateFabricCode();
                      _setBatchNumber(); // ✅ ADD THIS
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: C.appBar3,strokeWidth: 1.5),
                    )
                  : const Icon(Icons.qr_code_2_rounded, size: 16),
              label: const Text("Generate Fabric Code & Batch No"),
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
        _sectionLabel("Production Options"),
        _card([
          // ── WO TYPE ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "WO Type",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("With WO"),
                      value: "WITH_WO",
                      groupValue: _woType,
                      onChanged: (val) {
                        setState(() => _woType = val.toString());
                      },
                      activeColor: _primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Without WO"),
                      value: "WITHOUT_WO",
                      groupValue: _woType,
                      onChanged: (val) {
                        setState(() => _woType = val.toString());
                      },
                      activeColor: _primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── ROLL FINISH ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Roll Finish",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Yes"),
                      value: "YES",
                      groupValue: _rollFinish,
                      onChanged: (val) {
                        setState(() => _rollFinish = val.toString());
                      },
                      activeColor: _primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("No"),
                      value: "NO",
                      groupValue: _rollFinish,
                      onChanged: (val) {
                        setState(() => _rollFinish = val.toString());
                      },
                      activeColor: _primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── WASTAGE FIELDS ──
          _row([
            _field(
              "Loom Wastage",
              _loomWastageCtrl,
              inputType: TextInputType.number,
            ),
            _field(
              "Lamination Wastage",
              _laminationWastageCtrl,
              inputType: TextInputType.number,
            ),
          ]),
        ]),
        _gap,

        _buildActionBar(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LAYOUT HELPERS
  // ══════════════════════════════════════════════════════════════
  Widget _row(List<Widget> children) {
    final expanded =
        children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 8)])
            .toList()
          ..removeLast();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: expanded,
    );
  }

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

  void _onRollWeightChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadTillRemaining(); // ✅ only once after typing stops
    });
  }
  //
  // void _calculateRollWeight() {
  //   final gross = double.tryParse(_grossWeightCtrl.text) ?? 0;
  //   final tare = double.tryParse(_tareWeightCtrl.text) ?? 0;
  //
  //   final rollWeight = (gross - tare).clamp(0, double.infinity);
  //
  //   _rollWeightCtrl.text = rollWeight.toStringAsFixed(2);
  //
  //   // ✅ yaha se avg weight update hogi
  //   _calculateAvgWeight();
  //
  //   // ✅ API bhi refresh
  //   _loadTillRemaining();
  // }

  void _calculateRollWeight() {
    print("🔥 calculateRollWeight triggered");

    final gross = double.tryParse(_grossWeightCtrl.text) ?? 0;
    final tare = double.tryParse(_tareWeightCtrl.text) ?? 0;

    final rollWeight = (gross - tare).clamp(0, double.infinity);

    print("👉 gross: $gross | tare: $tare | rollWeight: $rollWeight");

    _rollWeightCtrl.text = rollWeight.toString();

    _calculateAvgWeight();
    // ✅ API CALL HERE
    _loadTillRemaining();
  }

  void _calculateAvgWeight() {
    final weight = double.tryParse(_rollWeightCtrl.text) ?? 0;
    final length = double.tryParse(_rollLengthCtrl.text) ?? 0;

    String value;

    if (length > 0) {
      value = (weight * 1000 / length).toStringAsFixed(2);
    } else {
      value = '0.00';
    }

    setState(() {
      _avgWeightMtrCtrl.text = value;
    });
  }

  // Future<void> _loadTillRemaining() async {
  //   final int code = widget.production.rollCode; // ✅ srno hi use karo
  //   final rollWeight = double.tryParse(_rollWeightCtrl.text) ?? 0.0;
  //
  //   print("👉 Calling API with:");
  //   print("SRNO 👉 $code");
  //   print("RollWeight 👉 $rollWeight");
  //
  //   // if (code.isEmpty) {
  //   //   print("❌ SRNO empty, API not called");
  //   //   return;
  //   // }
  //
  //   try {
  //     final result = await NaradanaApiService.getRemainingWeight(
  //       code: code,
  //       rollWeight: rollWeight,
  //     );
  //
  //     if (result != null) {
  //       final value = result.remaining.toStringAsFixed(2);
  //
  //       _tillRemCtrl.text = value;
  //       _calculateUseAndFinalRem();
  //
  //       print("✅ Till Remaining 👉 $value");
  //     } else {
  //       print("❌ API returned null");
  //     }
  //   } catch (e) {
  //     print("❌ API Error 👉 $e");
  //   }
  // }

  Future<void> _loadTillRemaining() async {
    print("🚀 _loadTillRemaining CALLED");

    final int code = widget.production.rollCode;
    final rollWeight = double.tryParse(_rollWeightCtrl.text) ?? 0.0;

    print("👉 rollCode: $code");
    print("👉 rollWeight: $rollWeight");

    try {
      final result = await NaradanaApiService.getRemainingWeight(
        code: code,
        rollWeight: rollWeight,
      );

      print("📦 FULL API RESPONSE 👉 $result");

      if (result != null) {
        print("👉 Remaining: ${result.remaining}");

        final value = result.remaining.toStringAsFixed(2);

        setState(() {
          _tillRemCtrl.text = value;
        });

        _calculateUseAndFinalRem();
      } else {
        print("❌ API returned NULL");
      }
    } catch (e) {
      print("❌ API Error 👉 $e");
    }
  }

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
                  (s) => DropdownMenuItem(
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

  Widget _genericDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
  }) {
    // ✅ Clean items
    final cleanItems = items.toSet().toList()
      ..removeWhere((e) => e.trim().isEmpty);

    // ✅ Safe value
    String? safeValue;
    if (value != null && cleanItems.contains(value)) {
      safeValue = value;
    } else {
      safeValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ SAME LABEL STYLE AS _field
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 4),

        // ✅ SAME BOX STYLE AS TEXTFIELD
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _inputBg, // ✅ same as textfield
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBCC8E8)), // ✅ same border
          ),
          child: DropdownButtonHideUnderline(
            child: isLoading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: C.appBar3,strokeWidth: 1.5),
                      ),
                      SizedBox(width: 8),
                      Text("Loading...", style: TextStyle(fontSize: 12)),
                    ],
                  )
                : DropdownButton<String>(
                    value: safeValue,
                    isExpanded: true,
                    isDense: true,

                    // ✅ SAME TEXT STYLE
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A2340),
                    ),

                    hint: const Text(
                      "Select",
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
                    ),

                    items: cleanItems
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
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
  }

  Widget _genericDropdownStr({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final cleanItems = items.where((e) => e.trim().isNotEmpty).toList();

    final effectiveValue = cleanItems.firstWhere(
      (item) => item.trim() == value?.trim(),
      orElse: () => '',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
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

            _dropdownBox(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveValue.isNotEmpty ? effectiveValue : null,
                  isExpanded: true,
                  isDense: true,

                  // ✅ IMPORTANT: makes dropdown scrollable + responsive
                  menuMaxHeight: constraints.maxHeight * 0.2,

                  dropdownColor: Colors.white,

                  hint: const Text(
                    "Select",
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
                  ),

                  items: cleanItems.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          s,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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

  Widget _loadingLabelBox(String label) => Column(
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
      _loadingBox(),
    ],
  );

  Widget _buildActionBar() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _actionBtn(
        "Save",
        Icons.check_rounded,
        _primary,
        _saveForm,
        loading: _isLoading,
      ),
      // _actionBtn("Update", Icons.edit_rounded, const Color(0xFF00897B), () {}),
      // _actionBtn(
      //   "Clear",
      //   Icons.refresh_rounded,
      //   const Color(0xFFF59E0B),
      //   _clearForm,
      // ),
      _actionBtn(
        "Exit",
        Icons.logout_rounded,
        const Color(0xFFEF4444),
        () => Navigator.maybePop(context),
      ),
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
}

class _NameValue {
  final String label;
  final String value;
  const _NameValue(this.label, this.value);
}

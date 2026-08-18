// import 'package:IMS/services/getSupervisors/getSupervisors.dart';
// import 'package:flutter/material.dart';
//
// import '../../../Color/Colorclass.dart';
// import '../../../services/visa_apis/visa_api.dart';
// import '../cutOutModelClass/ModelClassOutstock.dart';
// import 'OutSavedList.dart';
//
// class CuttingOutStockForm extends StatefulWidget {
//   final CuttingOutstock production;
//
//   const CuttingOutStockForm({super.key, required this.production});
//
//   @override
//   State<CuttingOutStockForm> createState() => _CuttingOutStockFormState();
// }
//
// class _CuttingOutStockFormState extends State<CuttingOutStockForm> {
//   // ─────────────── Theme ───────────────
//
//   static const _surface = Color(0xFFF8FAFF);
//   static const _border = Color(0xFFDDE3F0);
//   static const _labelColor = Colors.black;
//   static const _inputBg = Colors.white;
//   static const _readOnlyBg = Color(0xFFF4F6FB);
//
//   final _apiService = VisaApiService();
//   final _inStockService = InStockService();
//   final _formKey = GlobalKey<FormState>();
//
//   // ── Dropdown state ─────────────────────────────────────────────
//   String? _selectedShift;
//   final List<String> _shiftOptions = ['A', 'B'];
//
//   List<String> _bomNumbers = [];
//   String? _selectedBomNo;
//
//   List<String> _componentList = [];
//   String? _selectedComponent;
//
//   List<String> _fabricWidthList = [];
//   String? _selectedFabricWidth;
//
//   List<String> _gsmList = [];
//   String? _selectedGsm;
//
//   List<_NameValue> _operatorList = [];
//   List<_NameValue> _supervisorList = [];
//   String? _operator2;
//   String? _selectedSupervisor;
//
//   // ── Loading flags ──────────────────────────────────────────────
//   bool _isLoadingFabricWidth = false;
//   bool _isLoadingGsm = false;
//   bool _isLoadingBomComponents = false;
//   bool _isLoadingOperator = false;
//   bool _isLoadingSupervisor = false;
//   bool _isLoading = false;
//
//   // ── Controllers ────────────────────────────────────────────────
//   late final TextEditingController _partyNameCtrl;
//   late final TextEditingController _poNoCtrl;
//   late final TextEditingController _articleNoCtrl;
//   late final TextEditingController _bomCtrl;
//   late final TextEditingController _componentCtrl;
//   late final TextEditingController _reqFabricCtrl;
//   late final TextEditingController _dateCtrl;
//   late final TextEditingController _timeCtrl;
//   late final TextEditingController _reqQtyKgCtrl;
//   late final TextEditingController _reqQtyMtrCtrl;
//
//   late final TextEditingController _machineStartCtrl;
//   late final TextEditingController _machineEndCtrl;
//   late final TextEditingController _cutLengthCtrl;
//   late final TextEditingController _baffleCtrl;
//
//   late final TextEditingController _fabricTypeCtrl;
//   late final TextEditingController _colorCtrl;
//   late final TextEditingController _specialIdCtrl;
//   late final TextEditingController _fabricGsmCtrl;
//   late final TextEditingController _fabricWidthCtrl;
//   late final TextEditingController _fabricBaffleCtrl;
//
//   late final TextEditingController _fabricConstCtrl;
//   late final TextEditingController _laminationCtrl;
//   late final TextEditingController _cutTypeCtrl;
//   late final TextEditingController _batchNoCtrl;
//
//   late final TextEditingController _grossWeightCtrl;
//   late final TextEditingController _tareWeightCtrl;
//   late final TextEditingController _rollWeightCtrl;
//   late final TextEditingController _rollLengthCtrl;
//   late final TextEditingController _avgWeightMtrCtrl;
//
//   // Weight & Output — separate controllers (no reuse)
//   late final TextEditingController _cutWidthCtrl;
//   late final TextEditingController _cutLengthCmCtrl;
//   late final TextEditingController _cutSizeQtyCtrl;
//   late final TextEditingController _netWtCtrl;
//   late final TextEditingController _wastageCtrl;
//   late final TextEditingController _tillRemCtrl;
//   late final TextEditingController _useCtrl;
//   late final TextEditingController _finalRemCtrl;
//
//   late final TextEditingController _remarkCtrl;
//   late final TextEditingController _generateCodeCtrl;
//
//   // ── initState ──────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     final p = widget.production;
//     final now = DateTime.now();
//
//     final dateStr =
//         "${now.day.toString().padLeft(2, '0')}-${_monthName(now.month)}-${now.year}";
//     final h = now.hour > 12
//         ? now.hour - 12
//         : now.hour == 0
//         ? 12
//         : now.hour;
//     final timeStr =
//         "$h:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} "
//         "${now.hour >= 12 ? 'PM' : 'AM'}";
//
//     _partyNameCtrl = TextEditingController(text: p.partyname);
//     _poNoCtrl = TextEditingController(text: p.workorderno);
//     _articleNoCtrl = TextEditingController();
//     _bomCtrl = TextEditingController(text: p.workorderno);
//     _componentCtrl = TextEditingController();
//     _reqFabricCtrl = TextEditingController(text: _buildFabricCode(p));
//     _dateCtrl = TextEditingController(text: dateStr);
//     _timeCtrl = TextEditingController(text: timeStr);
//     _reqQtyKgCtrl = TextEditingController(text: p.requiredNetWeight.toString());
//     _reqQtyMtrCtrl = TextEditingController(text: p.requiredQtyMtr.toString());
//
//     _machineStartCtrl = TextEditingController();
//     _machineEndCtrl = TextEditingController();
//     // _cutLengthCtrl = TextEditingController(text: _cutLengthCtrl.text);
//     _cutLengthCtrl = TextEditingController(text: '0.00');
//     _baffleCtrl = TextEditingController(text: p.cuttype);
//
//     _fabricTypeCtrl = TextEditingController(text: p.typeuse);
//     _colorCtrl = TextEditingController(text: p.color);
//     _specialIdCtrl = TextEditingController();
//     _fabricGsmCtrl = TextEditingController();
//     _fabricWidthCtrl = TextEditingController();
//     _fabricBaffleCtrl = TextEditingController(text: p.buffle);
//     _fabricConstCtrl = TextEditingController(text: p.fabricwidth);
//     _laminationCtrl = TextEditingController();
//     _cutTypeCtrl = TextEditingController(text: p.sid);
//     _batchNoCtrl = TextEditingController();
//
//     _grossWeightCtrl = TextEditingController(text: p.jobwork.toString());
//     _tareWeightCtrl = TextEditingController(text: p.weekno.toString());
//     _rollLengthCtrl = TextEditingController(text: p.quantity.toString());
//     _rollWeightCtrl = TextEditingController(text: p.netwt.toStringAsFixed(2));
//     _avgWeightMtrCtrl = TextEditingController(
//       text: p.requiredNetWeight.toStringAsFixed(2),
//     );
//
//     // Weight & Output Controllers
//     _cutWidthCtrl = TextEditingController();
//     _cutLengthCmCtrl = TextEditingController();
//     _cutSizeQtyCtrl = TextEditingController();
//
//     _netWtCtrl = TextEditingController();
//     _wastageCtrl = TextEditingController();
//     _tillRemCtrl = TextEditingController();
//     _useCtrl = TextEditingController();
//     _finalRemCtrl = TextEditingController();
//
//     _remarkCtrl = TextEditingController();
//     _generateCodeCtrl = TextEditingController(text: _buildFabricCode(p));
//
//     // Add listeners AFTER initialization
//     _cutWidthCtrl.addListener(() {
//       print("Width changed");
//       _calculateNetWeight();
//     });
//     _cutLengthCmCtrl.addListener(_calculateNetWeight);
//     _cutSizeQtyCtrl.addListener(_calculateNetWeight);
//     _fabricGsmCtrl.addListener(_calculateNetWeight);
//
//     _wastageCtrl.addListener(_calculateUseAndFinalRem);
//     _tillRemCtrl.addListener(_calculateUseAndFinalRem);
//
//     _machineEndCtrl.addListener(_calculateCutLength);
//
//     _grossWeightCtrl.addListener(_calculateRollWeight);
//     _tareWeightCtrl.addListener(_calculateRollWeight);
//     _rollLengthCtrl.addListener(_calculateAvgWeight);
//
//     _remarkCtrl = TextEditingController();
//     _generateCodeCtrl = TextEditingController(text: _buildFabricCode(p));
//
//     // Pre-select GSM & Fabric Width (will be validated after list loads)
//     _selectedGsm = p.gsm;
//     _selectedFabricWidth = p.fabricwidth;
//
//     // Listeners
//     // _machineEndCtrl.addListener(_calculateCutLength);
//     // _rollWeightCtrl.addListener(_calculateUseAndFinalRem);
//     // _wastageCtrl.addListener(_calculateUseAndFinalRem);
//
//     // _netWtCtrl.text = "";
//     // _wastageCtrl.text = "";
//
//     _loadOperators();
//     _loadSupervisors();
//     _loadFabricWidth();
//     _loadGsm();
//     _fetchArticleAndThenBom();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadTillRemaining();
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _calculateAvgWeight();
//     });
//
//     // initState mein ye listener add karo
//     // _generateCodeCtrl.addListener(() {
//     //   if (_generateCodeCtrl.text.isNotEmpty) {
//     //     _loadTillRemaining();
//     //   }
//     // });
//   }
//
//   @override
//   void dispose() {
//     for (final c in [
//       _partyNameCtrl,
//       _poNoCtrl,
//       _articleNoCtrl,
//       _bomCtrl,
//       _componentCtrl,
//       _reqFabricCtrl,
//       _dateCtrl,
//       _timeCtrl,
//       _reqQtyKgCtrl,
//       _reqQtyMtrCtrl,
//       _machineStartCtrl,
//       _machineEndCtrl,
//       _cutLengthCtrl,
//       _baffleCtrl,
//       _fabricTypeCtrl,
//       _colorCtrl,
//       _specialIdCtrl,
//       _fabricGsmCtrl,
//       _fabricWidthCtrl,
//       _fabricBaffleCtrl,
//       _laminationCtrl,
//       _cutTypeCtrl,
//       _batchNoCtrl,
//       _grossWeightCtrl,
//       _tareWeightCtrl,
//       _rollWeightCtrl,
//       _rollLengthCtrl,
//       _avgWeightMtrCtrl,
//       _cutWidthCtrl,
//       _cutLengthCmCtrl,
//       _cutSizeQtyCtrl,
//       _netWtCtrl,
//       _wastageCtrl,
//       _tillRemCtrl,
//       _useCtrl,
//       _finalRemCtrl,
//       _remarkCtrl,
//       _generateCodeCtrl,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────
//   String _monthName(int m) => const [
//     '',
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ][m];
//
//   String _buildFabricCode(CuttingOutstock p) =>
//       "${p.fabricwidth}-${p.machineno}-${p.typeuse}-${p.gsm}--${p.color}-${p.cuttype}-";
//
//   // ── Calculations ───────────────────────────────────────────────
//   void _calculateCutLength() {
//     final start = double.tryParse(_machineStartCtrl.text) ?? 0;
//     final end = double.tryParse(_machineEndCtrl.text) ?? 0;
//     _cutLengthCtrl.text = (end - start)
//         .clamp(0, double.infinity)
//         .toStringAsFixed(2);
//   }
//
//   Future<void> _loadInitialData() async {
//     await Future.wait([
//       _loadOperators(),
//       _loadSupervisors(),
//       _loadFabricWidth(),
//       _loadGsm(),
//     ]);
//
//     await _fetchArticleAndThenBom();
//
//     _loadTillRemaining();
//     _calculateAvgWeight();
//   }
//
//   void _calculateUseAndFinalRem() {
//     final net = double.tryParse(_netWtCtrl.text) ?? 0;
//     final wastage = double.tryParse(_wastageCtrl.text) ?? 0;
//     final tillRem = double.tryParse(_tillRemCtrl.text) ?? 0;
//
//     // USE = Net + Wastage
//     final use = net + wastage;
//
//     _useCtrl.text = use.toStringAsFixed(2);
//
//     // Final Remaining = TillRem - Use
//     double finalRem = tillRem - use;
//
//     // ✅ Validation: negative allow nahi
//     if (finalRem < 0) {
//       finalRem = 0;
//
//       // Optional: user ko warning dikhao
//       _showSnack("Final Remaining negative nahi ho sakta", Colors.orange);
//     }
//
//     _finalRemCtrl.text = finalRem.toStringAsFixed(2);
//   }
//
//   void _calculateNetWeight() {
//     debugPrint("W:${_cutWidthCtrl.text} L:${_cutLengthCmCtrl.text} GSM:${_fabricGsmCtrl.text} Qty:${_cutSizeQtyCtrl.text}");
//     final cutWidth  = double.tryParse(_cutWidthCtrl.text.trim())    ?? 0.0;
//     final cutLength = double.tryParse(_cutLengthCmCtrl.text.trim()) ?? 0.0;
//     final gsm = double.tryParse(_fabricGsmCtrl.text.trim()) ?? 0.0;
//     final qty = double.tryParse(_cutSizeQtyCtrl.text.trim()) ?? 0.0;
//
//     debugPrint("Width  : $cutWidth");
//     debugPrint("Length : $cutLength");
//     debugPrint("GSM    : $gsm");
//     debugPrint("Qty    : $qty");
//     debugPrint("Baffle : ${_fabricBaffleCtrl.text}");
//
//     if (cutWidth <= 0 ||
//         cutLength <= 0 ||
//         gsm <= 0 ||
//         qty <= 0) {
//       _netWtCtrl.text = "0.00";
//       return;
//     }
//
//     final baffle = _fabricBaffleCtrl.text.trim().toUpperCase();
//
//     final bool isDoubleLayer =
//         baffle == "CRF" ||
//             baffle == "C00";
//
//     double netWt =
//         (cutWidth * cutLength * gsm * qty) / 10000000;
//
//     if (isDoubleLayer) {
//       netWt *= 2;
//     }
//
//     _netWtCtrl.text = netWt.toStringAsFixed(2);
//
//     _calculateUseAndFinalRem();
//   }
//
//   // ── API Calls ──────────────────────────────────────────────────
//   Future<void> _loadFabricWidth() async {
//     setState(() => _isLoadingFabricWidth = true);
//     final data = await VisaApiService.getGsmOrFabricWidth(type: "FW");
//
//     // debugPrint("FabricWidth API response: $data"); // ← Ye add karo
//     // debugPrint("FabricWidth list length: ${data.length}");
//
//     setState(() {
//       _fabricWidthList = data;
//       if (!data.contains(_selectedFabricWidth)) {
//         _selectedFabricWidth = data.isNotEmpty ? data.first : null;
//       }
//       _fabricWidthCtrl.text = _selectedFabricWidth ?? '';
//       _isLoadingFabricWidth = false;
//     });
//   }
//
//   // Future<void> _loadGsm() async {
//   //   setState(() => _isLoadingGsm = true);
//   //   final data = await VisaApiService.getGsmOrFabricWidth(type: "GSM");
//   //   setState(() {
//   //     _gsmList = data;
//   //     // Validate pre-selected value; fallback to first item if not found
//   //     if (!data.contains(_selectedGsm)) {
//   //       _selectedGsm = data.isNotEmpty ? data.first : null;
//   //     }
//   //     _fabricGsmCtrl.text = _selectedGsm ?? '';
//   //     _isLoadingGsm = false;
//   //   });
//   // }
//   Future<void> _loadGsm() async {
//     setState(() => _isLoadingGsm = true);
//     final data = await VisaApiService.getGsmOrFabricWidth(type: "GSM");
//     setState(() {
//       _gsmList = data;
//       if (!data.contains(_selectedGsm)) {
//         _selectedGsm = data.isNotEmpty ? data.first : null;
//       }
//       _fabricGsmCtrl.text = _selectedGsm ?? '';
//       _isLoadingGsm = false;
//     });
//     _calculateNetWeight(); // ✅ ADD
//   }
//   Future<void> _loadOperators() async {
//     setState(() => _isLoadingOperator = true);
//     try {
//       final data = await _inStockService.getCuttingOperators();
//       setState(() {
//         _operatorList = data.map((e) => _NameValue(e, e)).toList();
//         _isLoadingOperator = false;
//       });
//     } catch (_) {
//       setState(() => _isLoadingOperator = false);
//     }
//   }
//
//   Future<void> _loadSupervisors() async {
//     setState(() => _isLoadingSupervisor = true);
//     try {
//       final data = await _inStockService.getCuttingSupervisors();
//       setState(() {
//         _supervisorList = data.map((e) => _NameValue(e, e)).toList();
//         _isLoadingSupervisor = false;
//       });
//     } catch (_) {
//       setState(() => _isLoadingSupervisor = false);
//     }
//   }
//
//   Future<void> _fetchArticleAndThenBom() async {
//     final sidInt = int.tryParse(widget.production.srno);
//     if (sidInt == null) {
//       await _loadBomAndComponents(articleOverride: widget.production.modelno);
//       return;
//     }
//     try {
//       final result = await _apiService.getArticleNo(sidInt);
//       setState(() => _articleNoCtrl.text = result ?? widget.production.modelno);
//       await _loadBomAndComponents(
//         articleOverride: result ?? widget.production.modelno,
//       );
//     } catch (e) {
//       setState(() => _articleNoCtrl.text = widget.production.modelno);
//       _showSnack("Failed to fetch Article No: $e", Colors.red);
//       await _loadBomAndComponents(articleOverride: widget.production.sid);
//     }
//   }
//
//   Future<void> _loadBomAndComponents({String? articleOverride}) async {
//     setState(() => _isLoadingBomComponents = true);
//     try {
//       final data = await VisaApiService.getBomAndComponents(
//         po: widget.production.workorderno,
//         article: articleOverride ?? _articleNoCtrl.text.trim(),
//       );
//       final boms = List<String>.from(data['bomNumbers'] ?? []);
//       final comps = List<String>.from(data['components'] ?? []);
//       setState(() {
//         _bomNumbers = boms;
//         _componentList = comps;
//         if (boms.isNotEmpty) {
//           _selectedBomNo = boms.first;
//           _bomCtrl.text = boms.first;
//         }
//         if (comps.isNotEmpty) {
//           _selectedComponent = comps.first;
//           _componentCtrl.text = comps.first;
//         }
//         _isLoadingBomComponents = false;
//       });
//       // Auto-fetch cut size once both BOM & Component are ready
//       await _fetchCutSize();
//     } catch (e) {
//       setState(() => _isLoadingBomComponents = false);
//       _showSnack("Failed to load BOM & Components: $e", Colors.red);
//     }
//   }
//
//   /// Called when BOM or Component dropdown changes, or after initial load
//   // Future<void> _fetchCutSize() async {
//   //   if (_selectedBomNo == null ||
//   //       _selectedBomNo!.isEmpty ||
//   //       _selectedComponent == null ||
//   //       _selectedComponent!.isEmpty) {
//   //     return; // ❌ API call mat karo
//   //   }
//   //
//   //   try {
//   //     final data = await VisaApiService.getCutSize(
//   //       woNumber: _selectedBomNo!, // ✅ BOM number
//   //       component: _selectedComponent!, // ✅ component
//   //     );
//   //
//   //     if (data != null) {
//   //       setState(() {
//   //         _cutWidthCtrl.text = "${data['cutWidth'] ?? ''}";
//   //         _cutLengthCmCtrl.text = "${data['cutLength'] ?? ''}";
//   //       });
//   //       _calculateNetWeight(); // ✅ Add this
//   //     }
//   //   } catch (e) {
//   //     _showSnack("Failed to fetch cut size: $e", Colors.red);
//   //   }
//   // }
//
//
//
//   Future _fetchCutSize() async {
//     if (_selectedBomNo == null || _selectedBomNo!.isEmpty ||
//         _selectedComponent == null || _selectedComponent!.isEmpty) {
//       debugPrint("❌ BOM or Component empty, skipping");
//       return;
//     }
//
//     debugPrint("🔍 Fetching CutSize: BOM=$_selectedBomNo, Component=$_selectedComponent");
//
//     try {
//       final data = await VisaApiService.getCutSize(
//         woNumber: _selectedBomNo!,
//         component: _selectedComponent!,
//       );
//
//       debugPrint("📦 CutSize Response: $data"); // ← YE SABSE IMPORTANT HAI
//
//       if (data != null) {
//         setState(() {
//           _cutWidthCtrl.text = "${data['cutWidth'] ?? '0'}";
//           _cutLengthCmCtrl.text = "${data['cutLength'] ?? '0'}";
//         });
//
//         // ✅ GSM load hone ka wait karo, phir calculate karo
//         await Future.delayed(const Duration(milliseconds: 300));
//
//         debugPrint("🧮 Before calc — W:${_cutWidthCtrl.text}, L:${_cutLengthCmCtrl.text}, GSM:${_fabricGsmCtrl.text}, Qty:${_cutSizeQtyCtrl.text}");
//
//         _calculateNetWeight();
//       }
//     } catch (e) {
//       debugPrint("❌ CutSize Error: $e");
//       _showSnack("Failed to fetch cut size: $e", Colors.red);
//     }
//   }
//
//   // ── Fabric Code & Batch No ─────────────────────────────────────
//   void _generateFabricCode() {
//     final code =
//         "${_fabricWidthCtrl.text}-${_baffleCtrl.text}-"
//         "${_fabricTypeCtrl.text}-${_fabricGsmCtrl.text}-"
//         "${_laminationCtrl.text}-${_colorCtrl.text}-"
//         "${_specialIdCtrl.text}-${_cutTypeCtrl.text}-${_fabricBaffleCtrl.text}";
//     setState(() {
//       _generateCodeCtrl.text = code;
//       _reqFabricCtrl.text = code;
//     });
//
//     _loadTillRemaining(); // ← YE ADD KARO
//   }
//
//   Future<void> _generateBatchNo() async {
//     _generateFabricCode();
//     if (_dateCtrl.text.isEmpty || _selectedShift == null) {
//       _showSnack("Shift select karo", Colors.orange);
//       return;
//     }
//     setState(() => _isLoading = true);
//     try {
//       final batchNo = await VisaApiService.generateBatchNo(
//         partyName: widget.production.machineno.trim(),
//         date: _dateCtrl.text.trim(),
//         loomType: "Cutting",
//         shift: _selectedShift ?? "",
//       );
//       if (batchNo != null) {
//         setState(() => _batchNoCtrl.text = batchNo);
//         _showSnack("Batch No generated: $batchNo", Colors.green);
//       } else {
//         _showSnack("Batch No generate nahi hua!", Colors.red);
//       }
//     } catch (e) {
//       _showSnack("Error: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ── Save ───────────────────────────────────────────────────────
//   // Future<void> _saveForm() async {
//   //   if (_batchNoCtrl.text.isEmpty) {
//   //     _showSnack("Pehle Batch No generate karo", Colors.orange);
//   //     return;
//   //   }
//   //   if (_selectedShift == null) {
//   //     _showSnack("Shift required hai", Colors.red);
//   //     return;
//   //   }
//   //   setState(() => _isLoading = true);
//   //   try {
//   //     final payload = _buildSavePayload();
//   //     debugPrint("SAVE PAYLOAD: $payload");
//   //     final message = await VisaApiService.saveLoomEntry(payload);
//   //     CuttingOutStockSavedList.addItem(widget.production);
//   //     _showSnack(message, Colors.green);
//   //   } catch (e) {
//   //     _showSnack("Error: $e", Colors.red);
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//
//   Future<void> _saveForm() async {
//     if (_batchNoCtrl.text.isEmpty) {
//       _showSnack("Pehle Batch No generate karo", Colors.orange);
//       return;
//     }
//
//     if (_selectedShift == null) {
//       _showSnack("Shift required hai", Colors.red);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final payload = _buildOutStockPayload();
//
//       final message = await VisaApiService.saveOutStock(payload);
//
//       if (message == "SUCCESS") {
//         CuttingOutStockSavedList.addItem(widget.production);
//
//         _showSnack("Saved Successfully ✅", Colors.green);
//       } else {
//         _showSnack(message, Colors.red);
//       }
//     } catch (e) {
//       _showSnack("Error: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ── Payload ────────────────────────────────────────────────────
//   // Map<String, dynamic> _buildSavePayload() => {
//   //   "operator": _operator2 ?? "",
//   //   "supervisor": _selectedSupervisor ?? "",
//   //   "fabricType": _fabricTypeCtrl.text,
//   //   "fabricWidth": _fabricWidthCtrl.text,
//   //   "color": _colorCtrl.text,
//   //   "laminationType": _laminationCtrl.text,
//   //   "gsm": _fabricGsmCtrl.text,
//   //   "cutType": _cutTypeCtrl.text,
//   //   "buffleType": _baffleCtrl.text,
//   //   "specialId": _specialIdCtrl.text,
//   //   "bomNo": _bomCtrl.text,
//   //   "poNo": _poNoCtrl.text,
//   //   "partyName": _partyNameCtrl.text,
//   //   "articleNo": _articleNoCtrl.text,
//   //   "grossWeight": _grossWeightCtrl.text,
//   //   "tareWeight": _tareWeightCtrl.text,
//   //   "netWeight": _rollWeightCtrl.text,
//   //   "rollLength": _rollLengthCtrl.text,
//   //   "avgWeight": _avgWeightMtrCtrl.text,
//   //   "startReading": _machineStartCtrl.text,
//   //   "endReading": _machineEndCtrl.text,
//   //   "cutLength": _cutLengthCtrl.text,
//   //   "cutWidth": _cutWidthCtrl.text,
//   //   "cutLengthCm": _cutLengthCmCtrl.text,
//   //   "cutSizeQty": _cutSizeQtyCtrl.text,
//   //   "netWt": _netWtCtrl.text,
//   //   "wastage": _wastageCtrl.text,
//   //   "tillRem": _tillRemCtrl.text,
//   //   "use": _useCtrl.text,
//   //   "finalRem": _finalRemCtrl.text,
//   //   "requiredFabric": _reqFabricCtrl.text,
//   //   "reqQtyKg": _reqQtyKgCtrl.text,
//   //   "reqQtyMtr": _reqQtyMtrCtrl.text,
//   //   "shift": _selectedShift,
//   //   "batchNo": _batchNoCtrl.text,
//   //   "generateCode": _generateCodeCtrl.text,
//   //   "remark": _remarkCtrl.text,
//   //   "rollEntry": "CUTTING",
//   //   "plant": "FIBC",
//   //   "productionType": "FIBC",
//   //   "department": widget.production.department,
//   //   "barcode": widget.production.barcode,
//   //   "workOrderNo": widget.production.workorderno,
//   //   "buffle": widget.production.buffle,
//   // };
//
//   Map<String, dynamic> _buildOutStockPayload() {
//     return {
//       "req": "OUTSTOCK",
//       "holdRoll": "NO",
//       "tillRem": _tillRemCtrl.text,
//       "sid": widget.production.sid, // 🔥 important
//       "Operator2": _operator2 ?? "",
//       "Party": widget.production.partyname,
//
//       "generatedCode": _generateCodeCtrl.text,
//       "avgWeight": _avgWeightMtrCtrl.text,
//
//       "supervisor": _selectedSupervisor ?? "",
//       "operator": _operator2 ?? "",
//
//       "fabricType": _fabricTypeCtrl.text,
//       "fabricConstruction": _fabricBaffleCtrl.text,
//       "fabricWidth": _fabricWidthCtrl.text,
//       "color": _colorCtrl.text,
//       "gsm": _fabricGsmCtrl.text,
//       "laminationType": _laminationCtrl.text,
//       "cutType": _cutTypeCtrl.text,
//       // "cutType": _fabricBaffleCtrl.text,
//
//       // "bomNo": _bomCtrl.text,
//       "bomNo": _componentCtrl.text,
//
//       // "partyName": _partyNameCtrl.text,
//       "partyName": _bomCtrl.text,
//
//       "rollWeight": double.tryParse(_rollWeightCtrl.text) ?? 0,
//       "rollLength": double.tryParse(_rollLengthCtrl.text) ?? 0,
//
//       "department": "CUTTING",
//       "plant": "FIBC",
//
//       // "requiredQtyKg": _reqQtyKgCtrl.text,
//       // "requiredQtyKg":  widget.production.requiredNetWeight,
//       // "requiredQtyMtr": _reqQtyMtrCtrl.text,
//       // "requiredQtyMtr": widget.production.requiredQtyMtr,
//       "requiredQtyKg": widget.production.requiredNetWeight.toString(),
//       "requiredQtyMtr": widget.production.requiredQtyMtr.toString(),
//
//       "weekNo": _tareWeightCtrl.text,
//
//       "machine": widget.production.machine,
//       "machineNo": widget.production.machineno,
//
//       // "modelNo": widget.production.modelno,
//       "modelNo": _cutSizeQtyCtrl.text,
//
//       "jobWork": _grossWeightCtrl.text,
//       // "purchaseOrder": _poNoCtrl.text,
//       "purchaseOrder": _articleNoCtrl.text,
//
//       "shift": _selectedShift ?? "",
//
//       "cutLength": _cutLengthCtrl.text,
//       "cutQty": _cutSizeQtyCtrl.text,
//       "finalRem": _finalRemCtrl.text,
//
//       "USE": _useCtrl.text,
//       "wastage": _wastageCtrl.text,
//       "netWt": _netWtCtrl.text,
//       "cutWidth": _cutWidthCtrl.text,
//
//       "isNormal": false,
//       "isCutting": true,
//
//       "items": [
//         {
//           "isChecked": false,
//           "batchNo": widget.production.srno,
//           "storeValue": widget.production.srno,
//         },
//       ],
//     };
//   }
//
//   void _showSnack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
//   }
//
//   // ════════════════════════════════════════════════════════════════
//   //  BUILD
//   // ════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _surface,
//       appBar: _buildAppBar(),
//       body: Form(
//         key: _formKey,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final pad = constraints.maxWidth > 600 ? 20.0 : 14.0;
//             return ListView(
//               padding: const EdgeInsets.all(14),
//               children: [_buildBody()],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     final now = DateTime.now();
//     final d =
//         "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//     return AppBar(
//       backgroundColor: C.appBar1,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//         onPressed: () => Navigator.maybePop(context),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.production.machineno,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//           ),
//           Text(d, style: const TextStyle(fontSize: 11, color: Colors.white70)),
//         ],
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 12),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.18),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.content_cut_rounded,
//                 color: Colors.white70,
//                 size: 13,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 widget.production.department,
//                 style: const TextStyle(color: Colors.white, fontSize: 11),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBody() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Job Info ──────────────────────────────────────────────
//         _sectionLabel("Job Info"),
//         _card([
//           _row([
//             _field("Article No", _articleNoCtrl, readOnly: true),
//             _field("Purchase Order No", _poNoCtrl, readOnly: true),
//           ]),
//           _row([
//             _isLoadingBomComponents
//                 ? _loadingLabelBox("BOM")
//                 : _genericDropdownStr(
//                     label: "BOM",
//                     items: _bomNumbers,
//                     value: _selectedBomNo,
//                     onChanged: (v) {
//                       setState(() {
//                         _selectedBomNo = v;
//                         _bomCtrl.text = v ?? '';
//                       });
//                       _fetchCutSize();
//                     },
//                   ),
//             _staticDropdown(
//               label: "Shift",
//               items: _shiftOptions,
//               value: _selectedShift,
//               onChanged: (v) => setState(() => _selectedShift = v),
//             ),
//           ]),
//         ]),
//         _gap,
//
//         // ── Scheduling ────────────────────────────────────────────
//         _sectionLabel("Scheduling"),
//         _card([
//           _row([
//             _field("Date", _dateCtrl, readOnly: true),
//             _field("Time", _timeCtrl, readOnly: true),
//           ]),
//           _row([
//             _genericDropdown(
//               label: "Supervisor",
//               items: _supervisorList.map((e) => e.label).toList(),
//               value: _selectedSupervisor,
//               isLoading: _isLoadingSupervisor,
//               onChanged: (v) => setState(() => _selectedSupervisor = v),
//             ),
//             _genericDropdown(
//               label: "Operator",
//               items: _operatorList.map((e) => e.label).toList(),
//               value: _operator2,
//               isLoading: _isLoadingOperator,
//               onChanged: (v) => setState(() => _operator2 = v),
//             ),
//           ]),
//         ]),
//         _gap,
//
//         // ── Fabric Specs ──────────────────────────────────────────
//         _sectionLabel("Fabric Specs"),
//         _card([
//           _row([
//             _field("Fabric Type / Use", _fabricTypeCtrl, readOnly: true),
//             // _staticDropdown(
//             //   label: "Fabric Construction",
//             //   items: const ['F00', '000'],
//             //   value: _baffleCtrl.text.isNotEmpty ? _baffleCtrl.text : null,
//             //   onChanged: (v) => setState(() => _baffleCtrl.text = v ?? ''),
//             // ),
//             _field("FabricConstruction", _fabricBaffleCtrl, readOnly: true),
//           ]),
//           _row([
//             _field("Color", _colorCtrl, readOnly: true),
//             _isLoadingBomComponents
//                 ? _loadingLabelBox("Component")
//                 : _genericDropdownStr(
//                     label: "Component",
//                     items: _componentList,
//                     value: _selectedComponent,
//                     onChanged: (v) {
//                       setState(() {
//                         _selectedComponent = v;
//                         _componentCtrl.text = v ?? '';
//                       });
//                       _fetchCutSize();
//                     },
//                   ),
//           ]),
//           _row([
//             _isLoadingGsm
//                 ? _loadingLabelBox("Fabric GSM")
//                 : _genericDropdownStr(
//                     label: "Fabric GSM",
//                     items: _gsmList,
//                     value: _selectedGsm,
//                     onChanged: (v) {
//                       setState(() {
//                         _selectedGsm = v;
//                         _fabricGsmCtrl.text = v ?? '';
//                       });
//
//                       _calculateNetWeight();
//                     },
//                   ),
//             _isLoadingFabricWidth
//                 ? _loadingLabelBox("Fabric Width")
//                 : _genericDropdownStr(
//                     label: "Fabric Width (cm)",
//                     items: _fabricWidthList,
//                     value: _selectedFabricWidth,
//                     onChanged: (v) => setState(() {
//                       _selectedFabricWidth = v;
//                       _fabricWidthCtrl.text = v ?? '';
//                     }),
//                   ),
//           ]),
//           _row([
//             _field("Baffle / Type", _fabricBaffleCtrl, readOnly: true),
//             _staticDropdown(
//               label: "Lamination Type",
//               items: const ['L', 'UL', 'SL'],
//               value: _laminationCtrl.text.isNotEmpty
//                   ? _laminationCtrl.text
//                   : null,
//               onChanged: (v) => setState(() => _laminationCtrl.text = v ?? ''),
//             ),
//           ]),
//           _row([
//             _field("Cut Type", _cutTypeCtrl, readOnly: true),
//             _field("Batch No", _batchNoCtrl),
//           ]),
//         ]),
//         _gap,
//
//         // ── Weight & Output ───────────────────────────────────────
//         _sectionLabel("Weight & Output"),
//         _card([
//           _row([
//             _field(
//               "Gross Weight (Kg)",
//               _grossWeightCtrl,
//               inputType: TextInputType.number,
//             ),
//             _field(
//               "Tare Weight (Kg)",
//               _tareWeightCtrl,
//               inputType: TextInputType.number,
//             ),
//           ]),
//           _row([
//             _field("Roll Weight (Kg)", _rollWeightCtrl, readOnly: true),
//             _field(
//               "Roll Length (Mtr)",
//               _rollLengthCtrl,
//               inputType: TextInputType.number,
//             ),
//           ]),
//           _row([
//             _field("Avg Weight / Mtr (g)", _avgWeightMtrCtrl, readOnly: true),
//           ]),
//           const Divider(height: 20, thickness: 0.5),
//           // ✅ SAHI — ye karo _buildBody() mein:
//           _row([
//             _field(
//               "Cut Width (cm)",
//               _cutWidthCtrl,        // ← swap karo
//               inputType: TextInputType.number,
//             ),
//             _field(
//               "Cut Length (cm)",
//               _cutLengthCmCtrl,     // ← swap karo
//               inputType: TextInputType.number,
//             ),
//           ]),
//           _row([
//             _field(
//               "Cut Size Qty",
//               _cutSizeQtyCtrl,
//               inputType: TextInputType.number,
//             ),
//             // _field("Net Wt", _netWtCtrl, inputType: TextInputType.number),
//             _field("Net Wt", _netWtCtrl, readOnly: true),
//             _field("Wastage", _wastageCtrl, inputType: TextInputType.number),
//           ]),
//           _row([
//             _field("Till Rem.", _tillRemCtrl, readOnly: true),
//             _field("USE", _useCtrl, readOnly: true),
//             _field("Final Rem.", _finalRemCtrl, readOnly: true),
//           ]),
//         ]),
//         _gap,
//
//         // ── Remarks & Code ────────────────────────────────────────
//         _sectionLabel("Remarks & Code"),
//         _card([
//           _row([_field("Remark", _remarkCtrl, maxLines: 2)]),
//           const SizedBox(height: 4),
//           _field("Generated Fabric Code", _generateCodeCtrl, readOnly: true),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: _isLoading ? null : _generateBatchNo,
//               icon: _isLoading
//                   ? const SizedBox(
//                       width: 14,
//                       height: 14,
//                       child: CircularProgressIndicator(
//                         color: C.appBar3,
//                         strokeWidth: 1.5,
//                       ),
//                     )
//                   : const Icon(Icons.qr_code_2_rounded, size: 16),
//               label: const Text("Generate Fabric Code & Batch No"),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: C.primary,
//                 side: const BorderSide(color: C.secondaryDark),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         ]),
//         _gap,
//
//         _buildActionBar(),
//         const SizedBox(height: 24),
//       ],
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════
//   //  LAYOUT HELPERS
//   // ══════════════════════════════════════════════════════════════
//   Widget _row(List<Widget> children) {
//     final expanded =
//         children
//             .expand((w) => [Expanded(child: w), const SizedBox(width: 8)])
//             .toList()
//           ..removeLast();
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: expanded,
//     );
//   }
//
//   Widget _sectionLabel(String title) => Padding(
//     padding: const EdgeInsets.only(bottom: 6, left: 2),
//     child: Text(
//       title.toUpperCase(),
//       style: const TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w700,
//         color: _labelColor,
//         letterSpacing: 1.2,
//       ),
//     ),
//   );
//
//   Widget _card(List<Widget> children) => Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: _border),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.03),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: children.expand((w) => [w, const SizedBox(height: 10)]).toList()
//         ..removeLast(),
//     ),
//   );
//
//   static const _gap = SizedBox(height: 14);
//
//   void _calculateRollWeight() {
//     final gross = double.tryParse(_grossWeightCtrl.text) ?? 0;
//     final tare = double.tryParse(_tareWeightCtrl.text) ?? 0;
//
//     final rollWeight = (gross - tare).clamp(0, double.infinity);
//
//     _rollWeightCtrl.text = rollWeight.toStringAsFixed(2);
//
//     // ✅ yaha se avg weight update hogi
//     _calculateAvgWeight();
//
//     // ✅ API bhi refresh
//     _loadTillRemaining();
//   }
//
//   void _calculateAvgWeight() {
//     final weight = double.tryParse(_rollWeightCtrl.text) ?? 0;
//     final length = double.tryParse(_rollLengthCtrl.text) ?? 0;
//
//     if (length > 0) {
//       _avgWeightMtrCtrl.text = (weight * 1000 / length).toStringAsFixed(2);
//     } else {
//       _avgWeightMtrCtrl.text = '0.00';
//     }
//   }
//
//   Future<void> _loadTillRemaining() async {
//     final code = widget.production.srno; // ✅ srno hi use karo
//     final rollWeight = double.tryParse(_rollWeightCtrl.text)?.toInt() ?? 0;
//
//     // print("👉 Calling API with:");
//     // print("SRNO 👉 $code");
//     // print("RollWeight 👉 $rollWeight");
//
//     if (code.isEmpty) {
//       print("❌ SRNO empty, API not called");
//       return;
//     }
//
//     try {
//       final result = await VisaApiService.getRemainingWeight(
//         code: code,
//         rollWeight: rollWeight,
//       );
//
//       if (result != null) {
//         final value = result.remaining.toStringAsFixed(2);
//
//         _tillRemCtrl.text = value;
//         _calculateUseAndFinalRem();
//
//         print("✅ Till Remaining 👉 $value");
//       } else {
//         print("❌ API returned null");
//       }
//     } catch (e) {
//       print("❌ API Error 👉 $e");
//     }
//   }
//
//   Widget _field(
//     String label,
//     TextEditingController ctrl, {
//     bool readOnly = false,
//     bool highlight = false,
//     TextInputType inputType = TextInputType.text,
//     int maxLines = 1,
//   }) {
//     final borderColor = highlight
//         ? C.brand700
//         : readOnly
//         ? _border
//         : const Color(0xFFBCC8E8);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: _labelColor,
//           ),
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: ctrl,
//           readOnly: readOnly,
//           maxLines: maxLines,
//           keyboardType: inputType,
//           style: TextStyle(
//             fontSize: 13,
//             color: readOnly ? const Color(0xFF8A97B5) : const Color(0xFF1A2340),
//             fontWeight: FontWeight.w500,
//           ),
//           decoration: InputDecoration(
//             isDense: true,
//             filled: true,
//             fillColor: readOnly ? _readOnlyBg : _inputBg,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: borderColor),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                 color: borderColor,
//                 width: highlight ? 1.5 : 1.0,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                 color: readOnly ? _border : C.secondaryDark,
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _staticDropdown({
//     required String label,
//     required List<String> items,
//     required String? value,
//     required ValueChanged<String?> onChanged,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: _labelColor,
//         ),
//       ),
//       const SizedBox(height: 4),
//       _dropdownBox(
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: value,
//             isExpanded: true,
//             isDense: true,
//             hint: const Text(
//               "Select",
//               style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
//             ),
//             items: items
//                 .map(
//                   (s) => DropdownMenuItem(
//                     value: s,
//                     child: Text(s, style: const TextStyle(fontSize: 13)),
//                   ),
//                 )
//                 .toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//     ],
//   );
//
//   Widget _genericDropdown({
//     required String label,
//     required List<String> items,
//     required String? value,
//     required bool isLoading,
//     required ValueChanged<String?> onChanged,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: _labelColor,
//         ),
//       ),
//       const SizedBox(height: 4),
//       _dropdownBox(
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: value,
//             isExpanded: true,
//             isDense: true,
//             hint: const Text(
//               "Select",
//               style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
//             ),
//             items: items
//                 .map(
//                   (e) => DropdownMenuItem(
//                     value: e,
//                     child: Text(e, style: const TextStyle(fontSize: 13)),
//                   ),
//                 )
//                 .toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//     ],
//   );
//
//   Widget _genericDropdownStr({
//     required String label,
//     required List<String> items,
//     required String? value,
//     required ValueChanged<String?> onChanged,
//   }) {
//     // Empty/null items filter karo
//     final cleanItems = items.where((e) => e.trim().isNotEmpty).toList();
//
//     final effectiveValue = cleanItems.firstWhere(
//       (item) => item.trim() == value?.trim(),
//       orElse: () => '',
//     );
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: _labelColor,
//           ),
//         ),
//         const SizedBox(height: 4),
//         _dropdownBox(
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: effectiveValue.isNotEmpty ? effectiveValue : null,
//               isExpanded: true,
//               isDense: true,
//               hint: const Text(
//                 "Select",
//                 style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
//               ),
//               items:
//                   cleanItems // ← cleanItems use karo
//                       .map(
//                         (s) => DropdownMenuItem(
//                           value: s,
//                           child: Text(s, style: const TextStyle(fontSize: 13)),
//                         ),
//                       )
//                       .toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _dropdownBox({required Widget child}) => Container(
//     height: 42,
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//     decoration: BoxDecoration(
//       color: _inputBg,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: const Color(0xFFBCC8E8)),
//     ),
//     child: child,
//   );
//
//   Widget _loadingBox() => Container(
//     height: 42,
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     decoration: BoxDecoration(
//       color: _readOnlyBg,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: _border),
//     ),
//     child: const Row(
//       children: [
//         SizedBox(
//           width: 13,
//           height: 13,
//           child: CircularProgressIndicator(color: C.appBar3, strokeWidth: 1.5),
//         ),
//         SizedBox(width: 8),
//         Text("Loading...", style: TextStyle(fontSize: 12, color: _labelColor)),
//       ],
//     ),
//   );
//
//   Widget _loadingLabelBox(String label) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: _labelColor,
//         ),
//       ),
//       const SizedBox(height: 4),
//       _loadingBox(),
//     ],
//   );
//
//   Widget _buildActionBar() => Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     children: [
//       _actionBtn(
//         "Save",
//         Icons.check_rounded,
//         C.primary,
//         _saveForm,
//         loading: _isLoading,
//       ),
//       // _actionBtn("Update", Icons.edit_rounded, const Color(0xFF00897B), () {}),
//       // _actionBtn(
//       //   "Clear",
//       //   Icons.refresh_rounded,
//       //   const Color(0xFFF59E0B),
//       //   _clearForm,
//       // ),
//       _actionBtn(
//         "Exit",
//         Icons.logout_rounded,
//         const Color(0xFFEF4444),
//         () => Navigator.maybePop(context),
//       ),
//     ],
//   );
//
//   Widget _actionBtn(
//     String label,
//     IconData icon,
//     Color color,
//     VoidCallback onTap, {
//     bool loading = false,
//   }) => SizedBox(
//     height: 40,
//     child: ElevatedButton.icon(
//       onPressed: loading ? null : onTap,
//       icon: loading
//           ? const SizedBox(
//               width: 12,
//               height: 12,
//               child: CircularProgressIndicator(
//                 strokeWidth: 1.5,
//                 color: C.appBar3,
//               ),
//             )
//           : Icon(icon, size: 15, color: Colors.white),
//       label: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         disabledBackgroundColor: color.withOpacity(0.6),
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     ),
//   );
// }
//
// class _NameValue {
//   final String label;
//   final String value;
//   const _NameValue(this.label, this.value);
// }

import 'dart:async';

import 'package:IMS/Color/Colorclass.dart';
import 'package:IMS/ScannedItem/Cutting/cutOutModelClass/ModelClassOutstock.dart';

import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:IMS/services/visa_apis/visa_api.dart';
import 'package:flutter/material.dart';

import 'OutSavedList.dart';

class CuttingOutStockForm extends StatefulWidget {
  final CuttingOutstock production;

  const CuttingOutStockForm({super.key, required this.production});

  @override
  State<CuttingOutStockForm> createState() => _CuttingOutStockFormState();
}

class _CuttingOutStockFormState extends State<CuttingOutStockForm> {

  static const _primary = Color(0xFF1A56DB);
  static const _surface = Color(0xFFF8FAFF);
  static const _border = Color(0xFFDDE3F0);
  static const _labelColor = Colors.black;
  static const _inputBg = Colors.white;
  static const _readOnlyBg = Color(0xFFF4F6FB);

  final _apiService = VisaApiService();
  final _inStockService = InStockService();
  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;
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

  List<String> _laminationList = ['L', 'UL', 'SL'];
  String? _selectedLamination;

  List<_NameValue> _operatorList = [];
  List<_NameValue> _supervisorList = [];
  String? _operator2;
  String? _selectedSupervisor;

  bool _isLoadingFabricWidth = false;
  bool _isLoadingGsm = false;
  bool _isLoadingBomComponents = false;
  bool _isLoadingOperator = false;
  bool _isLoadingSupervisor = false;
  bool _isLoading = false;

  final _partyNameCtrl = TextEditingController();
  final _poNoCtrl = TextEditingController();
  final _articleNoCtrl = TextEditingController();
  final _bomCtrl = TextEditingController();
  final _componentCtrl = TextEditingController();
  final _reqFabricCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _reqQtyKgCtrl = TextEditingController();
  final _reqQtyMtrCtrl = TextEditingController();

  final _machineStartCtrl = TextEditingController();
  final _machineEndCtrl = TextEditingController();
  final _cutLengthCtrl = TextEditingController();
  final _baffleCtrl = TextEditingController();

  final _fabricTypeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _specialIdCtrl = TextEditingController();
  final _fabricGsmCtrl = TextEditingController();
  final _fabricWidthCtrl = TextEditingController();
  final _fabricBaffleCtrl = TextEditingController();
  final _fabricConstCtrl = TextEditingController();
  final _laminationCtrl = TextEditingController();
  final _cutTypeCtrl = TextEditingController();
  final _batchNoCtrl = TextEditingController();

  final _grossWeightCtrl = TextEditingController();
  final _tareWeightCtrl = TextEditingController();
  final _rollWeightCtrl = TextEditingController();
  final _rollLengthCtrl = TextEditingController();
  final _avgWeightMtrCtrl = TextEditingController();

  // Weight & Output
  final _cutWidthCtrl = TextEditingController();
  final _cutLengthCmCtrl = TextEditingController();
  final _cutSizeQtyCtrl = TextEditingController();
  final _netWtCtrl = TextEditingController();
  final _wastageCtrl = TextEditingController();
  final _tillRemCtrl = TextEditingController();
  final _useCtrl = TextEditingController();
  final _finalRemCtrl = TextEditingController();

  final _remarkCtrl = TextEditingController();
  final _generateCodeCtrl = TextEditingController();

  // ─────────────── initState ───────────────
  @override
  void initState() {
    super.initState();
    final p = widget.production;
    final now = DateTime.now();

    // Date / Time
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}";

    // ── Pre-fill from production object ──────────────────────────
    _partyNameCtrl.text = p.partyname;
    _poNoCtrl.text = p.workorderno;
    _bomCtrl.text = p.workorderno;
    _reqFabricCtrl.text = _buildFabricCode(p);
    _generateCodeCtrl.text = _buildFabricCode(p);
    _dateCtrl.text = dateStr;
    _timeCtrl.text = timeStr;
    _reqQtyKgCtrl.text = p.requiredNetWeight.toString();
    _reqQtyMtrCtrl.text = p.requiredQtyMtr.toString();

    _baffleCtrl.text = p.cuttype;
    _fabricTypeCtrl.text = p.typeuse;
    _colorCtrl.text = p.color;
    _fabricBaffleCtrl.text = p.buffle;
    _fabricConstCtrl.text = p.fabricwidth;
    _cutTypeCtrl.text = p.sid;

    _grossWeightCtrl.text = p.jobwork.toString();
    _tareWeightCtrl.text = p.weekno.toString();
    _rollLengthCtrl.text = p.quantity.toString();
    _rollWeightCtrl.text = p.netwt.toStringAsFixed(2);
    _avgWeightMtrCtrl.text = p.requiredNetWeight.toStringAsFixed(2);

    _cutLengthCtrl.text = '0.00';

    // Pre-select dropdowns (validated after list loads)
    _selectedGsm = p.gsm;
    _selectedFabricWidth = p.fabricwidth;

    // ── Listeners ──────────────────────────────────────────────
    _machineEndCtrl.addListener(_calculateCutLength);

    _grossWeightCtrl.addListener(_calculateRollWeight);
    _tareWeightCtrl.addListener(_calculateRollWeight);

    _rollWeightCtrl.addListener(_onRollWeightChanged);
    _rollLengthCtrl.addListener(_calculateAvgWeight);

    _cutWidthCtrl.addListener(_calculateNetWeight);
    _cutLengthCmCtrl.addListener(_calculateNetWeight);
    _cutSizeQtyCtrl.addListener(_calculateNetWeight);
    _fabricGsmCtrl.addListener(_calculateNetWeight);

    _wastageCtrl.addListener(_calculateUseAndFinalRem);
    _tillRemCtrl.addListener(_calculateUseAndFinalRem);

    _initialLoad();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
      _fabricConstCtrl,
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
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  //  INITIAL LOAD
  // ════════════════════════════════════════════════════════════════
  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);

    await _loadOperators();
    await _loadSupervisors();

    // Article → BOM → CutSize chain
    await _fetchArticleAndThenBom();

    // These can run after article chain
    await _loadGsm();
    await _loadFabricWidth();

    // Till remaining based on pre-filled roll weight
    await _loadTillRemaining();
    _calculateAvgWeight();

    setState(() => _isLoading = false);
  }

  // ════════════════════════════════════════════════════════════════
  //  CALCULATIONS
  // ════════════════════════════════════════════════════════════════
  void _calculateCutLength() {
    final start = double.tryParse(_machineStartCtrl.text) ?? 0;
    final end = double.tryParse(_machineEndCtrl.text) ?? 0;
    _cutLengthCtrl.text = (end - start)
        .clamp(0, double.infinity)
        .toStringAsFixed(2);
  }

  void _calculateRollWeight() {
    final gross = double.tryParse(_grossWeightCtrl.text) ?? 0;
    final tare = double.tryParse(_tareWeightCtrl.text) ?? 0;
    final rollWeight = (gross - tare).clamp(0, double.infinity);
    _rollWeightCtrl.text = rollWeight.toStringAsFixed(2);
    _calculateAvgWeight();
    _loadTillRemaining();
  }

  void _calculateAvgWeight() {
    final weight = double.tryParse(_rollWeightCtrl.text) ?? 0;
    final length = double.tryParse(_rollLengthCtrl.text) ?? 0;
    setState(() {
      _avgWeightMtrCtrl.text = length > 0
          ? (weight * 1000 / length).toStringAsFixed(2)
          : '0.00';
    });
  }

  void _calculateNetWeight() {
    final cutWidth = double.tryParse(_cutWidthCtrl.text.trim()) ?? 0.0;
    final cutLength = double.tryParse(_cutLengthCmCtrl.text.trim()) ?? 0.0;
    final gsm = double.tryParse(_fabricGsmCtrl.text.trim()) ?? 0.0;
    final qty = double.tryParse(_cutSizeQtyCtrl.text.trim()) ?? 0.0;

    if (cutWidth <= 0 || cutLength <= 0 || gsm <= 0 || qty <= 0) {
      _netWtCtrl.text = '0.00';
      return;
    }

    final baffle = _fabricBaffleCtrl.text.trim().toUpperCase();
    final isDoubleLayer = baffle == 'CRF' || baffle == 'C00';

    double netWt = (cutWidth * cutLength * gsm * qty) / 10000000;
    if (isDoubleLayer) netWt *= 2;

    _netWtCtrl.text = netWt.toStringAsFixed(2);
    _calculateUseAndFinalRem();
  }

  void _calculateUseAndFinalRem() {
    final net = double.tryParse(_netWtCtrl.text) ?? 0;
    final wastage = double.tryParse(_wastageCtrl.text) ?? 0;
    final tillRem = double.tryParse(_tillRemCtrl.text) ?? 0;

    final use = net + wastage;
    double finalRem = (tillRem - use).clamp(0, double.infinity);

    _useCtrl.text = use.toStringAsFixed(2);
    _finalRemCtrl.text = finalRem.toStringAsFixed(2);
  }

  // Debounced roll-weight listener → avoids too many API calls while typing
  void _onRollWeightChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadTillRemaining);
  }

  // ════════════════════════════════════════════════════════════════
  //  API CALLS
  // ════════════════════════════════════════════════════════════════
  Future<void> _loadFabricWidth() async {
    setState(() => _isLoadingFabricWidth = true);
    final data = await VisaApiService.getGsmOrFabricWidth(type: "FW");
    setState(() {
      _fabricWidthList = data;
      if (!data.contains(_selectedFabricWidth)) {
        _selectedFabricWidth = data.isNotEmpty ? data.first : null;
      }
      _fabricWidthCtrl.text = _selectedFabricWidth ?? '';
      _isLoadingFabricWidth = false;
    });
  }

  Future<void> _loadGsm() async {
    setState(() => _isLoadingGsm = true);
    final data = await VisaApiService.getGsmOrFabricWidth(type: "GSM");
    setState(() {
      _gsmList = data;
      if (!data.contains(_selectedGsm)) {
        _selectedGsm = data.isNotEmpty ? data.first : null;
      }
      _fabricGsmCtrl.text = _selectedGsm ?? '';
      _isLoadingGsm = false;
    });
    _calculateNetWeight();
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

  Future<void> _fetchArticleAndThenBom() async {
    final sidInt = int.tryParse(widget.production.srno);
    if (sidInt == null) {
      await _loadBomAndComponents(articleOverride: widget.production.modelno);
      return;
    }
    try {
      final result = await _apiService.getArticleNo(sidInt);
      setState(() => _articleNoCtrl.text = result ?? widget.production.modelno);
      await _loadBomAndComponents(
        articleOverride: result ?? widget.production.modelno,
      );
    } catch (e) {
      setState(() => _articleNoCtrl.text = widget.production.modelno);
      _showSnack("Article fetch failed: $e", Colors.red);
      await _loadBomAndComponents(articleOverride: widget.production.sid);
    }
  }

  Future<void> _loadBomAndComponents({String? articleOverride}) async {
    setState(() => _isLoadingBomComponents = true);
    try {
      final data = await VisaApiService.getBomAndComponents(
        po: widget.production.workorderno,
        article: articleOverride ?? _articleNoCtrl.text.trim(),
      );
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
      // ❌ REMOVE await
      Future.microtask(() => _fetchCutSize());
    } catch (e) {
      setState(() => _isLoadingBomComponents = false);
      _showSnack("BOM fetch failed: $e", Colors.red);
    }
  }

  Future<void> _fetchCutSize() async {
    if (_selectedBomNo == null ||
        _selectedBomNo!.isEmpty ||
        _selectedComponent == null ||
        _selectedComponent!.isEmpty)
      return;

    try {
      final data = await VisaApiService.getCutSize(
        woNumber: _selectedBomNo!,
        component: _selectedComponent!,
      );
      if (data != null) {
        setState(() {
          _cutWidthCtrl.text = "${data['cutWidth'] ?? '0'}";
          _cutLengthCmCtrl.text = "${data['cutLength'] ?? '0'}";
        });
        await Future.delayed(const Duration(milliseconds: 300));
        _calculateNetWeight();
      }
    } catch (e) {
      _showSnack("CutSize fetch failed: $e", Colors.red);
    }
  }

  Future<void> _loadTillRemaining() async {
    final code = widget.production.srno;
    final rollWeight = double.tryParse(_rollWeightCtrl.text)?.toInt() ?? 0;

    if (code.isEmpty) return;

    try {
      final result = await VisaApiService.getRemainingWeight(
        code: code,
        rollWeight: rollWeight,
      );
      if (result != null) {
        setState(() => _tillRemCtrl.text = result.remaining.toStringAsFixed(2));
        _calculateUseAndFinalRem();
      }
    } catch (e) {
      debugPrint("TillRemaining error: $e");
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  FABRIC CODE & BATCH NO
  // ════════════════════════════════════════════════════════════════
  String _buildFabricCode(CuttingOutstock p) =>
      "${p.fabricwidth}-${p.machineno}-${p.typeuse}-${p.gsm}--${p.color}-${p.cuttype}-";

  void _generateFabricCode() {
    final code =
        "${_fabricWidthCtrl.text}-"
            "${_fabricBaffleCtrl.text}-"
        "${_fabricTypeCtrl.text}-"
        "${_fabricGsmCtrl.text}-"
        "${_laminationCtrl.text}-"
        "${_colorCtrl.text}-"
        "${_specialIdCtrl.text}-"
        "${_cutTypeCtrl.text}-"
            "${_baffleCtrl.text}";

    setState(() {
      _generateCodeCtrl.text = code;
      _reqFabricCtrl.text = code;
    });
    _loadTillRemaining();
  }

  Future<void> _generateBatchNo() async {
    _generateFabricCode();

    if (_selectedShift == null) {
      _showSnack("Shift select karo", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      print("partyName: ${widget.production.machineno.trim()}");
      print("date: ${_dateCtrl.text.trim()}");
      print("loomType: Cutting");
      print("shift: ${_selectedShift ?? ""}");
      final batchNo = await VisaApiService.generateBatchNo(
        partyName: widget.production.machineno.trim(),
        date: _dateCtrl.text.trim(),
        loomType: "Cutting",
        shift: _selectedShift ?? "",
      );
      if (batchNo != null) {
        setState(() => _batchNoCtrl.text = batchNo);
        _showSnack("Batch No generated: $batchNo", Colors.green);
      } else {
        _showSnack("Batch No generate nahi hua!", Colors.red);
      }
    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  SAVE
  // ════════════════════════════════════════════════════════════════
  Future<void> _saveForm() async {
    if (_batchNoCtrl.text.isEmpty) {
      _showSnack("Generate Batch No", Colors.orange);
      return;
    }
    if (_selectedShift == null) {
      _showSnack("Select Shift ", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = _buildOutStockPayload();
      debugPrint("SAVE PAYLOAD: $payload");

      final message = await VisaApiService.saveOutStock(payload);

      if (message == "SUCCESS") {
        CuttingOutStockSavedList.addItem(widget.production);
        _showSnack("Saved Successfully ✅", Colors.green);
      } else {
        _showSnack(message, Colors.red);
      }
    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  PAYLOAD
  // ════════════════════════════════════════════════════════════════
  Map<String, dynamic> _buildOutStockPayload() => {
    "req": "OUTSTOCK",
    "holdRoll": "NO",
    "tillRem": _tillRemCtrl.text,
    "sid": widget.production.sid,
    "Operator2": _operator2 ?? "",
    "Party": widget.production.partyname,
    "generatedCode": _generateCodeCtrl.text,
    "avgWeight": _avgWeightMtrCtrl.text,
    "supervisor": _selectedSupervisor ?? "",
    "operator": _operator2 ?? "",
    "fabricType": _fabricTypeCtrl.text,
    "fabricConstruction": _fabricBaffleCtrl.text,
    "fabricWidth": _fabricWidthCtrl.text,
    "color": _colorCtrl.text,
    "gsm": _fabricGsmCtrl.text,
    "laminationType": _laminationCtrl.text,
    "cutType": _cutTypeCtrl.text,
    "bomNo": _componentCtrl.text,
    "partyName": _bomCtrl.text,
    "rollWeight": double.tryParse(_rollWeightCtrl.text) ?? 0,
    "rollLength": double.tryParse(_rollLengthCtrl.text) ?? 0,
    "department": "CUTTING",
    "plant": "FIBC",
    "requiredQtyKg": widget.production.requiredNetWeight.toString(),
    "requiredQtyMtr": widget.production.requiredQtyMtr.toString(),
    "weekNo": _tareWeightCtrl.text,
    "machine": widget.production.machine,
    "machineNo": widget.production.machineno,
    "wastage": _wastageCtrl.text,
    "modelNo": _cutSizeQtyCtrl.text,
    "jobWork": _grossWeightCtrl.text,
    "purchaseOrder": _articleNoCtrl.text,
    "shift": _selectedShift ?? "",
    "cutLength": _cutLengthCtrl.text,
    "cutQty": _cutSizeQtyCtrl.text,
    "finalRem": _finalRemCtrl.text,
    "USE": _useCtrl.text,
    "netWt": _netWtCtrl.text,
    "cutWidth": _cutWidthCtrl.text,
    "isNormal": false,
    "isCutting": true,
    "items": [
      {
        "isChecked": false,
        "batchNo": widget.production.srno,
        "storeValue": widget.production.srno,
      },
    ],
  };

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
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 20.0 : 14.0,
                vertical: 16,
              ),
              child: _buildBody(),
            );
          },
        ),
      ),
    );
  }

  // ─────────────── AppBar ───────────────
  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final d =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
    return AppBar(
      backgroundColor: C.appBar1,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.production.machineno,
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

  // ─────────────── Body ───────────────
  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Job Info ─────────────────────────────────────────────
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

        // ── Scheduling ───────────────────────────────────────────
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

        // ── Fabric Specs ─────────────────────────────────────────
        _sectionLabel("Fabric Specs"),
        _card([
          _row([
            _field("Fabric Type / Use", _fabricTypeCtrl, readOnly: true),
            _field("Fabric Construction", _baffleCtrl, ),
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
                      _calculateNetWeight();
                    },
                  ),
            _isLoadingFabricWidth
                ? _loadingLabelBox("Fabric Width")
                : _genericDropdownStr(
                    label: "Fabric Width (cm)",
                    items: _fabricWidthList,
                    value: _selectedFabricWidth,
                    onChanged: (v) => setState(() {
                      _selectedFabricWidth = v;
                      _fabricWidthCtrl.text = v ?? '';
                    }),
                  ),
          ]),
          _row([
            _field("Baffle / Type", _fabricBaffleCtrl, readOnly: true),
            _staticDropdown(
              label: "Lamination Type",
              items: _laminationList,
              value: _laminationCtrl.text.isNotEmpty
                  ? _laminationCtrl.text
                  : null,
              onChanged: (v) => setState(() => _laminationCtrl.text = v ?? ''),
            ),
          ]),
          _row([
            _field("Cut Type", _cutTypeCtrl, readOnly: true),
            _field("Batch No", _batchNoCtrl),
          ]),
        ]),
        _gap,

        // ── Weight & Output ──────────────────────────────────────
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
          _row([
            _field("Avg Weight / Mtr (g)", _avgWeightMtrCtrl, readOnly: true),
          ]),
          const Divider(height: 20, thickness: 0.5),
          _row([
            _field(
              "Cut Width (cm)",
              _cutWidthCtrl,
              inputType: TextInputType.number,
            ),
            _field(
              "Cut Length (cm)",
              _cutLengthCmCtrl,
              inputType: TextInputType.number,
            ),
          ]),
          _row([
            _field(
              "Cut Size Qty",
              _cutSizeQtyCtrl,
              inputType: TextInputType.number,
            ),
            _field("Net Wt", _useCtrl, readOnly: true),
            _field("Wastage", _wastageCtrl, inputType: TextInputType.number),
          ]),
          _row([
            _field("Till Rem.", _tillRemCtrl, readOnly: true),
            _field("USE", _useCtrl, readOnly: true),
            _field("Final Rem.", _finalRemCtrl, readOnly: true),
          ]),
        ]),
        _gap,

        // ── Remarks & Code ───────────────────────────────────────
        _sectionLabel("Remarks & Code"),
        _card([
          _row([_field("Remark", _remarkCtrl, maxLines: 2)]),
          const SizedBox(height: 4),
          _field("Generated Fabric Code", _generateCodeCtrl, readOnly: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _generateBatchNo,
              icon: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: C.appBar3,
                        strokeWidth: 1.5,
                      ),
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

        _buildActionBar(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  LAYOUT HELPERS
  // ════════════════════════════════════════════════════════════════
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

  // ─────────────── Field ───────────────
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

  // ─────────────── Static Dropdown ───────────────
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

  // ─────────────── Generic Dropdown (with loading) ───────────────
  Widget _genericDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
  }) {
    final cleanItems = items.toSet().toList()
      ..removeWhere((e) => e.trim().isEmpty);
    final safeValue = cleanItems.contains(value) ? value : null;

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
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBCC8E8)),
          ),
          child: DropdownButtonHideUnderline(
            child: isLoading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: C.appBar3,
                          strokeWidth: 1.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Loading...", style: TextStyle(fontSize: 12)),
                    ],
                  )
                : DropdownButton<String>(
                    value: safeValue,
                    isExpanded: true,
                    isDense: true,
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

  // ─────────────── Generic Dropdown Str ───────────────
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
                  menuMaxHeight: constraints.maxHeight * 0.2,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    "Select",
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A97B5)),
                  ),
                  items: cleanItems
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              s,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
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
      },
    );
  }

  // ─────────────── Dropdown Box ───────────────
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

  // ─────────────── Loading Box ───────────────
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
          child: CircularProgressIndicator(color: C.appBar3, strokeWidth: 1.5),
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

  // ─────────────── Action Bar ───────────────
  // ─────────────── Action Bar ───────────────
  Widget _buildActionBar() => Wrap(
    spacing: 8, runSpacing: 8,
    children: [
      _actionBtn("Save",  Icons.check_rounded,  _primary,             _saveForm, loading: _isLoading),
      _actionBtn("Exit",  Icons.logout_rounded,  const Color(0xFFEF4444), () => Navigator.maybePop(context)),
    ],
  );

  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onTap,
      {bool loading = false}
      ) =>
      SizedBox(
        height: 40,
        child: ElevatedButton.icon(
          onPressed: loading ? null : onTap,
          icon: loading
              ? const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: C.appBar3))
              : Icon(icon, size: 15, color: Colors.white),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
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

// ── Helper class ──────────────────────────────────────────────────
class _NameValue {
  final String label;
  final String value;

  const _NameValue(this.label, this.value);
}

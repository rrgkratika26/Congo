import 'dart:async';

import 'package:IMS/ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/RollData.dart';
import 'package:IMS/screen/Printing/ModelClass/Saveprintingsave.dart';
import 'package:IMS/services/Visa_SmallbagAPIS/VISA_SApis.dart';

import 'package:IMS/services/visa_apis/visa_api.dart';
import 'package:flutter/material.dart';
import 'package:IMS/ScannedItem/Lamination/lAMINATION_OUTsTOCK/modelClass/roll_wiseModle.dart';
import 'package:IMS/Color/Colorclass.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../../NARDANA/LaminationReports/LaminationOutNewEntryList.dart';
import '../../../services/NardanaApis/NardanaApi.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import '../../ScannedItem/Lamination/lAMINATION_OUTsTOCK/laminationOut_model.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ModelClass/Printmodel.dart';
import 'PrintingOutSavedList.dart';

class PrintRollEntryForm extends StatefulWidget {
  final PrintingOutModel roll;

  const PrintRollEntryForm({super.key, required this.roll});

  @override
  State<PrintRollEntryForm> createState() => _PrintRollEntryFormState();
}

class _PrintRollEntryFormState extends State<PrintRollEntryForm> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMsg;
  LaminationOutModel? _model;
  String? _bomNo;
  String unitName = '';
  List<dynamic> supervisors = [];
  List<dynamic> operators = [];

  String? selectedSupervisor;
  String? selectedOperator;

  String? _selectedShift;
  String? _selectedSupervisor;
  String? _selectedOpName;
  String? _selectedOperator;
  String? _selectedMachineType;
  String? _selectedLaminationType;
  final _batchNoCtrl = TextEditingController();
  final List<String> _laminationTypes = ["SL", "LL", "L"];
  final List<String> _machineTypes = ["LAMI-1", "LAMI-2"];
  Timer? _debounce;
  bool _isCodeGenerated = false;
  bool _isSaved = false;

  // ── Controllers ────────────────────────────────────────────────
  final _machineCtrl = TextEditingController();
  final _bomNoCtrl = TextEditingController();
  final _partyCtrl = TextEditingController();
  final _orderNoCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  final _articleCtrl = TextEditingController();
  final _articleNoCtrl = TextEditingController();
  final _loomTypeCtrl = TextEditingController();
  final _reqQtyKgCtrl = TextEditingController();
  final _reqQtyMtrCtrl = TextEditingController();
  // final _meshCtrl = TextEditingController();
  final _gsmCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _rollLengthCtrl = TextEditingController();
  final _rollWeightCtrl = TextEditingController();
  final _grossCtrl = TextEditingController();
  final _tareCtrl = TextEditingController();
  final _avgCtrl = TextEditingController();
  final _avgMtrGmCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  final _meshCtrl = TextEditingController();

  final _fabricWidthCtrl = TextEditingController();
  final _fabricBaffleCtrl = TextEditingController();
  final _fabricTypeCtrl = TextEditingController();
  final _fabricGsmCtrl = TextEditingController();
  final _laminationCtrl = TextEditingController();
  final _cutTypeCtrl = TextEditingController();
  final _specialIdCtrl = TextEditingController();
  final _generateCodeCtrl = TextEditingController();

  // ✅ Additional fields
  final _netWeightCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _weekCtrl = TextEditingController();
  final _planningCtrl = TextEditingController();
  final _modelNoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grossCtrl.text = widget.roll.grossWeight.toString() ?? "";
    _tareCtrl.text = widget.roll.tareWeight.toString() ?? "";
    _articleNoCtrl.text = widget.roll.articleNo.toString() ?? "";
    _rollLengthCtrl.text = widget.roll.rollLength.toString() ?? "";
    _meshCtrl.text = widget.roll.mesh.toString() ?? "";
    _partyCtrl.text = widget.roll.partyName.toString() ?? "";
    _poCtrl.text = widget.roll.poNo.toString() ?? "";
    _orderNoCtrl.text = widget.roll.orderNo.toString() ?? "";
    _loomTypeCtrl.text = widget.roll.loomType ?? "";
    // print("Roll Length API = ${data.rollData.requiredqtymtr}");
    print("Controller = ${_rollLengthCtrl.text}");
    _loadPlant();
    _fillFabricDetails(widget.roll.fabricCode ?? "");

    _loadDropdowns();

    _grossCtrl.addListener(_calculateWeights);
    _tareCtrl.addListener(_calculateWeights);
    _rollLengthCtrl.addListener(_calculateWeights);
    _fabricWidthCtrl.addListener(_calculateWeights);
    _rollWeightCtrl.addListener(_calculateWeights);
    _fabricWidthCtrl.addListener(_updateFabricCode);
    _fabricGsmCtrl.addListener(_updateFabricCode);
    _fabricBaffleCtrl.addListener(_updateFabricCode);
    _fabricTypeCtrl.addListener(_updateFabricCode);
    _laminationCtrl.addListener(_updateFabricCode);
    _colorCtrl.addListener(_updateFabricCode);
    _specialIdCtrl.addListener(_updateFabricCode);
    // _loadPlant();
    _fillFabricDetails(widget.roll.fabricCode ?? "");
    // _fetchData();

    _loadDropdowns();
  }

  @override
  void dispose() {
    for (final c in [
      _machineCtrl,
      _partyCtrl,
      _poCtrl,
      _articleCtrl,
      _articleNoCtrl,
      _reqQtyKgCtrl,
      _gsmCtrl,
      _widthCtrl,
      _rollLengthCtrl,
      _rollWeightCtrl,
      _grossCtrl,
      _tareCtrl,
      _avgCtrl,
      _remarkCtrl,
      _colorCtrl,
      _bomNoCtrl,
      _meshCtrl,
      _fabricWidthCtrl,
      _fabricBaffleCtrl,
      _fabricTypeCtrl,
      _fabricGsmCtrl,
      _laminationCtrl,
      _cutTypeCtrl,
      _specialIdCtrl,
      _generateCodeCtrl,
      _avgMtrGmCtrl,
      _netWeightCtrl,
      _qtyCtrl,
      _stateCtrl,
      _weekCtrl,
      _planningCtrl,
      _modelNoCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    try {
      final response = await VisaSmallBagApiService().getPrintingSpAndOpName();

      print(response);
      print(response["supervisors"]);
      print(response["operators"]);
      setState(() {
        supervisors = response["supervisors"] ?? [];
        operators = response["operators"] ?? [];

        // selectedSupervisor = widget.roll.;
        // selectedOperator = widget.roll.operatorName;

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateFabricCode() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final width = _fabricWidthCtrl.text.trim();
      final baffle = _fabricBaffleCtrl.text.trim();
      final type = _fabricTypeCtrl.text.trim();
      final gsm = _fabricGsmCtrl.text.trim();
      final lamination = _selectedLaminationType ?? '';
      final color = _colorCtrl.text.trim();
      final cutType = _laminationCtrl.text.trim();
      final specialId = _specialIdCtrl.text.trim();

      final allFilled = [
        width,
        baffle,
        type,
        gsm,
        lamination,
        color,
        cutType,
        specialId,
      ].every((e) => e.isNotEmpty);

      if (!allFilled) {
        setState(() {
          _generateCodeCtrl.text = "";
          _isCodeGenerated = false;
        });
        return;
      }

      final code =
          "$width-$baffle-$type-$gsm-$lamination-$color-$cutType-$specialId";

      setState(() {
        _generateCodeCtrl.text = code;
        _isCodeGenerated = true;
      });
    });
  }
  // ── API ────────────────────────────────────────────────────────

  // Future<void> _generateBatchNo() async {
  //   if (_selectedShift == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Shift select karo")));
  //     return;
  //   }
  //
  //   try {
  //     final batchNo = await VisaApiService.generateBatchNo(
  //       partyName: _partyCtrl.text.trim(), // 👈 correct field
  //       date: DateTime.now().toString().split(" ")[0], // yyyy-MM-dd
  //       loomType: "Lamination", // ✅ FIX
  //       shift: _selectedShift ?? "",
  //     );
  //
  //     if (batchNo != null) {
  //       setState(() {
  //         _batchNoCtrl.text = batchNo;
  //       });
  //
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Batch No: $batchNo")));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  // }

  Future<void> _loadPlant() async {
    unitName = (await AppSession.getUnit())!;

    setState(() {});
  }

  // Future<void> _fetchData() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMsg = null;
  //   });
  //   try {
  //     final id = int.parse(widget.roll.id.toString());
  //     // final data = await VisaSmallBagApiService.getLaminationDetails(id);
  //
  //     setState(() {
  //       _model = data;
  //       _isLoading = false;
  //     });
  //     setState(() {
  //       _model = data;
  //
  //       _partyCtrl.text = data.rollData.partyName ?? "";
  //       _poCtrl.text = data.rollData.purchsE_ORDER ?? "";
  //       _articleCtrl.text = data.rollData.articleNo ?? "";
  //       _fabricTypeCtrl.text = data.rollData.fabricBaffleType ?? "";
  //       _machineCtrl.text = data.rollData.modelno ?? "";
  //       _meshCtrl.text = data.rollData.mesh ?? "";
  //       _fabricWidthCtrl.text = data.rollData.fabricWidth ?? "";
  //       _fabricGsmCtrl.text = data.rollData.gsm ?? "";
  //       _rollLengthCtrl.text = data.rollData.requiredqtymtr ?? "";
  //       _bomNoCtrl.text = data.rollData.bomNo ?? "";
  //       _grossCtrl.text = data.rollData.grossWeight ?? "";
  //       _tareCtrl.text = data.rollData.tareWeight ?? "";
  //       _calculateWeights();
  //
  //
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMsg = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  // }

  void _calculateWeights() {
    final gross = double.tryParse(_grossCtrl.text) ?? 0;
    final tare = double.tryParse(_tareCtrl.text) ?? 0;
    final rollLength = double.tryParse(_rollLengthCtrl.text) ?? 0;
    final fabricWidth = double.tryParse(_fabricWidthCtrl.text) ?? 0;

    final rollWeight = gross - tare;
    _rollWeightCtrl.text = rollWeight.toStringAsFixed(2);

    double avgWeightGm = 0;
    if (rollLength > 0) avgWeightGm = (rollWeight / rollLength) * 1000;
    _avgCtrl.text = avgWeightGm.toStringAsFixed(2);

    double avgMtrGm = 0;
    if (fabricWidth > 0) {
      avgMtrGm = avgWeightGm / (fabricWidth / 100);
    }
    _avgMtrGmCtrl.text = avgMtrGm.toStringAsFixed(2);
  }

  void _generateFabricCode() {
    if (_fabricWidthCtrl.text.isEmpty ||
        _fabricBaffleCtrl.text.isEmpty ||

        _fabricGsmCtrl.text.isEmpty ||
        _laminationCtrl.text.isEmpty ||
        _colorCtrl.text.isEmpty ||
        _cutTypeCtrl.text.isEmpty ||
        _specialIdCtrl.text.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Please fill all fields before generating code"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      return;
    }

    final code =
        "${_fabricWidthCtrl.text}-${_fabricBaffleCtrl.text}-"
        "${_fabricTypeCtrl.text}-${_fabricGsmCtrl.text}-"
        "${_selectedLaminationType ?? ''}-"
        "${_colorCtrl.text}-${_laminationCtrl.text}-"
        "${_specialIdCtrl.text}";

    setState(() {
      _generateCodeCtrl.text = code;

      _isCodeGenerated = true;
    });
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final payload = SaveprintingModel(
      rollId: '0',
      srNo: widget.roll.id,
      barcode: widget.roll.rollCode.toString(),
      machineType: _selectedMachineType ?? "",
      generateCode: _generateCodeCtrl.text,
      supervisorName: _selectedSupervisor ?? "",
      operatorName: _selectedOperator ?? "",
      // specialId: _specialIdCtrl.text,
      fabricTypeUse: _fabricTypeCtrl.text,
      fabricWidth: _fabricWidthCtrl.text,
      color: _colorCtrl.text,
      mesh: _meshCtrl.text,
      loomType: _loomTypeCtrl.text ?? "",
      laminationType: _selectedLaminationType ?? "",
      fabricGsm: _fabricGsmCtrl.text,
      cutType: _laminationCtrl.text,
      sid: _specialIdCtrl.text,
      fabricBaffleType: _fabricBaffleCtrl.text,
      rollWeightKg: _rollWeightCtrl.text,
      rollLengthMtr: _rollLengthCtrl.text,
      grossWeight: _grossCtrl.text,
      avgWeight: _avgCtrl.text,
      tareWeight: _tareCtrl.text,
      partyName: _partyCtrl.text,
      poNumber: _poCtrl.text,
      articleNumber: _articleNoCtrl.text,
      loomNo: _machineCtrl.text,
      avgweightmtrgm: _avgMtrGmCtrl.text,
      opname: _selectedOpName ?? "",
      bomno: widget.roll.bomNo,
      batchNo: _batchNoCtrl.text,
      shift: _selectedShift ?? "",
      unit: unitName,
    );

    debugPrint("══════════ SAVE PAYLOAD ══════════");

    final json = payload.toJson();

    json.forEach((key, value) {
      debugPrint("$key : $value");
    });

    debugPrint("══════════════════════════════════");

    try {
      final success = await VisaSmallBagApiService.savePrintOutstock(
        payload.toJson(),
      );
      setState(() => _isSaving = false);

      if (success) {
        setState(() => _isSaved = true);
        Get.offAll(() => PrintOutsavedList(title: "Printing Rolls"));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text("Saved successfully ...\n New Barcode Generated"),
              ],
            ),
            backgroundColor: C.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  pay
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: _appBar(),
      body: _isLoading
          ? _loadingView()
          : _errorMsg != null
          ? _errorView()
          : _formView(),
      bottomNavigationBar: (!_isLoading && _errorMsg == null)
          ? _actionBar()
          : null,
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: C.appBar1,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
      onPressed: () => Navigator.maybePop(context),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Printing Out",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        // Text(
        //   _isLoading
        //       ? "Sr. No: ${widget.roll.srNo}"
        //       : "Sr. No: ${widget.roll.srNo} ",
        //   // " •  ${_partyCtrl.text.isNotEmpty ? _partyCtrl.text : '—'}",
        //   style: const TextStyle(
        //     fontSize: 18,
        //     color: Colors.white,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      ],
    ),
    // actions: [
    //   if (!_isLoading)
    //     IconButton(
    //       icon: const Icon(Icons.refresh_rounded, size: 20),
    //       onPressed: _fetchData,
    //       tooltip: "Refresh",
    //     ),
    // ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(3),
      child: Container(height: 3),
    ),
  );

  // ── Loading ────────────────────────────────────────────────────
  Widget _loadingView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: C.primary, strokeWidth: 2.5),
        const SizedBox(height: 16),
        Text(
          "Loading data...",
          style: TextStyle(color: C.primary, fontSize: 13),
        ),
      ],
    ),
  );

  // ── Error ──────────────────────────────────────────────────────
  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: C.danger.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, color: C.danger, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: C.textBody,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMsg!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: C.primary),
          ),
          const SizedBox(height: 24),
          // ElevatedButton.icon(
          //   onPressed: _fetchData,
          //   icon: const Icon(Icons.refresh_rounded, size: 16),
          //   label: const Text("Try Again"),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: C.primary,
          //     foregroundColor: Colors.white,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //   ),
          // ),
        ],
      ),
    ),
  );

  // ── Form ───────────────────────────────────────────────────────
  Widget _formView() => LayoutBuilder(
    builder: (ctx, constraints) {
      final wide = constraints.maxWidth > 600;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Info Header ───────────────────────────────
            _infoHeader(),
            const SizedBox(height: 14),

            // ── 2. Operator Info ─────────────────────────────
            _section("Operator Info", Icons.people_alt_rounded, [
              _rowGroup(wide, [
                _dropdown(
                  label: "Shift",
                  value: _selectedShift,
                  items: const ["A", "B"],
                  onChanged: (v) => setState(() => _selectedShift = v),
                ),
                const SizedBox.shrink(),
              ]),
              _rowGroup(wide, [
                _dropdown(
                  label: "Supervisor",
                  items: supervisors.cast<String>(),
                  value: _selectedSupervisor,
                  onChanged: (value) {
                    setState(() {
                      _selectedSupervisor = value;
                      selectedSupervisor = value;
                    });
                  },
                ),

                _dropdown(
                  label: "Operator",
                  items: operators.cast<String>(),
                  value: _selectedOperator,
                  onChanged: (value) {
                    setState(() {
                      _selectedOperator = value;
                      _selectedOpName = value;
                      selectedOperator = value;
                    });
                  },
                ),
              ]),
            ]),
            const SizedBox(height: 14),

            _section("Production Details", Icons.factory_rounded, [
              _twoCol(
                _field("Article Number", _articleNoCtrl),
                _field("Loom Type", _loomTypeCtrl),
              ),
              const SizedBox(height: 5),
              // _twoCol(
              //   _field(
              //     "Required Qty (KG)",
              //     _reqQtyKgCtrl,
              //     type: TextInputType.number,
              //   ),
              //
              //   _field(
              //     "Required Qty (Mtr)",
              //     _reqQtyMtrCtrl,
              //     type: TextInputType.number,
              //   ),
              // ),
              const SizedBox(height: 5),

              _twoCol(
                _field("Mesh", _meshCtrl),
                _field("Order No", _orderNoCtrl),

                // const SizedBox(),
              ),
            ]),
            const SizedBox(height: 14),

            // ── 4. Order Details ─────────────────────────────
            _section("Order Details", Icons.assignment_rounded, [
              _twoCol(_field("PO Number", _poCtrl), const SizedBox()),
              const SizedBox(height: 5),

              _twoCol(
                _field("Fabric Type", _fabricTypeCtrl),
                // _field("Fabric GSM", _gsmCtrl, type: TextInputType.number),
                _field(
                  "Fabric GSM",
                  _fabricGsmCtrl,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(height: 10),

              _twoCol(
                _dropdown(
                  label: "Machine Type",

                  value: _selectedMachineType,
                  items: _machineTypes,
                  onChanged: (v) => setState(() => _selectedMachineType = v),
                ),

                _dropdown(
                  label: "Lamination Type",
                  value: _selectedLaminationType,
                  items: _laminationTypes,
                  // onChanged: (v) => setState(() => _selectedLaminationType = v),
                  onChanged: (v) {
                    setState(() => _selectedLaminationType = v);
                    _updateFabricCode(); // 🔥 important
                  },
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── 5. Fabric Measurements ───────────────────────
            _section("Fabric Measurements", Icons.straighten_rounded, [
              _twoCol(
                _field(
                  "Fabric Width (cm)",
                  _fabricWidthCtrl,
                  type: TextInputType.number,
                ),
                _field(
                  "Roll Length (Mtr)",
                  _rollLengthCtrl,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(height: 5),

              _twoCol(
                _field("Roll Weight (Kg)", _rollWeightCtrl, readOnly: true),
                _field("Avg Weight (Gm)", _avgCtrl, readOnly: true),
              ),
              const SizedBox(height: 5),

              _twoCol(
                _field("Avg Weight (Mtr/Gm)", _avgMtrGmCtrl, readOnly: true),
                const SizedBox(),
              ),
            ]),
            const SizedBox(height: 14),

            // ── 6. Weight Details ────────────────────────────
            _section("Weight Details", Icons.monitor_weight_rounded, [
              _twoCol(
                _field(
                  "Gross Weight (Kg)",
                  _grossCtrl,
                  type: TextInputType.number,
                ),
                _field(
                  "Tare Weight (Kg)",
                  _tareCtrl,
                  type: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── 7. Fabric Code ───────────────────────────────
            _section("Fabric Code", Icons.qr_code_rounded, [
              _twoCol(
                _field("Fabric Baffle/Type", _fabricBaffleCtrl),
                _field("Fabric Type/Use", _fabricTypeCtrl),
              ),
              const SizedBox(height: 5),

              _twoCol(
                _field("Cut Type", _laminationCtrl, readOnly: true),

                _field("Special ID", _specialIdCtrl, readOnly: true),
              ),

              const SizedBox(height: 8),

              // Generated code display box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: C.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.primary.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            !_isCodeGenerated
                                ? "Tap 'Generate Fabric Code'"
                                : _generateCodeCtrl.text,
                            style: TextStyle(
                              fontSize: 12,
                              color: _generateCodeCtrl.text.isEmpty
                                  ? C.primary
                                  : C.textBody,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              _field("Batch No", _batchNoCtrl, readOnly: true),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _generateFabricCode();

                    if (_selectedShift == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Shift select karo")),
                      );
                      return;
                    }

                    final batchNo = _generateBatchNumber();

                    setState(() {
                      _batchNoCtrl.text = batchNo;
                    });
                  },
                  icon: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Generate Fabric Code",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),

            // ── 8. Remark ────────────────────────────────────
            _section("Remark", Icons.notes_rounded, [
              _field("Add a remark...", _remarkCtrl, maxLines: 3),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );

  // ── Info Header ────────────────────────────────────────────────
  Widget _infoHeader() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: C.primary,
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _infoTile("Party Name", _partyCtrl.text)),
            const SizedBox(width: 10),
            // ${widget.roll.srNo}
            Expanded(
              child: _infoTile(
                "Sr No.",
                _isLoading ? "${widget.roll.id}" : "${widget.roll.id}",
              ),
            ),
            // Expanded(child: _infoTile("Order No", _model?.rollData.partyName ?? "—")),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _infoTile(
                "Bom No",
                // _bomNoCtrl.text.isNotEmpty ? _bomNoCtrl.text : "—",
                _isLoading ? widget.roll.bomNo : widget.roll.bomNo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoTile(
                "Loom No",
                _isLoading ? "${widget.roll.loomNo}" : "${widget.roll.loomNo}",
                // _machineCtrl.text.isNotEmpty ? _machineCtrl.text : "—",
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row(
        //   children: [
        //     Expanded(
        //       child: _infoTile(
        //         "Req Net Wt",
        //         _model?.rollData.requirednewt ?? "—",
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     Expanded(
        //       child: _infoTile(
        //         "Req Qty Mtr",
        //         _model?.rollData.requiredqtymtr ?? "—",
        //       ),
        //     ),
        //   ],
        // ),
      ],
    ),
  );

  // Widget _infoTile(String label, String value) => Container(
  //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //   decoration: BoxDecoration(
  //     color: C.border,
  //     borderRadius: BorderRadius.circular(10),
  //   ),
  //   child: Row(
  //     children: [
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 fontSize: 10,
  //                 color: C.textHead,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             Text(
  //               value,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 color: C.textHead,
  //                 fontWeight: FontWeight.w700,
  //               ),
  //               overflow: TextOverflow.ellipsis,
  //               maxLines: 1,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // );
  Widget _infoTile(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: C.bg,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Section Card ───────────────────────────────────────────────
  Widget _section(String title, IconData icon, List<Widget> children) =>
      Container(
        decoration: BoxDecoration(
          color: C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: C.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: C.textHigh, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: C.primaryDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Divider(height: 1, color: C.border),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      );

  Widget _twoCol(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }

  // ── Responsive Row ─────────────────────────────────────────────
  Widget _rowGroup(bool wide, List<Widget> children) {
    List<Widget> rows = [];

    for (int i = 0; i < children.length; i += 2) {
      final first = children[i];
      final second = (i + 1 < children.length)
          ? children[i + 1]
          : const SizedBox();

      rows.add(
        wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 10),
                  Expanded(child: second),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  first,
                  if (second is! SizedBox) ...[
                    const SizedBox(height: 10),
                    second,
                  ],
                ],
              ),
      );
    }

    return Column(
      children: rows.expand((w) => [w, const SizedBox(height: 10)]).toList()
        ..removeLast(),
    );
  }

  // ── Field ──────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: readOnly ? C.brand900 : C.brand800,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: type,
        style: TextStyle(
          fontSize: 13,
          color: readOnly ? C.textHigh : C.textBody,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: readOnly ? C.bg : C.cardBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: readOnly ? C.border : const Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: readOnly ? C.border : C.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );

  // ── Dropdown ───────────────────────────────────────────────────
  Widget _dropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: C.brand700,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: C.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            hint: Text(
              "Select $label",
              style: TextStyle(fontSize: 12, color: C.textMid),
            ),
            style: const TextStyle(
              fontSize: 13,
              color: C.textBody,
              fontWeight: FontWeight.w500,
            ),
            items: items
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );

  // ── API Dropdown ───────────────────────────────────────────────
  Widget _apiDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) => items.isEmpty
      ? _field(label, TextEditingController(text: "No data"), readOnly: true)
      : _dropdown(
          label: label,
          items: items,
          value: value,
          onChanged: onChanged,
        );

  // ── Action Bar ─────────────────────────────────────────────────
  Widget _actionBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: C.border)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      children: [
        Row(
          children: [
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                label: Text(
                  _isSaving ? "Saving..." : "Save Entry",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.success,
                  disabledBackgroundColor: C.success.withOpacity(0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
        TextButton.icon(
          icon: const Icon(
            Icons.list_alt_rounded,
            size: 20,
            color: Colors.white,
          ),
          label: Padding(
            padding: const EdgeInsets.all(3.0),
            child: const Text(
              "New Barcode List",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: C.success, // highlight color from your theme
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              // For Naradana
              builder: (_) => const PrintOutsavedList(title: "Printing Rolls"),

              // For VISA
              // builder: (_) => const LamRollPrintScreen(title: "Lamination Rolls"),//visa
            ),
          ),
        ),
      ],
    ),
  );

  String _generateBatchNumber() {
    final party = widget.roll.partyName.trim() ?? '';
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

    return "$partyCode$date$month${shift}PA";
  }

  void _fillFabricDetails(String fabricCode) {
    if (fabricCode.isEmpty) return;

    final parts = fabricCode.split('-');

    if (parts.length < 8) return;

    setState(() {
      _fabricWidthCtrl.text = parts[0];
      _fabricBaffleCtrl.text = parts[1];
      _fabricTypeCtrl.text = parts[2];
      _fabricGsmCtrl.text = parts[3];

      final lamination = parts[4];

      _selectedLaminationType = _laminationTypes.contains(lamination)
          ? lamination
          : null;

      _colorCtrl.text = parts[5];
      _laminationCtrl.text = parts[6];
      _specialIdCtrl.text = parts[7];

      _generateCodeCtrl.text = fabricCode;
      _isCodeGenerated = true;
    });
  }
} // ← end of _PrintRollEntryFormState

import 'dart:convert';

import 'package:IMS/JBL/JBL_Loom/modelClass/FIBCmodel.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../../Color/Colorclass.dart';
import 'SavedListScreenLomm.dart';

class LoomForm extends StatefulWidget {
  final ProductionModel production;
  const LoomForm({super.key, required this.production});

  @override
  State<LoomForm> createState() => _LoomFormState();
}

class _LoomFormState extends State<LoomForm> {
  List<String> supervisors = [];
  List<String> operators = [];
  List<String> machines = [];
  List<String> machineTypes = [];

  String? selectedSupervisor;
  String? selectedMachine;
  String? selectedOperator1;
  String? selectedShift;
  String? selectedOperator2;
  bool isLoading = false;
  String? selectedMachineType;
  // final _formKey = GlobalKey<FormState>();
  // String? _generatedBatch;
  // String? _generatedCode;
  int? cId;
  String? barcode;

  String unit = "";

  late TextEditingController _batchController;
  late TextEditingController _generatedCodeController;
  late TextEditingController articleNoCtrl;
  late TextEditingController partyController;
  late TextEditingController loomOrderController;
  late TextEditingController reqQntyKgController;
  late TextEditingController reqQntyMtrController;

  late TextEditingController poNoController;
  late TextEditingController loomNoController;
  late TextEditingController fabricController;
  late TextEditingController qtyKgController;
  late TextEditingController qtyMtrController;
  late TextEditingController fabricWidthCtrl;
  late TextEditingController cutTypeCtrl;
  late TextEditingController fabricTypeCtrl;
  late TextEditingController gsmCtrl;
  late TextEditingController laminationCtrl;
  late TextEditingController colorCtrl;
  late TextEditingController sidCtrl;
  late TextEditingController baffleCtrl;
  late TextEditingController meshCtrl;
  late TextEditingController loomStartCtrl;
  late TextEditingController loomEndCtrl;
  late TextEditingController remarkCtrl;
  late TextEditingController grossWeightCtrl;
  late TextEditingController tareWeightCtrl;
  late TextEditingController netWeightCtrl;
  late TextEditingController rollLengthCtrl;
  late TextEditingController avgWeightMtrCtrl;
  late TextEditingController avgWeightMtrGmCtrl;
  void _clearForm() {
    // Clear logic
  }

  @override
  void initState() {
    super.initState();
    // _loadUnit();
    _initializeData();
    final data = widget.production;
    _batchController = TextEditingController();
    _generatedCodeController = TextEditingController();
    partyController = TextEditingController(text: data.partyName);
    loomOrderController = TextEditingController(text: data.orderNo.toString());
    reqQntyKgController = TextEditingController(
      text: data.balanceKgInt.toString(),
    );
    reqQntyMtrController = TextEditingController(
      text: data.balanceMtrInt.toString(),
    );

    poNoController = TextEditingController(text: data.poNumber.toString());
    fabricController = TextEditingController(text: data.fabricCode);
    loomNoController = TextEditingController();
    articleNoCtrl = TextEditingController(text: data.articleNo.toString());
    qtyKgController = TextEditingController(
      text: data.actualRequiredKg.toString(),
    );

    qtyMtrController = TextEditingController(
      text: data.actualRequiredMtr.toString(),
    );
    fabricWidthCtrl = TextEditingController();
    cutTypeCtrl = TextEditingController();
    fabricTypeCtrl = TextEditingController();
    gsmCtrl = TextEditingController();
    laminationCtrl = TextEditingController();
    colorCtrl = TextEditingController();
    sidCtrl = TextEditingController();
    baffleCtrl = TextEditingController();
    meshCtrl = TextEditingController();
    remarkCtrl = TextEditingController();
    loomStartCtrl = TextEditingController();
    loomEndCtrl = TextEditingController();
    grossWeightCtrl = TextEditingController();
    tareWeightCtrl = TextEditingController();
    netWeightCtrl = TextEditingController();
    rollLengthCtrl = TextEditingController();
    avgWeightMtrCtrl = TextEditingController();
    avgWeightMtrGmCtrl = TextEditingController();
    grossWeightCtrl.addListener(_calculateValues);
    tareWeightCtrl.addListener(_calculateValues);
    rollLengthCtrl.addListener(_calculateValues);
    fabricWidthCtrl.addListener(_calculateValues); // IMPORTANT
    _parseFabricCode(widget.production.fabricCode);
    setState(() => isLoading = true);
    _loadDropdowns();
    if (selectedMachine != null && selectedMachineType != null) {
      _fetchLoomReading();
    }
    _fetchNextCid();

    setState(() => isLoading = false);
    // loadData();
  }

  // Future<void> loadData() async {
  //   final data = await getSupervisors(); // your API call
  //
  //   setState(() {
  //     supervisors = List<String>.from(data['supervisors'] ?? []);
  //     operators = List<String>.from(data['operator'] ?? []);
  //     machines = List<String>.from(data['machines'] ?? []);
  //     machineTypes = List<String>.from(data['machineTypes'] ?? []);
  //   });
  // }

  Future<void> _fetchNextCid() async {
    final url = Uri.parse("${InStockService.baseUrl}/LoomForward/next-cid");

    try {
      final res = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      print("👉 NEXT CID RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          cId = data['cId'];
          barcode = data['barcode'];
        });

        print("✅ cId: $cId");
        print("✅ barcode: $barcode");
      }
    } catch (e) {
      print("❌ CID API ERROR: $e");
    }
  }

  Future<void> _fetchLoomReading() async {
    if (selectedMachine == null || selectedMachineType == null) return;

    // final url = Uri.parse(
    //   "${InStockService.baseUrl}/LoomForward/loom-reading"
    //   // "?unit=UNIT-NARDANA"
    //   // "?unit=UNIT-SILVASSA"
    //   "?unit=UNIT-1"
    //   // "&machine=$selectedMachineType" // ✅ correct
    //   // "&machineType=$selectedMachine",
    //   "&machine=${selectedMachine?.trim()}"
    //   "&machineType=${selectedMachineType?.trim()}",
    // );

    final url = Uri.parse(
      "${InStockService.baseUrl}/LoomForward/loom-reading"
      "?unit=${Uri.encodeComponent(unit)}"
      "&machine=${Uri.encodeComponent(selectedMachine?.trim() ?? '')}"
      "&machineType=${Uri.encodeComponent(selectedMachineType?.trim() ?? '')}",
    );

    try {
      final res = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      // print("👉 FINAL URL: $url");
      // print("👉 MACHINE: $selectedMachine");
      // print("👉 MACHINE TYPE: $selectedMachineType");
      // print("RAW RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final reading = data['loomReading'];

        print("loomReading value: $reading");

        setState(() {
          loomStartCtrl.text =
              (reading != null && reading.toString().isNotEmpty)
              ? reading.toString()
              : "";
        });

        print("✅ Loom Start Updated: ${loomStartCtrl.text}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  void _parseFabricCode(String code) {
    final parts = code.split('-');

    if (parts.length >= 8) {
      fabricWidthCtrl.text = parts[0];
      cutTypeCtrl.text = parts[1];
      fabricTypeCtrl.text = parts[2];
      gsmCtrl.text = parts[3];
      laminationCtrl.text = parts[4];
      colorCtrl.text = parts[5];
      sidCtrl.text = parts[6];
      baffleCtrl.text = parts[7];
    }
  }

  String _generateBatchNumber() {
    final party = partyController.text.trim();
    final po = poNoController.text.trim();
    final shift = selectedShift ?? ''; // or any shift field if you have

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

  void _generateCodes() {
    if (selectedMachine == null || selectedMachineType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select Machine & Loom No first")),
      );
      return;
    }

    final batch = _generateBatchNumber();
    final code =
        "${fabricWidthCtrl.text}"
        "-${cutTypeCtrl.text}"
        "-${selectedShift ?? ''}"
        "-${gsmCtrl.text}"
        "-${laminationCtrl.text}"
        "-${colorCtrl.text}"
        "-${sidCtrl.text}"
        "-${baffleCtrl.text}";

    setState(() {
      _batchController.text = batch;
      _generatedCodeController.text = code;
    });
  }

  Future<void> _loadDropdowns({String? machine}) async {
    try {
      final res = await InStockService.fetchSuperDropdownData(machine: machine);

      // print("✅ Supervisors: ${res.supervisors}");
      // print("✅ Machines: ${res.machines}");
      // print("✅ Operators: ${res.operators}");

      setState(() {
        supervisors = res.supervisors;
        machines = res.machines;
        operators = res.operators;
        machineTypes = res.machineTypes; // ✅ IMPORTANT

        selectedSupervisor ??= supervisors.isNotEmpty
            ? supervisors.first
            : null;
        selectedMachine ??= machines.isNotEmpty ? machines.first : null;
      });
    } catch (e) {
      print("❌ Dropdown error: $e");
    }
  }

  Future<void> _saveForm() async {
    final url = Uri.parse(
      "${InStockService.baseUrl}/LoomForward/save-loom-entry",
    );

    final body = {
      "date": DateTime.now().toIso8601String(),
      "machine": selectedMachine,
      // "operator": selectedOperator1,
      "operator": selectedOperator2,
      "fabricCode": fabricController.text,
      "supervisor": selectedSupervisor,

      "buffie": baffleCtrl.text,
      "typeUse": fabricTypeCtrl.text,
      "fabricWidth": fabricWidthCtrl.text,
      "color": colorCtrl.text,
      "lamination": laminationCtrl.text,
      "gsm": gsmCtrl.text,
      "sid": sidCtrl.text,
      "cutType": cutTypeCtrl.text,

      // "netWeight": double.tryParse(qtyKgController.text) ?? 0,
      "netWeight": double.tryParse(netWeightCtrl.text) ?? 0,
      "jobWork": grossWeightCtrl.text,
      "quantity": rollLengthCtrl.text,
      "remark": remarkCtrl.text,

      "partyName": loomOrderController.text,
      "workOrderNo": poNoController.text,

      "weekNo": tareWeightCtrl.text, // dynamic if needed
      // "requiredNetWt": qtyKgController.text,
      "requiredNetWt": reqQntyKgController.text,
      // "requiredQtyMtr": qtyMtrController.text,

      // "requiredQtyMtr": reqQntyKgController.text,
      "requiredQtyMtr": qtyMtrController.text,

      "fromRoll": "LOOM",
      "modelNo": selectedMachineType,

      "rmdSupervisor": meshCtrl.text,

      "loomOperator1": selectedOperator1,
      // "loomOperator2": selectedOperator2 ?? selectedOperator1,
      "loomOperator2": avgWeightMtrCtrl.text,

      "laminationRemark": "0",
      "uscRemark": "FIBC",
      "cuttingRemark": "0",
      "multiple": "0",

      "machineNo": partyController.text,
      "planningWeek": tareWeightCtrl.text,

      "plant1": unit,
      "plant2": unit,

      "stateName": avgWeightMtrGmCtrl.text,
      "cDept": "LO",

      "cId": cId ?? 0,
      "purchaseOrder": articleNoCtrl.text,

      "batchNo": _batchController.text,
      "shift": selectedShift ?? "A",
    };

    try {
      // print("========== API DEBUG START ==========");
      // print("👉 URL: $url");
      // print("👉 HEADERS: ${await InStockService.authHeaders()}");
      // print("👉 BODY: ${jsonEncode(body)}");

      final res = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      // print("👉 STATUS CODE: ${res.statusCode}");
      // print("👉 RESPONSE BODY: ${res.body}");
      // print("========== API DEBUG END ==========");

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Saved Successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${res.statusCode}: ${res.body}")),
        );
      }
    } catch (e, stack) {
      print("❌ EXCEPTION: $e");
      print("❌ STACKTRACE: $stack");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exception: $e")));
    }
  }

  @override
  void dispose() {
    _batchController.dispose();
    _generatedCodeController.dispose();
    partyController.dispose();
    fabricController.dispose();
    qtyKgController.dispose();
    qtyMtrController.dispose();
    grossWeightCtrl.dispose();
    tareWeightCtrl.dispose();
    netWeightCtrl.dispose();
    rollLengthCtrl.dispose();
    avgWeightMtrCtrl.dispose();
    avgWeightMtrGmCtrl.dispose();
    super.dispose();
  }

  void _calculateValues() {
    final gross = double.tryParse(grossWeightCtrl.text) ?? 0;
    final tare = double.tryParse(tareWeightCtrl.text) ?? 0;
    final roll = double.tryParse(rollLengthCtrl.text) ?? 0;
    final width = double.tryParse(fabricWidthCtrl.text) ?? 0;

    final net = gross - tare;
    netWeightCtrl.text = net.toStringAsFixed(2);

    final avgMtr = roll > 0 ? (net / roll) * 1000 : 0.0;
    avgWeightMtrCtrl.text = avgMtr.toStringAsFixed(2);

    final avgGm = width > 0 ? (avgMtr / (width / 100)) : 0.0;
    avgWeightMtrGmCtrl.text = avgGm.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    icon: Icons.person_outline_rounded,
                    title: "General Info",
                    children: [
                      _row([
                        DropdownButtonFormField<String>(
                          value: selectedSupervisor,
                          hint: Text("Select Supervisor"),
                          items: supervisors.map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedSupervisor = val);
                          },
                        ),
                      ]),
                      _buildField("Party Name", controller: partyController),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "BOM No",
                              controller: loomOrderController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              "PO No",
                              controller: poNoController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedShift,
                              hint: const Text("Select Shift"),
                              items: ['A', 'B', 'C'].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => selectedShift = val);
                              },
                              decoration: InputDecoration(
                                labelText: "Shift",
                                filled: true,
                                fillColor: C.brand50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildField(
                              "Article No",
                              controller: articleNoCtrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildSection(
                    icon: Icons.layers_outlined,
                    title: "Fabric Details",
                    children: [
                      _row([
                        _buildField(
                          "Required Fabric",
                          controller: fabricController,
                          fullWidth: true,
                          readOnly: true,
                        ),
                      ]),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Req.netWt (Kg)",
                              controller: reqQntyKgController,
                            ),
                          ),

                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              "Req.netWt (Mtr)",
                              controller: reqQntyMtrController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Qty (Kg)",
                              controller: qtyKgController,
                            ),
                          ),

                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              "Qty (Mtr)",
                              controller: qtyMtrController,
                            ),
                          ),
                        ],
                      ),

                      // ✅ NEW ROW (Loom No + Machine)
                      _row([
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedMachine,
                          hint: const Text("Select Loom Type"),
                          items: machines.map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              selectedMachine = val;
                            });
                            await _loadDropdowns(machine: val);
                            await _fetchLoomReading();

                            //

                            // 👇 IMPORTANT: call after machine is selected
                            // await _fetchLoomReading();
                          },
                        ),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedMachineType,
                          hint: const Text("Select Loom No"),
                          items: machineTypes.map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              selectedMachineType = val;
                            });

                            await _fetchLoomReading();
                          },
                        ),
                      ]),

                      _row([
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedOperator1,
                          hint: const Text("Select Operator1"),
                          items: operators.map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedOperator1 = val);
                          },
                        ),
                      ]),

                      _row([
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedOperator2,
                          hint: const Text("Select Operator2"),
                          items: operators.map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedOperator2 = val);
                          },
                        ),
                      ]),
                    ],
                  ),
                  _buildSection(
                    icon: Icons.tune_rounded,
                    title: "Specifications",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Fabric Width",
                              controller: fabricWidthCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField("Cut Type", controller: sidCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Fabric Type",
                              controller: fabricTypeCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField("GSM", controller: gsmCtrl),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Lamination",
                              controller: laminationCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildField("Color", controller: colorCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField("SID", controller: baffleCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              "Baffle",
                              controller: cutTypeCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _row([_buildField("Mesh", controller: meshCtrl)]),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  _buildSection(
                    icon: Icons.monitor_weight_outlined,
                    title: "Weights & Measures",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Gross Weight",
                              controller: grossWeightCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildField(
                              "Tare Weight",
                              controller: tareWeightCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Net Weight",
                              controller: netWeightCtrl,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildField(
                              "Roll Length",
                              controller: rollLengthCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              "Avg Wt (Mtr)",
                              controller: avgWeightMtrCtrl,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              "Avg Wt (GSM)",
                              controller: avgWeightMtrGmCtrl,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  _buildField(
                    "Batch No",
                    controller: _batchController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),

                  _buildField(
                    "Generated Code",
                    controller: _generatedCodeController,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateCodes,
                      icon: const Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Generate Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.brand600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSection(
                    icon: Icons.more_horiz_rounded,
                    title: "Other Details",
                    children: [
                      _row([
                        _buildField("Loom Starting", controller: loomStartCtrl),
                        _buildField("Loom Ending", controller: loomEndCtrl),
                      ]),
                      _buildField(
                        "Remark",
                        controller: remarkCtrl,
                        fullWidth: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 8),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final today = DateTime.now();
    final dateStr =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.appBar1, C.appBar4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Loom Production Form",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.warning,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Saved List",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Card ────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.borderLight),
        boxShadow: [
          BoxShadow(
            color: C.brand500.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: C.brand50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: C.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: C.brand700.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: C.brand700),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: C.textHigh,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ── Two-column row ──────────────────────────────────────────
  Widget _row(List<Widget> children) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: children.map((child) {
          return SizedBox(
            width: isMobile
                ? double
                      .infinity // full width on mobile
                : (width / 2) - 26, // 2 columns on bigger screens
            child: child,
          );
        }).toList(),
      ),
    );
  }

  // ── Field ───────────────────────────────────────────────────
  Widget _buildField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
    bool fullWidth = false,
    bool readOnly = false,
  }) {
    final field = Padding(
      padding: fullWidth ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 13,
          color: C.textHigh,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,

          filled: true,
          fillColor: C.brand50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );

    return field;
  }

  // ── Action Buttons ──────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: _saveForm,
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              "Save Form",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.brand700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: C.brand700.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: _clearForm,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: C.brand700,
            ),
            label: const Text(
              "Clear",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: C.brand700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: C.brand600, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadUnit() async {
    final savedUnit = await AppSession.getUnit();

    setState(() {
      unit = savedUnit ?? "";
    });
  }

  Future<void> _initializeData() async {
    await _loadUnit();

    final data = widget.production;

    _batchController = TextEditingController();
    _generatedCodeController = TextEditingController();

    partyController = TextEditingController(text: data.partyName);

    // remaining controller code...

    _parseFabricCode(widget.production.fabricCode);

    setState(() => isLoading = true);

    await _loadDropdowns();

    if (selectedMachine != null && selectedMachineType != null) {
      await _fetchLoomReading();
    }

    await _fetchNextCid();

    setState(() => isLoading = false);
  }
}

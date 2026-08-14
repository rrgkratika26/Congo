import 'dart:convert';

import 'package:IMS/JBL/JBL_Loom/modelClass/FIBCmodel.dart';
import 'package:IMS/NARDANA/RmdINReports/RmdSavedListForPrint.dart';
import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/RmdService.dart';

class RmdRollENtryScreen extends StatefulWidget {
  const RmdRollENtryScreen({super.key});

  @override
  State<RmdRollENtryScreen> createState() => _RmdRollENtryScreenState();
}

class _RmdRollENtryScreenState extends State<RmdRollENtryScreen> {
  List<String> partyNames = [];
  List<String> supervisors = [];
  List<String> operators = [];

  List<String> fabricCodes = [];
  List<String> locations = [];

  List<String> poNumbers = [];
  List<String> articleNumbers = [];
  List<String> bomNumbers = [];

  String? selectedParty;
  String? selectedSupervisor;
  String? selectedFabric;
  String? selectedLocation;

  String? selectedPoNo;
  String? selectedArticle;
  String? selectedBom;

  String? selectedMachine;

  String? selectedOperator;
  String? selectedShift;
  String? selectedOperator2;
  bool isLoading = false;
  String? selectedMachineType;

  int? cId;
  String? barcode;

  String? unit = AppGlobals.unit;
  String? selectedProductionType;
  String? selectedRollFrom;

  final List<String> productionTypes = ["FIBC"];
  final List<String> rollFromList = ["IPS", "OTHERS"];
  // final List<String> rollFromList = ["UNIT-VISA", "OTHERS"]; //Visa_S small bag

  final supervisorController = TextEditingController();

  final operatorController = TextEditingController();
  final partyController = TextEditingController();
  final locationController = TextEditingController();
  final poController = TextEditingController();
  final bomController = TextEditingController();
  final articleController = TextEditingController();

  late TextEditingController _batchController;
  late TextEditingController _generatedCodeController;
  late TextEditingController articleNoCtrl;

  late TextEditingController loomOrderController;
  late TextEditingController bomNoController;
  late TextEditingController reqQntyKgController;
  // late TextEditingController poNoController;
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

  @override
  void initState() {
    super.initState();

    _batchController = TextEditingController();
    _generatedCodeController = TextEditingController();
    // partyController = TextEditingController();
    loomOrderController = TextEditingController();
    bomNoController = TextEditingController();
    articleNoCtrl = TextEditingController();

    // poNoController = TextEditingController();
    loomNoController = TextEditingController();
    fabricController = TextEditingController();
    reqQntyKgController = TextEditingController();
    qtyKgController = TextEditingController();
    qtyMtrController = TextEditingController();
    fabricWidthCtrl = TextEditingController();
    cutTypeCtrl = TextEditingController();
    fabricTypeCtrl = TextEditingController();
    gsmCtrl = TextEditingController();
    laminationCtrl = TextEditingController();
    colorCtrl = TextEditingController();
    sidCtrl = TextEditingController();
    baffleCtrl = TextEditingController();
    meshCtrl = TextEditingController();
    loomStartCtrl = TextEditingController();
    loomEndCtrl = TextEditingController();
    remarkCtrl = TextEditingController();
    grossWeightCtrl = TextEditingController();
    tareWeightCtrl = TextEditingController();
    netWeightCtrl = TextEditingController();
    rollLengthCtrl = TextEditingController();
    avgWeightMtrCtrl = TextEditingController();
    avgWeightMtrGmCtrl = TextEditingController();

    grossWeightCtrl.addListener(_calculateValues);
    tareWeightCtrl.addListener(_calculateValues);
    rollLengthCtrl.addListener(_calculateValues);
    fabricWidthCtrl.addListener(_calculateValues);

    _initialize();
  }

  Future<void> _initialize() async {
    isLoading = true;
    setState(() {});
    await _fetchNextCid();
    await loadMasterData();
    isLoading = false;
    setState(() {});
  }

  void _clearForm() {
    for (final c in [
      partyController,
      bomNoController,
      loomOrderController,
      poController,
      articleNoCtrl,
      fabricController,
      qtyKgController,
      qtyMtrController,
      grossWeightCtrl,
      tareWeightCtrl,
      netWeightCtrl,
      rollLengthCtrl,
      avgWeightMtrCtrl,
      avgWeightMtrGmCtrl,
      remarkCtrl,
      _batchController,
      _generatedCodeController,
    ]) {
      c.clear();
    }

    setState(() {
      selectedSupervisor = null;
      selectedMachine = null;
      selectedMachineType = null;
      selectedShift = null;
      selectedOperator = null;
      selectedOperator2 = null;
      selectedProductionType = null;
      selectedRollFrom = null;
      selectedLocation = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
        content: const Text("Form cleared"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _fetchNextCid() async {
    final url = Uri.parse("${InStockService.baseUrl}/LoomForward/next-cid");
    try {
      final res = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          cId = data['cId'];
          barcode = data['barcode'];
        });
      }
    } catch (e) {
      debugPrint("❌ CID API ERROR: $e");
    }
  }

  String _generateBatchNumber() {
    final party = selectedParty ?? "";

    String partyCode = party.length >= 3
        ? party.substring(0, 3).toUpperCase()
        : party.toUpperCase();

    final now = DateTime.now();

    return "$partyCode${now.day.toString().padLeft(2, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${selectedShift ?? ""}LO";
  }

  void _generateCodes() {
    if (selectedFabric == null || selectedFabric!.isEmpty) {
      Get.snackbar(
        "Warning",
        "Please select Fabric Code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _generatedCodeController.text =
        "${fabricWidthCtrl.text}"
        "-${baffleCtrl.text}"
        "-${fabricTypeCtrl.text}"
        "-${gsmCtrl.text}"
        "-${laminationCtrl.text}"
        "-${colorCtrl.text}"
        "-${cutTypeCtrl.text}"
        "-${sidCtrl.text}";

    setState(() {});
  }

  void _fillFabricDetails(String fabricCode) {
    if (fabricCode.trim().isEmpty) return;

    final parts = fabricCode.split("-");

    // Example:
    // 030-F00-AI-90+20-SL-OR-H-000
    //
    // 0 -> Fabric Width
    // 1 -> Baffle Type
    // 2 -> Fabric Type
    // 3 -> GSM
    // 4 -> Lamination
    // 5 -> Color
    // 6 -> Mesh (optional)
    // 7 -> Special ID

    fabricWidthCtrl.clear();
    baffleCtrl.clear();
    fabricTypeCtrl.clear();
    gsmCtrl.clear();
    laminationCtrl.clear();
    colorCtrl.clear();
    meshCtrl.clear();
    sidCtrl.clear();

    if (parts.isNotEmpty) fabricWidthCtrl.text = parts[0];

    if (parts.length > 1) baffleCtrl.text = parts[1];

    if (parts.length > 2) fabricTypeCtrl.text = parts[2];

    if (parts.length > 3) gsmCtrl.text = parts[3];

    if (parts.length > 4) laminationCtrl.text = parts[4];

    if (parts.length > 5) colorCtrl.text = parts[5];

    if (parts.length > 6) cutTypeCtrl.text = parts[6];

    if (parts.length > 7) sidCtrl.text = parts[7];

    _calculateValues();

    setState(() {});
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

  Future<void> loadMasterData() async {
    final data = await RmdService.getMasterData(unit: '$unit');

    if (data == null) return;

    setState(() {
      partyNames = data.customerNames;
      supervisors = data.supervisors;
      operators = data.supervisors;
      fabricCodes = data.fabricCodes;
      locations = data.locations;
    });
  }

  // Future<void> loadPoNumbers(String customerName) async {
  //   final data = await RmdService.getPoNumbers(customerName);
  //
  //   if (data == null) return;
  //
  //   setState(() {
  //     poNumbers = data.poNumbers;
  //
  //     selectedPoNo = null;
  //     selectedArticle = null;
  //     selectedBom = null;
  //
  //     articleNumbers.clear();
  //     bomNumbers.clear();
  //
  //     poController.clear();
  //     articleController.clear();
  //     bomController.clear();
  //   });
  // }

  Future loadPoNumbers(String customerName) async {
    final data = await RmdService.getPoNumbers(customerName);

    if (data == null) return;

    setState(() {
      poNumbers = List<String>.from(data.poNumbers);

      selectedPoNo = null;

      poController.clear();
      articleController.clear();
      bomController.clear();

      articleNumbers.clear();
      bomNumbers.clear();
    });

    print("PO Numbers : $poNumbers");
  }

  // Future<void> loadArticleBom(String customer, String po) async {
  //   final data = await RmdService.getArticleBom(
  //     customerName: customer,
  //     poNumber: po,
  //   );
  //
  //   if (data != null) {
  //     setState(() {
  //       articleNumbers = data.articles;
  //       bomNumbers = data.generatedInquiries;
  //
  //       articleController.clear();
  //       bomController.clear();
  //     });
  //   }
  // }

  Future<void> loadArticleBom(String customer, String po) async {
    final data = await RmdService.getArticleBom(
      customerName: customer,
      poNumber: po,
    );

    if (data == null) return;

    setState(() {
      articleNumbers = List<String>.from(data.articles);
      bomNumbers = List<String>.from(data.generatedInquiries);

      selectedArticle = null;
      selectedBom = null;

      articleController.clear();
      bomController.clear();
    });

    print("Article List : $articleNumbers");
    print("BOM List : $bomNumbers");
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

    setState(() {});
  }

  Future<void> _saveRollEntry() async {
    final body = {
      // "articleNo": selectedArticle ?? "",
      "generateCode": _generatedCodeController.text,
      // "supervisor": supervisorController.text,
      "specialId": sidCtrl.text,
      "fabricType": fabricTypeCtrl.text,
      "fabricWidth": fabricWidthCtrl.text,
      "color": colorCtrl.text,
      "laminationType": laminationCtrl.text,
      "fabricGsm": gsmCtrl.text,
      "cutType": cutTypeCtrl.text,
      "fabricBaffle": baffleCtrl.text,
      "rollWeight": netWeightCtrl.text,
      "rollLength": rollLengthCtrl.text,
      "remark": remarkCtrl.text,
      "rollFrom": selectedRollFrom ?? "",
      // "purchaseOrder": selectedPoNo ?? "N/A",
      "tareWeight": tareWeightCtrl.text,
      "grossWeight": grossWeightCtrl.text,
      "mesh": meshCtrl.text,

      // "partyName": selectedParty ?? "",
      "partyName": partyController.text.trim(),
      "supervisor": supervisorController.text.trim(),
      "operator": operatorController.text.trim(),
      // "location": locationController.text.trim(),
      "purchaseOrder": poController.text.trim(),
      "articleNo": articleController.text.trim(),
      "bomNo": bomController.text.trim(),
      "fabricCode": fabricController.text.trim(),

      "avgWeight": avgWeightMtrCtrl.text,
      "productionType": selectedProductionType ?? "",
      "location": selectedLocation ?? locationController.text.trim(),
      // "bomNo": selectedBom ?? "",
    };

    setState(() {
      isLoading = true;
    });
    debugPrint(" Save Body:$body");

    if (selectedParty == null ||
        selectedFabric == null ||
        selectedSupervisor == null ||
        selectedProductionType == null) {
      setState(() {
        isLoading = false; // Reset loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all mandatory fields."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      return; // Stay on the same screen
    }
    debugPrint(" Save Body:$body");
    final success = await RmdService.saveRollEntry(body: body);

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data Saved Successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true); // Go back only after successful save
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save data"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("RMD Roll Entry", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: C.appBar1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: C.border,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RmdRollSavedList()),
                );
              },
              child: const Text(
                "Saved List",
                style: TextStyle(
                  color: C.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        // C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionCard(
                          title: "General Info",
                          icon: Icons.info_outline_rounded,
                          children: [
                            responsiveRow([
                              buildDropdown(
                                label: "Production Type",
                                icon: Icons.category_outlined,
                                value: selectedProductionType,
                                items: productionTypes,
                                onChanged: (v) =>
                                    setState(() => selectedProductionType = v),
                              ),
                              buildDropdown(
                                label: "Roll From",
                                icon: Icons.move_down_outlined,
                                value: selectedRollFrom,
                                items: rollFromList,
                                onChanged: (v) =>
                                    setState(() => selectedRollFrom = v),
                              ),
                              buildDropdown(
                                label: "Location",
                                value: selectedLocation,
                                items: locations,
                                icon: Icons.location_on,
                                onChanged: (v) {
                                  setState(() {
                                    selectedLocation = v;
                                  });
                                },
                              ),
                            ]),
                          ],
                        ),
                        _sectionCard(
                          title: "Fabric Info",
                          icon: Icons.precision_manufacturing_outlined,
                          children: [
                            responsiveRow([
                              buildEditableDropdown(
                                label: "Supervisor",
                                items: supervisors,
                                controller: supervisorController,
                                icon: Icons.person,
                                onSelected: (value) {
                                  selectedSupervisor = value;
                                },
                              ),
                              responsiveRow([
                                buildEditableDropdown(
                                  label: "Operator",
                                  items: operators,
                                  controller: operatorController,
                                  icon: Icons.person,
                                  onSelected: (value) {
                                    selectedOperator = value;
                                  },
                                ),
                                // buildDropdown(
                                //   label: "Fabric Code",
                                //   value: selectedFabric,
                                //   items: fabricCodes,
                                //   icon: Icons.view_quilt,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       selectedFabric = value;
                                //     });
                                //
                                //     if (value != null) {
                                //       _fillFabricDetails(value);
                                //     }
                                //   },
                                // ),
                                buildEditableDropdown(
                                  label: "Fabric Code",
                                  items: fabricCodes,
                                  controller: fabricController,
                                  icon: Icons.view_quilt,
                                  onSelected: (value) {
                                    selectedFabric = value;
                                    _fillFabricDetails(value);
                                  },
                                ),
                                buildEditableDropdown(
                                  label: "Party Name",
                                  items: partyNames,
                                  controller: partyController,
                                  icon: Icons.business,

                                  onSelected: (value) async {
                                    selectedParty = value;
                                    await loadPoNumbers(value);
                                  },

                                  onChanged: (value) async {
                                    selectedParty = value;

                                    if (partyNames.contains(value)) {
                                      await loadPoNumbers(value);
                                    } else {
                                      setState(() {
                                        poNumbers.clear();
                                        articleNumbers.clear();
                                        bomNumbers.clear();

                                        poController.clear();
                                        articleController.clear();
                                        bomController.clear();
                                      });
                                    }
                                  },
                                ),
                              ]),
                            ]),
                          ],
                        ),
                        _sectionCard(
                          title: "Order Details",
                          icon: Icons.assignment_outlined,
                          children: [
                            responsiveRow([
                              // buildDropdown(
                              //   label: "PO Number",
                              //   icon: Icons.confirmation_number,
                              //   value: selectedPoNo,
                              //   items: poNumbers,
                              //   onChanged: (value) async {
                              //     setState(() {
                              //       selectedPoNo = value;
                              //     });
                              //
                              //     if (selectedParty != null && value != null) {
                              //       await loadArticleBom(selectedParty!, value);
                              //     }
                              //   },
                              // ),
                              buildEditableDropdown(
                                key: ValueKey(poNumbers.join(",")),
                                label: "PO Number",
                                items: List<String>.from(poNumbers),
                                controller: poController,
                                icon: Icons.confirmation_number,

                                onSelected: (value) async {
                                  selectedPoNo = value;

                                  await loadArticleBom(
                                    partyController.text.trim(),
                                    value,
                                  );
                                },
                              ),

                              // buildDropdown(
                              //   label: "BOM Number",
                              //   icon: Icons.numbers,
                              //   value: selectedBom,
                              //   items: bomNumbers,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       selectedBom = value;
                              //     });
                              //   },
                              // ),
                              buildEditableDropdown(
                                key: ValueKey(bomNumbers.join(",")),
                                label: "BOM Number",
                                items: List<String>.from(bomNumbers),
                                controller: bomController,
                                icon: Icons.numbers,

                                onSelected: (value) {
                                  setState(() {
                                    selectedBom = value;
                                  });
                                },

                                onChanged: (value) {
                                  selectedBom = value;
                                },
                              ),

                              // buildDropdown(
                              //   label: "Article Number",
                              //   icon: Icons.article,
                              //   value: selectedArticle,
                              //   items: articleNumbers,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       selectedArticle = value;
                              //     });
                              //   },
                              // ),
                              buildEditableDropdown(
                                key: ValueKey(articleNumbers.join(",")),
                                label: "Article Number",
                                items: List<String>.from(articleNumbers),
                                controller: articleController,
                                icon: Icons.article,

                                onSelected: (value) {
                                  setState(() {
                                    selectedArticle = value;
                                  });
                                },

                                onChanged: (value) {
                                  selectedArticle = value;
                                },
                              ),
                            ]),
                          ],
                        ),
                        _sectionCard(
                          title: "Fabric",
                          icon: Icons.monitor_weight_outlined,
                          children: [
                            responsiveRow([
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Fabric Width",
                                      controller: fabricWidthCtrl,
                                      icon: Icons.straighten,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildField(
                                      "Fabric Baffle Type",
                                      controller: baffleCtrl,
                                      icon: Icons.grid_view,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Fabric Type",
                                      controller: fabricTypeCtrl,
                                      icon: Icons.category,
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  Expanded(
                                    child: _buildField(
                                      "Fabric GSM",
                                      controller: gsmCtrl,
                                      icon: Icons.scale,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Lamination Type",
                                      controller: laminationCtrl,
                                      icon: Icons.layers,
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  Expanded(
                                    child: _buildField(
                                      "Color",
                                      controller: colorCtrl,
                                      icon: Icons.palette,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Cut Type",
                                      controller: cutTypeCtrl,
                                      icon: Icons.blur_on,
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  Expanded(
                                    child: _buildField(
                                      "Special ID",
                                      controller: sidCtrl,
                                      icon: Icons.tag,
                                    ),
                                  ),
                                ],
                              ),
                            ]),

                          ],
                        ),
                        _sectionCard(
                          title: "Weight & Length",
                          icon: Icons.monitor_weight_outlined,
                          children: [
                            responsiveRow([
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Gross Weight",
                                      controller: grossWeightCtrl,

                                      suffix: "kg",
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildField(
                                      "Tare Weight",
                                      controller: tareWeightCtrl,

                                      suffix: "kg",
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Roll Length",
                                      controller: rollLengthCtrl,

                                      suffix: "m",
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildField(
                                      "Roll Weight",
                                      controller: netWeightCtrl,

                                      readOnly: true,
                                      suffix: "kg",
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      "Avg Wt(Gm)",
                                      controller: avgWeightMtrCtrl,

                                      readOnly: true,
                                      suffix: "g/m",
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildField(
                                      "Mesh",
                                      controller: meshCtrl,
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                        _sectionCard(
                          title: "Generated Codes",
                          icon: Icons.qr_code_2_rounded,
                          children: [
                            responsiveRow([
                              // _buildField(
                              //   "Batch No",
                              //   controller: _batchController,
                              //   icon: Icons.confirmation_number_outlined,
                              //   readOnly: true,
                              // ),
                              _buildField(
                                "Generated Code",
                                controller: _generatedCodeController,
                                icon: Icons.code_rounded,
                                readOnly: true,
                              ),
                            ]),
                          ],
                        ),

                        _sectionCard(
                          title: "Remark",
                          icon: Icons.notes_rounded,
                          children: [
                            _buildField(
                              "Remark",
                              controller: remarkCtrl,
                              icon: Icons.edit_note_rounded,
                              maxLines: 3,
                              fullWidth: true,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _generateCodes,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Generate Code"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isLoading ? null : _buildActionBar(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: C.primaryDark),
          SizedBox(height: 14),
          Text(
            "Loading entry details…",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 12.5,
              color: C.appBar1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky Action Bar ───────────────────────────────────────
  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Clear"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _saveRollEntry,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text("Save Entry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.appBar1,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Card ────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: C.appBar1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: C.appBar1),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ── Field ───────────────────────────────────────────────────
  Widget _buildField(
    String label, {
    TextEditingController? controller,
    IconData? icon,
    int maxLines = 1,
    bool fullWidth = false,
    bool readOnly = false,
    String? suffix,
  }) {
    return Padding(
      padding: fullWidth ? const EdgeInsets.only(bottom: 4) : EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 13,
          color: readOnly ? C.appBar1 : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12.5, color: Colors.black54),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  size: 17,
                  color: readOnly ? C.appBar1 : Colors.black38,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 0,
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            fontSize: 11.5,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: readOnly
              ? C.appBar1.withOpacity(0.05)
              : const Color(0xFFF6F7FB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: readOnly
                ? BorderSide(color: C.primaryDark)
                : BorderSide(color: C.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: readOnly
                ? BorderSide(color: C.appBar1.withOpacity(0.18))
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: C.appBar1, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12.5, color: Colors.black54),
        prefixIcon: icon != null
            ? Icon(icon, size: 17, color: Colors.black38)
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: C.appBar1, width: 1.5),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget buildEditableDropdown({
    Key? key,
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required Function(String value) onSelected,
    Function(String value)? onChanged,
    IconData? icon,
  }) {
    return Autocomplete<String>(
      key: key,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();

        if (query.isEmpty) {
          return items;
        }

        return items.where((item) => item.toLowerCase().contains(query));
      },

      displayStringForOption: (option) => option,

      onSelected: (value) {
        controller.text = value;
        onSelected(value);
      },

      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.value = TextEditingValue(
              text: controller.text,
              selection: TextSelection.collapsed(
                offset: controller.text.length,
              ),
            );

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                isDense: true,
                prefixIcon: icon != null ? Icon(icon,size: 16,) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                controller.text = value;

                if (onChanged != null) {
                  onChanged(value);
                }
              },
            );
          },

      optionsViewBuilder:
          (
            context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 150,
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);

                      return ListTile(
                        dense: true,
                        minTileHeight: 32,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4,
                        ),
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }

  // ── Responsive Grid Row ─────────────────────────────────────
  Widget responsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 1;
        if (constraints.maxWidth > 1100) {
          count = 4;
        } else if (constraints.maxWidth > 800) {
          count = 3;
        } else if (constraints.maxWidth > 500) {
          count = 2;
        }

        const spacing = 10.0;
        final width = (constraints.maxWidth - ((count - 1) * spacing)) / count;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((e) => SizedBox(width: width, child: e))
              .toList(),
        );
      },
    );
  }
}

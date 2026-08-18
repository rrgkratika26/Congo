import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../Color/Colorclass.dart';
import '../../services/GlobalLoader/GloabalUnit.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ModelClass/Bom/PartyNameDropdown.dart';
import 'ModelClass/CombineToLoomModel.dart';
import 'ModelClass/DropdownModel_GenCode.dart';
import 'ModelClass/ForwardListModel.dart';
import 'ModelClass/PartyNameModel.dart';

class ManualToLoomScreen extends StatefulWidget {
  // final CombineToLoomModel data;

  const ManualToLoomScreen({super.key});

  @override
  State<ManualToLoomScreen> createState() => _ManualToLoomScreenState();
}

class _ManualToLoomScreenState extends State<ManualToLoomScreen> {
  bool dropdownLoading = true;

  String? selectedPartyName;
  String? selectedPoNo;
  String? selectedArticle;

  // List<InquiryModel> inquiryList = [];
  List<String> inquiryList = [];
  String? selectedBomNo;
  List<String> partyList = [];
  List<String> poList = [];
  List<String> articleList = [];
  late String _unit;
  List<FabricDropdownModel> typeList = [];
  List<FabricDropdownModel> fabricTypeList = [];
  List<FabricDropdownModel> colorList = [];
  List<FabricDropdownModel> laminationList = [];
  List<FabricDropdownModel> cutList = [];
  List<FabricDropdownModel> specialList = [];
  String generatedFabricCode = "";
  String? selectedType;
  String? selectedFabricType;
  String? selectedLamination;
  String? selectedColor;
  String? selectedCut;
  String? selectedSpecial;
  PartyNameModel? partyData;

  String? apiFabricCode;

  List<ForwardListModel> forwardList = [];
  String forwardResponse = "";
  String partyResponse = "";
  bool tableLoading = true;
  final widthController = TextEditingController();
  bool isForwardLoading = false;
  final gsmController = TextEditingController();
  final poController = TextEditingController();
  final articleController = TextEditingController();
  final extraMtrController = TextEditingController();
  final reqMtrController = TextEditingController();
  final reqKgController = TextEditingController();
  final extraKgController = TextEditingController();
  final bomController = TextEditingController();
  final partyController = TextEditingController();
  Map<String, PartyNameModel> partyMap = {};
  double actualMtr = 0;
  double actualKg = 0;

  @override
  void initState() {
    super.initState();
    loadUnit();
    extraMtrController.addListener(calculateValues);
    reqMtrController.addListener(calculateValues);
    reqKgController.addListener(calculateValues);
    _initialize();
  }

  Future<void> loadUnit() async {
    _unit = (await AppSession.getUnit())!;

    debugPrint("Unit = $_unit");

    await _initialize();
  }

  Future<void> _initialize() async {
    // await AppSession.init();

    _unit = await AppSession.getUnit() ?? "";

    print("Loaded Unit : $_unit");

    await loadDropdownData();
    await loadBomList();
    await _loadData();
  }

  @override
  void dispose() {
    poController.dispose();
    articleController.dispose();
    bomController.dispose();
    partyController.dispose();
    reqMtrController.dispose();
    reqKgController.dispose();
    widthController.dispose();
    gsmController.dispose();
    extraMtrController.dispose();
    extraKgController.dispose();

    super.dispose();
  }

  void calculateValues() {
    double reqMtr = double.tryParse(reqMtrController.text) ?? 0;
    double reqKg = double.tryParse(reqKgController.text) ?? 0;

    double extraMtr = double.tryParse(extraMtrController.text) ?? 0;

    double calculatedExtraKg = reqMtr == 0 ? 0 : (reqKg * extraMtr) / reqMtr;

    int roundedExtraKg = calculatedExtraKg.round();

    extraKgController.text = roundedExtraKg.toString();

    setState(() {
      actualMtr = reqMtr + extraMtr;

      // Rounded Extra KG add hoga
      actualKg = reqKg + roundedExtraKg;
    });
  }
  // void calculateValues() {
  //   double reqMtr = double.tryParse(widget.data.mtr.toString()) ?? 0;
  //
  //   double reqKg = double.tryParse(widget.data.kg.toString()) ?? 0;
  //
  //   double extraMtr = double.tryParse(extraMtrController.text) ?? 0;
  //
  //   double extraKg = reqMtr == 0 ? 0 : (reqKg * extraMtr) / reqMtr;
  //
  //   /// Approx rounded value
  //   int roundedExtraKg = extraKg.round();
  //
  //   extraKgController.text = roundedExtraKg.round().toString();
  //
  //   setState(() {
  //     actualMtr = reqMtr + extraMtr;
  //
  //     actualKg = reqKg + extraKg;
  //   });
  // }

  void generateFabricCode() {
    generatedFabricCode =
        "${widthController.text.isEmpty ? '000' : widthController.text}"
        "-${selectedFabricType ?? 'F00'}"
        "-${selectedType ?? 'AI'}"
        "-${gsmController.text.isEmpty ? '000' : gsmController.text}"
        "-${selectedLamination ?? 'UL'}"
        "-${selectedColor ?? 'WH'}"
        "-${selectedCut ?? 'H'}"
        "-${selectedSpecial ?? '000'}";

    setState(() {});
  }

  void setFabricValuesFromApi(String fabricCode) {
    try {
      final parts = fabricCode.trim().split('-');

      if (parts.length != 8) {
        debugPrint("Invalid Fabric Code => $fabricCode");
        return;
      }

      widthController.text = parts[0];
      gsmController.text = parts[3];

      selectedFabricType = parts[1];
      selectedType = parts[2];
      selectedLamination = parts[4];
      selectedColor = parts[5];
      selectedCut = parts[6];
      selectedSpecial = parts[7];

      generateFabricCode();

      setState(() {});
    } catch (e) {
      debugPrint("Fabric Parse Error: $e");
    }
  }

  Future<void> loadDropdownData() async {
    try {
      final response = await NaradanaApiService().getFabricDropdowns(_unit);

      for (var item in response) {
        switch (item.type) {
          case "Typee":
            typeList = item.data;
            break;

          case "TypeOfFabric":
            fabricTypeList = item.data;
            break;

          case "Color":
            colorList = item.data;
            break;

          case "Lamination":
            laminationList = item.data;
            break;

          case "Cut":
            cutList = item.data;
            break;

          case "Series":
            specialList = item.data;
            break;
        }
      }

      setState(() {
        dropdownLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        dropdownLoading = false;
      });
    }
  }

  Future<void> forwardToLoomApi() async {
    if (generatedFabricCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please generate fabric code")),
      );
      return;
    }

    setState(() {
      isForwardLoading = true;
    });

    Map<String, dynamic> body = {
      "ordeR_NO": 0,
      "boM_NO": selectedBomNo,
      "fabriC_CODE": generatedFabricCode,

      "requireD_MTR": reqMtrController.text,
      "requireD_KG": reqKgController.text,

      "extrA_MTR": extraMtrController.text.isEmpty
          ? "0"
          : extraMtrController.text,

      "extrA_KG": extraKgController.text.isEmpty ? "0" : extraKgController.text,

      "actuaL_REQUIRED_MTR": actualMtr.round().toString(),

      "actuaL_REQUIRED_KG": actualKg.round().toString(),

      "customeR_NAME": selectedPartyName,
      "pO_NUM": selectedPoNo ?? "",
      "articlE_NUM": selectedArticle ?? "",

      // "pO_NUM": partyData?.poNum ?? "",
      //
      // "articlE_NUM": partyData?.articleNum ?? "",
      "forward_By": "Manual",
    };

    bool success = await NaradanaApiService().forwardPlanningToLoom(
      unit: _unit,
      body: body,
    );

    setState(() {
      isForwardLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Forwarded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Get.back(result: true);

      // Get.to(() => NewAdminDashboard());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to Forward"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget infoDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    final validValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: validValue,
          isExpanded: true,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),

          items: items
              .toSet()
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildField(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        SizedBox(height: 46, child: child),
      ],
    );
  }

  Widget customTextField({
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: (_) => generateFabricCode(),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade200,

        contentPadding: const EdgeInsets.symmetric(horizontal: 12),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget customDropdown({
    required String title,
    required List<FabricDropdownModel> list,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    final validValue = list.any((e) => e.code == selectedValue)
        ? selectedValue
        : null;

    return buildField(
      title,
      DropdownButtonFormField<String>(
        initialValue: validValue,
        isExpanded: true,

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),

        hint: const Text("Select"),

        items: list.map((e) {
          return DropdownMenuItem<String>(
            value: e.code,
            child: Text(e.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.yellow.shade100,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey.shade200)],
      ),

      child: Column(
        children: [
          Icon(icon, color: C.primary),

          const SizedBox(height: 2),

          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final columns = width < 700 ? 2 : 3;

    List<Widget> formFields = [
      customDropdown(
        title: "Fabric Type",
        list: fabricTypeList,
        selectedValue: selectedFabricType,
        onChanged: (v) {
          setState(() {
            selectedFabricType = v;
          });
          generateFabricCode();
        },
      ),

      customDropdown(
        title: "Type",
        list: typeList,
        selectedValue: selectedType,
        onChanged: (v) {
          setState(() {
            selectedType = v;
          });
          generateFabricCode();
        },
      ),

      customDropdown(
        title: "Lamination",
        list: laminationList,
        selectedValue: selectedLamination,
        onChanged: (v) {
          setState(() {
            selectedLamination = v;
          });
          generateFabricCode();
        },
      ),

      customDropdown(
        title: "Color",
        list: colorList,
        selectedValue: selectedColor,
        onChanged: (v) {
          setState(() {
            selectedColor = v;
          });
          generateFabricCode();
        },
      ),

      customDropdown(
        title: "Cut",
        list: cutList,
        selectedValue: selectedCut,
        onChanged: (v) {
          setState(() {
            selectedCut = v;
          });
          generateFabricCode();
        },
      ),

      customDropdown(
        title: "Special",
        list: specialList,
        selectedValue: selectedSpecial,
        onChanged: (v) {
          setState(() {
            selectedSpecial = v;
          });
          generateFabricCode();
        },
      ),
      buildField("Width", customTextField(controller: widthController)),

      buildField(
        "GSM",
        customTextField(
          controller: gsmController,
          keyboardType: TextInputType.number,
        ),
      ),

      buildField(
        "Extra MTR",
        customTextField(
          controller: extraMtrController,
          keyboardType: TextInputType.number,
        ),
      ),

      buildField(
        "Extra KG",
        customTextField(controller: extraKgController, enabled: false),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: C.bg),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [
            /// Party Name
            Text(
              "Manual Loom Planning",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: C.appBar1,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(colors: [C.appBar2, C.appBar3]),
        //   ),
        // ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: C.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(15),

                child: dropdownLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: formFields.length,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,

                          crossAxisSpacing: 8,

                          mainAxisSpacing: 8,

                          childAspectRatio: 1.4,
                        ),

                        itemBuilder: (_, index) {
                          return formFields[index];
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: C.primaryLight,

              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// BOM + PO
                    Row(
                      children: [
                        //       Expanded(
                        //         child:infoDropdown(
                        // title: "BOM No",
                        // value: selectedBomNo,
                        //           items: inquiryList,
                        //           onChanged: (value) {
                        //             setState(() {
                        //               selectedBomNo = value;
                        //             });
                        //           },
                        //
                        //         ),
                        //       ),
                        //
                        //       const SizedBox(width: 8),
                        //
                        //       Expanded(
                        //         child: infoDropdown(
                        //           title: "Party Name",
                        //           value: selectedPartyName,
                        //           items: partyList,
                        //           onChanged: (value) {
                        //             setState(() {
                        //               selectedPartyName = value;
                        //             });
                        //           },
                        //
                        //         ),
                        //       ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "BOM No",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),

                              Autocomplete<String>(
                                optionsBuilder: (TextEditingValue value) {
                                  if (value.text.isEmpty) {
                                    return inquiryList;
                                  }

                                  return inquiryList.where(
                                    (e) => e.toLowerCase().contains(
                                      value.text.toLowerCase(),
                                    ),
                                  );
                                },

                                onSelected: (value) {
                                  setState(() {
                                    selectedBomNo = value;
                                    bomController.text = value;
                                  });
                                },

                                fieldViewBuilder:
                                    (
                                      context,
                                      textController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      textController.text = bomController.text;

                                      return TextField(
                                        controller: textController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText: "Enter BOM No",
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          selectedBomNo = value;
                                          bomController.text = value;
                                        },
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: editableDropdown(
                            title: "Party Name",
                            controller: partyController,
                            items: partyList,
                            onSelected: (value) {
                              setState(() {
                                selectedPartyName = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// Party
                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            "PO No",
                            TextField(
                              controller: poController,
                              decoration: InputDecoration(
                                hintText: "Enter PO No",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                selectedPoNo = value;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: buildField(
                            "Article",
                            TextField(
                              controller: articleController,
                              decoration: InputDecoration(
                                hintText: "Enter Article",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                selectedArticle = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: buildField(
                    "Required MTR",
                    customTextField(
                      controller: reqMtrController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: summaryCard(
                    "Actual MTR",
                    actualMtr.toStringAsFixed(2),
                    Icons.calculate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: buildField(
                    "Required KG",
                    customTextField(
                      controller: reqKgController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: summaryCard(
                    "Actual KG",
                    actualKg.toStringAsFixed(2),
                    Icons.analytics,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal.shade200,

                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    generatedFabricCode.isEmpty
                        ? "Not Generated"
                        : generatedFabricCode,
                    style: const TextStyle(
                      color: C.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              height: 50,
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: isForwardLoading
                    ? null
                    : () async {
                        generateFabricCode();

                        await forwardToLoomApi();
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: C.primaryDark,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                icon: const Icon(Icons.send, color: Colors.white),

                label: isForwardLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "FORWARD TO LOOM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editableDropdown({
    required String title,
    required TextEditingController controller,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),

        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return items;
            }

            return items.where(
              (item) => item.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },

          onSelected: (value) {
            controller.text = value;
            onSelected(value);
          },

          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
                textController.text = controller.text;

                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );

                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    controller.text = value;
                    onSelected(value);
                  },
                );
              },
        ),
      ],
    );
  }

  Future loadBomList() async {
    final data = await InStockService().getBomPartyList();

    inquiryList =
        (data["generatedInquiry"] as List?)
            ?.map((e) => e.toString().trim())
            .toSet()
            .toList() ??
        [];

    partyList =
        (data["customerNames"] as List?)
            ?.map((e) => e.toString().trim())
            .toSet()
            .toList() ??
        [];

    setState(() {});
  }

  Future<void> _loadData() async {
    partyList = partyMap.values.map((e) => e.partyName).toSet().toList();

    poList = partyMap.values.map((e) => e.poNum).toSet().toList();

    articleList = partyMap.values.map((e) => e.articleNum).toSet().toList();

    // if (bomList.isNotEmpty) {
    //   selectedBomNo = bomList.first;
    //   partyData = partyMap[selectedBomNo];
    //   selectedPartyName = partyData?.partyName;
    //   selectedPoNo = partyData?.poNum;
    //   selectedArticle = partyData?.articleNum;
    // }
    try {
      print("AppCtrl Unit : $_unit");
      print("Global Unit : ${AppGlobals.unit}");
      forwardList = await NaradanaApiService().getForwardList(
        unit: _unit,
        orderNo: "0",
      );

      debugPrint("========= FORWARD LIST =========");

      for (var item in forwardList) {
        debugPrint(
          "Order:${item.orderNo}"
          " BOM:${item.bomNo}",
        );

        /// BOM use karke Party API call
        if (item.bomNo.isNotEmpty) {
          String bomNo = item.bomNo.trim();

          debugPrint("Sending BOM => $bomNo");
          final party = await NaradanaApiService().getPartyDetails(
            unit: _unit!,
            bomNo: item.bomNo,
          );

          if (party != null) {
            partyMap[item.bomNo] = party;

            partyData = party;

            /// Get fabric code from ForwardList
            if (item.fabricCode.isNotEmpty) {
              setFabricValuesFromApi(item.fabricCode);
            }

            setState(() {});
          }
        }
      }
    } catch (e) {
      debugPrint("ERROR : $e");
    }

    setState(() {
      tableLoading = false;
    });
  }
}

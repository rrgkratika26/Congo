import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ModelClass/CombineToLoomModel.dart';
import 'ModelClass/DropdownModel_GenCode.dart';
import 'ModelClass/ForwardListModel.dart';
import 'ModelClass/PartyNameModel.dart';

class GenerateCodeScreen extends StatefulWidget {
  final CombineToLoomModel data;

  const GenerateCodeScreen({super.key, required this.data});

  @override
  State<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends State<GenerateCodeScreen> {
  bool dropdownLoading = true;

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

  final extraMtrController = TextEditingController();

  final extraKgController = TextEditingController();
  String? unit = AppSession.unit;
  Map<String, PartyNameModel> partyMap = {};
  double actualMtr = 0;
  double actualKg = 0;

  @override
  void initState() {
    super.initState();

    actualMtr = double.tryParse(widget.data.mtr.toString()) ?? 0;
    actualKg = double.tryParse(widget.data.kg.toString()) ?? 0;

    extraMtrController.addListener(calculateValues);

    _initialize();
  }

  Future<void> _initialize() async {
    await loadDropdownData();
    await _loadData();
  }

  @override
  void dispose() {
    widthController.dispose();
    gsmController.dispose();
    extraMtrController.dispose();
    extraKgController.dispose();

    super.dispose();
  }

  void calculateValues() {
    double reqMtr = double.tryParse(widget.data.mtr.toString()) ?? 0;

    double reqKg = double.tryParse(widget.data.kg.toString()) ?? 0;

    double extraMtr = double.tryParse(extraMtrController.text) ?? 0;

    double extraKg = reqMtr == 0 ? 0 : (reqKg * extraMtr) / reqMtr;

    /// Approx rounded value
    int roundedExtraKg = extraKg.round();

    extraKgController.text = roundedExtraKg.toString();


    setState(() {
      actualMtr = reqMtr + extraMtr;

      actualKg = reqKg + extraKg;
    });
  }

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
      final response = await NaradanaApiService().getFabricDropdowns();

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
      "ordeR_NO": int.tryParse(widget.data.orderNo.toString()) ?? 0,

      "fabriC_CODE": generatedFabricCode,

      "requireD_MTR": widget.data.mtr.toString(),

      "requireD_KG": widget.data.kg.toString(),

      "extrA_MTR": extraMtrController.text.isEmpty
          ? "0"
          : extraMtrController.text,

      "extrA_KG": extraKgController.text.isEmpty ? "0" : extraKgController.text,

      "actuaL_REQUIRED_MTR": actualMtr.toStringAsFixed(2),

      "actuaL_REQUIRED_KG": actualKg.toStringAsFixed(2),

      "customeR_NAME": partyData?.partyName ?? "",

      "pO_NUM": partyData?.poNum ?? "",

      "articlE_NUM": partyData?.articleNum ?? "",
    };

    bool success = await NaradanaApiService().forwardPlanningToLoom(
      unit: unit!,
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

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to Forward"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        value: validValue,
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
            child: Text(
              e.name,
              overflow: TextOverflow.ellipsis,
            ),
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

          const SizedBox(height: 5),

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
              "${partyData?.partyName ?? "Loading..."}",
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

                  const Text(
                    "Generated Fabric Code",
                    style: TextStyle(
                      color: C.textHigh,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 1),

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
                  /// Article
                  Text(
                    "Article : ${partyData?.articleNum ?? widget.data.articleNum}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: C.textHigh),
                  ),

                  /// PO
                  Text(
                    "PO : ${partyData?.poNum ?? widget.data.poNum}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: C.textHigh),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    "Req MTR",
                    widget.data.mtr.toString(),
                    Icons.straighten,
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
                  child: summaryCard(
                    "Req KG",
                    widget.data.kg.toString(),
                    Icons.scale,
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

            const SizedBox(height: 15),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Forward List",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (tableLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (forwardList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No data found",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          headingRowColor: WidgetStatePropertyAll(
                            Colors.blue.shade50,
                          ),

                          columnSpacing: 25,

                          columns: const [
                            DataColumn(
                              label: Text(
                                "BOM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Component",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "Fab Code",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "MTR",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "KG",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],

                          rows: forwardList.map((item) {
                            final party = partyMap[item.bomNo];

                            return DataRow(
                              cells: [
                                DataCell(Text(item.bomNo)),

                                DataCell(Text(item.component)),

                                DataCell(Text(item.fabricCode)),

                                DataCell(Text(item.mtr.toString())),

                                DataCell(Text(item.kg.toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                  backgroundColor: C.primary,

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

  Future<void> _loadData() async {
    unit = await AppSession.getUnit();

    if (unit == null) return;

    try {
      forwardList = await NaradanaApiService().getForwardList(
        unit: unit!,
        orderNo: widget.data.orderNo.toString(),
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
            unit: unit!,
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

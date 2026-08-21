import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../Color/Colorclass.dart';
import '../../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../../routes/app_routes.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ModelClass/PlanningModel.dart';
import 'ModelClass/OrderPlanningModel.dart';

class OrderPlanningScreen2 extends StatefulWidget {
  final OrderPlanningModel orderData;

  const OrderPlanningScreen2({super.key, required this.orderData});

  @override
  State<OrderPlanningScreen2> createState() => _OrderPlanningScreen2State();
}

class _OrderPlanningScreen2State extends State<OrderPlanningScreen2> {
  final ScrollController horizontalCtrl = ScrollController();
  final TextEditingController wastageController = TextEditingController(
    text: "0",
  );
  String wastageValue = "0";
  final ScrollController listCtrl = ScrollController();
  String? unit;
  List<PlanningModel> planningList = [];
  List<String> departments = ["LOOM", "STORE", "TAPE", "WEBBING"];
  Map<String, String> departmentWastage = {
    "LOOM": "0",
    "STORE": "0",
    "TAPE": "0",
    "WEBBING": "0",
  };
  String startDate = "";
  String endDate = "";
  String selectedDepartment = "LOOM";
  bool isLoading = true;
  bool _isSaving = false;

  static const w1 = 90.0;
  static const w2 = 190.0;
  static const w = 75.0;

  double get totalWidth => w1 + w2 + (w * 13);

  @override
  void initState() {
    super.initState();
    wastageController.text = departmentWastage[selectedDepartment] ?? "0";
    _loadUnit();
    loadPlanning();
  }

  @override
  void dispose() {
    wastageController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await NaradanaApiService().savePlanning(
        woNumber: widget.orderData.generatedInquiry,
        quantity: widget.orderData.quantity,
        poNum: widget.orderData.poNum,
        articleNum: widget.orderData.articleNo,
        items: planningList,
        unit: unit ?? "",
      );

      Navigator.pop(context);

      Get.offNamed(AppRoutes.orderComposition);

      Get.snackbar(
        "Success",
        "Data Saved Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _isSaving = false;
    }
  }
  // Future loadPlanning() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     final result = await NaradanaApiService().fetchPlanningData(
  //       inquiryNo: widget.orderData.generatedInquiry,
  //     );
  //
  //
  //
  //     setState(() {
  //       planningList = result;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //
  //     debugPrint(e.toString());
  //   }
  // }

  Future loadPlanning() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await NaradanaApiService().fetchPlanningData(
        inquiryNo: widget.orderData.generatedInquiry,
      );

      // Filter unwanted rows
      final filteredData = result.where((item) {
        final row = item.rowList.toUpperCase();

        return row != "LABEL" &&
            row != "DOC" &&
            row != "PRINTING" &&
            row != "FLAP TIE HOOK" &&
            row != "INK1";
      }).toList();

      setState(() {
        planningList = filteredData;

        if (filteredData.isNotEmpty) {
          // API response:
          // extrA38 = 13-Nov-2025
          // extrA39 = 25-Nov-2025

          startDate = filteredData.first.startDate.trim();
          endDate = filteredData.first.endDate.trim();
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  // Future loadPlanning() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     final result = await NaradanaApiService().fetchPlanningData(
  //       // dynamic inquiry
  //       inquiryNo: widget.orderData.generatedInquiry,
  //     );
  //
  //     setState(() {
  //       planningList = result;
  //
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //
  //     debugPrint(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: C.appBar1,
        iconTheme: const IconThemeData(color: Colors.white),

        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [C.appBar2, C.appBar3]),
        //   ),
        // ),
        title: const Text(
          "FIBC Planning",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _topSection(),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: C.appBar3),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: _table(),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.warning.withOpacity(0.7),
                      ),
                      onPressed: _saveData,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topSection() {
    return Padding(
      padding: const EdgeInsets.all(12),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _infoCard("PO.Date", startDate, Icons.calendar_today),
              ),

              const SizedBox(width: 10),

              Expanded(child: _infoCard("Dispatch Date", endDate, Icons.event)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  "BOM No.",
                  widget.orderData.generatedInquiry,
                  Icons.badge,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _infoCard(
                  "PO No",
                  widget.orderData.poNum,
                  Icons.receipt,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  "Article",
                  widget.orderData.articleNo,
                  Icons.inventory,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _infoCard(
                  "Quantity",
                  widget.orderData.quantity,
                  Icons.shopping_cart,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: _departmentSelector()),
              const SizedBox(width: 10),
              Expanded(child: _wastageDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _table() {
    return Scrollbar(
      controller: horizontalCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: horizontalCtrl,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: listCtrl,

                      itemCount: planningList.length,
                      itemBuilder: (_, index) =>
                          _row(planningList[index], index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 50,

      color: C.bg,

      child: Row(
        children: [
          head("COMPONENT", w1),

          head("FABRIC Code", w2),

          head("GSM/GRM", w),

          head("LAM", w),

          head("FABRIC SIZE", w),

          head("CUT SIZE", w),

          head("REQ MTR", w),

          head("REQ KG", w),

          head("REQ PCS", w),
          head("Department", w),

          head("Wastage", w),

          // head("ORD MTR", w),
          //
          // head("ORD KG", w),
          //
          // head("ORD REQ. PCS", w),
          head("ORD Req(Mtr)", w),
          head("ORD Req(Kg)", w),
          head("ORD Req.Pcs", w),
        ],
      ),
    );
  }

  Widget head(String text, double width) {
    return Container(
      width: width,

      alignment: Alignment.center,

      child: Text(
        text,

        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 13,

          fontWeight: FontWeight.bold,

          color: C.primary,
        ),
      ),
    );
  }

  Widget _row(PlanningModel item, int index) {
    return Container(
      height: 50,
      color: index.isEven ? Colors.white : const Color(0xFFF7F9FC),
      child: Row(
        children: [
          cell(item.rowList, w1),
          cell(item.fabricCode, w2),
          cell(item.fabricGsm, w),
          cell(item.lamination, w),
          cell(item.fabricSize, w),
          cell(item.cutSize, w),
          cell(item.reqMtr, w),
          cell(item.reqKg, w),
          cell(item.reqPcs, w),
          cell(item.department, w),
          cell(item.wastage, w),
          // cell(item.startDate, w),
          //
          // cell(item.endDate, w),
          //
          // cell(item.quantity, w),
          cell(calculateOReqMtr(item), w), // O Req Mtr
          cell(calculateOReqKg(item), w), // O Req Kg
          cell(calculateOReqPcs(item), w),
        ],
      ),
    );
  }

  Widget cell(String text, double width) {
    return Container(
      width: width,

      alignment: Alignment.center,

      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: Text(
        text.isEmpty ? "0" : text,

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, color: C.appBar1),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDepartment,

                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),

                items: departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,

                    child: Text(dept, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value!;

                    wastageValue = departmentWastage[selectedDepartment] ?? "0";

                    wastageController.text = wastageValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wastageDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: wastageController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Wastage",
          hintText: "Enter wastage",
          suffixText: "",
        ),

        onChanged: (value) {
          setState(() {
            wastageValue = value;

            departmentWastage[selectedDepartment] = value;

            for (var item in planningList) {
              if (item.department.toUpperCase() ==
                  selectedDepartment.toUpperCase()) {
                item.wastage = value;
              }
            }
          });
        },
      ),
    );
  }

  Future<void> _loadUnit() async {
    final savedUnit = await AppSession.getUnit();

    setState(() {
      unit = savedUnit ?? "";
    });
  }

  String calculateOReqMtr(PlanningModel item) {
    final ordReqMtr = double.tryParse(item.reqMtr) ?? 0;
    final wastage = double.tryParse(item.wastage) ?? 0;

    final result = ordReqMtr + (ordReqMtr * wastage / 100);

    return result.round().toString();
  }

  String calculateOReqKg(PlanningModel item) {
    final ordReqKg = double.tryParse(item.reqKg) ?? 0;
    final wastage = double.tryParse(item.wastage) ?? 0;

    final result = ordReqKg + (ordReqKg * wastage / 100);

    return result.round().toString();
  }

  String calculateOReqPcs(PlanningModel item) {
    final ordReqPcs = int.tryParse(item.reqPcs) ?? 0;
    final wastage = int.tryParse(item.wastage) ?? 0;

    final result = ordReqPcs + wastage;

    return result.toStringAsFixed(0);
  }
}

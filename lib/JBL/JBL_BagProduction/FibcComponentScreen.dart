import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'ComponentModel.dart';

class FibcComponentScreen extends StatefulWidget {
  final String woNumber;

  const FibcComponentScreen({super.key, required this.woNumber});

  @override
  State<FibcComponentScreen> createState() => _FibcComponentScreenState();
}

class _FibcComponentScreenState extends State<FibcComponentScreen> {
  List<FibcComponentModel> components = [];
  List<FibcComponentModel> allComponents = [];
  List<String> inquiryList = [];
  String? selectedInquiry;
  bool loading = true;

  Map<String, TextEditingController> pcsControllers = {};

  @override
  void initState() {
    super.initState();
    loadData(inquiry: "0"); // 🔥 default inquiry
  }

  Future<void> loadData({String? inquiry}) async {
    try {
      setState(() => loading = true);

      final response = await JblApiService.getFibcComponents(
        widget.woNumber,
        inquiry: inquiry, // 🔥 always pass
      );

      print("FULL RESPONSE: $response");

      final List<FibcComponentModel> data = response["components"];
      final List<String> inquiries = response["inquiries"];

      print("Components Count: ${data.length}");
      print("Inquiry List: $inquiries");

      /// 🔥 REMOVE DUPLICATES (important)
      final uniqueMap = <String, FibcComponentModel>{};
      for (var item in data) {
        uniqueMap[item.component] = item;
      }
      final uniqueList = uniqueMap.values.toList();

      /// Controllers
      final newControllers = <String, TextEditingController>{};
      for (var item in uniqueList) {
        newControllers[item.component] = TextEditingController();
      }

      /// Move LOOM bottom
      uniqueList.sort((a, b) {
        if (a.department == "LOOM" && b.department != "LOOM") return 1;
        if (a.department != "LOOM" && b.department == "LOOM") return -1;
        return 0;
      });

      setState(() {
        allComponents = uniqueList;
        components = uniqueList;
        pcsControllers = newControllers;
        inquiryList = inquiries;

        selectedInquiry = inquiry != null && inquiries.contains(inquiry)
            ? inquiry
            : (inquiries.isNotEmpty ? inquiries.first : null);

        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  void onSave() async {
    try {
      List<Map<String, dynamic>> compList = [];

      pcsControllers.forEach((component, controller) {
        final pcs = int.tryParse(controller.text) ?? 0;

        if (pcs > 0) {
          compList.add({"component": component, "pcs": pcs});
        }
      });

      if (compList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter PCS before saving")),
        );
        return;
      }

      await JblApiService.saveFibcStoreEntry(
        wo: widget.woNumber,
        components: compList,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Saved Successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: C.primary,
        title: Text(
          "WO Number - ${widget.woNumber}",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: C.primary,
        onPressed: onSave,
        child: const Text("Save", style: TextStyle(color: Colors.white)),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                children: [
                  /// 🔥 DROPDOWN
                  DropdownButtonFormField<String>(
                    value: inquiryList.contains(selectedInquiry)
                        ? selectedInquiry
                        : null,
                    hint: const Text("Select Inquiry No"),
                    items: inquiryList.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) async {
                      await loadData(inquiry: value); // 🔥 reload
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 TABLE
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: C.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            horizontalMargin: 8,
                            headingRowHeight: 38,
                            dataRowMinHeight: 34,

                            columns: const [
                              DataColumn(label: Text("Component")),
                              DataColumn(label: Text("Dept")),
                              DataColumn(label: Text("Req Pcs")),
                              DataColumn(label: Text("Order")),
                              DataColumn(label: Text("Entry")),
                              DataColumn(label: Text("Till")),
                            ],

                            rows: components.map((e) {
                              bool isLoom =
                                  e.department.toUpperCase() == "LOOM";

                              return DataRow(
                                color:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (isLoom) {
                                        return Colors.orange.shade50;
                                      }
                                      return null;
                                    }),

                                cells: [
                                  DataCell(Text(e.component)),
                                  DataCell(Text(e.department)),
                                  DataCell(Text(e.requiredPcs.toString())),
                                  DataCell(Text(e.orderRequiredPcs.toString())),

                                  DataCell(
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        controller: pcsControllers[e.component],
                                        enabled: !isLoom,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 6,
                                              ),
                                          border: const OutlineInputBorder(),
                                          fillColor: isLoom
                                              ? Colors.grey.shade200
                                              : null,
                                          filled: isLoom,
                                        ),
                                      ),
                                    ),
                                  ),

                                  DataCell(Text(e.tillProvide.toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

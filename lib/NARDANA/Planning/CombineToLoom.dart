import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../Color/Colorclass.dart';
import '../../services/GlobalLoader/GloabalUnit.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import 'ModelClass/CombineToLoomModel.dart';
import 'ToLOomPlanningGenCode.dart';

class CombineToLoomScreen extends StatefulWidget {
  const CombineToLoomScreen({super.key});

  @override
  State<CombineToLoomScreen> createState() => _CombineToLoomScreenState();
}

class _CombineToLoomScreenState extends State<CombineToLoomScreen> {
  bool isLoading = true;
  final appCtrl = Get.find<AppController>();

  late String unit = appCtrl.unit.value;
  List<CombineToLoomModel> loomList = [];
  List<CombineToLoomModel> filteredList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLoomData();
  }

  Future<void> getLoomData() async {
    try {
      final data = await NaradanaApiService().getCombineToLoomList(unit);

      setState(() {
        loomList = data;
        filteredList = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredList = loomList;
      } else {
        filteredList = loomList.where((item) {
          return item.orderNo.toString().toLowerCase().contains(
            value.toLowerCase(),
          ) ||
              item.articleNum.toLowerCase().contains(
                value.toLowerCase(),
              ) ||
              item.BomNo.toString().toLowerCase().contains(
                value.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        iconTheme: IconThemeData(color: C.bg),
        backgroundColor: C.appBar1,
        title: const Text("Combine To Loom", style: TextStyle(color: C.bg)),

        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(colors: [C.appBar2, C.appBar3]),
        //   ),
        // ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3))
          : Column(
              children: [
                /// Search
                Padding(
                  padding: const EdgeInsets.all(12),

                  child: TextField(
                    controller: searchController,

                    onChanged: filterData,

                    decoration: InputDecoration(
                      hintText: "Search Bom No./ Order / Article",

                      prefixIcon: const Icon(Icons.search),

                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController.clear();

                                filterData("");
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text("No Data Found"))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),

                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  C.primary,
                                ),

                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),

                                columnSpacing: 25,

                                horizontalMargin: 15,

                                columns: const [
                                  DataColumn(label: Text("Sr.No")),

                                  DataColumn(label: Text("Order No.")),

                                  DataColumn(label: Text("Bom No.")),

                                  DataColumn(label: Text("Req Mtr")),

                                  DataColumn(label: Text("Req Kg")),

                                  DataColumn(label: Text("PO No.")),

                                  DataColumn(label: Text("Article No.")),
                                ],

                                rows: filteredList.asMap().entries.map((entry) {
                                  int index = entry.key;

                                  var item = entry.value;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text("${index + 1}")),

                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    GenerateCodeScreen(
                                                      data: item,
                                                    ),
                                              ),
                                            );
                                          },

                                          child: Text(
                                            item.orderNo.toString(),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item.BomNo.toString())),

                                      DataCell(Text(item.mtr.toString())),

                                      DataCell(Text(item.kg.toString())),

                                      DataCell(
                                        SizedBox(
                                          width: 150,

                                          child: Text(
                                            item.poNum,

                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        SizedBox(
                                          width: 100,

                                          child: Text(
                                            item.articleNum,

                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../Color/Colorclass.dart';
import '../../services/GlobalLoader/GloabalUnit.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import '../../util/sharedpreference/shared_preference.dart';
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
  int totalRecords = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
    getLoomData();
  }


  Future<void> _initialize() async {
    unit = await AppSession.getUnit() ?? "";
    await getLoomData();
  }
  Future getLoomData() async {
    try {
      final data = await NaradanaApiService().getCombineToLoomList(unit);

      setState(() {
        loomList = data;
        filteredList = data;
        totalRecords = data.length; // Total records
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
              item.articleNum.toLowerCase().contains(value.toLowerCase()) ||
              item.BomNo.toString().toLowerCase().contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: C.bg),
        backgroundColor: C.appBar1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Combine To Loom", style: TextStyle(color: C.bg)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Total : $totalRecords",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
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
                                  Colors.grey.shade300,
                                ),

                                headingTextStyle: const TextStyle(
                                  color: C.textHead,
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
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GenerateCodeScreen(
                                              data: item,
                                            ),
                                          ),
                                        );
                                      }
                                    },
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
                                          width: 50,

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

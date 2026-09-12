import 'dart:convert';
import 'package:IMS/NARDANA/Planning/CombineToLoom.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import 'ModelClass/OrderCompositionModel.dart';

class SelectedOrderScreen extends StatefulWidget {
  final String orderType;
  final List<OrderCompositionModel> selectedItems;

  const SelectedOrderScreen({
    super.key,
    required this.orderType,
    required this.selectedItems,
  });

  @override
  State<SelectedOrderScreen> createState() => _SelectedOrderScreenState();
}

class _SelectedOrderScreenState extends State<SelectedOrderScreen> {
  late List<OrderCompositionModel> data;

  @override
  void initState() {
    super.initState();

    data = widget.selectedItems;

    for (var e in data) {
      e.selected = false;
    }
  }

  bool isClubValid() {
    List<OrderCompositionModel> selectedItems = data
        .where((e) => e.selected)
        .toList();

    if (selectedItems.isEmpty) {
      return false;
    }

    String bom = selectedItems.first.woNumber;
    String fabric = selectedItems.first.fabricCode;

    return selectedItems.every(
      (e) => e.woNumber == bom && e.fabricCode == fabric,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: AppBar(
        title: Text(
          "${widget.orderType} Selection",
          style: TextStyle(color: C.bg),
        ),
        iconTheme: IconThemeData(color: C.bg),
        backgroundColor: C.primary,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.length,

              itemBuilder: (context, index) {
                final item = data[index];

                return Card(
                  elevation: 3,

                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: CheckboxListTile(
                    value: item.selected,

                    activeColor: const Color(0xFFC97554),

                    checkColor: Colors.white,

                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFC97554);
                      }

                      return Colors.grey.shade300;
                    }),

                    side: BorderSide(
                      color: item.selected
                          ? const Color(0xFFC97554)
                          : Colors.grey.shade400,

                      width: 1.5,
                    ),

                    title: Text(
                      item.component,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text("BOM : ${item.woNumber}"),

                          Text("Fabric : ${item.fabricCode}"),

                          Text("MTR : ${item.orderRequiredMtr}"),

                          Text("KG : ${item.orderRequiredKg}"),

                          Text("PO : ${item.poNum}"),

                          Text("Article : ${item.articleNum}"),
                        ],
                      ),
                    ),

                    onChanged: (v) {
                      setState(() {
                        if (widget.orderType == "SINGLE") {
                          for (var e in data) {
                            e.selected = false;
                          }

                          item.selected = v ?? false;
                        } else {
                          item.selected = v ?? false;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),

            child: SizedBox(
              width: double.infinity,

              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: C.primary),

                onPressed: () async {
                  List<OrderCompositionModel> selected = data
                      .where((e) => e.selected)
                      .toList();

                  if (selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select item")),
                    );

                    return;
                  }

                  // if (widget.orderType == "CLUB") {
                  //   if (!isClubValid()) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         backgroundColor: Colors.red,
                  //
                  //         content: Text("For Club BOM and Fabric must be same"),
                  //       ),
                  //     );
                  //
                  //     return;
                  //   }
                  // }

                  showDialog(
                    context: context,

                    barrierDismissible: false,

                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    dynamic response;

                    if (widget.orderType == "SINGLE") {
                      response = await NaradanaApiService().singleSave(
                        selected,
                      );
                    } else {
                      response = await NaradanaApiService().clubSave(selected);
                    }

                    // Navigator.pop(context);

                    final responseData = jsonDecode(response.body);
                    Get.to(
                            () =>CombineToLoomScreen()
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(responseData["message"]),
                      ),
                    );

                    await Future.delayed(const Duration(seconds: 1));


                  } catch (e) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,

                        content: Text(e.toString()),
                      ),
                    );
                  }
                },

                child: const Text(
                  "COMBINE & MAKE ORDER",

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
    );
  }
}

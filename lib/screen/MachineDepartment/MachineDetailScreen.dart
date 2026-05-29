import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/getSupervisors/MAchineApiService.dart';

class MachineDetailScreen extends StatefulWidget {
  final String machineBrId; // Add this - for QR scanning
  final int machineId;

  const MachineDetailScreen({
    Key? key,
    required this.machineBrId,
    required this.machineId,
  }) : super(key: key);

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  Map<String, dynamic>? machineData;
  bool isLoading = true;

  List<Map<String, dynamic>> categoryList = [];
  int? selectedCategoryId;
  bool isCategoryLoading = true;

  final List<Map<String, dynamic>> itemList = [];

  final qtyController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMachine();
    fetchCategories();
  }

  @override
  void dispose() {
    qtyController.dispose();
    descController.dispose();
    super.dispose();
  }

  // ================= FETCH MACHINE =================
  Future<void> fetchMachine() async {
    try {
      final url = Uri.parse(
        "https://fibcsoftware.in:4430/api/api/Machine/machines",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List machinesList = decoded['data'];

        // Find machine by machineBrId instead of id
        final machine = machinesList.firstWhere(
          (m) => m['machineBrId'] == widget.machineBrId,
          orElse: () => null,
        );

        setState(() {
          machineData = machine;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse(
        "https://fibcsoftware.in:4430/api/api/Machine/Categories",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          categoryList = List<Map<String, dynamic>>.from(decoded['data']);
          isCategoryLoading = false;
        });
      } else {
        setState(() => isCategoryLoading = false);
      }
    } catch (e) {
      setState(() => isCategoryLoading = false);
    }
  }

  Future<void> submitData() async {
    if (itemList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one item")));
      return;
    }

    bool allSuccess = true;

    for (var item in itemList) {
      final now = DateTime.now().toUtc().toIso8601String();

      final response = await MachineApiService.insertFault(
        machineId: widget.machineId.toString(),
        faultId: item["categoryId"],
        referenceNo: "NL${DateTime.now().millisecondsSinceEpoch}",
        status: "Deactive",
        createdBy: 49,
        updatedBy: 49,
        createdDate: now,
        updatedDate: now,
        quantity: int.parse(item["qty"]),
        description: item["description"] ?? "",
        imagePath: "",
      );

      if (response["success"] != true) {
        allSuccess = false;
        break;
      }
    }

    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saved Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // 👈 Navigate back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Some items failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= ADD ITEM =================
  void addItem() {
    if (selectedCategoryId == null || qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select category & enter quantity"),
        ),
      );
      return;
    }

    final selectedCategory = categoryList.firstWhere(
      (cat) => cat['id'] == selectedCategoryId,
    );

    setState(() {
      itemList.add({
        "categoryId": selectedCategoryId,
        "categoryName": selectedCategory['categorypart'],
        "qty": qtyController.text,
        "description": descController.text,
      });

      qtyController.clear();
      descController.clear();
      selectedCategoryId = null;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5AA8),
        leading: const BackButton(color: Colors.white),
        title: isLoading || machineData == null
            ? const Text(
                "Machine Details",
                style: TextStyle(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machineData!['machineName'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    machineData!['machineType'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E5AA8),
        onPressed: addItem,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : machineData == null
          ? const Center(child: Text("Machine Not Found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _simpleRow("Department", machineData!['department'] ?? ''),
                  _simpleRow("Location", machineData!['location'] ?? ''),
                  _simpleRow(
                    "Capacity",
                    machineData!['capacity']?.toString() ?? '',
                  ),

                  const SizedBox(height: 25),
                  const Divider(),
                  // const SizedBox(height: 10),
                  // ========= TABLE =========
                  if (itemList.isNotEmpty) ...[
                    const Text(
                      "Added Items",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Machine")),
                          DataColumn(label: Text("Type")),
                          DataColumn(label: Text("Category")),
                          DataColumn(label: Text("Qty")),
                          DataColumn(label: Text("Desc")),
                          DataColumn(label: Text("")),
                        ],
                        rows: List.generate(itemList.length, (index) {
                          final item = itemList[index];

                          return DataRow(
                            cells: [
                              DataCell(Text(machineData!['machineName'])),
                              DataCell(Text(machineData!['machineType'])),
                              DataCell(Text(item['categoryName'])),
                              DataCell(Text(item['qty'])),
                              DataCell(Text(item['description'] ?? '')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      itemList.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),


                  ],
                  const Text(
                    "Add Maintenance Item",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ========= DROPDOWN =========
                  isCategoryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Select Category",
                            labelStyle: TextStyle(color: Colors.blueGrey),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade600,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: categoryList
                              .map(
                                (category) => DropdownMenuItem<int>(
                                  value: category['id'],
                                  child: Text(
                                    category['categorypart'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategoryId = val;
                            });
                          },
                        ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      labelStyle: TextStyle(color: Colors.blueGrey),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: descController,
                    maxLines: 5, // 👈 keeps height small
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: "Description",
                      alignLabelWithHint: true,

                      labelStyle: const TextStyle(color: Colors.blueGrey),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 38, // 👈 smaller height
                        child: ElevatedButton(
                          onPressed: submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade500,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, // 👈 controls width
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
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

  Widget _simpleRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

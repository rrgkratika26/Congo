import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ModelClass.dart';

class MachineRepairScreen extends StatefulWidget {
  final int machineId;

  const MachineRepairScreen({Key? key, required this.machineId})
    : super(key: key);

  @override
  State<MachineRepairScreen> createState() => _MachineRepairScreenState();
}

class _MachineRepairScreenState extends State<MachineRepairScreen> {
  List<Map<String, dynamic>> repairList = [];
  Map<String, dynamic>? machineData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachineDetails();
    fetchRepairs();
  }

  Future<void> fetchMachineDetails() async {
    try {
      final url = Uri.parse(
        "https://fibcsoftware.in:4430/api/api/Machine/getById?id=${widget.machineId}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["success"] == true) {
          setState(() {
            machineData = decoded["data"];
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchRepairs() async {
    try {
      final url = Uri.parse(
        "https://fibcsoftware.in:4430/api/api/Machine/repairs?machineId=${widget.machineId}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["success"] == true) {
          setState(() {
            repairList = List<Map<String, dynamic>>.from(decoded["data"]);
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5AA8),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 makes back button white
        ),
        title: Text(
          "Machine ID: ${widget.machineId}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

      ),


      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (machineData != null) ...[
              _infoRow("Department", machineData!["department"] ?? ""),
              _infoRow("Location", machineData!["location"] ?? ""),
              _infoRow("Capacity", machineData!["capacity"]?.toString() ?? ""),
            ],

            const SizedBox(height: 20),
            const Divider(),

            const SizedBox(height: 10),
            const Text(
              "Repair History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : repairList.isEmpty
                  ? const Center(child: Text("No Repair Records Found"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Machine ID")),
                      DataColumn(label: Text("Ref No")),
                      DataColumn(label: Text("Fault ID")),
                      DataColumn(label: Text("Fault Code")),
                      DataColumn(label: Text("Category")),
                      DataColumn(label: Text("Qty")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Description")),
                      DataColumn(label: Text("Image Path")),
                      DataColumn(label: Text("Created Date")),
                      DataColumn(label: Text("Updated Date")),
                    ],
                    rows: repairList.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item["id"]?.toString() ?? "")),
                          DataCell(Text(item["machineId"]?.toString() ?? "")),
                          DataCell(Text(item["referenceNo"] ?? "")),
                          DataCell(Text(item["faultId"]?.toString() ?? "")),
                          DataCell(Text(item["faultCode"] ?? "")),
                          DataCell(Text(item["categorypart"] ?? "")),
                          DataCell(Text(item["quantity"]?.toString() ?? "0")),
                          DataCell(
                            Text(
                              item["status"] ?? "",
                              style: TextStyle(
                                color: item["status"] == "Deactive"
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                          DataCell(Text(item["description"] ?? "")),
                          DataCell(Text(item["imagePath"] ?? "")),
                          DataCell(
                            Text(
                              (item["createdDate"] ?? "")
                                  .toString()
                                  .split("T")
                                  .first,
                            ),
                          ),
                          DataCell(
                            Text(
                              (item["updatedDate"] ?? "")
                                  .toString()
                                  .split("T")
                                  .first,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

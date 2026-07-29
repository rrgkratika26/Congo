import 'package:IMS/AdminDashBoard/DepartmentDashboard.dart';
import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';


import '../../Color/Colorclass.dart';
import '../../JBL/JBL_Loom/LoomListSavedModel.dart';

import '../../services/getSupervisors/RmdService.dart';
import 'RmdRollModelclass/RmdRollEntrysavedListModel.dart';

class RmdRollSavedList extends StatefulWidget {
  const RmdRollSavedList({super.key});

  @override
  State<RmdRollSavedList> createState() => _RmdRollSavedListState();
}

class _RmdRollSavedListState extends State<RmdRollSavedList> {
  late Future<List<RmdRollEntrySavedListModel>> futureData;
  final _storage = GetStorage();
  List<BluetoothInfo> printers = [];
  bool isScanning = false;
  bool _isProcessing = false;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  bool isLoading = true;
  String get fromDateString =>
      DateFormat("dd-MMM-yyyy").format(fromDate);

  String get toDateString =>
      DateFormat("dd-MMM-yyyy").format(toDate);
  Future<void> _checkPrinterConnection() async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;

    Get.snackbar(
      "Printer Status",
      isConnected == true ? "✅ Printer Connected" : "❌ Printer Not Connected",
      backgroundColor: isConnected == true ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }


  // @override
  // void initState() {
  //   super.initState();
  //
  //   final today = DateFormat("dd-MMM-yyyy").format(DateTime.now());
  //
  //   futureData = RmdService.fetchSavedRollEntry(fromDate: today, toDate: today);
  // }


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    futureData = RmdService.fetchSavedRollEntry(
      fromDate: fromDateString,
      toDate: toDateString,
    );

    await futureData;

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: fromDate,
        end: toDate,
      ),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });

      await loadData();
    }
  }

  Future<void> scanPrinters() async {
    setState(() {
      isScanning = true;
      printers.clear();
    });

    try {
      final result = await PrintBluetoothThermal.pairedBluetooths;

      setState(() {
        printers = result;
        isScanning = false;
      });

      if (printers.isEmpty) {
        Get.snackbar(
          "No Printer",
          "No paired printers found",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isScanning = false;
      });

      // Get.snackbar(
      //   "Error",
      //   e.toString(),
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    }
  }

  void showPrinterList() async {
    await scanPrinters();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 15),

              const Text(
                "Select Printer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const Divider(),

              if (isScanning)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (_, index) {
                      final p = printers[index];

                      return ListTile(
                        leading: const Icon(Icons.print, color: Colors.blue),

                        title: Text(p.name ?? "Unknown"),

                        subtitle: Text(p.macAdress ?? ""),

                        onTap: () async {
                          _storage.write('printer_name', p.name);

                          _storage.write('printer_address', p.macAdress);

                          Navigator.pop(context);

                          Get.snackbar(
                            "Success",
                            "Printer Connected",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.appBar1,
        elevation: 0,
        iconTheme: const IconThemeData(color: C.bg),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rmd Roll List",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$fromDateString  →  $toDateString",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth_searching, color: Colors.white),
            onPressed: showPrinterList,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<RmdRollEntrySavedListModel>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: C.appBar3),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final data = snapshot.data!;

            if (data.isEmpty) {
              return const Center(child: Text("No Data Found"));
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowHeight: 50,
                        dataRowHeight: 52,

                        headingRowColor: MaterialStateProperty.all(C.border),

                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("Barcode")),

                          DataColumn(label: Text("Supervisor")),
                          DataColumn(label: Text("Article No")),

                          DataColumn(label: Text("Party Name")),

                          DataColumn(label: Text("PO Order")),

                          DataColumn(label: Text("Gross Wt")),
                          DataColumn(label: Text("Color")),
                          DataColumn(label: Text("Mesh")),

                          DataColumn(label: Text("Fab Type")),
                          DataColumn(label: Text("Fab Const.")),

                          DataColumn(label: Text("Fab Width")),
                          DataColumn(label: Text("Fab GSM")),
                          DataColumn(label: Text("Lami Type")),
                          DataColumn(label: Text("Cut Type")),

                          DataColumn(label: Text("Special Id")),

                          DataColumn(label: Text("Roll Wt")),

                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Time")),
                          DataColumn(label: Text(" Print Barcode")),
                        ],

                        rows: List.generate(data.length, (index) {
                          final e = data[index];

                          return DataRow(
                            color: MaterialStateProperty.all(
                              index % 2 == 0
                                  ? Colors.grey.shade50
                                  : Colors.white,
                            ),
                            cells: [
                              DataCell(Text(e.srNo.toString())),
                              DataCell(Text(e.barcode)),

                              DataCell(Text(e.supervisorName)),

                              DataCell(Text(e.operatorName)),
                              DataCell(Text(e.component)),
                              // DataCell(Text(e.partyName)),

                              /// ✅ NEW
                              DataCell(Text(e.workOrderNo)),

                              DataCell(Text(e.orderType)),
                              DataCell(Text(e.color)),
                              DataCell(Text(e.mesh.toString())),

                              DataCell(Text(e.fabricType.toString())),
                              DataCell(Text(e.fabricConstruction.toString())),

                              /// ✅ NEW
                              DataCell(Text(e.fabricWidth)),
                              DataCell(Text(e.fabricGsm)),

                              DataCell(Text(e.laminationType)),

                              DataCell(Text(e.cutType)),

                              DataCell(Text(e.specialIdentification)),

                              DataCell(Text(e.rollWeight)),

                              DataCell(
                                Text(
                                  e.date != null
                                      ? "${e.date!.day}-${e.date!.month}-${e.date!.year}"
                                      : "-",
                                ),
                              ),

                              DataCell(Text(e.time)),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () => _showIssueOptions(e),
                                  child: const Text(
                                    "Print / Issue",
                                    style: TextStyle(color: C.success),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> showPrintPreview(RmdRollEntrySavedListModel item) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    item.component,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "BARCODE : ${item.barcode}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SUP : ${item.supervisorName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "QTY : ${item.requiredQuantityMtr}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 25),

                  BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: item.barcode,
                    width: 180,
                    height: 180,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    item.barcode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: C.primaryDark),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            "Print & Issue",
                            style: TextStyle(color: C.primaryDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _printBarcodeApi(RmdRollEntrySavedListModel item) async {
    final address = _storage.read<String>('printer_address');
    final name = _storage.read<String>('printer_name') ?? 'Printer';

    if (address == null) {
      Get.snackbar(
        "Printer Error",
        "❌ Please connect printer first",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    bool? ok = await showPrintPreview(item);

    if (ok != true) return;

    /// 🔹 Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Print Barcode"),
        content: Text("Print barcode?\n\n${item.barcode}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Print"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      /// 🔥 CONNECT PRINTER
      await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
      await Future.delayed(const Duration(milliseconds: 400));

      await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: name,
          address: address,
          isBle: false,
          autoConnect: false,
        ),
      );

      /// 🔥 WAKE PRINTER
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: [27, 64],
      );

      await Future.delayed(const Duration(milliseconds: 200));

      /// 🔥 TSPL LABEL (LIKE YOUR FIRST CODE)
      String tspl =
          '''
  SIZE 100 mm,100 mm
  GAP 3 mm,0 mm
  DIRECTION 1
  CLS

  TEXT 30,80,"3",0,1,2,"${item.component}"

  TEXT 40,140,"3",0,2,2,"BARCODE:${item.barcode}"
  TEXT 40,200,"3",0,2,2,"OP:${item.operatorName}"

  TEXT 40,260,"3",0,2,2,"SUP:${item.supervisorName}"
  TEXT 40,320,"3",0,2,2,"QTY:${item.requiredQuantityMtr}"

  QRCODE 240,390,L,12,A,0,"${item.barcode}"

  TEXT 180,660,"3",0,2,2,"${item.barcode}"

  PRINT 1
  ''';

      /// 🔥 PRINT
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: tspl.codeUnits,
      );
      final response = await RmdService().printBarcode(
        id: item.srNo,
        rollEntry: "RMD",
        barcode: item.barcode,
        plant: AppGlobals.unit,
        location: item.location,
        operator: item.operatorName,
        supervisor: item.supervisorName,
      );
      print("SAVE BODY: $response");

      Get.snackbar(
        "Success",
        response['message'] ?? "Printed Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

// Refresh the table after printing
      await loadData();

      /// Wait a moment so snackbar is visible
      // Wait briefly so the user sees the success message
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to Dashboar
      Get.offAll(() => const NewAdminDashboard());

      /// Navigate to Dashboard
    } catch (e) {
      print("Error❌ Print failed: $e");
      // Get.snackbar(
      //   "Error",
      //   "❌ Print failed: $e",F
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    }
  }

  Future<void> _showIssueOptions(RmdRollEntrySavedListModel item) async {
    showModalBottomSheet(
      backgroundColor: C.bg,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Action",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// PRINT + ISSUE
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: C.appBar4),
                  icon: const Icon(Icons.print, color: C.textHigh),
                  label: const Text(
                    "Print + Issue",
                    style: TextStyle(color: C.textHigh),
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                    Navigator.pop(context); // Close bottom sheet first

                    setState(() => _isProcessing = true);

                    try {
                      await _printBarcodeApi(item);
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),

              /// ONLY ISSUE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: C.success),
                  icon: const Icon(Icons.check, color: C.bg),
                  label: const Text(
                    "Only Issue",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                    Navigator.pop(context); // Close bottom sheet first

                    setState(() => _isProcessing = true);

                    try {
                      await _issueWithoutPrint(item);
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _issueWithoutPrint(RmdRollEntrySavedListModel item) async {
    try {
      final response = await RmdService().printBarcode(
        id: item.srNo,
        rollEntry: "RMD",
        barcode: item.barcode,
        plant: AppGlobals.unit,
        location: item.location,
        operator: item.operatorName,
        supervisor: item.supervisorName,
      );
      print(response);
      print("ID        : ${item.srNo}");
      print("Barcode   : ${item.barcode}");
      print("Plant     : ${AppGlobals.unit}");
      print("Location  : ${item.location}");
      print("Operator  : ${item.operatorName}");
      print("Supervisor: ${item.supervisorName}");
      Get.snackbar(
        "Success",
        response['message'] ?? "Issued Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(result: true);
      /// Navigate to Dashboard
      // Get.offAll(() => const NewAdminDashboard());
    } catch (e) {
      // Get.snackbar(
      //   "Error",
      //   "❌ $e",
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    }
  }
}

import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../Color/Colorclass.dart';
import 'LoomListSavedModel.dart';

class SavedListScreen extends StatefulWidget {
  const SavedListScreen({super.key});

  @override
  State<SavedListScreen> createState() => _SavedListScreenState();
}

class _SavedListScreenState extends State<SavedListScreen> {
  late Future<List<LoomListModel>> futureData;
  final _storage = GetStorage();
  List<BluetoothInfo> printers = [];
  bool isScanning = false;

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

  @override
  void initState() {
    super.initState();
    futureData = InStockService().fetchLoomList();
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

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        title: const Text("Loom List", style: TextStyle(color: C.bg)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     C.appBar1,
            //     C.appBar4,
            //   ],
            // ),
            color: C.appBar1
          ),
        ),
        // C.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: C.bg),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.bluetooth),
          //   onPressed: _checkPrinterConnection,
          // ),
          IconButton(
            icon: const Icon(Icons.bluetooth_searching),
            onPressed: showPrinterList,
          ),
        ],
      ),
      body: FutureBuilder<List<LoomListModel>>(
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

                      headingRowColor: MaterialStateProperty.all(C.brand50),

                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Barcode")),
                        DataColumn(label: Text("Operator")),
                        DataColumn(label: Text("Supervisor")),
                        DataColumn(label: Text("Party Name")),
                        DataColumn(label: Text("OrderNo.")),
                        DataColumn(label: Text("Work Order")),
                        DataColumn(label: Text("Req.Qty(Kg)")),
                        DataColumn(label: Text("Req.Qty(Mtr)")),
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Time")),
                        DataColumn(label: Text("Fab GSM")),
                        DataColumn(label: Text("Color")),
                        DataColumn(label: Text("Net Wt")),
                        DataColumn(label: Text("Roll L.Mtr")),
                        DataColumn(label: Text("Loom Type")),
                        DataColumn(label: Text("Department")),
                        DataColumn(label: Text(" Print Barcode")),
                      ],

                      rows: List.generate(data.length, (index) {
                        final e = data[index];

                        return DataRow(
                          color: MaterialStateProperty.all(
                            index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                          ),
                          cells: [
                            DataCell(Text(e.id.toString())),
                            DataCell(Text(e.barcode)),
                            DataCell(Text(e.operator)),
                            DataCell(Text(e.supervisor)),
                            DataCell(Text(e.machineNo)),
                            DataCell(Text(e.partyName)),

                            /// ✅ NEW
                            DataCell(Text(e.workOrderNo)),

                            DataCell(Text(e.requiredNetWt.toString())),
                            DataCell(Text(e.requiredQtyMtr.toString())),

                            DataCell(
                              Text(
                                e.date != null
                                    ? "${e.date!.day}-${e.date!.month}-${e.date!.year}"
                                    : "-",
                              ),
                            ),

                            DataCell(Text(e.time)),
                            DataCell(Text(e.gsm)),
                            DataCell(Text(e.color)),
                            DataCell(Text(e.netWt.toString())),
                            DataCell(Text(e.quantity.toString())),

                            /// ✅ NEW
                            DataCell(Text(e.modelNo)),
                            DataCell(Text(e.department)),

                            // DataCell(
                            //   ElevatedButton(
                            //     onPressed: () => _printBarcodeApi(e),
                            //     child: const Text(
                            //       "Print / Issue",
                            //       style: TextStyle(color: C.success),
                            //     ),
                            //   ),
                            // ),
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
    );
  }

    Future<void> _printBarcodeApi(LoomListModel item) async {
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

        await Future.delayed(const Duration(milliseconds: 800));

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

  TEXT 30,80,"3",0,1,2,"${item.partyName}"

  TEXT 40,140,"3",0,2,2,"BARCODE:${item.barcode}"
  TEXT 40,200,"3",0,2,2,"OP:${item.operator}"

  TEXT 40,260,"3",0,2,2,"SUP:${item.supervisor}"
  TEXT 40,320,"3",0,2,2,"QTY:${item.quantity}"

  QRCODE 240,390,L,12,A,0,"${item.barcode}"

  TEXT 180,660,"3",0,2,2,"${item.barcode}"

  PRINT 1
  ''';

        /// 🔥 PRINT
        await PrinterManager.instance.send(
          type: PrinterType.bluetooth,
          bytes: tspl.codeUnits,
        );

        /// 🔥 OPTIONAL API CALL AFTER PRINT
        final response = await InStockService().printBarcode(
          id: item.id,
          barcode: item.barcode,
        );

        Get.snackbar(
          "Success",
          response['message'] ?? "Printed Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "❌ Print failed: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

//   Future<void> _printBarcodeApi(LoomListModel item) async {
//     final address = _storage.read<String>('printer_address');
//     final name = _storage.read<String>('printer_name') ?? 'Printer';
//
//     /// Printer selected or not
//     if (address == null || address.isEmpty) {
//       Get.snackbar(
//         "Printer Error",
//         "❌ Please connect printer first",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     /// Confirm dialog
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Print Barcode"),
//         content: Text("Print barcode?\n\n${item.barcode}"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Yes, Print"),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     try {
//       /// Disconnect previous connection
//       await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       /// Connect printer
//       await PrinterManager.instance.connect(
//         type: PrinterType.bluetooth,
//         model: BluetoothPrinterInput(
//           name: name,
//           address: address,
//           isBle: false,
//           autoConnect: false,
//         ),
//       );
//
//       await Future.delayed(const Duration(seconds: 1));
//
//       /// Verify connection
//       bool? isConnected = await PrintBluetoothThermal.connectionStatus;
//
//       if (isConnected != true) {
//         Get.snackbar(
//           "Printer Error",
//           "❌ Printer not connected",
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//
//         return; // STOP HERE
//       }
//
//       /// Wake printer
//       await PrinterManager.instance.send(
//         type: PrinterType.bluetooth,
//         bytes: [27, 64],
//       );
//
//       await Future.delayed(const Duration(milliseconds: 300));
//
//       String tspl =
//           '''
// SIZE 100 mm,100 mm
// GAP 3 mm,0 mm
// DIRECTION 1
// CLS
//
// TEXT 30,80,"3",0,1,2,"${item.partyName}"
//
// TEXT 40,140,"3",0,2,2,"BARCODE:${item.barcode}"
// TEXT 40,200,"3",0,2,2,"OP:${item.operator}"
//
// TEXT 40,260,"3",0,2,2,"SUP:${item.supervisor}"
// TEXT 40,320,"3",0,2,2,"QTY:${item.quantity}"
//
// QRCODE 240,390,L,12,A,0,"${item.barcode}"
//
// TEXT 180,660,"3",0,2,2,"${item.barcode}"
//
// PRINT 1
// ''';
//
//       /// Send print data
//       await PrinterManager.instance.send(
//         type: PrinterType.bluetooth,
//         bytes: tspl.codeUnits,
//       );
//
//       /// Wait before API call
//       await Future.delayed(const Duration(seconds: 2));
//
//       /// API ONLY AFTER SUCCESSFUL PRINT
//       final response = await InStockService().printBarcode(
//         id: item.id,
//         barcode: item.barcode,
//       );
//
//       Get.snackbar(
//         "Success",
//         response['message'] ?? "Printed Successfully",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         "Print Failed",
//         "❌ $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

  Future<void> _showIssueOptions(LoomListModel item) async {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.appBar4,
                  ),
                  icon: const Icon(Icons.print,color: C.textHigh,),
                  label: const Text("Print + Issue",style: TextStyle(color: C.textHigh),),
                  onPressed: () async {
                    Navigator.pop(context);

                    await _printBarcodeApi(item);
                  },
                ),
              ),

              const SizedBox(height: 12),

              /// ONLY ISSUE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.success,
                  ),
                  icon: const Icon(Icons.check,color: C.bg,),
                  label: const Text(
                    "Only Issue",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    await _issueWithoutPrint(item);
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

  Future<void> _issueWithoutPrint(LoomListModel item) async {
    try {
      final response = await InStockService().printBarcode(
        id: item.id,
        barcode: item.barcode,
      );

      Get.snackbar(
        "Success",
        response['message'] ?? "Issued Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "❌ $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

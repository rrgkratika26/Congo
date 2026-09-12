import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/barcode.dart' hide Barcode;
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../Color/Colorclass.dart';
import '../../JBL/JBLBailing/BarcodeLabel.dart';
import '../../services/DashboardApiServices.dart';
import '../../services/GlobalLoader/GloabalUnit.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ReportmodelClass/webSaveEntriesList.dart';
enum PrintAction {
  printAndIssue,
  issueOnly,
  cancel,
}
class WebSaveEntriesScreen extends StatefulWidget {
  const WebSaveEntriesScreen({super.key});

  @override
  State<WebSaveEntriesScreen> createState() => _WebSaveEntriesScreenState();
}

class _WebSaveEntriesScreenState extends State<WebSaveEntriesScreen> {

  bool loading = true;
  bool printing = false;
  List<WebbingSavedEntry> list = [];
  final _storage = GetStorage();

  List printers = [];
  bool isScanning = false;
  @override
  void initState() {
    super.initState();
    loadData();
  }
  Future scanPrinters() async {
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
    } catch (e) {
      setState(() => isScanning = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Future<void> loadData() async {
    loading = true;

    AppGlobals.unit = await AppSession.getUnit() ?? "";

    print("Plant = ${AppGlobals.unit}");

    try {
      list = await DashboardService.fetchSavedWebbingEntries(AppGlobals.unit);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
  Future<void> printBarcode(WebbingSavedEntry item) async {

    final action = await showPrintPreview(item);

    if (action == null || action == PrintAction.cancel) {
      return;
    }

    if (action == PrintAction.issueOnly) {
      await issueWithoutPrint(item);
      return;
    }

    final address = _storage.read("printer_address");
    final name = _storage.read("printer_name") ?? "Printer";

    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Bluetooth printer first."),
        ),
      );
      return;
    }


    if (action == null || action == PrintAction.cancel) {
      return;
    }

    if (action == PrintAction.issueOnly) {
      await issueWithoutPrint(item);
      return;
    }

    try {

      await PrinterManager.instance.disconnect(
        type: PrinterType.bluetooth,
      );

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

      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: [27, 64],
      );

      String tspl = '''
SIZE 100 mm,100 mm
GAP 3 mm,0 mm
DIRECTION 1
CLS

TEXT 30,60,"3",0,2,2,"${item.partyName}"

TEXT 40,120,"3",0,2,2,"BARCODE:${item.barcode}"

TEXT 40,180,"3",0,2,2,"LOT:${item.lotNo}"

TEXT 40,240,"3",0,2,2,"FAB:${item.fabricCode}"

TEXT 40,300,"3",0,2,2,"WT:${item.rollWeight}"

QRCODE 220,380,L,10,A,0,"${item.barcode}"

TEXT 180,620,"3",0,2,2,"${item.barcode}"

PRINT 1
''';

      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: tspl.codeUnits,
      );

      final response =
      await DashboardService.printWebbingBarcode(
        barcode: item.barcode,
        department: "RMD",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));

      Get.to(() => const NewAdminDashboard());

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
  void showPrinterList() async {
    await scanPrinters();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: printers.length,
          itemBuilder: (_, index) {
            final p = printers[index];

            return ListTile(
              title: Text(p.name ?? ""),
              subtitle: Text(p.macAdress ?? ""),
              leading: const Icon(Icons.print),
              onTap: () {
                _storage.write("printer_name", p.name);
                _storage.write("printer_address", p.macAdress);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Printer Selected")),
                );
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.primary,
        title: const Text("Saved Entries", style: TextStyle(color: C.bg)),
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth_searching),
              onPressed: showPrinterList,
            )
          ],
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Card(
              elevation: 6,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.table_chart, color: C.primaryDark),

                        Text(
                          "Total Records  ${list.length} ",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: C.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            C.brand200,
                          ),

                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),

                          columns: const [
                            DataColumn(label: Text("Sr")),
                            DataColumn(label: Text("Roll Code")),
                            DataColumn(label: Text("Barcode")),
                            DataColumn(label: Text("Lot No")),
                            DataColumn(label: Text("Supervisor")),
                            DataColumn(label: Text("Operator")),
                            DataColumn(label: Text("Date")),
                            DataColumn(label: Text("Bom No")),
                            DataColumn(label: Text("Party Name")),
                            DataColumn(label: Text("Machine")),
                            DataColumn(label: Text("Width")),
                            DataColumn(label: Text("GSM")),
                            DataColumn(label: Text("Color")),
                            DataColumn(label: Text("Weight")),
                            DataColumn(label: Text("Fabric Code")),
                            DataColumn(label: Text("Action")),
                          ],

                          rows: List.generate(list.length, (index) {
                            final e = list[index];

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (index.isEven) {
                                  return Colors.grey.shade50;
                                }
                                return Colors.white;
                              }),

                              cells: [
                                cell(e.srNo.toString()),

                                cell(e.rollCode),

                                cell(e.barcode),

                                cell(e.lotNo),

                                cell(e.supervisorName),

                                cell(e.operatorName),

                                cell(e.date.split("T").first),

                                cell(e.orderNo),

                                cell(e.partyName),

                                DataCell(
                                  Chip(
                                    label: Text(e.machineNo),
                                    backgroundColor: Colors.indigo.shade50,
                                  ),
                                ),

                                cell(e.beltWidth),

                                cell(e.beltGsm),

                                cell(e.color),

                                DataCell(
                                  Chip(
                                    label: Text("${e.rollWeight} Kg"),
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                ),

                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      e.fabricCode,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),

                                DataCell(
                                  ElevatedButton.icon(

                                    onPressed: printing
                                        ? null
                                        : () => printBarcode(e),
                                    icon: printing
                                        ? const SizedBox(
                                      height: 16,
                                      width: 16,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Icon(Icons.print,color: C.primaryDark,),
                                    label: const Text("Print",style: TextStyle(color: C.primaryDark),),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  DataCell cell(String value) {
    return DataCell(
      Text(
        value,
        style: const TextStyle(fontSize: 13),
        softWrap: false,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Future<void> issueWithoutPrint(WebbingSavedEntry item) async {
    try {
      final response = await DashboardService.printWebbingBarcode(
        barcode: item.barcode,
        department: "RMD",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Future<PrintAction?> showPrintPreview(WebbingSavedEntry item) {
    return showDialog<PrintAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Barcode Preview"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.partyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                Text("Barcode : ${item.barcode}"),
                Text("Lot No : ${item.lotNo}"),
                Text("Fabric : ${item.fabricCode}"),
                Text("Weight : ${item.rollWeight} Kg"),

                const SizedBox(height: 20),

                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: item.barcode,
                  width: 170,
                  height: 170,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, PrintAction.cancel),
              child: const Text("Cancel"),
            ),

            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pop(context, PrintAction.issueOnly),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text("Issue Only"),
            ),

            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pop(context, PrintAction.printAndIssue),
              icon: const Icon(Icons.print),
              label: const Text("Print & Issue"),
            ),
          ],
        );
      },
    );
  }

}


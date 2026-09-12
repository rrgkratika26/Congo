import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../Color/Colorclass.dart';
import 'baleStockModel/BaleReportModel.dart';

class BailingLabelPreview extends StatefulWidget {
  final BailingReportModel data;

  const BailingLabelPreview({super.key, required this.data});

  @override
  State<BailingLabelPreview> createState() => _BailingLabelPreviewState();
}

class _BailingLabelPreviewState extends State<BailingLabelPreview> {
  final _storage = GetStorage();

  bool _printing = false;
  bool _scanning = false;
  String? _printerAddress;
  String? _printerName;
  List<BluetoothInfo> _pairedPrinters = [];

  @override
  void initState() {
    super.initState();
    _printerAddress = _storage.read<String>('printer_address');
    _printerName = _storage.read<String>('printer_name');
  }

  @override
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth < 420 ? screenWidth - 40 : 380.0;

    return Container(
      width: boxWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Column(
        children: [
          /// 🔹 Printer status / connect bar
          Row(
            children: [
              Icon(
                Icons.bluetooth,
                size: 18,
                color: _printerAddress != null ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _printerAddress != null
                      ? _printerName ?? "Printer connected"
                      : "No printer selected",
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _showPrinterPicker,
                child: Text(_printerAddress != null ? "Change" : "Connect",style: TextStyle(color: C.warning),),
              ),
            ],
          ),
          const Divider(),

          _row("PARTY NAME :", data.partyName),
          _row("ARTICLE NO :", data.articleNo),
          _row("BAG SIZE :", data.bagType),

          Row(
            children: [
              Expanded(
                child: Text(
                  "BALE # : ${data.baleNo}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  "BAG/PC : ${data.bagQty}",
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: data.barcode,
            width: 180,
            height: 180,
            drawText: false,
          ),

          const SizedBox(height: 15),

          Text(
            "BARCODE::${data.barcode}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// 🔹 Cancel + Print buttons side by side
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _printing ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _printing ? null : _confirmAndPrint,
                  icon: _printing
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.print,color: C.warning,),
                  label: Text(_printing ? "Printing..." : "Print",style: TextStyle(color: C.warning),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  /// 🔹 Scan paired bluetooth printers (same as loom list screen)
  Future<void> _scanPrinters() async {
    setState(() {
      _scanning = true;
      _pairedPrinters = [];
    });

    try {
      final result = await PrintBluetoothThermal.pairedBluetooths;
      setState(() => _pairedPrinters = result);

      if (_pairedPrinters.isEmpty) {
        Get.snackbar(
          "No Printer",
          "No paired Bluetooth printers found. Pair it first from phone settings.",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Scan failed: $e");
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _showPrinterPicker() async {
    await _scanPrinters();

    if (!mounted) return;

    await showModalBottomSheet(
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
              if (_scanning)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_pairedPrinters.isEmpty)
                const Expanded(
                  child: Center(child: Text("No paired printers found")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _pairedPrinters.length,
                    itemBuilder: (_, index) {
                      final p = _pairedPrinters[index];
                      return ListTile(
                        leading: const Icon(Icons.print, color: Colors.blue),
                        title: Text(p.name),
                        subtitle: Text(p.macAdress),
                        onTap: () {
                          _storage.write('printer_name', p.name);
                          _storage.write('printer_address', p.macAdress);

                          setState(() {
                            _printerName = p.name;
                            _printerAddress = p.macAdress;
                          });

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

  Future<void> _confirmAndPrint() async {
    final data = widget.data;

    if (_printerAddress == null) {
      Get.snackbar(
        "Printer Error",
        "❌ Please connect printer first",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await _showPrinterPicker();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Print Label"),
        content: Text("Print bale label?\n\n${data.barcode}"),
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

    await _printLabel();
  }

  /// 🔹 Same working flow as SavedListScreen._printBarcodeApi
  Future<void> _printLabel() async {
    final data = widget.data;
    final address = _printerAddress!;
    final name = _printerName ?? 'Printer';

    setState(() => _printing = true);

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

      final String tspl =
      '''
SIZE 100 mm,100 mm
GAP 3 mm,0 mm
DIRECTION 1
CLS

TEXT 30,80,"3",0,2,2,"Party Name: ${data.partyName}"

TEXT 40,140,"3",0,2,2,"Article No#: ${data.articleNo}"

TEXT 40,200,"3",0,2,2,"BAG SIZE: ${data.bagType}"

TEXT 40,260,"3",0,2,2,"BALE#: ${data.baleNo}"

TEXT 40,320,"3",0,2,2,"BOM#: ${data.bomNo}"

TEXT 40,380,"3",0,2,2,"ARTICLE: ${data.articleNo}"

TEXT 40,440,"3",0,2,2,"BAG QTY: ${data.bagQty}"

TEXT 40,500,"3",0,2,2,"NET WT: ${data.netWt}"

TEXT 40,560,"3",0,2,2,"GROSS WT: ${data.grossWt}"

QRCODE 240,650,L,12,A,0,"${data.barcode}"

TEXT 180,920,"3",0,2,2,"${data.barcode}"

PRINT 1
''';

      /// 🔥 PRINT
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: tspl.codeUnits,
      );

      Get.snackbar(
        "Success",
        "Label Printed Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // let the user see the success message, then go back
      await Future.delayed(const Duration(milliseconds: 100));
Navigator.pop(context);
      if (mounted) Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        "❌ Print failed: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}
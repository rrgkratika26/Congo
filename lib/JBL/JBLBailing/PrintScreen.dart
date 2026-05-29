import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';
import 'dart:typed_data';
import '../../Color/Colorclass.dart';
import 'PrintController.dart';

class ShowPrintDocPage extends StatefulWidget {
  const ShowPrintDocPage({super.key});

  @override
  State<ShowPrintDocPage> createState() => _ShowPrintDocPageState();
}

class _ShowPrintDocPageState extends State<ShowPrintDocPage> {
  final _logic = Get.find<ShowPrintController>();

  PrintingInfo? printingInfo;
  var defaultPrinterType = PrinterType.bluetooth;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter? selectedPrinter;

  var storage = Get.isRegistered<GetStorage>()
      ? Get.find<GetStorage>()
      : Get.put(GetStorage());

  // ✅ Type parameter pehle save karo — Get.back() ke baad lost ho jaata hai
  int? _printType;

  @override
  void initState() {
    super.initState();
    _portController.text = _port;

    // ✅ FIX: BTStatus listener — iOS ke liye bluetooth use karo (usb nahi)
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((
      status,
    ) {
      print('----------------- BT STATUS: $status -----------------');
      _currentStatus = status;

      if (status == BTStatus.connected) {
        setState(() => _isConnected = true);

        // ✅ Pending task bhejo jab connected ho jaye
        if (pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(
              type: PrinterType
                  .bluetooth, // ✅ iOS aur Android dono ke liye bluetooth
              bytes: pendingTask!,
            );
            pendingTask = null;
          });
        }
      }

      if (status == BTStatus.none) {
        setState(() => _isConnected = false);
      }
    });

    _init();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    printingInfo = info;
    var parameter = Get.parameters;

    // ✅ Type pehle save karo — Get.back() ke baad parameters lost ho jaate hain
    if (parameter['type'] != null) {
      _printType = int.tryParse(parameter['type'].toString());
      try {
        await _logic.loadData(_printType);
      } catch (e) {
        print('_init loadData error: $e');
      }
    }

    Get.back();
    _loadStoredPrinter();
  }

  Future<void> _loadStoredPrinter() async {
    final address = storage.read('printer_address');
    final name = storage.read('printer_name');
    final port = storage.read('printer_port');

    print("Stored printer → name: $name, address: $address");

    if (address != null && name != null) {
      _ipAddress = address;
      _port = port ?? '9100';
      var device = BluetoothPrinter(
        deviceName: name,
        address: _ipAddress,
        port: _port,
        typePrinter: PrinterType.bluetooth,
      );
      await selectDevice(device);
      // ✅ Device connect hone ke baad print karo
      await Future.delayed(const Duration(milliseconds: 1500));
      printReceiveTest();
    } else {
      _scan();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _scan() {
    devices.clear();
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
          devices.add(
            BluetoothPrinter(
              deviceName: device.name,
              address: device.address,
              isBle: _isBle,
              vendorId: device.vendorId,
              productId: device.productId,
              typePrinter: defaultPrinterType,
            ),
          );
          setState(() {});
        });
  }

  Future<void> selectDevice(BluetoothPrinter device) async {
    // Pehle se connected hai toh disconnect karo
    if (selectedPrinter != null) {
      if (device.address != selectedPrinter!.address) {
        await PrinterManager.instance.disconnect(
          type: selectedPrinter!.typePrinter,
        );
      }
    }

    selectedPrinter = device;

    if (Platform.isIOS) {
      // ✅ iOS: PrintBluetoothThermal se connect karo
      if (device.address != null) {
        final bool result = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.address!,
        );
        print("iOS BT connect result: $result");
        _isConnected = result;
      }
    } else {
      // ✅ Android: PrinterManager se connect karo
      await printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: device.deviceName ?? '',
          address: device.address ?? '',
          isBle: device.isBle ?? false,
          autoConnect: _reconnect,
        ),
      );
    }

    // Storage mein save karo
    await storage.write('printer_address', device.address);
    await storage.write('printer_name', device.deviceName);
    await storage.write('printer_port', _port);
    await storage.write('printer_vendor', device.vendorId);
    await storage.write('printer_productid', device.productId);

    print("Device saved: ${device.deviceName} @ ${device.address}");

    if (mounted) setState(() {});
  }

  // ✅ FIXED _printEscPos — duplicate case hataya, sahi logic lagaya
  void _printEscPos(List<int> bytes, Generator generator) async {
    if (selectedPrinter == null) {
      print('No printer selected!');
      return;
    }
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb: // ✅ USB alag case
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
          type: PrinterType.usb,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        printerManager.send(type: PrinterType.usb, bytes: bytes);
        break;

      case PrinterType.bluetooth: // ✅ Bluetooth sahi case
        bytes += generator.cut();

        if (Platform.isAndroid) {
          // Android: connect karo, pending mein rakho, BTStatus.connected par send hoga
          await printerManager.connect(
            type: PrinterType.bluetooth,
            model: BluetoothPrinterInput(
              name: bluetoothPrinter.deviceName ?? '',
              address: bluetoothPrinter.address!,
              isBle: bluetoothPrinter.isBle ?? false,
              autoConnect: _reconnect,
            ),
          );

          if (_currentStatus == BTStatus.connected) {
            // Pehle se connected hai toh seedha bhejo
            print('Already connected — sending bytes directly');
            await Future.delayed(const Duration(milliseconds: 500));
            printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
          } else {
            // Connected nahi hai — pending mein rakho, listener bhejega
            print('Not yet connected — storing as pendingTask');
            pendingTask = bytes;
          }
        }
        // iOS ke liye printReceiveTest mein directly PrintBluetoothThermal.writeBytes call hoti hai
        break;

      case PrinterType.network: // ✅ Network/TCP
        bytes += generator.feed(2);
        bytes += generator.cut();
        final connectedTCP = await printerManager.connect(
          type: PrinterType.network,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        if (connectedTCP) {
          printerManager.send(type: PrinterType.network, bytes: bytes);
        } else {
          print('TCP connection failed — check IP/port');
        }
        break;

      default:
        print('Unknown printer type');
        break;
    }
  }

  Future<void> printReceiveTest() async {
    print('printReceiveTest started...');

    // ✅ Saved _printType use karo — Get.parameters ab available nahi hota
    if (_printType == null) {
      print('No print type found');
      return;
    }

    Uint8List? pdfData = _logic.uint8list;
    if (pdfData == null && _logic.pdf != null) {
      pdfData = await _logic.pdf?.save();
    }

    if (pdfData == null) {
      print('No PDF data to print.');
      return;
    }

    final profile = await CapabilityProfile.load(name: 'RP80USE');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final doc = await PdfDocument.openData(pdfData);
    final pageCount = doc.pagesCount;
    print('Total pages: $pageCount');

    for (int i = 1; i <= pageCount; i++) {
      final page = await doc.getPage(i);
      final pageImage = await page.render(
        width: 1080,
        height: 1920,
        backgroundColor: '#FFFFFFFF',
      );
      await page.close();

      final Uint8List pageBytes = pageImage!.bytes;
      img.Image? image = img.decodeImage(pageBytes);

      if (image == null) {
        print('Error decoding page $i');
        continue;
      }

      // White space trim karo
      image = _trimWhiteSpace(image);

      // Resize karo — 58mm printer ke liye 380px width
      const int maxPrintWidth = 380;
      final double aspectRatio = image.height / image.width;
      final int newHeight = (maxPrintWidth * aspectRatio).round();
      img.Image resized = img.copyResize(
        image,
        width: maxPrintWidth,
        height: newHeight,
      );

      // ✅ Grayscale karo — thermal printer ke liye zaroori
      img.Image grayImage = img.grayscale(resized);

      bytes += generator.imageRaster(grayImage, align: PosAlign.center);
      bytes += generator.feed(1);
    }

    await doc.close();
    bytes += generator.cut();

    print('Total bytes generated: ${bytes.length}');

    if (Platform.isIOS) {
      // ✅ iOS: PrintBluetoothThermal se directly bhejo
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      print('iOS print result: $result');
    } else {
      // ✅ Android: _printEscPos se bhejo
      _printEscPos(bytes, generator);
    }
  }

  img.Image _trimWhiteSpace(img.Image src) {
    int top = 0;
    int bottom = src.height - 1;
    int left = 0;
    int right = src.width - 1;

    for (int y = 0; y < src.height; y++) {
      if (!_isRowWhite(src, y)) {
        top = y;
        break;
      }
    }
    for (int y = src.height - 1; y >= 0; y--) {
      if (!_isRowWhite(src, y)) {
        bottom = y;
        break;
      }
    }
    for (int x = 0; x < src.width; x++) {
      if (!_isColumnWhite(src, x, top, bottom)) {
        left = x;
        break;
      }
    }
    for (int x = src.width - 1; x >= 0; x--) {
      if (!_isColumnWhite(src, x, top, bottom)) {
        right = x;
        break;
      }
    }

    final newWidth = (right - left + 1).clamp(1, src.width - left);
    final newHeight = (bottom - top + 1).clamp(1, src.height - top);

    return img.copyCrop(
      src,
      x: left,
      y: top,
      width: newWidth,
      height: newHeight,
    );
  }

  bool _isRowWhite(img.Image image, int y) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) return false;
    }
    return true;
  }

  bool _isColumnWhite(img.Image image, int x, int top, int bottom) {
    for (int y = top; y <= bottom; y++) {
      final pixel = image.getPixel(x, y);
      if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) return false;
    }
    return true;
  }

  void _showDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Available Printers"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: devices
                .map(
                  (device) => ListTile(
                    title: Text('${device.deviceName}'),
                    subtitle: Platform.isAndroid
                        ? null
                        : Text("${device.address}"),
                    leading:
                        selectedPrinter != null &&
                            (device.address == selectedPrinter!.address)
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await selectDevice(device);
                      printReceiveTest();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<ShowPrintController>(),
      builder: (logic) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                _scan();
                _showDeviceDialog();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bluetooth),
                  const SizedBox(width: 6),
                  Text(
                    selectedPrinter?.deviceName ?? 'Printer Select karo',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Icon(
                    _isConnected ? Icons.circle : Icons.circle_outlined,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 12,
                  ),
                ],
              ),
            ),
            actions: [
              InkWell(
                onTap: () => printReceiveTest(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.print),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: logic.uint8list == null
              ? const Center(child: CircularProgressIndicator(color: C.appBar3,
            backgroundColor: Colors.transparent,
          ))
              : InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(0),
                  minScale: 1,
                  maxScale: 3,
                  child: PdfPreview(
                    useActions: false,
                    canChangeOrientation: true,
                    build: (format) => logic.uint8list!,
                    allowPrinting: false,
                    allowSharing: true,
                  ),
                ),
        );
      },
    );
  }
}

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });
}

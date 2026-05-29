//
//
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/services.dart';
//
// class PrinterService {
//   BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//
//   Future<void> printText() async {
//     try {
//       bool? isConnected = await bluetooth.isConnected;
//
//       if (isConnected == true) {
//         bluetooth.printCustom("IMS SYSTEM", 3, 1); // size 3, center
//         bluetooth.printNewLine();
//
//         bluetooth.printCustom("Hello Kratika 👋", 1, 0);
//         bluetooth.printCustom("Printing Successful", 1, 0);
//
//         bluetooth.printNewLine();
//         bluetooth.printNewLine();
//
//         bluetooth.paperCut();
//       } else {
//         print("Printer not connected");
//       }
//     } on PlatformException catch (e) {
//       print("Error: ${e.message}");
//     }
//   }
// }


import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';


class BluetoothPrintService {
  final PrinterManager _printerManager = PrinterManager.instance;

  /// CONNECT TO PRINTER
  Future<void> connect(String macAddress) async {
    await _printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: "Printer",
        address: macAddress,
        isBle: false, // ⚠️ IMPORTANT — 58mm printers are Classic
      ),
    );

    debugPrint("✅ Connected to printer");
  }

  /// PRINT WIDGET
  Future<void> printWidget(GlobalKey boundaryKey) async {
    debugPrint("📸 Capturing widget...");

    final boundary =
    boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image uiImage = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
    await uiImage.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    img.Image? original = img.decodeImage(pngBytes);

    if (original == null) {
      debugPrint("❌ Image decode failed");
      return;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = _buildBytes(generator, original);

    debugPrint("🖨️ Sending ${bytes.length} bytes...");

    const chunkSize = 1024;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize < bytes.length)
          ? i + chunkSize
          : bytes.length;

      await _printerManager.send(
        type: PrinterType.bluetooth,
        bytes: bytes.sublist(i, end),
      );

      await Future.delayed(const Duration(milliseconds: 30));
    }

    debugPrint("✅ Print complete");
  }

  /// BUILD ESC/POS BYTES
  List<int> _buildBytes(Generator generator, img.Image labelImage) {
    List<int> bytes = [];

    bytes.addAll(generator.reset());

    // Resize for 58mm printer
    const int width = 280;
    final int height =
    (width * labelImage.height / labelImage.width).round();

    img.Image resized =
    img.copyResize(labelImage, width: width, height: height);

    resized = img.grayscale(resized);

    // ⚠️ IMPORTANT — use image() NOT imageRaster()
    bytes.addAll(generator.image(resized, align: PosAlign.center));

    bytes.addAll(generator.feed(5));
    bytes.addAll(generator.cut());

    return bytes;
  }

  /// DISCONNECT
  Future<void> disconnect() async {
    await _printerManager.disconnect(type: PrinterType.bluetooth);
  }
}
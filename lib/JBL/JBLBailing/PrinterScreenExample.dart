// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: PrinterScreen(),
//     );
//   }
// }
//
// class PrinterScreen extends StatefulWidget {
//   const PrinterScreen({super.key});
//
//   @override
//   State<PrinterScreen> createState() => _PrinterScreenState();
// }
//
// class _PrinterScreenState extends State<PrinterScreen> {
//   BlueThermalPrinter printer = BlueThermalPrinter.instance;
//   List<BluetoothDevice> devices = [];
//   BluetoothDevice? selectedDevice;
//   bool _connecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getDevices();
//   }
//
//   Future<void> getDevices() async {
//     List<BluetoothDevice> bondedDevices = await printer.getBondedDevices();
//     setState(() {
//       devices = bondedDevices;
//     });
//   }
//
//   Future<void> connect() async {
//     if (selectedDevice == null) return;
//     setState(() => _connecting = true);
//     try {
//       await printer.connect(selectedDevice!);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Connected")),
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Connect failed: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _connecting = false);
//     }
//   }
//
//   /// Print using high-level methods + delay and paper feed so content comes out.
//   Future<void> printTest() async {
//     bool? isConnected = await printer.isConnected;
//     if (isConnected != true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Printer not connected")),
//       );
//       return;
//     }
//
//     try {
//       // Small delay after connect so printer is ready
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       printer.printCustom("HELLO KRATIKA", 3, 1);
//       printer.printCustom("DCode DC2M Printer", 2, 0);
//       printer.printNewLine();
//       printer.printCustom("----------------------", 1, 0);
//       printer.printCustom("Test Print Successful", 2, 0);
//       printer.printNewLine();
//       printer.printNewLine();
//       // Feed paper so the receipt comes out (many printers need this)
//       for (int i = 0; i < 4; i++) {
//         printer.printNewLine();
//       }
//       printer.paperCut();
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Print sent")),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Print error: $e")),
//         );
//       }
//     }
//   }
//
//   /// Fallback: send raw ESC/POS bytes (works when printCustom does nothing).
//   Future<void> printTestRaw() async {
//     bool? isConnected = await printer.isConnected;
//     if (isConnected != true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Printer not connected")),
//       );
//       return;
//     }
//
//     try {
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // ESC/POS: ESC @ = initialize, text, GS V 0 = feed & cut
//       final List<int> bytes = [];
//       bytes.addAll([0x1B, 0x40]); // Reset
//       bytes.addAll("HELLO KRATIKA\r\n".codeUnits);
//       bytes.addAll("DCode DC2M Printer\r\n".codeUnits);
//       bytes.addAll("----------------------\r\n".codeUnits);
//       bytes.addAll("Test Print Successful\r\n".codeUnits);
//       bytes.addAll([0x0A, 0x0A, 0x0A, 0x0A]); // Line feeds
//       bytes.addAll([0x1D, 0x56, 0x00]); // Full cut (GS V 0)
//
//       await printer.writeBytes(Uint8List.fromList(bytes));
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Raw print sent")),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Print error: $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("DC2M Printer"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButton<BluetoothDevice>(
//               hint: const Text("Select Printer"),
//               value: selectedDevice,
//               isExpanded: true,
//               items: devices.map((device) {
//                 return DropdownMenuItem(
//                   value: device,
//                   child: Text(device.name ?? device.address ?? "Unknown"),
//                 );
//               }).toList(),
//               onChanged: (device) {
//                 setState(() => selectedDevice = device);
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _connecting ? null : connect,
//               child: Text(_connecting ? "Connecting..." : "Connect"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: printTest,
//               child: const Text("Print Test (normal)"),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: printTestRaw,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange.shade700,
//               ),
//               child: const Text("Print Test (raw ESC/POS)"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

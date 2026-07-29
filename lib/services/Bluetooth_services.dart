import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Color/Colorclass.dart';

class BluetoothDeviceListScreen extends StatefulWidget {
  const BluetoothDeviceListScreen({super.key});

  @override
  State<BluetoothDeviceListScreen> createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState
    extends State<BluetoothDeviceListScreen> {
  final _storage = GetStorage();
  List<BluetoothInfo> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);

    final List<BluetoothInfo> devices =
    await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _devices = devices;
      _loading = false;
    });
  }

  Future<void> _selectDevice(BluetoothInfo device) async {
    await _storage.write('printer_name', device.name);
    await _storage.write('printer_address', device.macAdress);

    Get.back();

    Get.snackbar(
      "Printer Selected",
      device.name ?? "",
      snackPosition: SnackPosition.TOP,
      animationDuration: Duration(milliseconds: 5)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Printer"),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
          : _devices.isEmpty
          ? const Center(child: Text("KNo Connection found"))
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            leading: const Icon(Icons.print),
            title: Text(device.name ?? "Unknown"),
            subtitle: Text(device.macAdress ?? ""),
            onTap: () => _selectDevice(device),
          );
        },
      ),
    );
  }
}
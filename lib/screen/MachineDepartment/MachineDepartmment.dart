import 'package:IMS/screen/MachineDepartment/MachineDetailScreen.dart';
import 'package:flutter/material.dart';
import '../../services/getSupervisors/MAchineApiService.dart';
import 'MachineRepaiScreen.dart';
import 'ModelClass.dart';
import 'ScanMachineQR.dart';

class MchineList extends StatefulWidget {
  final String screenType;
  const MchineList({Key? key,required this.screenType}) : super(key: key);

  @override
  State<MchineList> createState() => _MchineListState();
}

class _MchineListState extends State<MchineList> {
  List<MachineModel> machines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMachines();
  }

  Future<void> loadMachines() async {
    final response = await MachineApiService.fetchMachines();

    setState(() {
      machines = response; // 🔥 no mapping needed now
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,

        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Asset Management",

          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                children: [
                  /// 🔹 Machine Count Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        "Total Machines: ${machines.length}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E5AA8),
                        ),
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 10),
            
                  /// 🔹 Center Scan + Manual Entry Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
            
                        /// QR Scan Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScanMachineQrScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 70,
                              color: Colors.black,
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 15),
            
                        const Text(
                          "Scan Machine QR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            
                        const SizedBox(height: 25),
            
                        /// Manual Entry Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5AA8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            _showManualEntryDialog(context);
                          },
                          child: const Text(
                            "Manual Machine ID Entry",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ),
            
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5AA8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            final TextEditingController idController = TextEditingController();
            
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text("Enter Machine ID"),
                                  content: TextField(
                                    controller: idController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: "Enter Machine ID",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel",style: TextStyle(color: Colors.black),),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E5AA8),
                                      ),
                                      onPressed: () {
                                        if (idController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please enter Machine ID")),
                                          );
                                          return;
                                        }

                                        int? machineId = int.tryParse(idController.text);

                                        if (machineId == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Enter valid numeric Machine ID")),
                                          );
                                          return;
                                        }

                                        Navigator.pop(context); // close dialog
            
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MachineRepairScreen(
                                              machineId: machineId, // 👈 pass only id
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Submit",style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
            
                          child: const Text(
                            "Machine Repair List",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  /// 🔹 Machine List
                  // Expanded(
                  //   child: machines.isEmpty
                  //       ? const Center(child: Text("No Machines Found"))
                  //       : ListView.builder(
                  //           padding: const EdgeInsets.all(16),
                  //           itemCount: machines.length,
                  //           itemBuilder: (context, index) {
                  //             final machine = machines[index];
                  //
                  //             return GestureDetector(
                  //               onTap: () {
                  //                 Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                     builder: (_) => MachineDetailScreen(
                  //                       machineBrId: machine.machineBrId,
                  //                       machineId: machine.id,
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //               child: _buildMachineCard(machine),
                  //             );
                  //           },
                  //         ),
                  // ),
                ],
              ),
          ),
    );
  }



  void _showManualEntryDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Machine ID"),
          content: TextField(
            controller: idController,
            decoration: const InputDecoration(hintText: "Enter Machine ID"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade100, // 💙 light blue
                foregroundColor: Colors.black, // text color
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final enteredId = idController.text.trim();
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MachineDetailScreen(
                      machineBrId: enteredId,
                      machineId: 0,
                    ),
                  ),
                );
              },
              child: const Text(
                "Submit",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

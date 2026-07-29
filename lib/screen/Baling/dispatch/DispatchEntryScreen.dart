import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'BarcCodeModel.dart';
import 'DispatchModel.dart';

class BalingDispatchScreen extends StatefulWidget {
  const BalingDispatchScreen({Key? key}) : super(key: key);

  @override
  State<BalingDispatchScreen> createState() => _BalingDispatchScreenState();
}

class _BalingDispatchScreenState extends State<BalingDispatchScreen> {
  final TextEditingController articleCtrl = TextEditingController();
  final TextEditingController srCtrl = TextEditingController(); // Static SR
  final TextEditingController barcodeCtrl = TextEditingController();
  bool isBarcodeValid = false;
  bool isSaving = false;
  int? dispatchId;
  String? DispatchSrNo;
  int? dispatchRmdTime;
  BarcodeResponseModel? barcodeData;

  String? party;
  String? bom;
  String? po;
  String? supervisor;
  String? operatorName;

  List<String> partyList = [];
  List<String> bomList = [];
  List<String> poList = [];
  List<String> supervisorList = [];
  List<String> operatorList = [];
  List<BarcodeResponseModel> barcodeDataList = []; // Store multiple barcodes

  bool isLoading = true;

  @override
  void dispose() {
    articleCtrl.dispose();
    srCtrl.dispose();
    barcodeCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDispatchInit();
  }

  // Future<void> _saveDispatch() async {
  //   if (barcodeDataList.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please scan at least one barcode")),
  //     );
  //     return;
  //   }
  //
  //   if (party == null || supervisor == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please complete required fields")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => isSaving = true);
  //
  //   try {
  //     final now = DateTime.now();
  //     final formattedDate =
  //         "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T"
  //         "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
  //
  //     // ✅ Loop through all barcodes and save each one
  //     int successCount = 0;
  //     int failCount = 0;
  //
  //     for (var barcodeData in barcodeDataList) {
  //       final request = DispatchSaveRequest(
  //         flag: "U",
  //         // id: int.tryParse(barcodeData.id) ?? 0,
  //         id: barcodeData.id,
  //         // id: int.tryParse(barcodeData.id) ?? 0,
  //         srNo: barcodeData.srno,
  //         barcode: barcodeData.barcode ?? "",
  //         partyName: party ?? "",
  //         articleNo: articleCtrl.text.replaceAll('"', '').trim(),
  //         supervisorName: supervisor ?? "",
  //         operatorName: operatorName ?? "",
  //         baleNo: "${barcodeData.entryout ?? ""}(bale no)",
  //         bagType: barcodeData.barcode ?? "",
  //         laminationDate1: formattedDate,
  //         laminationToRoll1: "",
  //         laminationTime1: "",
  //         laminationOperator1: operatorName ?? "",
  //         laminationRoll1: bom ?? "",
  //         laminationLocation1: "",
  //         laminationSupervisor1: supervisor ?? "",
  //         toRoll: "",
  //         forward: "",
  //         rmdSupervisor: supervisor ?? "",
  //         rmdLocation: "",
  //         rmdOperator: operatorName ?? "",
  //         rmdSupervisor1: "",
  //         rmdLocation1: "",
  //         rmdOperator1: "",
  //         toRoll1: "",
  //         forward1: "",
  //         statusRollType: srCtrl.text,
  //         rmStatus: "OUT",
  //         rmdRemark: "OUT_STOCK",
  //         rmdSupervisorOut: "ART001",
  //         fromRoll: "OUT_STOCK",
  //         rmdTime: int.tryParse(srCtrl.text) ?? 0,
  //         tableBaleNo: "${barcodeData.entryout ?? ""}(bale no)",
  //           machine: "testing",   // ✅ REQUIRED
  //
  //           entries: entries.map((e) => e.toJson()).toList(), // ✅ REQUIRED
  //       );
  //
  //       debugPrint("SAVING BARCODE: ${barcodeData.srno}");
  //
  //       final success = await InStockService.saveDispatch(request);
  //
  //       if (success) {
  //         successCount++;
  //       } else {
  //         failCount++;
  //       }
  //     }
  //
  //     if (successCount > 0) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "Saved $successCount barcode(s) successfully" +
  //                 (failCount > 0 ? ", $failCount failed" : ""),
  //           ),
  //           backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
  //         ),
  //       );
  //
  //       // ✅ Clear the list after successful save
  //       setState(() {
  //         barcodeDataList.clear();
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("All saves failed - please check your data"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error while saving dispatch: $e")),
  //     );
  //   } finally {
  //     setState(() => isSaving = false);
  //   }
  // }

  Future<void> _saveDispatch() async {
    if (barcodeDataList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please scan at least one barcode")),
      );
      return;
    }

    if (party == null || supervisor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete required fields")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final now = DateTime.now();

      final formattedDate = DateTime(now.year, now.month, now.day).toIso8601String().split('T').first;

      // ✅ CREATE ENTRIES LIST
      final entries = barcodeDataList.map((barcodeData) {
        return {
          "srNo": barcodeData.srno,
          "barcode": barcodeData.barcode ?? "",
          "entryOut": barcodeData.entryout ?? "",
          "status": barcodeData.status ?? "",
          "remark": barcodeData.remark ?? "",
          "activeIn": barcodeData.activein ?? "",
          "partyName": party ?? "",
          "department": barcodeData.department ?? "",
          "activeOut": barcodeData.activeout ?? "",
        };
      }).toList();

      // ✅ FINAL REQUEST BODY
      final requestBody = {
        "flag": "U",
        "DispatchSrNo": srCtrl.text,
        "articleNo": articleCtrl.text.replaceAll('"', '').trim(),
        "supervisorName": supervisor ?? "",
        // "operatorName": operatorName ?? "",
        "operatorName": bom ?? "",
        "baleNo": "MULTI",
        // "bagType": "MULTI",
        "bagType": barcodeData?.barcode ?? "",

        "laminationDate1": formattedDate,
        "machine": party ?? "", // ✅ REQUIRED
        // id: int.tryParse(barcodeData.id) ?? 0,
        "id": barcodeData?.id,

        // id: int.tryParse(barcodeData.id) ?? 0,
        // "articleNo": articleCtrl.text.replaceAll('"', '').trim(),
        // "supervisorName": supervisor ?? "",
        // "operatorName": operatorName ?? "",
        // "baleNo": "${barcodeData?.entryout ?? ""}(bale no)",
        // "bagType": barcodeData?.barcode ?? "",
        "laminationToRoll1": "0",
        "laminationTime1": "0",

        // "laminationOperator1": operatorName ?? "",
        // "laminationRoll1": bom ?? "",
        "laminationLocation1": "",
        "laminationSupervisor1": supervisor ?? "",

        "status": srCtrl.text,
        // "rmStatus": "OUT",
        // "rmdRemark": "OUT_STOCK",
        // "rmdSupervisorOut": "ART001",
        // "fromRoll": "OUT_STOCK",
        // "rmdTime": int.tryParse(srCtrl.text) ?? 0,
        "BaleNo": "${barcodeData?.entryout ?? ""}(bale no)",
        "entries": entries, // ✅ REQUIRED
      };

      // 🔥 DEBUG PRINT
      debugPrint("FINAL REQUEST 👉 ${jsonEncode(requestBody)}");

      // ✅ SINGLE API CALL
      final success = await InStockService.saveDispatch(requestBody);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dispatch saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          barcodeDataList.clear();
        });
        // ✅ THIS WILL POP SCREEN
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Save failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while saving dispatch: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }
  // Future<void> _saveDispatch() async {
  //   if (!isBarcodeValid || barcodeData == null) return;
  //
  //   if (party == null || supervisor == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please complete required fields")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => isSaving = true);
  //
  //   try {
  //     final now = DateTime.now();
  //
  //     final formattedDate =
  //         "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T"
  //         "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
  //
  //     final request = DispatchSaveRequest(
  //       flag: "U",
  //       id: int.tryParse(srCtrl.text) ?? 0,
  //       srNo: srCtrl.text,
  //
  //       barcode: barcodeData?.barcode ?? "",
  //       partyName: party ?? "",
  //       articleNo: articleCtrl.text,
  //       supervisorName: supervisor ?? "",
  //       operatorName: operatorName ?? "",
  //
  //       baleNo: "${barcodeData?.entryout ?? ""}(bale no)",
  //       bagType: barcodeData?.barcode ?? "",
  //
  //       laminationDate1: formattedDate,
  //       laminationToRoll1: "",
  //       laminationTime1: "",
  //       laminationOperator1: "",
  //       laminationRoll1: "",
  //       laminationLocation1: "",
  //       laminationSupervisor1: "",
  //
  //       toRoll: "",
  //       forward: "",
  //
  //       rmdSupervisor: "",
  //       rmdLocation: "",
  //       rmdOperator: "",
  //       rmdSupervisor1: "",
  //       rmdLocation1: "",
  //       rmdOperator1: "",
  //       toRoll1: "",
  //       forward1: "",
  //
  //       statusRollType: "17",
  //       rmStatus: "OUT",
  //       rmdRemark: "OUT_STOCK",
  //       rmdSupervisorOut: "ART001",
  //       fromRoll: "OUT_STOCK",
  //
  //       rmdTime: 17,
  //       tableBaleNo: "${barcodeData?.entryout ?? ""}(bale no)",
  //     );
  //
  //     // ✅ ADD THIS HERE
  //     debugPrint("FINAL REQUEST BODY 👉 ${jsonEncode(request.toJson())}");
  //     final success = await InStockService.saveDispatch(request);
  //
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Dispatch saved successfully"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //
  //       setState(() {
  //         barcodeCtrl.clear();
  //         barcodeData = null;
  //         isBarcodeValid = false;
  //       });
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("Save failed")));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error while saving dispatch: $e")),
  //     );
  //   } finally {
  //     setState(() => isSaving = false);
  //   }
  // }

  Future<void> _fetchBomNumbers(String partyName) async {
    try {
      setState(() {
        bom = null;
        bomList = [];
        articleCtrl.clear();
      });

      final boms = await InStockService.fetchBomNumbers(partyName);

      setState(() {
        bomList = boms;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load BOM numbers")),
      );
    }
  }

  Future<void> _fetchPONumbers(String partyName) async {
    try {
      setState(() {
        po = null;
        poList = [];
      });

      final pos = await InStockService.fetchPONumbers(partyName: partyName);

      setState(() {
        poList = pos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load PO numbers")),
      );
    }
  }

  Future<void> _fetchArticleNumber() async {
    if (party == null || bom == null) return;

    setState(() {
      articleCtrl.text = "Fetching...";
    });

    try {
      final articleNo = await InStockService.fetchArticleNumber(
        partyName: party!,
        bomNumber: bom!,
      );

      setState(() {
        articleCtrl.text = articleNo ?? "";
      });
    } catch (e) {
      setState(() {
        articleCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch article number")),
      );
    }
  }

  // Future<void> _fetchBarcodeDetails() async {
  //   if (barcodeCtrl.text.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Please enter SR No")));
  //     return;
  //   }
  //
  //   final srNo = int.tryParse(barcodeCtrl.text);
  //
  //   if (srNo == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Invalid SR No")));
  //     return;
  //   }
  //
  //   try {
  //     FocusScope.of(context).unfocus();
  //
  //     final result = await InStockService.fetchBarcodeBySrNo(srNo: srNo);
  //
  //     if (!result.found) {
  //       setState(() {
  //         isBarcodeValid = false;
  //         barcodeData = null;
  //         dispatchId = null;
  //         dispatchSrNo = null;
  //         dispatchRmdTime = null;
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(result.message ?? "Record not found")),
  //       );
  //       return;
  //     }
  //
  //     setState(() {
  //       isBarcodeValid = true;
  //       barcodeData = result;
  //
  //       // 🔥 Save backend fields dynamically
  //       dispatchId = int.tryParse(result.srno) ?? 0; // backend ID
  //       dispatchSrNo = result.srno; // backend SR No
  //       dispatchRmdTime = int.tryParse(result.srno) ?? 0; // backend RMD time
  //     });
  //
  //     debugPrint("BARCODE DATA UI 👉 ${result.toString()}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Barcode details loaded"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       isBarcodeValid = false;
  //       barcodeData = null;
  //       dispatchId = null;
  //       dispatchSrNo = null;
  //       dispatchRmdTime = null;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Failed to fetch barcode details")),
  //     );
  //   }
  // }

  Future<void> _fetchBarcodeDetails([String? scannedCode]) async {
    // Use scanned code if provided, otherwise use text field value
    final inputCode = scannedCode ?? barcodeCtrl.text;

    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter Barcode No.")));
      return;
    }

    final srNo = int.tryParse(inputCode);

    if (srNo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid SR No")));
      return;
    }

    try {
      FocusScope.of(context).unfocus();

      // If code came from QR scanner, populate the text field
      if (scannedCode != null) {
        barcodeCtrl.text = scannedCode;
      }

      final result = await InStockService.fetchBarcodeBySrNo(srNo: srNo);

      if (!result.found) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "Record not found")),
        );
        return;
      }

      // ✅ Check if barcode already exists (prevent duplicates)
      final isDuplicate = barcodeDataList.any(
        (item) => item.srno == result.srno,
      );

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This barcode is already added!"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        barcodeCtrl.clear(); // Clear the input
        return;
      }

      // ✅ Add to list
      setState(() {
        barcodeDataList.add(result);
      });

      // Clear input for next scan
      barcodeCtrl.clear();

      debugPrint("BARCODE DATA UI 👉 ${result.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Barcode added successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch barcode details")),
      );
    }
  }

  // void _showQRScanner() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: SizedBox(
  //         height: 400,
  //         child: QRView(
  //           key: GlobalKey(debugLabel: 'QR'),
  //           onQRViewCreated: (QRViewController controller) {
  //             controller.scannedDataStream.listen((scanData) async {
  //               await controller.pauseCamera();
  //               Navigator.pop(context);
  //               _fetchBarcodeDetails(scanData.code?.trim() ?? "");
  //             });
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }


  void _showQRScanner() {
    QRViewController? qrController;
    bool scanned = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          height: 450,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      "Scan Barcode",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        qrController?.dispose();
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: QRView(
                  key: GlobalKey(debugLabel: 'QR'),
                  onQRViewCreated: (controller) {
                    qrController = controller;

                    controller.scannedDataStream.listen((scanData) async {
                      if (scanned) return;
                      scanned = true;

                      final code = scanData.code?.trim();

                      if (code == null || code.isEmpty) return;

                      await controller.pauseCamera();

                      Navigator.pop(dialogContext);

                      await _fetchBarcodeDetails(code);

                      qrController?.dispose();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showQRScanner() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // optional (user manually close na kare)
  //     builder: (context) => Dialog(
  //       child: SizedBox(
  //         height: 400,
  //         child: QRView(
  //           key: GlobalKey(debugLabel: 'QR'),
  //           onQRViewCreated: (QRViewController controller) {
  //             controller.scannedDataStream.listen((scanData) async {
  //               final code = scanData.code?.trim();
  //
  //               if (code == null || code.isEmpty) return;
  //
  //               // ❌ REMOVE THESE LINES
  //               await controller.pauseCamera();
  //               Navigator.pop(context);
  //
  //               // ✅ Direct fetch karo
  //               _fetchBarcodeDetails(code);
  //
  //               // OPTIONAL: duplicate fast scanning avoid karne ke liye delay
  //               await Future.delayed(const Duration(seconds: 2));
  //             });
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _loadDispatchInit() async {
    try {
      final result = await InStockService.fetchDispatchInit();

      setState(() {
        srCtrl.text = result.srNo.toString();
        partyList = result.partyNames;
        supervisorList = result.supervisors;
        operatorList = result.operators;
        bomList = result.bomNumbers ?? [];
        poList = result.poNumbers ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load dispatch data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _articleSection(),
            const SizedBox(height: 1),

            _sectionCard(title: "Order Details", child: _dropdownSection()),


            _sectionCard(title: "Personnel", child: _supervisorSection()),
            const SizedBox(height: 1),
            _barcodeSection(),
            // if (isBarcodeValid && barcodeData != null) ...[
            //   const SizedBox(height: 16),
            //   _barcodeDetailsCard(),
            // ],
            if (barcodeDataList.isNotEmpty) ...[
              const SizedBox(height: 2),
              _barcodeDetailsListView(),
            ],

            const SizedBox(height: 1),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _barcodeDetailsListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Scanned Barcodes (${barcodeDataList.length})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (barcodeDataList.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    barcodeDataList.clear();
                  });
                },
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text("Clear All"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ List of barcode cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: barcodeDataList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final barcodeData = barcodeDataList[index];
            return _barcodeDetailsCard(barcodeData, index);
          },
        ),
      ],
    );
  }

  Widget _barcodeDetailsCard(BarcodeResponseModel barcodeData, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Barcode #${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      barcodeDataList.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Barcode removed"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _detailRow("Barcode No", barcodeData.srno),
            _detailRow("Bag WT(GM):", barcodeData.partyname),
            _detailRow("BagType", barcodeData.barcode),
            _detailRow("Bag Size", barcodeData.department),
            _detailRow("Bale No", barcodeData.entryout),
            _detailRow("BagQNT(PCS): ", barcodeData.status),
            _detailRow("BaleNWT: ", barcodeData.remark),
            _detailRow("Bale(GWT): ", barcodeData.activein),
            _detailRow("Pallet Size: ", barcodeData.activeout),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 4, child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
    Color? color,
  }) {
    final sectionColor = color ?? C.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    sectionColor.withOpacity(.12),
                    sectionColor.withOpacity(.05),
                  ],
                ),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [


                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔷 BODY
            Padding(padding: const EdgeInsets.all(18), child: child),
          ],
        ),
      ),
    );
  }

  Widget _articleSection() {
    return Row(
      children: [
        // 🔹 ARTICLE NUMBER
        Expanded(
          flex: 3,
          child: _buildTextField(
            controller: articleCtrl,
            label: "Article Number",
            readOnly: true,

          ),
        ),

        const SizedBox(width: 10),

        // 🔹 SR NUMBER
        Expanded(
          child: _buildTextField(
            controller: srCtrl,
            label: "Sr.No.",
            readOnly: true,

          ),
        ),
      ],
    );
  }


  Widget _dropdownSection() {
    return Column(
      children: [
        _dropdown("Party Name", party, partyList, (v) {
          if (v == null) return;

          setState(() {
            party = v;
            bom = null;
            po = null;
            articleCtrl.clear();
          });

          _fetchBomNumbers(v); // 🔥 Fetch BOM
          _fetchPONumbers(v); // 🔥 Fetch PO
        }),

        const SizedBox(height: 14),
        _dropdown("BOM No.", bom, bomList, (v) {
          setState(() {
            bom = v;
          });

          _fetchArticleNumber(); // already implemented earlier
        }),

        const SizedBox(height: 14),
        _dropdown("PO Number", po, poList, (v) {
          setState(() => po = v);
        }),
      ],
    );
  }

  Widget _supervisorSection() {
    return Column(
      children: [
        _dropdown(
          "Supervisor",
          supervisor,
          supervisorList,
          (v) => setState(() => supervisor = v),
        ),
        const SizedBox(height: 14),
        _dropdown(
          "Operator",
          operatorName,
          operatorList,
          (v) => setState(() => operatorName = v),
        ),
      ],
    );
  }

  Widget _barcodeSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔍 Barcode Field
          Expanded(
            child: TextField(
              controller: barcodeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _fetchBarcodeDetails(),
              decoration: InputDecoration(
                hintText: "Enter Barcode",
                labelText: "Barcode",
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),



                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: C.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🔎 Search Button
          Material(
            color: C.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _fetchBarcodeDetails,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 📷 Scanner Button
          Material(
            color: C.warning.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _showQRScanner,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: C.warning,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (barcodeDataList.isNotEmpty && !isSaving)
                ? _saveDispatch
                : null, // ✅ Enable only if barcodes exist
            icon: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: C.appBar3,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              isSaving ? "Saving..." : "SAVE",
              style: TextStyle(color: C.textBody),
            ),
          ),
        ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: ElevatedButton.icon(
        //     autofocus: true,
        //     onPressed: _showQRScanner,
        //     icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
        //     label: const Text("SCAN", style: TextStyle(color: Colors.black)),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,

        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          size: 20,
          color: C.primary,
        )
            : null,

        filled: true,
        fillColor: const Color(0xFFF7F9FC),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: C.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // ✅ VERY IMPORTANT (fix overflow)
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .toSet()
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis, // ✅ prevent overflow
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

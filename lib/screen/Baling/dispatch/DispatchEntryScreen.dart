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

  Future<void> _saveDispatch() async {
    if (barcodeDataList.isEmpty) {
      _snack("Please scan at least one barcode");
      return;
    }

    if (party == null || supervisor == null) {
      _snack("Please complete required fields");
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
        "operatorName": bom ?? "",
        "baleNo": "MULTI",
        "bagType": barcodeData?.barcode ?? "",
        "laminationDate1": formattedDate,
        "machine": party ?? "", // ✅ REQUIRED
        "id": barcodeData?.id,
        "laminationToRoll1": "0",
        "laminationTime1": "0",
        "laminationLocation1": "",
        "laminationSupervisor1": supervisor ?? "",
        "status": srCtrl.text,
        "BaleNo": "${barcodeData?.entryout ?? ""}(bale no)",
        "entries": entries, // ✅ REQUIRED
      };

      // 🔥 DEBUG PRINT
      debugPrint("FINAL REQUEST 👉 ${jsonEncode(requestBody)}");

      // ✅ SINGLE API CALL
      final success = await InStockService.saveDispatch(requestBody);

      if (success) {
        _snack("Dispatch saved successfully", color: Colors.green);

        setState(() {
          barcodeDataList.clear();
        });
        // ✅ THIS WILL POP SCREEN
        Navigator.pop(context);
      } else {
        _snack("Save failed", color: Colors.red);
      }
    } catch (e) {
      _snack("Error while saving dispatch: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

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
      _snack("Failed to load BOM numbers");
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
      _snack("Failed to load PO numbers");
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

      _snack("Failed to fetch article number");
    }
  }

  Future<void> _fetchBarcodeDetails([String? scannedCode]) async {
    // Use scanned code if provided, otherwise use text field value
    final inputCode = scannedCode ?? barcodeCtrl.text;

    if (inputCode.isEmpty) {
      _snack("Please enter Barcode No.");
      return;
    }

    final srNo = int.tryParse(inputCode);

    if (srNo == null) {
      _snack("Invalid SR No");
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
        _snack(result.message ?? "Record not found");
        return;
      }

      // ✅ Check if barcode already exists (prevent duplicates)
      final isDuplicate = barcodeDataList.any(
            (item) => item.srno == result.srno,
      );

      if (isDuplicate) {
        _snack("This barcode is already added!", color: Colors.orange);
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
      _snack("Barcode added successfully", color: Colors.green);
    } catch (e) {
      _snack("Failed to fetch barcode details");
    }
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ));
  }

  void _showQRScanner() {
    QRViewController? qrController;
    bool scanned = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 450,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, color: C.primary),
                    const SizedBox(width: 8),
                    const Text(
                      "Scan Barcode",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      _snack("Failed to load dispatch data");
    }
  }

  bool _wide(double w) => w >= 700;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: _appBar(),
        body: Center(child: CircularProgressIndicator(color: C.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _appBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = _wide(constraints.maxWidth);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _card('Article', C.primary, [_articleRow()]),
                    _card('Order Details', C.appBar3, [
                      _rowOrColumn(wide, [
                        _dropdown("Party Name", party, partyList, (v) {
                          if (v == null) return;
                          setState(() {
                            party = v;
                            bom = null;
                            po = null;
                            articleCtrl.clear();
                          });
                          _fetchBomNumbers(v);
                          _fetchPONumbers(v);
                        }),
                        _dropdown("BOM No.", bom, bomList, (v) {
                          setState(() => bom = v);
                          _fetchArticleNumber();
                        }),
                      ]),
                      const SizedBox(height: 12),
                      _dropdown("PO Number", po, poList, (v) => setState(() => po = v)),
                    ]),
                    _card('Personnel', Colors.teal, [
                      _rowOrColumn(wide, [
                        _dropdown("Supervisor", supervisor, supervisorList,
                                (v) => setState(() => supervisor = v)),
                        _dropdown("Operator", operatorName, operatorList,
                                (v) => setState(() => operatorName = v)),
                      ]),
                    ]),
                    _card('Scan Barcode', C.warning, [_barcodeInputRow()]),
                    if (barcodeDataList.isNotEmpty) _barcodeListSection(wide),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _saveBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: C.primary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: C.bg),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Dispatch Entry",
        style: TextStyle(color: C.bg, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---------------------
  // Sections
  // ---------------------

  Widget _articleRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _textField(articleCtrl, "Article Number", readOnly: true),
        ),
        const SizedBox(width: 10),
        Expanded(child: _textField(srCtrl, "Sr. No.", readOnly: true)),
      ],
    );
  }

  Widget _barcodeInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: barcodeCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _fetchBarcodeDetails(),
            decoration: _decoration("Enter Barcode"),
          ),
        ),
        const SizedBox(width: 8),
        _roundIconButton(
          icon: Icons.search_rounded,
          bg: C.primary,
          fg: Colors.white,
          onTap: _fetchBarcodeDetails,
        ),
        const SizedBox(width: 8),
        _roundIconButton(
          icon: Icons.qr_code_scanner_rounded,
          bg: C.warning.withOpacity(.12),
          fg: C.warning,
          onTap: _showQRScanner,
        ),
      ],
    );
  }

  Widget _barcodeListSection(bool wide) {
    return _card('Scanned Barcodes (${barcodeDataList.length})', Colors.green.shade600, [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => setState(() => barcodeDataList.clear()),
          icon: const Icon(Icons.delete_sweep, size: 18),
          label: const Text("Clear All"),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ),
      wide ? _barcodeGrid() : _barcodeList(),
    ]);
  }

  Widget _barcodeList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: barcodeDataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _barcodeCard(barcodeDataList[index], index),
    );
  }

  Widget _barcodeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: barcodeDataList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) => _barcodeCard(barcodeDataList[index], index),
    );
  }

  Widget _barcodeCard(BarcodeResponseModel item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Barcode #${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              InkWell(
                onTap: () {
                  setState(() => barcodeDataList.removeAt(index));
                  _snack("Barcode removed");
                },
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
            ],
          ),
          const Divider(height: 14),
          _detailRow("Barcode No", item.srno),
          _detailRow("Bag WT (GM)", item.partyname),
          _detailRow("Bag Type", item.barcode),
          _detailRow("Bag Size", item.department),
          _detailRow("Bale No", item.entryout),
          _detailRow("Bag Qnt (PCS)", item.status),
        ],
      ),
    );
  }

  Widget _detailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          ),
          Expanded(
            flex: 4,
            child: Text(value?.toString() ?? "-",
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _saveBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: (barcodeDataList.isNotEmpty && !isSaving) ? _saveDispatch : null,
            icon: isSaving
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              isSaving ? "Saving..." : "Save Dispatch",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------
  // Shared UI helpers
  // ---------------------

  Widget _card(String title, Color color, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _rowOrColumn(bool wide, List<Widget> children) {
    if (!wide) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Icon(icon, color: fg, size: 22),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, {bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      decoration: _decoration(label, filledColor: readOnly ? Colors.grey.shade100 : null),
    );
  }

  Widget _dropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: items.contains(value) ? value : null,
      decoration: _decoration(label),
      items: items
          .toSet()
          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(String label, {Color? filledColor}) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: filledColor ?? Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.primary, width: 1.4)),
    );
  }
}
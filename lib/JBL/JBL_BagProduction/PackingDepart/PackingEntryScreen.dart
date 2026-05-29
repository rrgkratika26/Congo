import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'PackingReportModel.dart';

class PackingItem {
  final int srNo;
  final int packingNo;
  final int noOfPcsPerPacking;
  final double perBagWT;
  final double packingNWT;

  PackingItem({
    required this.srNo,
    required this.packingNo,
    required this.noOfPcsPerPacking,
    required this.perBagWT,
    required this.packingNWT,
  });

  int get totalPcs => noOfPcsPerPacking;
  double get totalNetWT => packingNWT;
}

class PackingEntryBag extends StatefulWidget {
  final PackingBagReportModel data;

  const PackingEntryBag({super.key, required this.data});

  @override
  State<PackingEntryBag> createState() => _PackingEntryBagState();
}

class _PackingEntryBagState extends State<PackingEntryBag> {
  DateTime? selectedDate;

  final TextEditingController _noOfPcsController = TextEditingController();
  final TextEditingController _perBagWTController = TextEditingController();

  // Auto-calculated display values
  String _autoPackingNo = '-';
  String _autoPackingNWT = '-';

  List<PackingItem> packingItems = [];
  int _srCounter = 1;
  int currentPackingNo = 0;
  // Simulated ready packed bunches (replace with real data from model)
  int readyPackedBunches = 0;

  double get totalNetWT => packingItems.fold(0.0, (s, i) => s + i.totalNetWT);
  int get totalPcs => packingItems.fold(0, (s, i) => s + i.totalPcs);

  @override
  void initState() {
    super.initState();

    // Fill Per Bag WT from report screen
    if (widget.data.baggwtgm != null) {
      _perBagWTController.text = widget.data.baggwtgm.toString();
    }

    _noOfPcsController.addListener(_recalculate);
    _perBagWTController.addListener(_recalculate);

    fetchPackingCount();
  }

  /// Auto-calculate Packing NWT and Packing No whenever inputs change
  void _recalculate() {
    final int? pcs = int.tryParse(_noOfPcsController.text.trim());
    final double? perBag = double.tryParse(_perBagWTController.text.trim());

    setState(() {
      if (pcs != null && perBag != null) {
        final nwt = pcs * (perBag / 1000);
        _autoPackingNWT = nwt.toStringAsFixed(4);

        _autoPackingNo = currentPackingNo.toString();
      } else {
        _autoPackingNWT = '-';

        _autoPackingNo = currentPackingNo.toString();
      }
    });
  }

  Future<void> fetchPackingCount() async {
    final count = await JblApiService.getPackingEntryCount(
      widget.data.workOrderNo ?? "",
    );

    if (count != null) {
      setState(() {
        readyPackedBunches = count;
        currentPackingNo = count + 1; // next packing no
        _autoPackingNo = currentPackingNo.toString();
      });
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void addItem() {
    final int? pcs = int.tryParse(_noOfPcsController.text.trim());
    final double? perBag = double.tryParse(_perBagWTController.text.trim());

    if (pcs == null || perBag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    final double nwt = pcs * (perBag / 1000);
    final int packingNo = readyPackedBunches + 1 + pcs;

    setState(() {
      packingItems.add(
        PackingItem(
          srNo: _srCounter++,
          packingNo: packingNo,
          noOfPcsPerPacking: pcs,
          perBagWT: perBag,
          packingNWT: nwt,
        ),
      );
      currentPackingNo++;

      // Update preview
      _autoPackingNo = currentPackingNo.toString();

      _noOfPcsController.clear();
      _recalculate();
    });
  }

  void deleteItem(int index) => setState(() => packingItems.removeAt(index));

  @override
  void dispose() {
    _noOfPcsController.dispose();
    _perBagWTController.dispose();
    super.dispose();
  }

  // ── Reusable Widgets ────────────────────────────────────────────

  Widget _infoChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcDisplay(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ── App Bar ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: C.appBar1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Packing Entry",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: C.bg,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Add Item",
            icon: const Icon(Icons.add_box_outlined),
            onPressed: addItem,
            color: C.bg,
          ),
          IconButton(
            tooltip: "Pick Date",
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
            color: C.bg,
          ),
          const SizedBox(width: 4),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // ── Scrollable Body ───────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Party Name + BOM No ─────────────────────────────
            Row(
              children: [
                _infoChip("Party Name", data.partyname ?? '-'),
                const SizedBox(width: 8),
                _infoChip("BOM No", data.workOrderNo ?? '-'),
              ],
            ),
            const SizedBox(height: 8),

            // ── Article No ──────────────────────────────────────
            Row(children: [_infoChip("Article No", data.articleNo ?? '-')]),
            const SizedBox(height: 10),

            // ── Summary Cards ───────────────────────────────────
            Row(
              children: [
                _summaryCard(
                  "Order Bags",
                  "${data.orderQty ?? 0}",
                  Colors.green,
                ),
                const SizedBox(width: 6),
                _summaryCard("Ready Bags", "${data.packedBags}", Colors.green),
                const SizedBox(width: 6),
                _summaryCard(
                  "Ready Bunches",
                  "$readyPackedBunches",
                  Colors.orange,
                ),
                const SizedBox(width: 6),
                _summaryCard(
                  "Ready Bags\nPackaging",
                  "${data.balanceBag}",
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Inputs ──────────────────────────────────────────
            _sectionLabel("  Entry"),
            Row(
              children: [
                _inputField("No. of Pcs / Packing", _noOfPcsController),
                const SizedBox(width: 8),
                _inputField(
                  "Per Bag WT (g)",
                  _perBagWTController,
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Auto-Calculated fields ──────────────────────────
            Row(
              children: [
                _calcDisplay("Packing No", _autoPackingNo, Colors.indigo),
                const SizedBox(width: 8),
                _calcDisplay(
                  "Packing NWT  (auto, kg)",
                  _autoPackingNWT,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Table ───────────────────────────────────────────
            _sectionLabel("  Items"),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAFF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Expanded(flex: 2, child: _HeaderText("No of Pcs/packing")),

                  Expanded(flex: 2, child: _HeaderText("Packing NET WT")),
                  SizedBox(width: 32),
                ],
              ),
            ),
            // Rows
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade100),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: packingItems.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          "No items yet.  Fill fields and tap  ＋",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(packingItems.length, (i) {
                        final item = packingItems[i];
                        return Column(
                          children: [
                            Container(
                              color: i.isEven
                                  ? Colors.white
                                  : const Color(0xFFF5F9FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _CellText(
                                      "${item.noOfPcsPerPacking}",
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: _CellText(
                                      item.packingNWT.toStringAsFixed(4),
                                      bold: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => deleteItem(i),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i != packingItems.length - 1)
                              Divider(height: 1, color: Colors.blue.shade50),
                          ],
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 10),

            // ── Totals ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Pcs : $totalPcs",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    "Net WT : ${totalNetWT.toStringAsFixed(4)} kg",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Save Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text(
                  "SAVE",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  // ✅ Party Name Validation
                  if ((widget.data.partyname ?? "").trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Party Name is required"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // ✅ Packing Items Validation
                  if (packingItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Add at least one packing item"),
                      ),
                    );
                    return;
                  }

                  List<Map<String, dynamic>> items = packingItems.map((item) {
                    return {
                      "noOfPcs": item.noOfPcsPerPacking,
                      "packingNetWt": item.packingNWT,
                    };
                  }).toList();

                  bool success = await JblApiService.savePackingEntry(
                    partyName: widget.data.partyname ?? "",
                    bomNo: widget.data.workOrderNo ?? "",
                    articleNo: widget.data.articleNo ?? "",
                    perBagWt: double.tryParse(_perBagWTController.text) ?? 0,
                    bagSize: widget.data.bagsize ?? "",
                    dateTime: selectedDate ?? DateTime.now(),
                    readyPackedBunches: readyPackedBunches,
                    items: items,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Packing Entry Saved Successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      packingItems.clear();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to save packing entry"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────────

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.indigo,
    ),
  );
}

class _CellText extends StatelessWidget {
  final String text;
  final bool bold;
  const _CellText(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

import 'package:IMS/NARDANA/RmdINReports/transferModelClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'ScanrMDTransfer.dart';

class RmdTransferScreen extends StatefulWidget {
  const RmdTransferScreen({super.key});

  @override
  State<RmdTransferScreen> createState() => _RmdTransferScreenState();
}

class _RmdTransferScreenState extends State<RmdTransferScreen>
    with TickerProviderStateMixin {
  final rollCodeCtrl = TextEditingController();
  final barcodeCtrl = TextEditingController();
  List<RmdTransferModel> dataList = [];
  RmdTransferModel? selectedItem;
  // List dataList = [];
  bool isLoading = false;
  bool hasSearched = false;

  late final AnimationController _listAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  @override
  void dispose() {
    rollCodeCtrl.dispose();
    barcodeCtrl.dispose();
    _listAnim.dispose();
    super.dispose();
  }



  Future<void> transferRoll() async {
    final roll = selectedItem?.rollCode ?? rollCodeCtrl.text.trim();

    if (roll.isEmpty) {
      _snack("Roll Code required", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await InStockService.receiveRoll({
        "id": int.parse(roll),
      });

      final status = result["status"] ?? "";
      final message = result["message"] ?? "No message";

      _snack(
        message,
        isError: status.toLowerCase() != "success",
      );

    } catch (e) {
      _snack(e.toString(), isError: true);
    }

    setState(() => isLoading = false);
  }



  // ── API ────────────────────────────────────────────────
  Future<void> fetchData() async {
    final roll = rollCodeCtrl.text.trim();
    final barcode = barcodeCtrl.text.trim();

    if (roll.isEmpty && barcode.isEmpty) {
      _snack("Roll Code ya Barcode enter karo", isError: true);
      return;
    }

    if (roll.isNotEmpty && barcode.isNotEmpty) {
      _snack("Ek hi field use karo (Roll ya Barcode)", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = false;
    });

    try {
      List result = [];

      if (roll.isNotEmpty) {
        result = await InStockService.fetchByRoll(roll);
      } else {
        result = await InStockService.fetchByBarcode(barcode);
      }

      print("FINAL RESULT: $result");

      setState(() {
        hasSearched = true;

        dataList = (result as List)
            .map<RmdTransferModel>((e) {
          return RmdTransferModel.fromJson(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        // ✅ AUTO SELECT FIRST ITEM
        if (dataList.isNotEmpty) {
          selectedItem = dataList.first;
          rollCodeCtrl.text = dataList.first.rollCode;
        }
      });

      _listAnim
        ..reset()
        ..forward();
    } catch (e) {
      _snack(e.toString(), isError: true);
    }

    setState(() => isLoading = false);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: Colors.white,
              size: 17,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? C.warning : C.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(isMobile),
            SizedBox(height: 8),
            Expanded(child: _buildResultsArea()),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: C.border),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: C.bg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: C.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: C.textBody,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: C.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "RMD Transfer",
                style: TextStyle(
                  color: C.textHead,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const Text(
                "Department tracking",
                style: TextStyle(
                  color: C.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (hasSearched && dataList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: C.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: C.primary),
                ),
                child: Text(
                  "${dataList.length} records",
                  style: const TextStyle(
                    color: C.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Search Card ────────────────────────────────────────
  Widget _buildSearchCard(bool isMobile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
        boxShadow: const [C.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: C.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: C.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Search Records",
                style: TextStyle(
                  color: C.textHead,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fields + button
          if (isMobile) ...[
            _buildField(
              rollCodeCtrl,
              "Roll Code",
              Icons.qr_code_2_rounded,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: C.primary),
                onPressed: fetchData,
              ),
            ),
            const SizedBox(height: 10),
            _buildField(
              barcodeCtrl,
              "Barcode",
              Icons.barcode_reader,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: C.primary),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanRmdTrasnfer(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      barcodeCtrl.text = result;
                    });

                    fetchData(); // auto search
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildSearchBtn(fullWidth: true),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    rollCodeCtrl,
                    "Roll Code",
                    Icons.qr_code_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                    barcodeCtrl,
                    "Barcode",
                    Icons.barcode_reader,
                  ),
                ),
                const SizedBox(width: 10),
                _buildSearchBtn(fullWidth: false),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        Widget? suffixIcon,
      }) {
    return TextField(
      controller: ctrl,
      onSubmitted: (_) => fetchData(),
      style: const TextStyle(
        color: C.textHead,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: C.textMuted, fontSize: 13),

        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, color: C.primary, size: 18),
        ),

        // ✅ QR SCAN BUTTON SUPPORT
        suffixIcon: suffixIcon,

        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        filled: true,
        fillColor: C.bg,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: C.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: C.primary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildSearchBtn({required bool fullWidth}) {
    return SizedBox(
      height: 50,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : transferRoll, // 🔥 API CALL
        icon: isLoading
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: C.appBar3,
          ),
        )
            : const Icon(Icons.send_rounded, size: 18),
        label: const Text(
          "Transfer", // 🔥 renamed
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: C.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  // ── Results Area ───────────────────────────────────────
  Widget _buildResultsArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: isLoading
          ? _stateLoading()
          : !hasSearched
          ? _stateIdle()
          : dataList.isEmpty
          ? _stateEmpty()
          : _buildCardList(),
    );
  }

  Widget _stateLoading() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: C.appBar3,),
        ),
        SizedBox(height: 14),
        Text(
          "Records fetch ho rahe hain...",
          style: TextStyle(color: C.textMuted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _stateIdle() => SingleChildScrollView(
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: C.primaryLight,
              child: Icon(Icons.swap_horiz_rounded, color: C.primary, size: 34),
            ),
            SizedBox(height: 16),
            Text(
              "Roll transfer",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: C.textHead,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Enter Roll code or Barcode \nSearch karo",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: C.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _stateEmpty() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: C.errorBg,
          child: Icon(Icons.search_off_rounded, color: C.warning, size: 30),
        ),
        SizedBox(height: 16),
        Text(
          "Koi record nahi mila",
          style: TextStyle(
            color: C.textHead,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Dusra Roll Code ya Barcode try karo",
          style: TextStyle(color: C.textMuted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: dataList.length,
      itemBuilder: (context, i) {
        return _TransferCard(
          item: dataList[i],
          index: i,
        );
      },
    );
  }
}

// ─────────────────────────── TRANSFER CARD ──────────────────────────
class _TransferCard extends StatelessWidget {
  final RmdTransferModel item;
  final int index;

  const _TransferCard({
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () {
        final screenState = context.findAncestorStateOfType<_RmdTransferScreenState>();

        screenState?.setState(() {
          screenState.selectedItem = item;
          screenState.rollCodeCtrl.text = item.rollCode;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected Roll: ${item.rollCode}")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            _row("Sr No", item.srNo),
            _row("Roll Code", item.rollCode),
            _row("Fabric Code", item.fabricCode),
            _row("Barcode", item.barcode),
            _row("From Dept", item.fromDept),
            _row("To Dept", item.toDept),
            _row("Entry In", item.entryIn),
            _row("Entry Out", item.entryOut),
            _row("First Stage", item.firstStage),
            _row("Second Stage", item.secondStage),
            _row("Current Dept", item.currentDept),
          ],
        ),
      ),
    );
  }

  TableRow _row(String key, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class CardHeader extends StatelessWidget {
  final RmdTransferModel item;
  final int index;
  const CardHeader({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final currentDept = item.currentDept;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: C.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: C.primaryLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.primary),
            ),
            alignment: Alignment.center,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: C.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.barcode,
                  style: const TextStyle(
                    color: C.textHead,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const Text(
                  "Barcode",
                  style: TextStyle(color: C.textMuted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          if (currentDept.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: C.warningBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: C.warning,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentDept,
                    style: const TextStyle(
                      color: C.warning,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeptFlow extends StatelessWidget {
  final String from;
  final String to;
  const _DeptFlow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FROM",
                  style: TextStyle(
                    color: C.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  from,
                  style: const TextStyle(
                    color: C.textHead,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: C.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.primary),
              ),
              child: const Icon(Icons.east_rounded, color: C.primary, size: 14),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "TO",
                  style: TextStyle(
                    color: C.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  to,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: C.textHead,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),

          /// ✅ KEY FIX
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // prevents overflow
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "-" : value, // ✅ safe fallback
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: C.textHead,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

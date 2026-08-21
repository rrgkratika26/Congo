import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../AdminDashBoard/DashBoard.dart';
import '../../AdminDashBoard/DepartmentDashboard.dart';
import '../../AdminDashBoard/ListMenuItems/dashBoardNewUi.dart';
import '../../Color/Colorclass.dart';
import 'RecentEntryScreen.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class EntryRecord {
  final int id;
  final String operator;
  final String party;
  final String recipe;
  final double gross;
  final bool isActive;

  const EntryRecord({
    required this.id,
    required this.operator,
    required this.party,
    required this.recipe,
    required this.gross,
    this.isActive = false,
  });
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class TapeLineEntryScreen extends StatefulWidget {
  final String inquiryNo;
  final String customerName;
  final String articleNo;
  final String bomNumber;
  final String extra13;
  final double totalMtr;
  final double totalKg;

  const TapeLineEntryScreen({
    super.key,
    required this.inquiryNo,
    required this.customerName,
    required this.articleNo,
    required this.bomNumber,
    required this.extra13,
    required this.totalMtr,
    required this.totalKg,
  });

  @override
  State<TapeLineEntryScreen> createState() => _TapeLineEntryScreenState();
}

class _TapeLineEntryScreenState extends State<TapeLineEntryScreen>
    with SingleTickerProviderStateMixin {
  final _widthController = TextEditingController();
  final _ppLotController = TextEditingController();
  final _dnrController = TextEditingController();
  final _grossController = TextEditingController();
  final _tareController = TextEditingController();
  final _netController = TextEditingController();
  final _batchController = TextEditingController();
  final _remarkController = TextEditingController();
  final TextEditingController _generatedCodeController =
  TextEditingController();

  // ✅ Smooth scrolling controller for the whole page
  final ScrollController _scrollController = ScrollController();

  // ✅ Shimmer animation for skeleton loading state
  late final AnimationController _shimmerController;

  bool isPoLoading = false;
  bool isArticleLoading = false;
  String? _generatedBatch;
  String? _generatedCode;
  List<String> partyList = [];
  List<String> operatorList = [];
  String? srNo;
  List<String> recipeList = [];
  List<String> poList = [];
  List<String> articleList = [];
  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  bool isLoading = true;
  String? _selectedParty;
  String? _selectedRecipe;
  String? _selectedPO;
  String? _selectedArticle;
  String _selectedOperator = '';
  String _selectedPlant = 'TAPE PLANT-1';
  String _getNumericDnr() {
    return _dnrController.text.replaceAll(RegExp(r'[^0-9]'), '');
  }
  String _selectedShift = 'A';

  final InStockService api = InStockService();

  String _generateBatchNumber() {
    final party = widget.customerName.trim();
    final po = widget.articleNo.trim(); // PO Number

    final shift = _selectedShift.isNotEmpty ? _selectedShift : '';

    final now = DateTime.now();

    final date = now.day.toString();
    final month = now.month.toString().padLeft(2, '0');

    String partyCode = '';
    if (party.length >= 3) {
      partyCode = party.substring(0, 3).toUpperCase();
    } else {
      partyCode = party.toUpperCase();
    }

    return "$partyCode$po$date$month${shift}TP";
  }

  String _generateFinalCode() {
    final dnr = _dnrController.text.trim();
    final recipe = _selectedRecipe ?? '';
    final width = _widthController.text.trim();

    return "${dnr}DNR/$recipe/${width}MM";
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadDropdownData();
    print("Party Name : ${widget.customerName}");
    print("BOM No      : ${widget.bomNumber}");
    print("Article No  : ${widget.articleNo}");
    if (operatorList.isNotEmpty) {
      _selectedOperator = operatorList.first;
      _operatorController.text = _selectedOperator;
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _ppLotController.dispose();
    _dnrController.dispose();
    _grossController.dispose();
    _tareController.dispose();
    _netController.dispose();
    _batchController.dispose();
    _generatedCodeController.dispose();
    _operatorController.dispose();
    _recipeController.dispose();
    _remarkController.dispose();
    _scrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _recalcNet() {
    final gross = double.tryParse(_grossController.text) ?? 0;
    final tare = double.tryParse(_tareController.text) ?? 0;
    setState(() {
      _netController.text = (gross - tare).toStringAsFixed(2);
    });
  }

  Future<void> _loadPoNumbers(String customerName) async {
    try {
      setState(() {
        isPoLoading = true;
        poList = [];
        _selectedPO = null;
        articleList = [];
        _selectedArticle = null;
      });

      final data = await api.getPoNumbers(customerName);

      setState(() {
        poList = List<String>.from(data);
        if (poList.isNotEmpty) {
          _selectedPO = poList.first;
          _loadArticleNumbers(customerName, _selectedPO!);
        }
        isPoLoading = false;
      });
    } catch (e) {
      debugPrint("PO API Error: $e");
      setState(() => isPoLoading = false);
    }
  }

  Future<void> _loadArticleNumbers(String customerName, String poNum) async {
    try {
      setState(() {
        isArticleLoading = true;
        articleList = [];
        _selectedArticle = null;
      });

      final data = await api.getArticleNumbers(customerName, poNum);

      setState(() {
        articleList = List<String>.from(data);
        if (articleList.isNotEmpty) {
          _selectedArticle = articleList.first;
        }
        isArticleLoading = false;
      });
    } catch (e) {
      debugPrint("Article API Error: $e");
      setState(() => isArticleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Tape Line Entry',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.bg,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: C.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(fontSize: 13, color: C.primaryDark),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: C.bg, height: 0.5),
        ),
        iconTheme: const IconThemeData(color: C.bg,),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: isLoading
            ? _buildSkeletonBody(key: const ValueKey('skeleton'))
            : _buildContent(key: const ValueKey('content')),
      ),
    );
  }

  // ─── Real form content (extracted so AnimatedSwitcher can cross-fade it) ───

  Widget _buildContent({Key? key}) {
    return Scrollbar(
      key: key,
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(10),
      thickness: 6,
      interactive: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SR No. ${srNo ?? '---'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: C.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildOperatorTableCard(),
            const SizedBox(height: 12),
            _buildProductionTableCard(),
            const SizedBox(height: 16),
            _buildActionRow(),
            const SizedBox(height: 20),
            _buildRecentEntries(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton loading state — mirrors the real layout's shape ─────────────

  Widget _shimmerBox({
    double height = 14,
    double? width,
    double radius = 6,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final t = _shimmerController.value; // 0 → 1 → 0
        final opacity = 0.35 + (t * 0.35); // pulse between 0.35–0.70
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Widget _skeletonRow({bool shaded = false}) {
    return Container(
      color: shaded ? const Color(0xFFFAFAFA) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 108, child: _shimmerBox(width: 70)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(height: 34, radius: 8)),
        ],
      ),
    );
  }

  Widget _skeletonCard({required int rows}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _shimmerBox(height: 10, width: 100),
                const SizedBox(height: 12),
                for (int i = 0; i < rows; i++) _skeletonRow(shaded: i.isOdd),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3.5, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBody({Key? key}) {
    return SingleChildScrollView(
      key: key,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 20, width: 90, radius: 8),
          const SizedBox(height: 12),
          _skeletonCard(rows: 6),
          const SizedBox(height: 12),
          _skeletonCard(rows: 11),
        ],
      ),
    );
  }

  // ─── Section Card (left-border accent via Stack, no overflow / border-radius issues) ─

  Widget _sectionCard({required String label, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: C.textHead,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3.5, color: C.primary),
          ),
        ],
      ),
    );
  }

  // ─── Table row helper: Label | Field, zebra striped ────────────────────────

  TableRow _tableRow(String label, Widget field, {bool shaded = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: shaded ? const Color(0xFFFAFAFA) : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: C.primaryDark,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: field,
        ),
      ],
    );
  }

  Table _wrapTable(List<TableRow> rows) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(108),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside:
        BorderSide(color: Colors.grey.shade200, width: 0.7),
      ),
      children: rows,
    );
  }

  // ─── Compact field widgets (no embedded label — table provides it) ────────

  Widget _textFieldCell(
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        String placeholder = '',
        bool readOnly = false,
        bool recalcOnChange = false,
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: placeholder,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      onChanged: recalcOnChange ? (_) => _recalcNet() : null,
    );
  }

  Widget _readOnlyCell(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Bottom-sheet selector — replaces cramped inline dropdowns ────────────

  Future<void> _pickFromList({
    required String title,
    required List<String> items,
    required String? current,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = query.isEmpty
                ? items
                : items
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: C.textHead,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          autofocus: false,
                          style: const TextStyle(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Search $title',
                            isDense: true,
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) => setSheetState(() => query = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                          child: Text(
                            "No matches found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                            : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                          itemBuilder: (context, i) {
                            final item = filtered[i];
                            final selected = item == current;
                            return ListTile(
                              title: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color:
                                  selected ? C.primary : Colors.black87,
                                ),
                              ),
                              trailing: selected
                                  ? Icon(Icons.check_circle,
                                  color: C.primary, size: 20)
                                  : null,
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (result != null) onSelected(result);
  }

  // ─── Tappable field that opens the selector — replaces DropdownButtonFormField ─

  Widget _selectorCell({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String emptyHint = 'Tap to select',
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: items.isEmpty
          ? null
          : () => _pickFromList(
        title: title,
        items: items,
        current: value,
        onSelected: onChanged,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                (value == null || value.isEmpty) ? emptyHint : value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: (value == null || value.isEmpty)
                      ? FontWeight.w400
                      : FontWeight.w600,
                  color: (value == null || value.isEmpty)
                      ? Colors.grey.shade500
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more, size: 20, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  // ─── Cards, now rendered as tables ──────────────────────────────────────────

  Widget _buildOperatorTableCard() {
    return _sectionCard(
      label: 'Operator & Plant',
      child: _wrapTable([
        _tableRow('Party Name', _readOnlyCell(widget.customerName)),
        _tableRow('BOM No', _readOnlyCell(widget.bomNumber), shaded: true),
        _tableRow('PO No', _readOnlyCell(widget.articleNo)),
        _tableRow('Article No', _readOnlyCell(widget.extra13), shaded: true),
        _tableRow(
          'Operator',
          _selectorCell(
            title: 'Select operator',
            value: _selectedOperator.isEmpty ? null : _selectedOperator,
            items: operatorList,
            onChanged: (v) => setState(() {
              _selectedOperator = v;
              _operatorController.text = v;
            }),
          ),
        ),
        _tableRow(
          'Tape Plant',
          _selectorCell(
            title: 'Select tape plant',
            value: _selectedPlant,
            items: const ['TAPE PLANT-1', 'TAPE PLANT-2'],
            onChanged: (v) => setState(() => _selectedPlant = v),
          ),
          shaded: true,
        ),
      ]),
    );
  }

  Widget _buildProductionTableCard() {
    return _sectionCard(
      label: 'Production Details',
      child: _wrapTable([
        _tableRow(
          'Recipe Type',
          _selectorCell(
            title: 'Select recipe type',
            value: _selectedRecipe,
            items: recipeList,
            onChanged: (v) => setState(() {
              _selectedRecipe = v;
              _recipeController.text = v;
            }),
          ),
        ),
        _tableRow(
          'Width (mm)',
          _textFieldCell(
            _widthController,
            keyboardType: TextInputType.number,
            placeholder: 'e.g. 2050',
          ),
          shaded: true,
        ),
        _tableRow(
          'PP Lot No',
          _textFieldCell(_ppLotController, placeholder: 'Enter PP Lot No'),
        ),
        _tableRow(
          'DNR',
          _textFieldCell(_dnrController, placeholder: 'Enter DNR'),
          shaded: true,
        ),
        _tableRow(
          'Gross Wt (kg)',
          _textFieldCell(
            _grossController,
            keyboardType: TextInputType.number,
            placeholder: '0.00',
            recalcOnChange: true,
          ),
        ),
        _tableRow(
          'Tare Wt (kg)',
          _textFieldCell(
            _tareController,
            keyboardType: TextInputType.number,
            placeholder: '0.00',
            recalcOnChange: true,
          ),
          shaded: true,
        ),
        _tableRow(
          'Net Wt (kg)',
          _textFieldCell(
            _netController,
            keyboardType: TextInputType.number,
            placeholder: 'Auto-calculated',
            readOnly: true,
          ),
        ),
        _tableRow(
          'Shift',
          _selectorCell(
            title: 'Select shift',
            value: _selectedShift,
            items: const ['A', 'B'],
            onChanged: (v) => setState(() => _selectedShift = v),
          ),
          shaded: true,
        ),
        _tableRow(
          'Batch No',
          _textFieldCell(_batchController, readOnly: true),
        ),
        _tableRow(
          'Generated Code',
          _textFieldCell(_generatedCodeController, readOnly: true),
          shaded: true,
        ),
        _tableRow(
          'Remark',
          TextField(
            controller: _remarkController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              hintText: 'Optional note...',
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Buttons ──────────────────────────────────────────────────────────────
  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _generatedBatch = _generateBatchNumber();
                _generatedCode = _generateFinalCode();

                _batchController.text = _generatedBatch!;
                _generatedCodeController.text = _generatedCode ?? '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Generate Code',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                // ─── DNR validation ─────────────────────────────
                final numericDnr = _getNumericDnr();

                if (numericDnr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid DNR number"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _dnrController.text = numericDnr;

                final now = DateTime.now();

                final time =
                    "${now.hour}:${now.minute.toString().padLeft(2, '0')}:00";

                final batch = _generateBatchNumber();

                // Generate code using numeric DNR
                final code = _generateFinalCode();

                _batchController.text = batch;
                _generatedCodeController.text = code;

                final body = {
                  "srNo": srNo,
                  "operator": _selectedOperator,
                  "tapePlant": _selectedPlant,
                  "partyName": widget.customerName,
                  "mPurchaseOrderNo": widget.articleNo,
                  "articleNo": widget.extra13,
                  "date": now.toString().split(' ')[0],
                  "time": time,
                  "recipeType": _selectedRecipe,
                  "bom": widget.bomNumber,
                  "dnr": _dnrController.text,
                  "widthMM": _widthController.text,
                  "grossWeight": _grossController.text,
                  "tareWeight": _tareController.text,
                  "netWeight": _netController.text,
                  "shift": _selectedShift,
                  "batchNo": _batchController.text,
                  "generateCode": _generatedCodeController.text,
                  "ppLotNo": _ppLotController.text,
                  "remark": _remarkController.text,
                };

                final res = await api.saveTapeLineEntry(body);

                print(res);
                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentEntriesScreen(),
                  ),
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8F5E9),
              foregroundColor: C.success,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Entries',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentEntriesScreen(),
                  ),
                );
              },
              child: const Text("View All",style: TextStyle(color: C.primary),),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadDropdownData() async {
    try {
      final data = await InStockService().fetchDropdownData();

      print("API RESPONSE: $data");

      setState(() {
        partyList = List<String>.from(data['customerNames'] ?? []);
        recipeList = List<String>.from(data['recipeTypes'] ?? []);
        srNo = data['id']?.toString();
        operatorList = List<String>.from(data['operators'] ?? []);

        if (operatorList.isNotEmpty) {
          _selectedOperator = operatorList.first;
        }
        if (partyList.isNotEmpty) _selectedParty = partyList.first;
        if (recipeList.isNotEmpty) _selectedRecipe = recipeList.first;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("API Error: $e");
      setState(() => isLoading = false);
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return "${now.day.toString().padLeft(2, '0')}-${months[now.month - 1]}-${now.year}";
  }
}
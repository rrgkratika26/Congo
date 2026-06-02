import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'ProductDetailModleclass.dart';

// ── Screen ─────────────────────────────────────────────────────
class JBLFormScreen extends StatefulWidget {
  const JBLFormScreen({
    super.key,
    required this.partyName,
    required this.woNumber,
    required this.articleNo,
    required this.quantity,
    required this.remainingToProduce,
    required this.canProduction,
    this.productDetails, // ✅ prefetched from list screen
  });

  final String partyName;
  final String woNumber;
  final String articleNo;
  final int quantity;
  final int remainingToProduce;
  final int canProduction;
  final ProductDetails? productDetails;

  @override
  State<JBLFormScreen> createState() => _JBLFormScreenState();
}

class _JBLFormScreenState extends State<JBLFormScreen>
    with SingleTickerProviderStateMixin {
  static const String _base = 'http://190.92.175.47:80/JblAPI/api';

  // ── Controllers ───────────────────────────────────────────────
  final _printStatusCtrl = TextEditingController();
  final _bagTypeCtrl = TextEditingController();
  final _bagQtyCtrl = TextEditingController();
  final _bagSizeCtrl = TextEditingController();
  final _bagWtCtrl = TextEditingController();
  final _lineNoCtrl = TextEditingController();
  final _shiftCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final _supervisorCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  // ── Service ───────────────────────────────────────────────────
  final JblApiService _apiService = JblApiService();

  // ── State ──────────────────────────────────────────────────────
  String _inquiryNo = '';
  bool _loadingId = true;
  bool _isSaving = false;
  bool _loadingProduct = false;
  ProductDetails? _productDetails;

  List<Map<String, dynamic>> _rows = [];

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ──────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _dateCtrl.text = DateTime.now().toString().split(' ')[0]; // yyyy-MM-dd
    _fetchNextId();
    _fetchProductDetails();
  }

  @override
  void dispose() {
    for (final c in [
      _printStatusCtrl,
      _bagTypeCtrl,
      _bagQtyCtrl,
      _bagSizeCtrl,
      _bagWtCtrl,
      _lineNoCtrl,
      _shiftCtrl,
      _remarkCtrl,
      _supervisorCtrl,
    ])
      c.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── APIs ───────────────────────────────────────────────────────
  Future<void> _fetchNextId() async {
    setState(() => _loadingId = true);
    try {
      final id = await JblApiService.getNextBagEntryId();
      setState(() => _inquiryNo = id?.toString() ?? '');
    } catch (e) {
      _snack('ID fetch error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingId = false);
    }
  }

  Future<void> _fetchProductDetails() async {
    // ✅ Use prefetched data from list screen if already available
    if (widget.productDetails != null) {
      _applyProductDetails(widget.productDetails!);
      return;
    }

    // Fallback: call JblApiService instance method
    if (!mounted) return;
    setState(() => _loadingProduct = true);

    try {
      final details = await _apiService.getProductDetails(
        partyName: widget.partyName,
        articleNo: widget.articleNo,
      );

      if (!mounted) return;

      if (details != null && details.success) {
        _applyProductDetails(details);
      } else {
        _snack('No product details found', error: true);
      }
    } catch (e) {
      _snack('Product details error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingProduct = false);
    }
  }

  /// Apply fetched product details to state + pre-fill fields
  void _applyProductDetails(ProductDetails details) {
    setState(() {
      _productDetails = details;
      _loadingProduct = false;
      _printStatusCtrl.text = details.printStatus.isNotEmpty
          ? details.printStatus
          : '';
      _bagTypeCtrl.text = details.bagType.isNotEmpty ? details.bagType : '';
      _bagSizeCtrl.text = details.bagSize.isNotEmpty ? details.bagSize : '';
      _bagWtCtrl.text = details.netWeight.isNotEmpty ? details.netWeight : '';
    });
  }

  Future<void> _saveEntry() async {
    try {
      /// 🔥 rows build karo (table se)
      final rows = _rows.map((e) {
        return {
          "shift": e['shift'],
          "bagQty": e['bagQty'],
          "lineNo": e['lineNo'],
        };
      }).toList();

      final body = {
        "srNo": _inquiryNo, // dynamic bhi kar sakte ho
        "date": _dateCtrl.text, // format: yyyy-MM-dd
        "partyName": widget.partyName,
        "bomNo": widget.woNumber,
        "articleNo": widget.articleNo,

        "printStatus": _printStatusCtrl.text,
        "bagSize": _bagSizeCtrl.text,
        "remark": _remarkCtrl.text,
        "bagType": _bagTypeCtrl.text,
        "bagWeight": int.tryParse(_bagWtCtrl.text) ?? 0,
        "supervisorName": _supervisorCtrl.text,
        "operatorName": _shiftCtrl,
        "tableQuantity": _rows.length,

        "rows": rows,
      };

      print("SAVE BODY: $body");

      final res = await JblApiService.saveBagProductionEntry(body: body);

      final data = res["data"];

      if (res["statusCode"] == 200 && data["success"] == true) {
        _snack(data["message"] ?? "Saved successfully");
      } else {
        _snack(data["message"] ?? "Save failed", error: true);
      }
    } catch (e) {
      print("❌ SAVE ERROR: $e");

      _snack("Save error: $e", error: true);
      _snack("Save error: $e", error: true);
    }
  }

  // ── Row helpers ────────────────────────────────────────────────
  void _addRow() {
    final qty = int.tryParse(_bagQtyCtrl.text.trim()) ?? 0;
    final wt = double.tryParse(_bagWtCtrl.text.trim()) ?? 0.0;

    if (_printStatusCtrl.text.trim().isEmpty ||
        _bagTypeCtrl.text.trim().isEmpty ||
        qty == 0) {
      _snack('Print Status, Bag Type and Bag Qty are required', error: true);
      return;
    }
    setState(() {
      _rows.add({
        'printStatus': _printStatusCtrl.text.trim(),
        'bagType': _bagTypeCtrl.text.trim(),
        'bagQty': qty,
        'bagSize': _bagSizeCtrl.text.trim(),
        'bagWt': wt,
        'lineNo': _lineNoCtrl.text.trim(),
        'shift': _shiftCtrl.text.trim(),
        'remark': _remarkCtrl.text.trim(),
      });
    });

    // Clear user-specific fields
    _bagQtyCtrl.clear();
    _lineNoCtrl.clear();
    _shiftCtrl.clear();
    _remarkCtrl.clear();

    // Restore product defaults for next row entry
    if (_productDetails != null) {
      _applyProductDetails(_productDetails!);
    }
  }

  void _deleteRow(int i) => setState(() => _rows.removeAt(i));

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: error ? const Color(0xFFE53935) : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  COMPUTED
  // ─────────────────────────────────────────────────────────────
  late final availableBag = widget.quantity - widget.remainingToProduce;

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: C.brand700,
            foregroundColor: Colors.white,
            title: const Text(
              'BAG ENTRY FORM',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _SrBadge(loading: _loadingId, value: _inquiryNo),
              ),
            ],
          ),

          // ── BODY ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BASIC INFO CARD ──────────────────────
                    _SectionCard(
                      title: 'BASIC INFORMATION',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _readonlyField(
                                  'PARTY NAME',
                                  widget.partyName,
                                  icon: Icons.business_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _readonlyField(
                                  'WO NUMBER',
                                  widget.woNumber,
                                  icon: Icons.confirmation_number_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _readonlyField(
                            'ARTICLE NO',
                            widget.articleNo,
                            icon: Icons.inventory_2_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Stats row
                          Row(
                            children: [
                              _StatPill(
                                label: 'Req. Bags',
                                value: widget.quantity.toString(),
                                color: C.brand600,
                                bgColor: C.brand100,
                              ),
                              const SizedBox(width: 8),
                              _StatPill(
                                label: 'Available',
                                value: availableBag.toString(),
                                color: const Color(0xFF2E7D32),
                                bgColor: const Color(0xFFE8F5E9),
                              ),
                              const SizedBox(width: 8),
                              _StatPill(
                                label: 'Remaining',
                                value: widget.remainingToProduce.toString(),
                                color: const Color(0xFFE65100),
                                bgColor: const Color(0xFFFFF3E0),
                              ),
                              const SizedBox(width: 8),
                              _StatPill(
                                label: 'Can Prod.',
                                value: widget.canProduction.toString(),
                                color: C.brand800,
                                bgColor: C.brand200,
                              ),
                            ],
                          ),

                          // Product details banner
                          if (_loadingProduct)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: _LoadingBanner(
                                label: 'Fetching product details...',
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SUPERVISOR ───────────────────────────
                    _SectionCard(
                      title: 'SUPERVISOR',
                      icon: Icons.badge_outlined,
                      child: _labeledInput(
                        label: 'SUPERVISOR NAME',
                        ctrl: _supervisorCtrl,
                        hint: 'Enter supervisor name',
                        icon: Icons.person_outline_rounded,
                        required: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── BAG ENTRY CARD ───────────────────────
                    _SectionCard(
                      title: 'BAG ENTRY',
                      icon: Icons.add_box_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _labeledInput(
                                  label: 'PRINT STATUS',
                                  ctrl: _printStatusCtrl,
                                  hint: 'e.g. YES 2S 1C',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labeledInput(
                                  label: 'BAG TYPE',
                                  ctrl: _bagTypeCtrl,
                                  hint: 'e.g. CIRCULAR CC',
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _labeledInput(
                                  label: 'BAG QTY (pcs)',
                                  ctrl: _bagQtyCtrl,
                                  hint: '0',
                                  type: TextInputType.number,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labeledInput(
                                  label: 'BAG SIZE',
                                  ctrl: _bagSizeCtrl,
                                  hint: 'e.g. 90x90x125',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labeledInput(
                                  label: 'BAG WT (GM)',
                                  ctrl: _bagWtCtrl,
                                  hint: '0.0',
                                  type: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _LabelText('LINE NO'),
                                    const SizedBox(height: 5),
                                    DropdownButtonFormField<String>(
                                      value: _lineNoCtrl.text.isEmpty
                                          ? null
                                          : _lineNoCtrl.text,
                                      items:
                                          List.generate(10, (i) => i.toString())
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        _lineNoCtrl.text = val ?? '';
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: C.cardBg,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 11,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.borderLight,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.borderLight,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.brand600,
                                            width: 1.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _LabelText('SHIFT'),
                                    const SizedBox(height: 5),
                                    DropdownButtonFormField<String>(
                                      value: _shiftCtrl.text.isEmpty
                                          ? null
                                          : _shiftCtrl.text,
                                      items: ['A', 'B']
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        _shiftCtrl.text = val ?? '';
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: C.cardBg,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 11,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.borderLight,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.borderLight,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          borderSide: const BorderSide(
                                            color: C.brand600,
                                            width: 1.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _labeledInput(
                            label: 'REMARK',
                            ctrl: _remarkCtrl,
                            hint: 'Any additional remarks...',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          _AddItemButton(onPressed: _addRow),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── ADDED ITEMS ──────────────────────────
                    _SectionCard(
                      title: 'ADDED ITEMS',
                      icon: Icons.list_alt_rounded,
                      trailing: _rows.isNotEmpty
                          ? _CountBadge(count: _rows.length)
                          : null,
                      child: _rows.isEmpty
                          ? const _EmptyState()
                          : _ItemsTable(rows: _rows, onDelete: _deleteRow),
                    ),

                    const SizedBox(height: 28),

                    // ── ACTION BUTTONS ───────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.textMid,
                              side: BorderSide(
                                color: C.borderLight,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _isSaving
                              ? Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: C.brand200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: C.appBar3,
                                      ),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _rows.isEmpty ? null : _saveEntry,
                                  icon: const Icon(
                                    Icons.save_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'SAVE ENTRY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _rows.isEmpty
                                        ? C.brand200
                                        : C.brand700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: _rows.isEmpty ? 0 : 2,
                                  ),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  REUSABLE WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _readonlyField(String label, String value, {IconData? icon}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LabelText(label),
      const SizedBox(height: 5),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: C.brand50,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: C.borderLight),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: C.brand500),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _labeledInput({
    required String label,
    required TextEditingController ctrl,
    TextInputType type = TextInputType.text,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool required = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LabelText(label, required: required),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 12,
          color: C.textHigh,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: C.textLow),
          prefixIcon: icon != null
              ? Icon(icon, size: 15, color: C.brand400)
              : null,
          filled: true,
          fillColor: C.cardBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: C.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: C.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: C.brand600, width: 1.8),
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
//  EXTRACTED WIDGETS
// ─────────────────────────────────────────────────────────────

class _LabelText extends StatelessWidget {
  final String text;
  final bool required;
  const _LabelText(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: C.textMid,
        letterSpacing: 0.4,
      ),
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFE53935)),
          ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.borderLight),
      boxShadow: [
        BoxShadow(
          color: C.brand500.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.brand100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: C.brand200,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: C.brand700),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: C.brand800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        // Body
        Padding(padding: const EdgeInsets.all(14), child: child),
      ],
    ),
  );
}

class _SrBadge extends StatelessWidget {
  final bool loading;
  final String value;
  const _SrBadge({required this.loading, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: loading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: C.appBar3,
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SR NO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
  );
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: C.brand200),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: C.brand500),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: C.textMid,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: C.textHigh,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _LoadingBanner extends StatelessWidget {
  final String label;
  const _LoadingBanner({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: C.brand50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: C.brand200),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: C.brand600),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: C.textMid,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: C.brand600,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$count item${count > 1 ? 's' : ''}',
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.brand50, shape: BoxShape.circle),
          child: const Icon(Icons.inbox_outlined, size: 32, color: C.brand300),
        ),
        const SizedBox(height: 12),
        const Text(
          'No items added yet',
          style: TextStyle(
            fontSize: 13,
            color: C.textMid,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Fill the form above and tap "Add Item"',
          style: TextStyle(fontSize: 11, color: C.textLow),
        ),
      ],
    ),
  );
}

class _AddItemButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddItemButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
      label: const Text(
        'ADD ITEM TO LIST',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: C.brand100,
        foregroundColor: C.brand700,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: C.brand300, width: 1.5),
        ),
      ),
    ),
  );
}

class _ItemsTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final void Function(int) onDelete;

  const _ItemsTable({required this.rows, required this.onDelete});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Column(
      children: [
        // Header
        Container(
          color: C.brand700,
          child: Row(
            children: const [
              _Th('#', flex: 1),
              _Th('Print Status', flex: 3),
              _Th('Type', flex: 2),
              _Th('Qty', flex: 1),
              _Th('Size', flex: 2),
              _Th('Wt', flex: 1),
              _Th('Line', flex: 1),
              _Th('Shift', flex: 1),
              _Th('', flex: 1),
            ],
          ),
        ),
        // Rows
        ...List.generate(rows.length, (i) {
          final r = rows[i];
          return Container(
            color: i.isEven ? Colors.white : C.brand50,
            child: Row(
              children: [
                _Td('${i + 1}', flex: 1, bold: true),
                _Td(r['printStatus'] ?? '', flex: 3),
                _Td(r['bagType'] ?? '', flex: 2),
                _Td(r['bagQty'].toString(), flex: 1),
                _Td(r['bagSize'] ?? '', flex: 2),
                _Td(r['bagWt'].toString(), flex: 1),
                _Td(r['lineNo'] ?? '', flex: 1),
                _Td(r['shift'] ?? '', flex: 1),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE53935),
                      size: 17,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => onDelete(i),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

class _Th extends StatelessWidget {
  final String t;
  final int flex;
  const _Th(this.t, {this.flex = 2});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}

class _Td extends StatelessWidget {
  final String v;
  final int flex;
  final bool bold;
  const _Td(this.v, {this.flex = 2, this.bold = false});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      child: Text(
        v,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: C.textHigh,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    ),
  );
}

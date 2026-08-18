import 'package:flutter/material.dart';
import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';

class AddRecutPcsPopupNardana {
  static Future<void> show(
      BuildContext context, {
        required int iid,
        String? partyName,
        double? width,
        double? cutLength,
        double? perPcsWt,
        VoidCallback? onSaved,
      }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _AddRecutPcsScreen(
          iid: iid,
          partyName: partyName,
          width: width,
          cutLength: cutLength,
          perPcsWt: perPcsWt,
          onSaved: onSaved,
        ),
      ),
    );
  }
}

class _AddRecutPcsScreen extends StatefulWidget {
  final int iid;
  final String? partyName;
  final double? width;
  final double? cutLength;
  final double? perPcsWt;
  final VoidCallback? onSaved;

  const _AddRecutPcsScreen({
    required this.iid,
    this.partyName,
    this.width,
    this.cutLength,
    this.perPcsWt,
    this.onSaved,
  });

  @override
  State<_AddRecutPcsScreen> createState() => _AddRecutPcsScreenState();
}

class _AddRecutPcsScreenState extends State<_AddRecutPcsScreen> {
  late final cutWidthCtrl =
  TextEditingController(text: widget.width?.toStringAsFixed(2) ?? '');
  late final cutLengthCtrl =
  TextEditingController(text: widget.cutLength?.toStringAsFixed(2) ?? '');
  final issuePcsCtrl = TextEditingController();
  final issueKgCtrl = TextEditingController();

  List<String> woNumbers = [];
  String? selectedWo;
  bool isLoadingWo = true;

  List<String> components = [];
  String? selectedComponent;
  bool isLoadingComp = false;

  bool isSaving = false;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _fetchWorkOrders();
  }

  @override
  void dispose() {
    cutWidthCtrl.dispose();
    cutLengthCtrl.dispose();
    issuePcsCtrl.dispose();
    issueKgCtrl.dispose();
    super.dispose();
  }

  void _calculateIssueKg() {
    final perPcsWeight = widget.perPcsWt ?? 0;
    final pcs = double.tryParse(issuePcsCtrl.text) ?? 0;
    final issueKg = perPcsWeight * pcs;
    issueKgCtrl.text = issueKg.toStringAsFixed(3);
  }

  Future<void> _fetchWorkOrders() async {
    final data = await InStockService.getWoNumbers();
    if (!mounted) return;
    setState(() {
      woNumbers = data;
      isLoadingWo = false;
    });
  }

  Future<void> _fetchComponents(String wo) async {
    setState(() => isLoadingComp = true);
    final data = await InStockService.getComponentsInCuttingIssued(wo);
    if (!mounted) return;
    setState(() {
      components = data;
      isLoadingComp = false;
    });
  }

  bool get _isFormValid =>
      selectedWo != null &&
          selectedComponent != null &&
          issuePcsCtrl.text.trim().isNotEmpty;

  Future<void> _onSave() async {
    setState(() => _submitAttempted = true);

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final result = await InStockService.saveCuttingIssue(
      iid: widget.iid,
      issueToWorkOrder: selectedWo!,
      issueToComponent: selectedComponent!,
      noOfPcs: int.tryParse(issuePcsCtrl.text) ?? 0,
      kg: double.tryParse(issueKgCtrl.text) ?? 0,
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    final success = result == "Data Saved Successfully";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      Navigator.pop(context);
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        title: const Text(
          "Add Recut PCS Issue",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: "Item Details",
                      icon: Icons.inventory_2_outlined,
                      children: [
                        _infoRow("IID", widget.iid.toString()),
                        if (widget.partyName != null)
                          _infoRow("Party Name", widget.partyName!),
                        if (widget.perPcsWt != null)
                          _infoRow(
                            "Per PCS Weight",
                            widget.perPcsWt!.toStringAsFixed(3),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _sectionCard(
                      title: "Work Order & Component",
                      icon: Icons.assignment_outlined,
                      children: [
                        _label("Work Order", required: true),
                        isLoadingWo
                            ? _loadingField()
                            : DropdownButtonFormField<String>(
                          value: selectedWo,
                          items: woNumbers
                              .map((e) => DropdownMenuItem(
                              value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) async {
                            setState(() {
                              selectedWo = v;
                              selectedComponent = null;
                              components = [];
                            });
                            if (v != null) await _fetchComponents(v);
                          },
                          decoration: _inputDecoration(
                            hint: "Select work order",
                            showError:
                            _submitAttempted && selectedWo == null,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _label("Component", required: true),
                        isLoadingComp
                            ? _loadingField()
                            : DropdownButtonFormField<String>(
                          value: selectedComponent,
                          items: components
                              .map((e) => DropdownMenuItem(
                              value: e, child: Text(e)))
                              .toList(),
                          onChanged: selectedWo == null
                              ? null
                              : (v) {
                            setState(() {
                              selectedComponent = v;
                              _calculateIssueKg();
                            });
                          },
                          decoration: _inputDecoration(
                            hint: selectedWo == null
                                ? "Select work order first"
                                : "Select component",
                            showError: _submitAttempted &&
                                selectedComponent == null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _sectionCard(
                      title: "Cut Dimensions",
                      icon: Icons.straighten_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                label: "Cut Width",
                                controller: cutWidthCtrl,
                                onChanged: (_) => _calculateIssueKg(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                label: "Cut Length",
                                controller: cutLengthCtrl,
                                onChanged: (_) => _calculateIssueKg(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _sectionCard(
                      title: "Issue Quantity",
                      icon: Icons.local_shipping_outlined,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _numField(
                                label: "Issue PCS",
                                controller: issuePcsCtrl,
                                required: true,
                                showError: _submitAttempted &&
                                    issuePcsCtrl.text.trim().isEmpty,
                                onChanged: (_) => setState(_calculateIssueKg),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _readonlyField(
                                label: "Issue KG (auto)",
                                controller: issueKgCtrl,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- STICKY SAVE BAR ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: C.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving ? null : _onSave,
                  child: isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: C.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
          children: required
              ? const [
            TextSpan(
              text: " *",
              style: TextStyle(color: Colors.redAccent),
            ),
          ]
              : [],
        ),
      ),
    );
  }

  Widget _loadingField() {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _numField({
    required String label,
    required TextEditingController controller,
    Function(String)? onChanged,
    bool required = false,
    bool showError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(hint: "0.00", showError: showError),
        ),
      ],
    );
  }

  Widget _readonlyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: _inputDecoration(hint: "0.000").copyWith(
            fillColor: Colors.grey.shade100,
            filled: true,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, bool showError = false}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: showError ? Colors.redAccent : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: C.primaryDark, width: 1.5),
      ),
    );
  }
}
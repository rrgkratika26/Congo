import 'package:flutter/material.dart';

import '../../../../Color/Colorclass.dart';
import '../../../services/NardanaApis/statusTrackerServices.dart';
import 'PrintingIssueList.dart';

class PrintingIssueDialog extends StatefulWidget {
  final PrintingIssueModel item;

  const PrintingIssueDialog({
    super.key,
    required this.item,
  });

  @override
  State<PrintingIssueDialog> createState() =>
      _PrintingIssueDialogState();
}

class _PrintingIssueDialogState extends State<PrintingIssueDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pcsController =
  TextEditingController();

  final TextEditingController _kgController =
  TextEditingController();

  bool _isSaving = false;

  String? _apiError;

  static const String _issueTo = 'FIBC';

  @override
  void initState() {
    super.initState();

    _pcsController.addListener(_recalculateKg);
  }

  @override
  void dispose() {
    _pcsController.removeListener(_recalculateKg);

    _pcsController.dispose();
    _kgController.dispose();

    super.dispose();
  }

  // ============================================================
  // CALCULATE KG
  // ============================================================

  void _recalculateKg() {
    final pcsText = _pcsController.text.trim();

    final pcs = int.tryParse(pcsText);

    if (pcs == null || pcs <= 0) {
      if (_kgController.text.isNotEmpty) {
        _kgController.clear();
      }
      return;
    }

    final kg = pcs * widget.item.perPcsWt;

    final formattedKg = kg.toStringAsFixed(3);

    if (_kgController.text != formattedKg) {
      _kgController.text = formattedKg;
    }
  }

  // ============================================================
  // VALIDATE PCS
  // ============================================================

  String? _validatePcs(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Issue PCS required';
    }

    final pcs = int.tryParse(text);

    if (pcs == null) {
      return 'Enter valid PCS';
    }

    if (pcs <= 0) {
      return 'PCS must be greater than 0';
    }

    if (pcs > widget.item.balancePcs) {
      return 'Maximum ${widget.item.balancePcs} PCS available';
    }

    return null;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _apiError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pcs = int.parse(
      _pcsController.text.trim(),
    );

    // Round KG to 3 decimal places.
    final kg = double.parse(
      (pcs * widget.item.perPcsWt).toStringAsFixed(3),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final response =
      await StatusTrackerService.savePrintingIssue(
        partyName: widget.item.partyName,
        bomNo: widget.item.bomNo,
        component: widget.item.component,
        cutLength: widget.item.cutLength,
        cutWidth: widget.item.cutWidth,
        pcs: pcs,
        netWt: kg,
        weightPerPcs: widget.item.perPcsWt,
        issueTo: _issueTo,
      );

      if (!mounted) return;

      debugPrint('====================================');
      debugPrint('SAVE RESULT');
      debugPrint('SUCCESS: ${response.success}');
      debugPrint('MESSAGE: ${response.message}');
      debugPrint('DATA: ${response.data}');
      debugPrint('====================================');

      if (response.success && response.data) {
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Printing issue saved successfully',
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _apiError = response.message.isNotEmpty
              ? response.message
              : 'Unable to save printing issue';
        });
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Save Printing Issue Error: $e');

      setState(() {
        _apiError = 'Failed to save printing issue';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          bottom: bottomInset,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // DRAG HANDLE
                  // ==================================================

                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: C.primary.withOpacity(.10),
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.print_outlined,
                          color: C.primary,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Printing Issue',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Create printing material issue',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: _isSaving
                            ? null
                            : () =>
                            Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // WORK ORDER CARD
                  // ==================================================

                  _sectionTitle(
                    'WORK ORDER DETAILS',
                    Icons.description_outlined,
                  ),

                  const SizedBox(height: 9),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _infoItem(
                                'Party Name',
                                item.partyName,
                                Icons.business_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoItem(
                                'Work Order',
                                item.bomNo,
                                Icons.receipt_long_outlined,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _infoItem(
                                'Component',
                                item.component,
                                Icons.category_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoItem(
                                'Issue To',
                                _issueTo,
                                Icons.arrow_forward_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SPECIFICATION
                  // ==================================================

                  _sectionTitle(
                    'SPECIFICATION',
                    Icons.straighten_outlined,
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          title: 'Cut Length',
                          value:
                          item.cutLength.toStringAsFixed(2),
                          unit: 'mm',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          title: 'Cut Width',
                          value:
                          item.cutWidth.toStringAsFixed(2),
                          unit: 'mm',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          title: 'PCS Weight',
                          value:
                          item.perPcsWt.toStringAsFixed(3),
                          unit: 'kg',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // ISSUE TRANSACTION
                  // ==================================================

                  _sectionTitle(
                    'ISSUE TRANSACTION',
                    Icons.swap_horiz_rounded,
                  ),

                  const SizedBox(height: 9),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // BALANCE
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 18,
                                color:
                                Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Available Balance',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${item.balancePcs} PCS',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w800,
                                  color:
                                  Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ISSUE PCS
                            Expanded(
                              child: TextFormField(
                                controller:
                                _pcsController,
                                enabled: !_isSaving,
                                keyboardType:
                                TextInputType.number,
                                validator:
                                _validatePcs,
                                decoration:
                                _inputDecoration(
                                  'Issue PCS',
                                  Icons.numbers_rounded,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ISSUE KG
                            Expanded(
                              child: TextFormField(
                                controller:
                                _kgController,
                                readOnly: true,
                                decoration:
                                _inputDecoration(
                                  'Issue KG',
                                  Icons.scale_outlined,
                                ).copyWith(
                                  filled: true,
                                  fillColor:
                                  Colors.grey.shade100,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Issue KG = Issue PCS × ${item.perPcsWt.toStringAsFixed(3)} kg',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // API ERROR
                  // ==================================================

                  if (_apiError != null) ...[
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.shade100,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 19,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _apiError!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.red.shade800,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () =>
                                Navigator.pop(
                                  context,
                                  false,
                                ),
                            style: OutlinedButton.styleFrom(
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(11),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                       
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                            _isSaving
                                ? null
                                : _handleSave,
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              C.primary,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(11),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [

                                Text(
                                  'Issue',
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: C.primary,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
      String title,
      String value,
      IconData icon,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: C.primary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // METRIC CARD
  // ============================================================

  Widget _metricCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 19,
      ),
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
        borderSide: BorderSide(
          color: C.primary,
          width: 1.5,
        ),
      ),
    );
  }
}
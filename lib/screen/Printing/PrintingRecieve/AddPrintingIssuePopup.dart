import 'package:flutter/material.dart';
import '../../../../Color/Colorclass.dart';
import '../ModelClass/PrintingissueListModel.dart';

class AddPrintingIssuePopup {
  static Future<void> show(
      BuildContext context, {
        required PrintingIssueListModel item,
        required String workOrderNo,
        VoidCallback? onSaved,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PrintingIssueDialog(
        item: item,
        workOrderNo: workOrderNo,
        onSaved: onSaved,
      ),
    );
  }
}

class _PrintingIssueDialog extends StatefulWidget {
  final PrintingIssueListModel item;
  final String workOrderNo;
  final VoidCallback? onSaved;

  const _PrintingIssueDialog({
    required this.item,
    required this.workOrderNo,
    this.onSaved,
  });

  @override
  State<_PrintingIssueDialog> createState() => _PrintingIssueDialogState();
}

class _PrintingIssueDialogState extends State<_PrintingIssueDialog> {
  final _issuePcsCtrl = TextEditingController();
  final _issueKgCtrl = TextEditingController();

  String? _issueTo = 'FIBC';
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _issuePcsCtrl.dispose();
    _issueKgCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final pcs = int.tryParse(_issuePcsCtrl.text.trim());
    final kg = double.tryParse(_issueKgCtrl.text.trim());

    if (pcs == null || pcs <= 0) {
      setState(() => _errorText = 'Enter valid Issue Pcs');
      return;
    }
    if (pcs > widget.item.balancePcs) {
      setState(() => _errorText = 'Issue Pcs cannot exceed Balance Pcs');
      return;
    }
    if (kg == null || kg <= 0) {
      setState(() => _errorText = 'Enter valid Issue Kg');
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    try {
      // TODO: wire to actual save API, e.g.:
      // await PrintingIssueService().saveIssue(
      //   partyName: widget.item.partyName,
      //   bomNo: widget.item.bomNo,
      //   component: widget.item.component,
      //   issueTo: _issueTo,
      //   issuePcs: pcs,
      //   issueKg: kg,
      // );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved?.call();
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleBar(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionCard(
                      title: 'WORK ORDER SPECIFICATIONS',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _readOnlyField(
                                  label: 'PARTY NAME',
                                  value: item.partyName,
                                  highlight: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _readOnlyField(
                                  label: 'CUT WIDTH',
                                  value: item.cutWidth.toStringAsFixed(2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _readOnlyField(
                                  label: 'CUT LENGTH',
                                  value: item.cutLength.toStringAsFixed(2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _readOnlyField(
                                  label: 'SINGLE PCS WT',
                                  value: item.perPcsWt.toStringAsFixed(3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'PRODUCTION PARAMETERS',
                      child: Row(
                        children: [
                          Expanded(
                            child: _readOnlyDropdownLike(
                              label: 'WORK ORDER NO',
                              value: widget.workOrderNo,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _readOnlyDropdownLike(
                              label: 'COMPONENT NAME',
                              value: item.component,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'ISSUE TRANSACTION DETAILS',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: _issueToDropdown(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _inputField(
                              label: 'ISSUE PCS',
                              controller: _issuePcsCtrl,
                              hint: 'Max ${item.balancePcs}',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _inputField(
                              label: 'ISSUE KG',
                              controller: _issueKgCtrl,
                              hint: 'Max ${item.balanceWt.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorText!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _cancelButton(),
                        const SizedBox(width: 12),
                        _saveButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: C.appBar1,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'PRINTING ISSUE DATA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: C.primaryDark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: highlight ? C.primary.withOpacity(0.12) : C.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: C.border),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: C.textHigh,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyDropdownLike({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: C.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: C.textHigh,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _issueToDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ISSUE TO', style: _labelStyle()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: C.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _issueTo,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              items: const [
                DropdownMenuItem(value: 'FIBC', child: Text('FIBC')),
                DropdownMenuItem(value: 'PRINTING', child: Text('PRINTING')),
                DropdownMenuItem(value: 'BALING', child: Text('BALING')),
              ],
              onChanged: (v) => setState(() => _issueTo = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: C.primary, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: Colors.grey,
      letterSpacing: 0.2,
    );
  }

  Widget _cancelButton() {
    return OutlinedButton(
      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: C.border),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isSaving
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
          : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
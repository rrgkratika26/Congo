import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Color/Colorclass.dart';
import '../../services/visa_apis/visa_api.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'LoomModelClass.dart';

/// ---------------------
/// Loom Entry Screen
/// ---------------------
class LoomEntryScreen extends StatefulWidget {
  final LoomOrder order;

  const LoomEntryScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<LoomEntryScreen> createState() => _LoomEntryScreenState();
}

class _LoomEntryScreenState extends State<LoomEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final supervisorCtrl = TextEditingController();
  final partyCtrl = TextEditingController();
  final poCtrl = TextEditingController();
  final orderNoCtrl = TextEditingController();
  final fabricCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final qtyKgCtrl = TextEditingController();
  final qtyMtrCtrl = TextEditingController();
  final articleCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  String? batchNo;
  bool isLoadingBatch = false;
  String productionType = 'FIBC';
  String shift = 'A';
  String laminationType = 'UL';
  bool _didInit = false;
  bool isLoadingDropdowns = false;
  LoomDropdownData? dropdownData;
  bool isFormValid() {
    return partyCtrl.text.isNotEmpty &&
        dateCtrl.text.isNotEmpty &&
        laminationType.isNotEmpty &&
        shift.isNotEmpty;
  }

  bool isMobile(double w) => w < 700;

  @override
  void initState() {
    super.initState();

    // Pre-fill from order
    orderNoCtrl.text = widget.order.loomOrderNo.toString();
    poCtrl.text = widget.order.woNo.toString();
    fabricCtrl.text = widget.order.requiredFabricCode;
    partyCtrl.text = widget.order.customerName;
    qtyKgCtrl.text = widget.order.requiredQuantityKg.toString();
    qtyMtrCtrl.text = widget.order.requiredQuantityMtr.toString();
  }

  @override
  void dispose() {
    supervisorCtrl.dispose();
    partyCtrl.dispose();
    poCtrl.dispose();
    orderNoCtrl.dispose();
    fabricCtrl.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();
    qtyKgCtrl.dispose();
    qtyMtrCtrl.dispose();
    articleCtrl.dispose();
    remarkCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInit) {
      dateCtrl.text = DateTime.now().toString().split(' ')[0];
      timeCtrl.text = TimeOfDay.now().format(context);
      _didInit = true;

      // Fetch API dropdowns
      _fetchDropdownData();
    }
  }

  Future<void> loadBatchNo() async {
    if (partyCtrl.text.isNotEmpty &&
        dateCtrl.text.isNotEmpty &&
        laminationType.isNotEmpty &&
        shift.isNotEmpty) {
      setState(() {
        isLoadingBatch = true;
      });

      final result = await VisaApiService.generateBatchNo(
        partyName: partyCtrl.text,
        date: dateCtrl.text, // yyyy-MM-dd
        loomType: laminationType,
        shift: shift,
      );
      print("Sending Data:");
      print(partyCtrl.text);
      print(dateCtrl.text);
      print(laminationType);
      print(shift);
      setState(() {
        batchNo = result;
        isLoadingBatch = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields first")),
      );
    }
  }

  Future<void> _fetchDropdownData() async {
    final unit = await AppSession.getUnit();
    setState(() => isLoadingDropdowns = true);
    try {
      dropdownData = await InStockService.fetchDropdowns(
        unit: '$unit',
        fabricCode: widget.order.requiredFabricCode,
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoadingDropdowns = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingDropdowns)
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: C.appBar3,)));

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Loom Entry Form'),
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = isMobile(constraints.maxWidth);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Form(
                  key: _formKey,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _sectionTitle('Production Details'),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Production Type',
                              productionType,
                              ['FIBC', 'NON-FIBC'],
                              (v) => setState(() => productionType = v!),
                            ),
                            _dropdown('Shift', shift, ['A', 'B'], (v) {
                              setState(() => shift = v!);
                            }),
                          ),

                          _sectionTitle('Order Details'),
                          _responsiveRow(
                            mobile,
                            _fullWidth(
                              _dropdown('Party Name', partyCtrl.text, dropdownData?.partyNames ?? [], (v) {
                                partyCtrl.text = v!;
                                setState(() {});
                              }),
                            ),
                            _textField('Supervisor Name', supervisorCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Order No',
                              orderNoCtrl.text,
                              dropdownData?.orderNos ?? [],
                              (v) => setState(() => orderNoCtrl.text = v!),
                            ),
                            _textField('Purchase Order No', poCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Required Fabric',
                              fabricCtrl.text,
                              dropdownData?.requiredFabrics ?? [],
                              (v) => setState(() => fabricCtrl.text = v!),
                            ),
                            _dropdown(
                              'Loom Type',
                              laminationType,
                              dropdownData?.loomTypes ?? [],
                              (v) {
                                laminationType = v!;
                                setState(() {});
                              },
                            ),
                          ),

                          _responsiveRow(
                            mobile,
                            _textField('Date', dateCtrl),
                            _textField('Time', timeCtrl),
                          ),
                          _responsiveRow(
                            mobile,
                            _numberField('Required Qty (Kg)', qtyKgCtrl),
                            _numberField('Required Qty (Mtr)', qtyMtrCtrl),
                          ),

                          _sectionTitle('Fabric Details'),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Operator Name 1',
                              '',
                              dropdownData?.operators ?? [],
                              (v) {},
                            ),
                            _dropdown(
                              'Operator Name 2',
                              '',
                              dropdownData?.operators ?? [],
                              (v) {},
                            ),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Fabric Width',
                              '',
                              dropdownData?.fabricWidthList ?? [],
                              (v) {},
                            ),
                            _dropdown(
                              'Fabric Type',
                              '',
                              dropdownData?.fabrictype ?? [],
                              (v) {},
                            ),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Fabric GSM',
                              '',
                              dropdownData?.fabricGSm ?? [],
                              (v) {},
                            ),
                            _dropdown(
                              'Color',
                              '',
                              dropdownData?.color ?? [],
                              (v) {},
                            ),
                          ),
                          _responsiveRow(
                            mobile,
                            _dropdown(
                              'Cut Type',
                              '',
                              dropdownData?.cutType ?? [],
                              (v) {},
                            ),
                            _dropdown(
                              'Special ID',
                              '',
                              dropdownData?.specialID ?? [],
                              (v) {},
                            ),
                          ),

                          _sectionTitle('Remarks'),
                          _fullWidth(
                            TextFormField(
                              controller: remarkCtrl,
                              maxLines: 3,
                              decoration: _decoration('Remark'),
                            ),
                          ),
                          _sectionTitle('Batch Details'),

                          _fullWidth(
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isLoadingBatch
                                  ? const Center(
                                      child: CircularProgressIndicator(color: C.appBar3,),
                                    )
                                  : Text(
                                      batchNo ?? "Click 'Generate Code'",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print("BUTTON CLICKED");
                                  _generateCode();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Generate Code', style: TextStyle(color: C.bg),),
                              ),
                              // const SizedBox(width: 10),
                              // ElevatedButton(
                              //   onPressed: _saveForm,
                              //   child: const Text('Save'),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------------
  /// UI Helpers
  /// ---------------------
  Widget _responsiveRow(bool mobile, Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [left, right],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: left,
            ),
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: right,
            ),
          ],
        );
      },
    );
  }
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ),
    );
  }

  Widget _fullWidth(Widget child) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: child);

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        decoration: _decoration(label),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl) =>
      _textField(label, ctrl);

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child:DropdownButtonFormField<String>(
        isExpanded: true, // ⭐ IMPORTANT
        value: items.contains(value) ? value : null,
        decoration: _decoration(label),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            overflow: TextOverflow.ellipsis, // optional
          ),
        ))
            .toList(),
        onChanged: onChanged,
      )
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }

  Future<void> _generateCode() async {
    print("=== _generateCode called ===");
    print("Party: '${partyCtrl.text}'");
    print("Date: '${dateCtrl.text}'");
    print("LoomType: '$laminationType'");
    print("Shift: '$shift'");
    print("isFormValid: ${isFormValid()}");

    if (!isFormValid()) {
      print("Form not valid");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all required fields")));
      return;
    }

    setState(() => isLoadingBatch = true);

    print("Calling API...");

    final result = await VisaApiService.generateBatchNo(
      partyName: partyCtrl.text,
      date: dateCtrl.text,
      loomType: laminationType,
      shift: shift,
    );

    print("API RESULT: $result");

    setState(() {
      batchNo = result;
      isLoadingBatch = false;
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loom Entry Saved')));
    }
  }
}

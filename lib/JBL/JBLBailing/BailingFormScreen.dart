import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart' as http;
import '../../AdminDashBoard/AsiaDashBoard/DepartmentdashboardBottom.dart';
import '../../Color/Colorclass.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'BarcodeLabel.dart';
import 'PackingDetailScreen.dart';
import 'QRPrinterBailing.dart';
import 'modleclass/modelClass.dart';

// ── Colors ───────────────────────────────────────────────────

class BailingFormScreen extends StatefulWidget {
  final BailingEntry entry;
  const BailingFormScreen({super.key, required this.entry});

  @override
  State<BailingFormScreen> createState() => _BailingFormScreenState();
}

class _BailingFormScreenState extends State<BailingFormScreen> {
  final _grossWt1 = TextEditingController();
  final _grossWt2 = TextEditingController();
  final _tareWt = TextEditingController();
  final _netWt = TextEditingController();
  final _bomWt = TextEditingController();
  final _diffWt = TextEditingController();
  final _custRef = TextEditingController();

  List<BailingDetail> _details = [];
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    for (final c in [
      _grossWt1,
      _grossWt2,
      _tareWt,
      _netWt,
      _bomWt,
      _diffWt,
      _custRef,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final token = await AppSession.getToken();

      final response = await http.get(
        Uri.parse(
          'http://190.92.175.47:80_DEMO/api/BaleDepartment/entry-report-details?bomNo=${widget.entry.bomNo}',
          // 'http://190.92.175.47:80/JblAPI/api/BaleDepartment/entry-report-details?bomNo=${widget.entry.bomNo}',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final detailsList = data.map((e) => BailingDetail.fromJson(e)).toList();

        setState(() {
          _details = detailsList;
          _isLoadingDetails = false;

          // ✅ Auto set BOM WT from first record
          if (_details.isNotEmpty) {
            _bomWt.text = _details.first.packingNetWt.toStringAsFixed(2);
          }
        });

        // Recalculate after setting BOM WT
        _calculate();
      } else {
        setState(() => _isLoadingDetails = false);
      }
    } catch (e) {
      setState(() => _isLoadingDetails = false);
    }
  }

  void _calculate() {
    final g1 = double.tryParse(_grossWt1.text) ?? 0;
    final g2 = double.tryParse(_grossWt2.text) ?? 0;
    final tare = double.tryParse(_tareWt.text) ?? 0;
    final bom = double.tryParse(_bomWt.text) ?? 0;

    // 👉 If you want total gross = g1 + g2
    // final grossTotal = g1 + g2;

    // ✅ Net = Gross - Tare
    final net = g1 - tare;

    // ✅ Difference = Net - BOM
    final diff = net - bom;

    setState(() {
      _netWt.text = net.toStringAsFixed(2);
      _diffWt.text = diff.toStringAsFixed(2);
    });
  }

  // Future<void> _save() async {
  //   _calculate();
  //   FocusScope.of(context).unfocus();
  //
  //   try {
  //     final token = await AppSession.getToken();
  //
  //     final grossTotal = (double.tryParse(_grossWt1.text) ?? 0);
  //
  //     final tare = double.tryParse(_tareWt.text) ?? 0;
  //     final net = double.tryParse(_netWt.text) ?? 0;
  //     final diff = double.tryParse(_diffWt.text) ?? 0;
  //
  //
  //     // 👉 Take packingNo from first detail row
  //     final packingNo = _details.isNotEmpty ? _details.first.packingNo : "";
  //     final baG_SIZE =_details.isNotEmpty ? _details.first.bag_size : "";
  //
  //     final body = {
  //       "packingNo": packingNo,
  //       "bailingGrossWt": grossTotal,
  //       "bailingTareWt": tare,
  //       "bag_size": baG_SIZE,
  //       "bailingStageDiffNetWt": diff,
  //       "bailingNetWt": net,
  //       "customerReference": _custRef.text,
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(
  //         "http://190.92.175.47:80/JblAPI/api/BaleDepartment/save-bale-entry",
  //       ),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     // if (response.statusCode == 200 || response.statusCode == 201) {
  //     //
  //     //   final packingNo = _details.isNotEmpty ? _details.first.packingNo : "";
  //     //
  //     //   showDialog(
  //     //     context: context,
  //     //     builder: (context) {
  //     //       return AlertDialog(
  //     //         title: const Text("Saved Successfully"),
  //     //         content: const Text("Do you want to print QR Code?"),
  //     //         actions: [
  //     //           TextButton(
  //     //             onPressed: () {
  //     //               Navigator.pop(context);
  //     //             },
  //     //             child: const Text("No",style: TextStyle(color: Colors.black)),
  //     //           ),
  //     //           ElevatedButton(
  //     //             onPressed: () async {
  //     //               Navigator.pop(context);
  //     //
  //     //               await BailingQrPrinter.printQr(
  //     //                 packingNo: packingNo,
  //     //                 netWt: double.tryParse(_netWt.text) ?? 0,
  //     //                 grossWt: double.tryParse(_grossWt1.text) ?? 0,
  //     //                 tareWt: double.tryParse(_tareWt.text) ?? 0,
  //     //                 customerRef: _custRef.text,
  //     //               );
  //     //             },
  //     //             child: const Text("Print",style: TextStyle(color: Colors.black),),
  //     //           ),
  //     //         ],
  //     //       );
  //     //     },
  //     //   );
  //     // }
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Saved Successfully"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //           // 🔹 Clear fields
  //           _grossWt1.clear();
  //           _tareWt.clear();
  //       _netWt.clear();
  //       _diffWt.clear();
  //       _custRef.clear();
  //       // 🔹 Reload API Data
  //       await _fetchDetails();
  //
  //       // 🔹 Recalculate
  //       _calculate();
  //
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Error: ${response.body}"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Exception: $e"), backgroundColor: Colors.red),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFA),
        elevation: 0,
        title: Text(
          "Bailing Form",
          style: TextStyle(color: C.primary, fontWeight: FontWeight.bold),
        ),
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          color: C.bg,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.to(() => const DeptBottomNavDashboard());

            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(entry: widget.entry),

            const SizedBox(height: 12),

            _FormCard(
              grossWt1: _grossWt1,

              tareWt: _tareWt,
              netWt: _netWt,
              bomWt: _bomWt,
              diffWt: _diffWt,
              custRef: _custRef,
              onChanged: _calculate,
              // onSave: _save,
            ),

            const SizedBox(height: 16),

            Center(
              child: const Text(
                "Packing Details",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: C.primary,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child:
              // _isLoadingDetails
              //     ? const Center(child: CircularProgressIndicator())
              //     : _details.isEmpty
              //     ? const Text("No data found")
              //     :
              _PackingDetailsTable(
                      details: _details,
                      onSelectPacking: (selected) {
                        setState(() {
                          _bomWt.text = selected.packingNetWt.toStringAsFixed(
                            2,
                          );
                        });
                        _calculate();
                      },
                      netWt: double.tryParse(_netWt.text) ?? 0,
                      grossWt: double.tryParse(_grossWt1.text) ?? 0,
                      tareWt: double.tryParse(_tareWt.text) ?? 0,
                      diffWt: double.tryParse(_diffWt.text) ?? 0,
                      customerRef: _custRef.text,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final BailingEntry entry;
  const _InfoCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: C.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Party: ${entry.partyName}"),
            Text("BOM: ${entry.bomNo}"),
            Text("Article: ${entry.articleNo}"),
          ],
        ),
      ),
    );
  }
}

// ── Packing Table ────────────────────────────────────────────
class _PackingDetailsTable extends StatelessWidget {
  final List<BailingDetail> details;
  final Function(BailingDetail) onSelectPacking;

  final double netWt;
  final double grossWt;
  final double tareWt;
  final double diffWt;
  final String customerRef;

  const _PackingDetailsTable({
    required this.details,
    required this.onSelectPacking,
    required this.netWt,
    required this.grossWt,
    required this.tareWt,
    required this.diffWt,
    required this.customerRef,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 150,
          horizontalMargin: 18,
          headingRowHeight: 36,
          dataRowHeight: 42,
          headingRowColor: MaterialStateProperty.all(C.primary),
          columns: const [
            DataColumn(label: Text("Packing No")),
            DataColumn(label: Text("Print")),
          ],
          rows: details.map((d) {
            return DataRow(
              cells: [
                // 🔹 PACKING NO (Select → Set BOM WT)
                DataCell(
                  InkWell(
                    onTap: () {
                      onSelectPacking(d);
                    },
                    child: Text(
                      d.packingNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: C.primary,
                      ),
                    ),
                  ),
                ),

                // 🔹 PRINT BUTTON
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.print, color: C.primary),
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) => PackingDetailsScreen(
                    //         detail: d,
                    //         netWt:
                    //             double.tryParse(
                    //               (context
                    //                       .findAncestorStateOfType<
                    //                         _BailingFormScreenState
                    //                       >()
                    //                       ?._netWt
                    //                       .text ??
                    //                   "0"),
                    //             ) ??
                    //             0,
                    //         diffWt:
                    //             double.tryParse(
                    //               (context
                    //                       .findAncestorStateOfType<
                    //                         _BailingFormScreenState
                    //                       >()
                    //                       ?._diffWt
                    //                       .text ??
                    //                   "0"),
                    //             ) ??
                    //             0,
                    //         grossWt:
                    //             double.tryParse(
                    //               (context
                    //                       .findAncestorStateOfType<
                    //                         _BailingFormScreenState
                    //                       >()
                    //                       ?._grossWt1
                    //                       .text ??
                    //                   "0"),
                    //             ) ??
                    //             0,
                    //         tareWt:
                    //             double.tryParse(
                    //               (context
                    //                       .findAncestorStateOfType<
                    //                         _BailingFormScreenState
                    //                       >()
                    //                       ?._tareWt
                    //                       .text ??
                    //                   "0"),
                    //             ) ??
                    //             0,
                    //         customerRef:
                    //             context
                    //                 .findAncestorStateOfType<
                    //                   _BailingFormScreenState
                    //                 >()
                    //                 ?._custRef
                    //                 .text ??
                    //             "",
                    //       ),
                    //     ),
                    //   );
                    // },
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarcodeLabelScreen(
                            labelData: BarcodeLabelData(
                              pcsPerPacking: d.pcsPerPacking.toString(),
                              packingNo: d.packingNo,
                              bag_size: d.bag_size,
                              partyName: d.partyName,
                              bomNo: d.bomNo,
                              articleNo: d.articleNo,
                              netWt: netWt,
                              grossWt: grossWt,
                              tareWt: tareWt,
                              diffWt: diffWt,
                              customerRef: customerRef,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final TextEditingController grossWt1, tareWt, netWt, bomWt, diffWt, custRef;
  final VoidCallback onChanged;

  const _FormCard({
    required this.grossWt1,

    required this.tareWt,
    required this.netWt,
    required this.bomWt,
    required this.diffWt,
    required this.custRef,
    required this.onChanged,
    // required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: C.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: C.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.scale_rounded,
                  size: 18,
                  color: C.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Weight Entry',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _Divider(),
          const SizedBox(height: 14),

          // Gross & Tare Section
          const _SectionLabel('Gross & Tare'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _WeightInput(
                  ctrl: grossWt1,
                  label: 'Gross WT',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: _WeightInput(
                  ctrl: tareWt,
                  label: 'Tare WT',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const _Divider(),
          const SizedBox(height: 14),

          // Calculated Section
          const _SectionLabel('Calculated'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _WeightInput(
                  ctrl: netWt,
                  label: 'Net WT',
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WeightInput(
                  ctrl: bomWt,
                  label: 'BOM WT',
                  onChanged: onChanged,
                  readOnly: true, // 👈 change this
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WeightInput(
                  ctrl: diffWt,
                  label: 'Diff WT',
                  readOnly: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const _Divider(),
          const SizedBox(height: 14),

          // Customer Reference
          const _SectionLabel('Customer Reference'),
          const SizedBox(height: 8),
          _WeightInput(
            ctrl: custRef,
            label: 'Enter reference',
            isNumeric: false,
          ),

          const SizedBox(height: 16),

          // // Save Button
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: onSave,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: _primary,
          //       foregroundColor: Colors.white,
          //       elevation: 0,
          //       padding: const EdgeInsets.symmetric(vertical: 14),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //     ),
          //     child: const Text(
          //       'SAVE',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w800,
          //         letterSpacing: 0.8,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// SECTION LABEL
class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: C.primary,
      ),
    );
  }
}

/// DIVIDER
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: C.border);
  }
}

/// WEIGHT INPUT FIELD
class _WeightInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool readOnly;
  final bool isNumeric;
  final VoidCallback? onChanged;

  const _WeightInput({
    required this.ctrl,
    required this.label,
    this.readOnly = false,
    this.isNumeric = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumeric
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) {
        if (onChanged != null) onChanged!();
      },
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
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
          borderSide: BorderSide(color: C.primary),
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) => Container(height: 1, color: C.border);

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'CuttinIN/Cutt_pieces_issueModel.dart';

class IssueCutPCSPopup {
  static Future<void> show(
    BuildContext context,
    String woNumber,
    CutPieceIssuedModel item,
  ) async {
    final pcsCtrl = TextEditingController();
    final kgCtrl = TextEditingController();

    List<String> components = [];
    String? selectedComponent;
    bool isLoading = true;

    /// Fetch components
    try {
      final url = Uri.parse(
        'https://190.92.175.47:80/JblAPI/api/Cutting/ComponentInCuttingIssued?woNumber=${Uri.encodeComponent(woNumber)}',
      );

      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        components = data
            .map<String>((e) => e['component'].toString())
            .toList();

        selectedComponent =
            item.component ?? (components.isNotEmpty ? components.first : null);
      } else {
        selectedComponent = item.component;
      }
    } catch (e) {
      debugPrint("Error fetching components: $e");
      selectedComponent = item.component;
    }

    isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          const Center(
                            child: Text(
                              "Issue Cut PCS",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// Order Details Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  _InfoRow(
                                    label: "ID",
                                    value: item.id?.toString() ?? "—",
                                  ),

                                  _InfoRow(
                                    label: "WO No",
                                    value: item.receiveOrderNo ?? "—",
                                  ),

                                  _InfoRow(
                                    label: "Cut Width",
                                    value:
                                        item.receivedWidth?.toString() ?? "0",
                                  ),

                                  _InfoRow(
                                    label: "Cut Length",
                                    value:
                                        item.receivedCutLength?.toString() ??
                                        "0",
                                  ),

                                  _InfoRow(
                                    label: "Single PCS WT",
                                    value: item.perPcsWt?.toString() ?? "0",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Component Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedComponent,
                            decoration: InputDecoration(
                              labelText: "Component Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              isDense: true,
                            ),
                            items: components
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedComponent = value),
                          ),

                          const SizedBox(height: 16),

                          /// Issue PCS
                          TextField(
                            controller: pcsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Issue in PCS",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              final pcs = double.tryParse(value) ?? 0;
                              final wt = item.perPcsWt ?? 0;

                              final kg = pcs * wt;

                              kgCtrl.text = kg == 0
                                  ? ""
                                  : kg.toStringAsFixed(2);
                            },
                          ),

                          const SizedBox(height: 14),

                          /// Issue KG
                          TextField(
                            controller: kgCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Issue in KG",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          /// Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () async {
                                  final pcs =
                                      double.tryParse(pcsCtrl.text.trim()) ?? 0;
                                  final kg =
                                      double.tryParse(kgCtrl.text.trim()) ??
                                      0; // ← add this

                                  if (pcs <= 0 || kg <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Enter valid PCS and KG"),
                                      ),
                                    );
                                    return;
                                  }

                                  final success =
                                      await JblApiService.issueCutPiece(
                                        id: item.id ?? 0,
                                        woNumber: item.receiveOrderNo ?? "",
                                        component: selectedComponent ?? "",
                                        issuePcs: pcs,
                                        issueKg: kg,
                                      );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Data Saved Successfully"
                                            : "Issue failed",
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height -
                                            120,
                                        left: 20,
                                        right: 20,
                                      ),
                                    ),
                                  );

                                  if (success) Navigator.pop(context);
                                },
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(":  "),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

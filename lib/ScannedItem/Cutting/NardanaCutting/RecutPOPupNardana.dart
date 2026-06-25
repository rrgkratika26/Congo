

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final cutWidthCtrl =
    TextEditingController(text: width?.toStringAsFixed(2) ?? '');

    final cutLengthCtrl =
    TextEditingController(text: cutLength?.toStringAsFixed(2) ?? '');

    final issuePcsCtrl = TextEditingController();
    final issueKgCtrl = TextEditingController();

    /// WORK ORDER
    List<String> woNumbers = [];
    String? selectedWo;
    final isLoadingWo = [true];
    final woFetchTriggered = [false];

    /// COMPONENT
    List<String> components = [];
    String? selectedComponent;
    final isLoadingComp = [false];

    final isSaving = [false];

    /// AUTO KG CALCULATION
    void calculateIssueKg() {
      double perPcsWeight = perPcsWt ?? 0;
      double pcs = double.tryParse(issuePcsCtrl.text) ?? 0;

      double issueKg = perPcsWeight * pcs;
      issueKgCtrl.text = issueKg.toStringAsFixed(3);
    }

    /// FETCH WORK ORDERS
    Future<void> fetchWorkOrders(StateSetter setState) async {
      final data = await InStockService.getWoNumbers();

      woNumbers = data;

      setState(() {
        isLoadingWo[0] = false;
      });
    }

    /// FETCH COMPONENTS BASED ON WO
    Future<void> fetchComponents(
        StateSetter setState, String wo) async {
      setState(() {
        isLoadingComp[0] = true;
      });

      components =
      await InStockService.getComponentsInCuttingIssued(wo);

      setState(() {
        isLoadingComp[0] = false;
      });
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(

          constraints: const BoxConstraints(
            maxHeight: 650,
            maxWidth: 420,
            
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              /// CALL WO API ONCE
              if (!woFetchTriggered[0]) {
                woFetchTriggered[0] = true;
                fetchWorkOrders(setState);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Add Recut PCS Issue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// IID
                    _label("IID"),
                    _readonly(iid.toString()),

                    const SizedBox(height: 12),

                    /// WORK ORDER DROPDOWN
                    _label("Work Order"),
                    isLoadingWo[0]
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: C.appBar3,),
                    )
                        : DropdownButtonFormField<String>(
                      value: selectedWo,
                      items: woNumbers
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),
                      onChanged: (v) async {
                        setState(() {
                          selectedWo = v;
                          selectedComponent = null;
                        });

                        if (v != null) {
                          await fetchComponents(setState, v);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// PARTY
                    if (partyName != null) ...[
                      _label("Party Name"),
                      _readonly(partyName),
                      const SizedBox(height: 12),
                    ],

                    /// PER PCS WT
                    if (perPcsWt != null) ...[
                      _label("Per PCS Weight"),
                      _readonly(perPcsWt.toStringAsFixed(3)),
                      const SizedBox(height: 12),
                    ],

                    /// COMPONENT DROPDOWN
                    _label("Component"),
                    isLoadingComp[0]
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: C.appBar3,),
                    )
                        : DropdownButtonFormField<String>(
                      value: selectedComponent,
                      items: components
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedComponent = v;
                          calculateIssueKg();
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// WIDTH + LENGTH
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _label("Cut Width"),
                              _field(
                                cutWidthCtrl,
                                onChanged: (_) => calculateIssueKg(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _label("Cut Length"),
                              _field(
                                cutLengthCtrl,
                                onChanged: (_) => calculateIssueKg(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// PCS + KG
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _label("Issue PCS"),
                              _field(
                                issuePcsCtrl,
                                onChanged: (_) => calculateIssueKg(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _label("Issue KG"),
                              _readonlyController(issueKgCtrl),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.primaryDark,
                        ),
                        onPressed: () async {
                          if (selectedWo == null ||
                              selectedComponent == null ||
                              issuePcsCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please fill all required fields"),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSaving[0] = true;
                          });

                          final result =
                          await InStockService.saveCuttingIssue(
                            iid: iid,
                            issueToWorkOrder: selectedWo!,
                            issueToComponent: selectedComponent!,
                            noOfPcs:
                            int.tryParse(issuePcsCtrl.text) ?? 0,
                            kg: double.tryParse(issueKgCtrl.text) ?? 0,
                          );

                          setState(() {
                            isSaving[0] = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );

                          if (result == "Data Saved Successfully") {
                            Navigator.pop(context);
                            onSaved?.call();
                          }
                        },
                        child: isSaving[0]
                            ? const CircularProgressIndicator(
                          color: C.appBar3,
                        )
                            : const Text("Save",style: TextStyle(color: C.bg),),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// LABEL
Widget _label(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

/// TEXT FIELD
Widget _field(
    TextEditingController controller, {
      Function(String)? onChanged,
    }) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}

/// READONLY
Widget _readonly(String value) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(6),
      color: Colors.grey.shade100,
    ),
    child: Text(value),
  );
}

/// READONLY CONTROLLER
Widget _readonlyController(TextEditingController controller) {
  return TextField(
    controller: controller,
    readOnly: true,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import 'ModelClass/OrderCompositionModel.dart';
import 'SelectOrderScreenCompo.dart';

class OrderCompositionScreen extends StatefulWidget {
  const OrderCompositionScreen({super.key});

  @override
  State<OrderCompositionScreen> createState() => _OrderCompositionScreenState();
}

class _OrderCompositionScreenState extends State<OrderCompositionScreen> {
  final ScrollController horizontalCtrl = ScrollController();

  String orderComponent = "SINGLE";
  TextEditingController searchController = TextEditingController();

  List<OrderCompositionModel> filteredData = [];
  List<String> componentTypes = ["SINGLE", "CLUB"];

  List<OrderCompositionModel> data = [];

  bool isLoading = true;

  static const selectW = 50.0;
  static const bomW = 70.0;
  static const componentW = 80.0;
  static const fabricW = 170.0;
  static const w = 80.0;

  double get totalWidth => selectW + bomW + componentW + fabricW + (w * 5);

  bool _isCompleting = false;

  Future<void> completeSelectedItems() async {
    if (_isCompleting) return;

    final selectedItems = data.where((e) => e.selected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select item first'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // ------------------------------------------------------------
    // CONFIRMATION
    // ------------------------------------------------------------

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 10),
              const Text(
                'Confirm Complete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            selectedItems.length == 1
                ? 'Are you sure you want to complete this item?'
                : 'Are you sure you want to complete these '
                '${selectedItems.length} items?',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'OK',
                style: TextStyle(

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // ------------------------------------------------------------
    // START API
    // ------------------------------------------------------------

    setState(() {
      _isCompleting = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: Card(
              margin: EdgeInsets.all(30),
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: C.primary,),
                    SizedBox(height: 10),
                    Text(
                      'Completing component...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      int successCount = 0;
      int failedCount = 0;

      String? lastMessage;

      // ----------------------------------------------------------
      // COMPLETE EACH SELECTED COMPONENT
      // ----------------------------------------------------------

      for (final item in selectedItems) {
        if (!mounted) return;



        final String wo = item.woNumber.trim();
        final int? id = int.tryParse(item.idForWo.toString());

        debugPrint('');
        debugPrint('--------------------------------------------------');
        debugPrint('COMPLETING COMPONENT');
        debugPrint('WO => $wo');
        debugPrint('ID => $id');
        debugPrint('--------------------------------------------------');

        if (wo.isEmpty || id == null) {
          debugPrint(
            'SKIPPED => Invalid WO or ID',
          );

          failedCount++;
          continue;
        }

        try {
          final response =
          await NaradanaApiService().updateComponentStatus(
            wo: wo,
            id: id,
          );

          debugPrint(
            'COMPLETE RESPONSE STATUS => ${response.statusCode}',
          );
          debugPrint(
            'COMPLETE RESPONSE BODY => ${response.body}',
          );

          Map<String, dynamic>? responseData;

          try {
            responseData = jsonDecode(response.body)
            as Map<String, dynamic>;
          } catch (e) {
            debugPrint(
              'JSON PARSE ERROR => $e',
            );
          }

          final bool apiSuccess =
              response.statusCode >= 200 &&
                  response.statusCode < 300 &&
                  responseData?['success'] == true;

          if (apiSuccess) {
            successCount++;

            lastMessage =
                responseData?['message']?.toString();

            debugPrint(
              'COMPLETE SUCCESS => WO: $wo | ID: $id',
            );
          } else {
            failedCount++;

            debugPrint(
              'COMPLETE FAILED => WO: $wo | ID: $id',
            );
          }
        } catch (e) {
          failedCount++;

          debugPrint(
            'COMPLETE API ERROR => WO: $wo | ID: $id | ERROR: $e',
          );
        }
      }

      // ----------------------------------------------------------
      // CLOSE LOADING
      // ----------------------------------------------------------

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      // ----------------------------------------------------------
      // REFRESH PAGE
      // ----------------------------------------------------------

      if (successCount > 0) {
        debugPrint('');
        debugPrint('REFRESHING ORDER COMPOSITION DATA...');
        debugPrint('');

        await loadData();

        // Make sure old selected flags are removed.
        if (mounted) {
          setState(() {
            for (final item in data) {
              item.selected = false;
            }

            for (final item in filteredData) {
              item.selected = false;
            }
          });
        }
      }

      if (!mounted) return;

      // ----------------------------------------------------------
      // RESULT MESSAGE
      // ----------------------------------------------------------

      if (successCount > 0 && failedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount == 1
                  ? (lastMessage ??
                  'Component completed successfully.')
                  : '$successCount components completed successfully.',
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (successCount > 0 && failedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount completed, $failedCount failed.',
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to complete component.',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('================ COMPLETE ERROR ================');
      debugPrint('ERROR => $e');
      debugPrint('STACK => $stackTrace');
      debugPrint('=================================================');

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to complete component\n$e',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void selectAll(bool value) {
    setState(() {
      if (orderComponent == "SINGLE") {
        // SINGLE mode: select only one item
        for (var item in data) {
          item.selected = false;
        }

        if (value && data.isNotEmpty) {
          data[0].selected = true;
        }
      } else {
        // CLUB mode
        for (var item in data) {
          item.selected = value;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void filterData(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        filteredData = data;
      } else {
        filteredData = data.where((item) {
          return item.woNumber.toLowerCase().contains(value.toLowerCase()) ||
              item.component.toLowerCase().contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  Future loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await NaradanaApiService().fetchOrderComposition();

      setState(() {
        data = result;
        filteredData = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Order Composition",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: C.appBar1,

        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors:  [C.appBar2, C.appBar3],
        //     ),
        //   ),
        // ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0.5),
            child: TextField(
              controller: searchController,
              onChanged: filterData,
              decoration: InputDecoration(
                hintText: "Search BOM / Component",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          filterData('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(15),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: componentTypes.map((e) {
                          bool isSelected = orderComponent == e;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  orderComponent = e;

                                  // clear selections when mode changes
                                  for (var item in data) {
                                    item.selected = false;
                                  }
                                });
                              },

                              child: Container(
                                margin: const EdgeInsets.all(4),

                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? C.actionOrange
                                      : Colors.transparent,

                                  borderRadius: BorderRadius.circular(8),
                                ),

                                alignment: Alignment.center,

                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 28,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.success,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),

                            onPressed: () {
                              selectAll(true);
                            },

                            icon: const Icon(
                              Icons.done_all,
                              size: 16,
                              color: Colors.white,
                            ),

                            label: const Text(
                              "All",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          height: 28,

                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.warning,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),

                            onPressed: () {
                              selectAll(false);
                            },

                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),

                            label: const Text(
                              "Clear",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),

                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Scrollbar(
                      controller: horizontalCtrl,

                      thumbVisibility: true,

                      child: SingleChildScrollView(
                        controller: horizontalCtrl,

                        scrollDirection: Axis.horizontal,

                        child: SizedBox(
                          width: totalWidth < width ? width : totalWidth,

                          child: Column(
                            children: [
                              header(),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: filteredData.length,

                                  itemBuilder: (_, index) {
                                    return tableRow(filteredData[index], index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 5,),

          // Padding(
          //   padding: const EdgeInsets.all(18),
          //
          //   child: SizedBox(
          //     width: double.infinity,
          //
          //     height: 50,
          //
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: C.warning.withOpacity(0.7),
          //
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //       ),
          //
          //       // onPressed: () async {
          //       //
          //       //   List<OrderCompositionModel> selectedItems =
          //       //   data.where((e) => e.selected).toList();
          //       //
          //       //   /// No item selected
          //       //   if (selectedItems.isEmpty) {
          //       //
          //       //     ScaffoldMessenger.of(context).showSnackBar(
          //       //
          //       //       SnackBar(
          //       //         behavior: SnackBarBehavior.floating,
          //       //         backgroundColor: Colors.red.shade600,
          //       //
          //       //         shape: RoundedRectangleBorder(
          //       //           borderRadius: BorderRadius.circular(15),
          //       //         ),
          //       //
          //       //         content: const Row(
          //       //           children: [
          //       //
          //       //             Icon(
          //       //               Icons.warning_amber_rounded,
          //       //               color: Colors.white,
          //       //             ),
          //       //
          //       //             SizedBox(width: 10),
          //       //
          //       //             Text(
          //       //               "Select item first",
          //       //               style: TextStyle(
          //       //                 color: Colors.white,
          //       //                 fontWeight: FontWeight.w600,
          //       //               ),
          //       //             )
          //       //           ],
          //       //         ),
          //       //       ),
          //       //     );
          //       //
          //       //     return;
          //       //   }
          //       //
          //       //   /// SINGLE validation
          //       //   if (orderComponent == "SINGLE" &&
          //       //       selectedItems.length > 1) {
          //       //
          //       //     ScaffoldMessenger.of(context).showSnackBar(
          //       //
          //       //       SnackBar(
          //       //         behavior: SnackBarBehavior.floating,
          //       //         backgroundColor: Colors.orange.shade700,
          //       //
          //       //         shape: RoundedRectangleBorder(
          //       //           borderRadius: BorderRadius.circular(15),
          //       //         ),
          //       //
          //       //         content: const Row(
          //       //           children: [
          //       //
          //       //             Icon(
          //       //               Icons.info_outline,
          //       //               color: Colors.white,
          //       //             ),
          //       //
          //       //             SizedBox(width: 10),
          //       //
          //       //             Expanded(
          //       //               child: Text(
          //       //                 "Single allows only one item",
          //       //                 style: TextStyle(
          //       //                   color: Colors.white,
          //       //                   fontWeight: FontWeight.w600,
          //       //                 ),
          //       //               ),
          //       //             )
          //       //
          //       //           ],
          //       //         ),
          //       //       ),
          //       //     );
          //       //
          //       //     return;
          //       //   }
          //       //
          //       //   /// Loading
          //       //   showDialog(
          //       //     context: context,
          //       //     barrierDismissible: false,
          //       //     builder: (_) => const Center(
          //       //       child: CircularProgressIndicator(),
          //       //     ),
          //       //   );
          //       //
          //       //   try {
          //       //
          //       //     dynamic response;
          //       //
          //       //     if (orderComponent == "SINGLE") {
          //       //
          //       //       response =
          //       //       await NaradanaApiService()
          //       //           .singleSave(selectedItems);
          //       //
          //       //     } else {
          //       //
          //       //       response =
          //       //       await NaradanaApiService()
          //       //           .clubSave(selectedItems);
          //       //     }
          //       //
          //       //
          //       //     /// DEBUG LOGS
          //       //     debugPrint(
          //       //         "=========== API RESPONSE ===========");
          //       //
          //       //     debugPrint(
          //       //         "Status Code => ${response.statusCode}");
          //       //
          //       //     debugPrint(
          //       //         "Headers => ${response.headers}");
          //       //
          //       //     debugPrint(
          //       //         "Response Body => ${response.body}");
          //       //
          //       //     debugPrint(
          //       //         "====================================");
          //       //
          //       //
          //       //     /// CLOSE LOADING
          //       //     Navigator.pop(context);
          //       //
          //       //
          //       //     /// SUCCESS
          //       //     if (response.statusCode == 200 ||
          //       //         response.statusCode == 201) {
          //       //
          //       //       final responseData =
          //       //       jsonDecode(response.body);
          //       //
          //       //       String message =
          //       //           responseData["message"] ??
          //       //               "Saved Successfully";
          //       //
          //       //
          //       //       ScaffoldMessenger.of(context)
          //       //           .showSnackBar(
          //       //
          //       //         SnackBar(
          //       //           behavior:
          //       //           SnackBarBehavior.floating,
          //       //
          //       //           backgroundColor:
          //       //           Colors.green.shade600,
          //       //
          //       //           margin:
          //       //           const EdgeInsets.all(15),
          //       //
          //       //           duration:
          //       //           const Duration(seconds: 3),
          //       //
          //       //           shape:
          //       //           RoundedRectangleBorder(
          //       //             borderRadius:
          //       //             BorderRadius.circular(15),
          //       //           ),
          //       //
          //       //           content: Row(
          //       //             children: [
          //       //
          //       //               const Icon(
          //       //                 Icons.check_circle,
          //       //                 color: Colors.white,
          //       //               ),
          //       //
          //       //               const SizedBox(width: 10),
          //       //
          //       //               Expanded(
          //       //                 child: Text(
          //       //                   message,
          //       //                   style: const TextStyle(
          //       //                     color: Colors.white,
          //       //                     fontWeight:
          //       //                     FontWeight.bold,
          //       //                     fontSize: 14,
          //       //                   ),
          //       //                 ),
          //       //               ),
          //       //
          //       //             ],
          //       //           ),
          //       //         ),
          //       //       );
          //       //
          //       //       /// Optional clear selection after success
          //       //       setState(() {
          //       //
          //       //         for (var item in data) {
          //       //           item.selected = false;
          //       //         }
          //       //
          //       //       });
          //       //
          //       //     }
          //       //
          //       //     /// ERROR RESPONSE
          //       //     else {
          //       //
          //       //       ScaffoldMessenger.of(context)
          //       //           .showSnackBar(
          //       //
          //       //         SnackBar(
          //       //           behavior:
          //       //           SnackBarBehavior.floating,
          //       //
          //       //           backgroundColor:
          //       //           Colors.red.shade600,
          //       //
          //       //           margin:
          //       //           const EdgeInsets.all(15),
          //       //
          //       //           shape:
          //       //           RoundedRectangleBorder(
          //       //             borderRadius:
          //       //             BorderRadius.circular(15),
          //       //           ),
          //       //
          //       //           content: Text(
          //       //             "Error ${response.statusCode}\n${response.body}",
          //       //             style: const TextStyle(
          //       //               color: Colors.white,
          //       //             ),
          //       //           ),
          //       //         ),
          //       //       );
          //       //     }
          //       //
          //       //   } catch (e) {
          //       //
          //       //     Navigator.pop(context);
          //       //
          //       //     debugPrint(
          //       //         "EXCEPTION => $e");
          //       //
          //       //     ScaffoldMessenger.of(context)
          //       //         .showSnackBar(
          //       //
          //       //       SnackBar(
          //       //         behavior:
          //       //         SnackBarBehavior.floating,
          //       //
          //       //         backgroundColor:
          //       //         Colors.red.shade600,
          //       //
          //       //         margin:
          //       //         const EdgeInsets.all(15),
          //       //
          //       //         shape:
          //       //         RoundedRectangleBorder(
          //       //           borderRadius:
          //       //           BorderRadius.circular(15),
          //       //         ),
          //       //
          //       //         content: Row(
          //       //           children: [
          //       //
          //       //             const Icon(
          //       //               Icons.error_outline,
          //       //               color: Colors.white,
          //       //             ),
          //       //
          //       //             const SizedBox(width: 10),
          //       //
          //       //             Expanded(
          //       //               child: Text(
          //       //                 e.toString(),
          //       //                 style: const TextStyle(
          //       //                   color: Colors.white,
          //       //                 ),
          //       //               ),
          //       //             )
          //       //
          //       //           ],
          //       //         ),
          //       //       ),
          //       //     );
          //       //   }
          //       // },
          //       onPressed: () {
          //         List<OrderCompositionModel> selectedItems = data
          //             .where((e) => e.selected)
          //             .toList();
          //
          //         if (selectedItems.isEmpty) {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             SnackBar(
          //               backgroundColor: Colors.red,
          //               content: Text("Select item first"),
          //             ),
          //           );
          //
          //           return;
          //         }
          //
          //         Navigator.push(
          //           context,
          //
          //           MaterialPageRoute(
          //             builder: (_) => SelectedOrderScreen(
          //               orderType: orderComponent,
          //               selectedItems: selectedItems,
          //             ),
          //           ),
          //         );
          //       },
          //       child: const Text(
          //         "NEXT →",
          //
          //         style: TextStyle(
          //           color: Colors.white,
          //
          //           fontWeight: FontWeight.bold,
          //
          //           letterSpacing: 1,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                // =========================
                // COMPLETE
                // =========================
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: completeSelectedItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE8F5E9),
                        foregroundColor: const Color(0xff2E7D32),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xffA5D6A7),
                            width: 1,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 19,
                      ),
                      label: const Text(
                        "COMPLETE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // =========================
                // NEXT
                // =========================
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final selectedItems = data
                            .where((e) => e.selected)
                            .toList();

                        if (selectedItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.blue.shade500,
                              margin: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Select item first",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectedOrderScreen(
                              orderType: orderComponent,
                              selectedItems: selectedItems,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFF3E0),
                        foregroundColor: const Color(0xffE65100),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xffFFCC80),
                            width: 1,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                      ),
                      label: const Text(
                        "NEXT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: 50,

      decoration: const BoxDecoration(
        color: C.brand50,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),

          topRight: Radius.circular(16),
        ),
      ),

      child: Row(
        children: [
          head("✓", selectW),
          head("BOM", bomW),
          head("COMPONENT", componentW),
          head("FABRIC", fabricW),
          head("Order MTR", w),
          head("Order KG", w),
          head("ID", w),
          head("PO", w),
          head("ARTICLE", w),
        ],
      ),
    );
  }

  Widget head(String text, double width) {
    return SizedBox(
      width: width,

      child: Center(
        child: Text(
          text,

          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget tableRow(OrderCompositionModel item, int index) {
    return Container(
      height: 55,
      color: index.isEven ? Colors.white : const Color(0xffF8FAFD),

      child: Row(
        children: [
          SizedBox(
            width: selectW,
            child: Checkbox(
              // value: data[index].selected,
              value: item.selected,
              activeColor: C.success,

              onChanged: (bool? value) {
                setState(() {
                  if (orderComponent == "SINGLE") {
                    // Clear all selections
                    for (var element in data) {
                      element.selected = false;
                    }

                    // Select only clicked filtered item
                    item.selected = value ?? false;
                  } else {
                    // Multiple selection in CLUB
                    item.selected = value ?? false;
                  }
                });
              },
            ),
          ),

          cell(item.woNumber, bomW),

          cell(item.component, componentW),

          cell(item.fabricCode, fabricW),

          cell(item.orderRequiredMtr, w),

          cell(item.orderRequiredKg, w),

          cell(item.idForWo, w),

          cell(item.poNum, w),

          cell(item.articleNum, w),
        ],
      ),
    );
  }

  Widget cell(String text, double width) {
    return SizedBox(
      width: width,

      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),

          child: Text(
            text,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

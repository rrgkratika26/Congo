import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class LedgerInQtyScreen extends StatefulWidget {
  final String fabricCode;
  final String date;

  const LedgerInQtyScreen({
    super.key,
    required this.fabricCode,
    required this.date,
  });

  @override
  State<LedgerInQtyScreen> createState() =>
      _LedgerInQtyScreenState();
}

class _LedgerInQtyScreenState
    extends State<LedgerInQtyScreen> {

  bool _loading = true;
  String _error = '';

  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchInQty();
  }

  Future<void> _fetchInQty() async {

    try {

      final data =
      await NaradanaApiService().fetchInQty(

        fabricCode: widget.fabricCode,

        fromDate: widget.date,

        toDate: widget.date,
      );

      setState(() {

        _data = data;

        _loading = false;

      });

    } catch (e) {

      setState(() {

        _error = e.toString();

        _loading = false;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              "IN Qty Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            Text(
              widget.fabricCode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        iconTheme:
        const IconThemeData(color: Colors.white),
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : _error.isNotEmpty
          ? Center(
        child: Text(_error),
      )

          : _data.isEmpty
          ? const Center(
        child: Text("No Data Found"),
      )

          : ListView.builder(
        padding: const EdgeInsets.all(12),

        itemCount: _data.length,

        itemBuilder: (context, index) {

          final r = _data[index];

          return Container(
            margin:
            const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [

                // HEADER
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: const BoxDecoration(
                    color: C.primary,

                    borderRadius:
                    BorderRadius.only(
                      topLeft:
                      Radius.circular(18),
                      topRight:
                      Radius.circular(18),
                    ),
                  ),

                  child: Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                        Colors.white,

                        child: Text(
                          "${index + 1}",
                          style:
                          const TextStyle(
                            color:
                            C.primary,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              r["rolL_CODE"]
                                  ?.toString() ??
                                  "-",

                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              r["partyname"]
                                  ?.toString() ??
                                  "-",

                              style:
                              const TextStyle(
                                color:
                                Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY
                Padding(
                  padding:
                  const EdgeInsets.all(14),

                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children: [

                      _field(
                        "Barcode",
                        r["barcode"]
                            ?.toString(),
                      ),

                      _field(
                        "Lot No",
                        r["loT_NO"]
                            ?.toString(),
                      ),

                      _field(
                        "Weight KG",
                        r["rolL_WEIGHT_KG"]
                            ?.toString(),
                      ),

                      _field(
                        "Length MTR",
                        r["rolL_LENGTH_MTR"]
                            ?.toString(),
                      ),

                      _field(
                        "Supervisor",
                        r["supervisoR_NAME"]
                            ?.toString(),
                      ),

                      _field(
                        "Operator",
                        r["operatoR_NAME"]
                            ?.toString(),
                      ),

                      _field(
                        "Machine No",
                        r["machinE_NO"]
                            ?.toString(),
                      ),

                      _field(
                        "Color",
                        r["color"]
                            ?.toString(),
                      ),

                      _field(
                        "Department",
                        r["department"]
                            ?.toString(),
                      ),

                      _field(
                        "Date",
                        r["date"]
                            ?.toString()
                            .split("T")
                            .first,
                      ),

                      _field(
                        "Time",
                        r["time"]
                            ?.toString(),
                      ),

                      _field(
                        "Week No",
                        r["weeK_NO"]
                            ?.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(
      String title,
      String? value,
      ) {

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xffF8FAFD),
        borderRadius:
        BorderRadius.circular(12),

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

            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value == null || value.isEmpty
                ? "-"
                : value,

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
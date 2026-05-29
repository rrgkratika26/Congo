import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'PrintBarcode.dart';

class RollLabelPreview extends StatelessWidget {
  final BaseRollData data;
  const RollLabelPreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380), // width bhi thoda kam
      padding: const EdgeInsets.all(10), // ⬅ reduced
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ⬅ important
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  data.machineLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                "ROLL:${data.rollNo}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Body (no IntrinsicHeight)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv("GSM", data.gsm),
                    _kv("Party", data.partyName),
                    _kv("WO", data.woNo),
                    _kv("Date", data.date),
                    const SizedBox(height: 6),

                    // Smaller QR
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Icon(Icons.qr_code, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv("SIZE", data.size),
                  _kv("MESH", data.mesh),
                  _kv("GW", data.gwKg),
                  _kv("TR", data.trKg),
                  _kv("NET", data.netKg),
                  _kv("MTR", data.mtr),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Operators
          if (data.operators.isNotEmpty)
            Text(
              data.operators,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),

          const SizedBox(height: 4),

          // Bottom Row
          Row(
            children: [
              Text(
                data.barcodeId,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  data.fabricCode,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF6B7A9F)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Text(
                data.labelType,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 2), // ⬅ reduced
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10, color: Color(0xFF1A2340)),
        children: [
          TextSpan(
            text: "$k:",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: v),
        ],
      ),
    ),
  );
}
abstract class BaseRollData {
  String get rollNo;
  String get machineLabel;
  String get gsm;
  String get size;
  String get partyName;
  String get woNo;
  String get date;
  String get mesh;
  String get gwKg;
  String get trKg;
  String get netKg;
  String get mtr;
  String get operators;
  String get barcodeId;
  String get fabricCode;
  String get labelType;
}
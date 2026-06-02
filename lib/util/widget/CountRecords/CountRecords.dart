import 'package:flutter/material.dart';

import '../../../Color/Colorclass.dart';

/// ======================================================
/// SIMPLE COUNT TEXT CLASS
/// ======================================================
class CountText extends StatelessWidget {
  final int count;

  const CountText({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: Text(
          " $count Records",
          style: const TextStyle(
            color: C.bg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


// ====================== CREATE NEW FILE ======================
// report_total_helper.dart

class ReportTotalHelper {
  /// Total Net Weight
  static double totalNetWeight<T>(
      List<T> data,
      double Function(T item) selector,
      ) {
    return data.fold(
      0.0,
          (sum, item) => sum + selector(item),
    );
  }

  /// Total Roll Length
  static double totalRollLength<T>(
      List<T> data,
      double Function(T item) selector,
      ) {
    return data.fold(
      0.0,
          (sum, item) => sum + selector(item),
    );
  }

  /// Record Count
  static int totalRecords<T>(List<T> data) {
    return data.length;
  }
}



//
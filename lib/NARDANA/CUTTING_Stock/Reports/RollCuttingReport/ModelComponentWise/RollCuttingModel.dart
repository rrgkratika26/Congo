import 'package:intl/intl.dart';

class RollCuttingReportModel {
  final DateTime todayDate;
  final double totalWeight;
  final double totalWastage;

  const RollCuttingReportModel({
    required this.todayDate,
    required this.totalWeight,
    required this.totalWastage,
  });

  factory RollCuttingReportModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RollCuttingReportModel(
      todayDate: _parseDate(json['todayDate']),
      totalWeight: _toDouble(json['totalWeight']),
      totalWastage: _toDouble(json['totalWastage']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().replaceAll(',', ''),
    ) ??
        0.0;
  }

  String get formattedDate {
    return DateFormat('dd-MM-yyyy').format(todayDate);
  }

  String get dayName {
    return DateFormat('EEE').format(todayDate);
  }

  String get searchText {
    return [
      formattedDate,
      DateFormat('yyyy-MM-dd').format(todayDate),
      DateFormat('yyyy/MM/dd').format(todayDate),
      dayName,
      totalWeight.toString(),
      totalWastage.toString(),
    ].join(' ').toLowerCase();
  }

  // double get wastagePercentage {
  //   if (totalWeight <= 0) {
  //     return 0;
  //   }
  //
  //   return (totalWastage / totalWeight) * 100;
  // }
}
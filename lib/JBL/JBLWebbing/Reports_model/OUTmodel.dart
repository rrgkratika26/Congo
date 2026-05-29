

import '../../JBL_Cutting/ModelClass/CuttinfType.dart';
class WebbingOutModel extends BaseModel {
  final int srNo;
  final String rollCode; // ✅ changed to String
  final String lotNo;
  final String code;
  final String fabricCode;
  final String operator;
  final DateTime date;
  final String time;
  final String machine;
  final String modelNo;
  final double netWeight;
  final double quantity;
  final String location;

  WebbingOutModel.fromJson(Map<String, dynamic> json)
      : srNo = json['Sr. No.'] ?? 0,
        rollCode = json['ROLL CODE']?.toString() ?? '', // ✅ safe
        lotNo = json['LOTNO'] ?? '',
        code = json['CODE'] ?? '',
        fabricCode = json['FABRIC_CODE'] ?? '',
        operator = json['OPERATOR'] ?? '',
        date = DateTime.tryParse(json['Date'] ?? '') ?? DateTime.now(),
        time = json['Time'] ?? '',
        machine = json['MACHINE'] ?? '',
        modelNo = json['MODELNO'] ?? '',
        netWeight = (json['NETWT'] ?? 0).toDouble(),
        quantity = (json['QUANTITY'] ?? 0).toDouble(),
        location = json['Location'] ?? '';

  @override
  Map<String, dynamic> toJson() {
    return {
      'Sr No': srNo,
      'Roll Code': rollCode,
      'Lot No': lotNo,
      'Code': code,
      'Fabric': fabricCode,
      'Operator': operator,
      'Date': date.toString(),
      'Time': time,
      'Machine': machine,
      'Model No': modelNo,
      'Net Weight': netWeight,
      'Quantity': quantity,
      'Location': location,
    };
  }
}
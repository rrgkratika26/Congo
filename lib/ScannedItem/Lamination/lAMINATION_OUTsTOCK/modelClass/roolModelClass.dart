import '../../../../Visa/Loom/PrintPreview.dart';

class LaminationRollData implements BaseRollData {
  final String rollNo;
  final String machineLabel;
  final String gsm;
  final String size;
  final String partyName;
  final String woNo;
  final String date;
  final String mesh;
  final String gwKg;
  final String trKg;
  final String netKg;
  final String mtr;
  final String avgWt;

  final String operators;
  final String barcodeId;
  final String fabricCode;
  final String labelType;

  final String color;
  final String laminationType;
  final String supervisor;

  const LaminationRollData({
    required this.rollNo,
    required this.machineLabel,
    required this.gsm,
    required this.size,
    required this.partyName,
    required this.woNo,
    required this.date,
    required this.mesh,
    required this.gwKg,
    required this.trKg,
    required this.netKg,
    required this.mtr,
    required this.operators,
    required this.barcodeId,
    required this.fabricCode,
    required this.labelType,
    required this.color,
    required this.laminationType,
    required this.supervisor, required this.avgWt,
  });

  factory LaminationRollData.fromMap(Map<String, dynamic> m) {
    return LaminationRollData(
      rollNo: m['rollCode']?.toString() ?? '',
      machineLabel: "LAMI",

      gsm: m['gsm']?.toString() ?? '',
      size: m['fabricWidth']?.toString() ?? '',
      partyName: m['partyName']?.toString() ?? '',
      woNo: m['workOrderNo']?.toString() ?? '',

      date: m['date']?.toString() ?? '',
      mesh: m['mesh']?.toString() ?? '',

      gwKg: m['grossWeight']?.toString() ?? '0',
      netKg: m['netWeight']?.toString() ?? '0',

      trKg: (
          (double.tryParse(m['grossWeight']?.toString() ?? '0') ?? 0) -
              (double.tryParse(m['netWeight']?.toString() ?? '0') ?? 0)
      ).toStringAsFixed(2),

      mtr: m['rollLength']?.toString() ?? '0',
      avgWt: m['avgWeight']?.toString() ?? '0',


      operators: m['operator']?.toString() ?? '',
      barcodeId: m['barcode']?.toString() ?? '',

      fabricCode: m['fabricCode']?.toString() ?? '',
      labelType: "LAMINATION",

      color: m['color']?.toString() ?? '',
      laminationType: m['laminationType']?.toString() ?? '',
      supervisor: m['supervisor']?.toString() ?? '',
    );
  }
}
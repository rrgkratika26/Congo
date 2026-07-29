// class BarcodeResponseModel {
//   final String? srno;
//   final String? entryout;
//   final String partyname;
//   final String? barcode;
//   final String? status; // Bag type / status
//   final String? remark; // Qty
//   final String? activein; // NWT
//   final String? activeout; // GWT
//   final String? department; // Bag size
//   final bool found;
//   final String? message;
//
//   BarcodeResponseModel({
//     this.srno,
//     this.entryout,
//     required this.partyname,
//     this.barcode,
//     this.status,
//     this.remark,
//     this.activein,
//     this.activeout,
//     this.department,
//     required this.found,
//     this.message,
//   });
//
//   factory BarcodeResponseModel.fromJson(Map<String, dynamic> json) {
//     return BarcodeResponseModel(
//       srno: json["srno"]?.toString(),
//       entryout: json["entryout"]?.toString(),
//       partyname: json['partyname']!.toString(),
//
//       barcode: json["barcode"]?.toString(),
//       status: json["status"]?.toString(),
//       remark: json["remark"]?.toString(),
//       activein: json["activein"]?.toString(),
//       activeout: json["activeout"]?.toString(),
//       department: json["department"]?.toString(),
//       found: json["found"] == true,
//       message: json["message"]?.toString(),
//     );
//   }
// }


class BarcodeResponseModel {
  final String srno;
  final int id;
  final String entryout;
  final String barcode;
  final String status;
  final String remark;
  final String activein;
  final String partyname;
  final String department;
  final String? activeout;
  final bool found;
  final String? message;

  BarcodeResponseModel({
    required this.srno,
    required this.entryout,
    required this.barcode,
    required this.status,
    required this.remark,
    required this.activein,
    required this.partyname,
    required this.department,
    required this.activeout,
    required this.found,
    this.message, required this.id,
  });

  factory BarcodeResponseModel.fromJson(Map<String, dynamic> json) {
    return BarcodeResponseModel(
      srno: json['srno'] ?? '',
      entryout: json['entryout'] ?? '',
      barcode: json['barcode'] ?? '',
      status: json['status'] ?? '',
      remark: json['remark'] ?? '',
      activein: json['activein'] ?? '',
      partyname: json['partyname'] ?? '',
      department: json['department'] ?? '',
      activeout: json['activeout'] ?? '',
      found: json['found'] ?? false,
      message: json['message'],
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    );
  }
}

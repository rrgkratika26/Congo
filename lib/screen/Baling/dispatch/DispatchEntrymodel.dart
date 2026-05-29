class DispatchEntry {
  final String srNo;
  final String barcode;
  final String entryOut;
  final String status;
  final String remark;
  final String activeIn;
  final String partyName;
  final String department;
  final String activeOut;

  DispatchEntry({
    required this.srNo,
    required this.barcode,
    required this.entryOut,
    required this.status,
    required this.remark,
    required this.activeIn,
    required this.partyName,
    required this.department,
    required this.activeOut,
  });

  Map<String, dynamic> toJson() => {
    "srNo": srNo,
    "barcode": barcode,
    "entryOut": entryOut,
    "status": status,
    "remark": remark,
    "activeIn": activeIn,
    "partyName": partyName,
    "department": department,
    "activeOut": activeOut,
  };
}
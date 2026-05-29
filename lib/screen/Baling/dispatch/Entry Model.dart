class EntryModel {
  String srNo;
  String barcode;
  String entryOut;
  String status;
  String remark;
  String activeIn;
  String partyName;
  String department;
  String activeOut;

  EntryModel({
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

  Map<String, dynamic> toJson() {
    return {
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
}
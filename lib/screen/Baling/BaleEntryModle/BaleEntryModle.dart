import 'BaleEntryROwModle.dart';

class BaleEntryModel {
  String srNo;
  String partyName;
  String bomNo;
  String supervisor;
  String checkedBy;
  String submittedBy;
  String articleNo;
  String poNumber;
  String shift;
  bool withoutM;
  int status;
  int remark;
  int activeIn;
  double activeOut;

  List<BaleEntryRowModel> rows;

  BaleEntryModel({
    required this.srNo,
    required this.partyName,
    required this.bomNo,
    required this.supervisor,
    required this.checkedBy,
    required this.submittedBy,
    required this.articleNo,
    required this.poNumber,
    required this.shift,
    required this.withoutM,
    required this.status,
    required this.remark,
    required this.activeIn,
    required this.activeOut,
    required this.rows,
  });

  Map<String, dynamic> toJson() {
    return {
      "srNo": srNo,
      "partyName": partyName,
      "bomNo": bomNo,
      "supervisor": supervisor,
      "checkedBy": checkedBy,
      "submittedBy": submittedBy,
      "articleNo": articleNo,
      "poNumber": poNumber,
      "shift": shift,
      "withoutM": withoutM,
      "status": status,
      "remark": remark,
      "activeIn": activeIn,
      "activeOut": activeOut,
      "rows": rows.map((e) => e.toJson()).toList(),
    };
  }
}
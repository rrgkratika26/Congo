class PrintingIssueSaveRequest {
  final String partyName;
  final String bomNo;
  final String component;
  final double cutLength;
  final double cutWidth;
  final int pcs;
  final double netWt;
  final double weightPerPcs;
  final String issueTo;

  PrintingIssueSaveRequest({
    required this.partyName,
    required this.bomNo,
    required this.component,
    required this.cutLength,
    required this.cutWidth,
    required this.pcs,
    required this.netWt,
    required this.weightPerPcs,
    required this.issueTo,
  });

  Map<String, dynamic> toJson() {
    return {
      "partyName": partyName,
      "bomNo": bomNo,
      "component": component,
      "cutLength": cutLength,
      "cutWidth": cutWidth,
      "pcs": pcs,
      "netWt": netWt,
      "weightPerPcs": weightPerPcs,
      "issueTo": issueTo,
    };
  }
}

class PrintingIssueSaveResponse {
  final bool success;
  final String message;
  final bool data;

  PrintingIssueSaveResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PrintingIssueSaveResponse.fromJson(Map<String, dynamic> json) {
    return PrintingIssueSaveResponse(
      success: json["success"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] == true,
    );
  }
}
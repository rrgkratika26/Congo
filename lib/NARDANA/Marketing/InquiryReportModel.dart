class InquiryReportModel {
  final String customerName;
  final String date;
  final String inquiryNoMain;
  final String employee;
  final String bagType;
  final String articleNo;
  final String fgNonFg;

  final String wo;
  final String woDate;
  final String woEmployee;

  final String srWoNum;
  final String srWoDate;
  final String srWoUserName;

  final String issueToQc;
  final String issuePerson;

  final String bomDate;
  final String bomToProduction;

  final String issueToSample;
  final String samplePerson;
  final String sampleProcessingDate;

  final String complaint;
  final String poNum;

  final String statusReason;
  final String inquiryNo;
  final String inquiryNo2;

  final String active;
  final String status;

  InquiryReportModel({
    required this.customerName,
    required this.date,
    required this.inquiryNoMain,
    required this.employee,
    required this.bagType,
    required this.articleNo,
    required this.fgNonFg,
    required this.wo,
    required this.woDate,
    required this.woEmployee,
    required this.srWoNum,
    required this.srWoDate,
    required this.srWoUserName,
    required this.issueToQc,
    required this.issuePerson,
    required this.bomDate,
    required this.bomToProduction,
    required this.issueToSample,
    required this.samplePerson,
    required this.sampleProcessingDate,
    required this.complaint,
    required this.poNum,
    required this.statusReason,
    required this.inquiryNo,
    required this.inquiryNo2,
    required this.active,
    required this.status,
  });

  factory InquiryReportModel.fromJson(
      Map<String,dynamic> json) {

    return InquiryReportModel(
      customerName: json["customeR_NAME"] ?? "",
      date: json["date"] ?? "",
      inquiryNoMain: json["inquirY_NO_main"] ?? "",
      employee: json["employee"] ?? "",
      bagType: json["baG_TYPE"] ?? "",
      articleNo: json["articlE_NO"] ?? "",
      fgNonFg: json["fG_NON_FG"] ?? "",

      wo: json["wo"] ?? "",
      woDate: json["wO_DATE"] ?? "",
      woEmployee: json["wO_EMPLOYEE"] ?? "",

      srWoNum: json["sR_WO_NUM"] ?? "",
      srWoDate: json["sR_WO_DATE"] ?? "",
      srWoUserName: json["sR_WO_USER_NAME"] ?? "",

      issueToQc: json["issuE_TO_QC"] ?? "",
      issuePerson: json["issuE_PERSON"] ?? "",

      bomDate: json["boM_DATE"] ?? "",
      bomToProduction: json["boM_TO_PRODUCTION"] ?? "",

      issueToSample: json["issuE_TO_SAMPLE"] ?? "",
      samplePerson: json["samplE_PERSON"] ?? "",
      sampleProcessingDate:
      json["samplE_PROCESSING_DATE"] ?? "",

      complaint: json["complain"] ?? "",
      poNum: json["po_num"] ?? "",

      statusReason: json["statuS_REASON"] ?? "",
      inquiryNo: json["inquirY_NO"] ?? "",
      inquiryNo2: json["inquirY_NO2"] ?? "",

      active: json["active"] ?? "",
      status: json["status"] ?? "",
    );
  }
}
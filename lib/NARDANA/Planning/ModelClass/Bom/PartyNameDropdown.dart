// class InquiryModel {
//   final String generatedInquiry;
//
//   InquiryModel({
//     required this.generatedInquiry,
//   });
//
//   factory InquiryModel.fromJson(Map<String, dynamic> json) {
//     return InquiryModel(
//       generatedInquiry: json['generateD_INQUIRY']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'generateD_INQUIRY': generatedInquiry,
//     };
//   }
//
//   @override
//   String toString() => generatedInquiry;
// }



class InquiryModel {
  final String generatedInquiry;
  final List<String> customerNames;

  InquiryModel({
    required this.generatedInquiry,
    required this.customerNames,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      generatedInquiry: json['generateD_INQUIRY']?.toString() ?? '',
      customerNames: (json['customerNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generateD_INQUIRY': generatedInquiry,
      'customerNames': customerNames,
    };
  }

  @override
  String toString() => generatedInquiry;
}
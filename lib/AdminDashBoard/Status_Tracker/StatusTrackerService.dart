// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import 'StatusTrackerModel.dart';
//
// class StatusTrackerService {
//   // ==========================================================
//   // BASE URL
//   // ==========================================================
//
//   static const String baseUrl = 'http://localhost:7165/api';
//
//   // ==========================================================
//   // TRACK ORDER
//   // ==========================================================
//
//   static Future<TrackingResponse> trackOrder(
//       String inquiryNo,
//       ) async {
//     final url = Uri.parse(
//       '$baseUrl/Marketing/track/${Uri.encodeComponent(inquiryNo)}',
//     );
//
//     print('==============================================');
//     print('TRACK ORDER API');
//     print('URL: $url');
//     print('METHOD: GET');
//     print('INQUIRY: $inquiryNo');
//     print('==============================================');
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//
//       print('STATUS CODE: ${response.statusCode}');
//       print('RESPONSE BODY: ${response.body}');
//
//       if (response.statusCode >= 200 &&
//           response.statusCode < 300) {
//         final decoded = jsonDecode(response.body);
//
//         return TrackingResponse.fromJson(
//           decoded as Map<String, dynamic>,
//         );
//       }
//
//       throw Exception(
//         'API failed with status ${response.statusCode}',
//       );
//     } catch (e) {
//       print('TRACK ORDER ERROR: $e');
//
//       rethrow;
//     }
//   }
// }
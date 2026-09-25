import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:IMS/screen/Printing/ModelClass/scanReportModel.dart';
import 'package:IMS/screen/Printing/PrintingRecieve/PrintingIssueList.dart';
import 'package:IMS/screen/Printing/PrintingRecieve/PrintingRecieveList.dart';
import 'package:IMS/screen/Printing/PrintingRecieve/REcieveModel.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../AdminDashBoard/Status_Tracker/StatusTrackerModel.dart';
import '../../screen/Printing/ModelClass/IssuesaveRequest.dart';
import '../../screen/Printing/PrintingRecieve/IssueReportModel.dart';

class StatusTrackerService {
  static const String _baseUrl = 'http://190.92.175.47:80/Nardana/api';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,


    ),
  );

  // ----------------------------------------------------------
  // COMMON GET
  // ----------------------------------------------------------

  static Future<dynamic> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: await InStockService.authHeaders()),
      );

      debugPrint('GET: ${response.realUri}');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      debugPrint('GET ERROR: ${e.message}');
      throw Exception(_errorMessage(e));
    }
  }

  // ----------------------------------------------------------
  // COMMON POST
  // ----------------------------------------------------------

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(headers: await InStockService.authHeaders()),
      );

      debugPrint('POST: ${response.realUri}');
      debugPrint('BODY: $body');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      debugPrint('POST ERROR: ${e.message}');
      throw Exception(_errorMessage(e));
    }
  }

  static String _errorMessage(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message']?.toString() ?? 'Something went wrong';
    }

    return e.message ?? 'Network error';
  }

  // ==========================================================
  // STATUS TRACKER
  // ==========================================================

  static Future<List<OrderStatusItem>> getOrders({
    required DateTime fromDate,
    required DateTime toDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final data = await _get(
      '/Marketing/order-status',
      query: {
        'fromDate': _date(fromDate),
        'toDate': _date(toDate),
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },

    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch orders');
    }

    return (data['data'] as List? ?? [])
        .map((e) => OrderStatusItem.fromJson(e))
        .toList();
  }

  // ==========================================================
  // TRACK ORDER
  // ==========================================================

  static Future<TrackingResponse> trackOrder(String inquiryNo) async {
    final data = await _get(
      '/Marketing/track/${Uri.encodeComponent(inquiryNo.trim())}',
    );

    return TrackingResponse.fromJson(data);
  }

  // ==========================================================
  // PRINTING RECEIVE LIST
  // ==========================================================

  static Future<List<PrintingReceiveModel>> fetchPrintingReceive() async {
    final data = await _get('/Printing/PrintingReceive');

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Unable to fetch printing receive data',
      );
    }

    return (data['data'] as List? ?? [])
        .map((e) => PrintingReceiveModel.fromJson(e))
        .toList();
  }

  // ==========================================================
  // PRINTING RECEIVE
  // ==========================================================

  static Future<Map<String, dynamic>> receivePrinting({
    required int transactionId,
    required String partyName,
    required String bomNo,
    required String component,
    required double cutLength,
    required double cutWidth,
    required double pcs,
    required double netWt,
    required double weightPerPcs,
  }) async {
    final body = {
      'transactionId': transactionId,
      'partyName': partyName,
      'bomNo': bomNo,
      'component': component,
      'cutLength': cutLength,
      'cutWidth': cutWidth,
      'pcs': pcs,
      'netWt': netWt,
      'weightPerPcs': weightPerPcs,
    };


    final data = await _post('/Printing/receive', body);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Printing receive failed');
    }

    return Map<String, dynamic>.from(data);
  }

  // ==========================================================
  // PRINTING RECEIVE REPORT
  // ==========================================================

  static Future<List<receiveReportModel>> fetchPrintingReceiveReport({
    required DateTime fromDate,
    required DateTime toDate,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final data = await _get(
      '/Printing/ReceiveReport',
      query: {
        'fromDate': _date(fromDate),
        'toDate': _date(toDate),
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to fetch printing receive report',
      );
    }

    return (data['data'] as List? ?? [])
        .map((e) => receiveReportModel.fromJson(e))
        .toList();
  }

  // ==========================================================
  // PRINTING ISSUE
  // ==========================================================
  static Future<List<PrintingIssueModel>> fetchPrintingIssue() async {
    final data = await _get('/Printing/PrintingIssueList');

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'Failed to fetch printing issue data',
      );
    }

    return (data['data'] as List? ?? [])
        .map((e) => PrintingIssueModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  static Future<PrintingIssueSaveResponse> savePrintingIssue({
    required String partyName,
    required String bomNo,
    required String component,
    required double cutLength,
    required double cutWidth,
    required int pcs,
    required double netWt,
    required double weightPerPcs,
    required String issueTo,
  }) async {
    final request = PrintingIssueSaveRequest(
      partyName: partyName,
      bomNo: bomNo,
      component: component,
      cutLength: cutLength,
      cutWidth: cutWidth,
      pcs: pcs,
      netWt: netWt,
      weightPerPcs: weightPerPcs,
      issueTo: issueTo,
    );

    const endpoint = '/Printing/SavePrintingIssue';

    debugPrint('====================================');
    debugPrint('SAVE PRINTING ISSUE REQUEST');
    debugPrint('====================================');
    debugPrint('BASE URL: ${_dio.options.baseUrl}');
    debugPrint('ENDPOINT: $endpoint');
    debugPrint('FULL URL: ${_dio.options.baseUrl}$endpoint');
    debugPrint('BODY: ${request.toJson()}');

    try {
      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(headers: await InStockService.authHeaders()),

      );

      debugPrint('====================================');
      debugPrint('SAVE PRINTING ISSUE RESPONSE');
      debugPrint('====================================');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.data}');

      return PrintingIssueSaveResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      debugPrint('====================================');
      debugPrint('PRINTING ISSUE API ERROR');
      debugPrint('====================================');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');
      debugPrint('REQUEST URL: ${e.requestOptions.uri}');
      debugPrint('REQUEST METHOD: ${e.requestOptions.method}');
      debugPrint('REQUEST DATA: ${e.requestOptions.data}');
      debugPrint('RESPONSE DATA: ${e.response?.data}');
      debugPrint('ERROR: $e');

      rethrow;
    } catch (e) {
      debugPrint('UNKNOWN ERROR: $e');
      rethrow;
    }
  }

  static Future<List<PrintingIssueReportModel>> fetchPrintingIssueReport({
    required DateTime fromDate,
    required DateTime toDate,
    required int pageNumber,
    required int pageSize,
  }) async {
    String fmt(DateTime d) =>
        '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

    // adjust base client/instance to match your existing pattern
    final response = await _dio.get(
      '/Printing/PrintingIssueReport',

      queryParameters: {
        'fromDate': fmt(fromDate),
        'toDate': fmt(toDate),
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
      options: Options(headers: await InStockService.authHeaders()),
      
    );

    final body = Map<String, dynamic>.from(response.data);
    debugPrint('STATUS CODE: ${response?.statusCode}');
    debugPrint('REQUEST URL: ${response.requestOptions.uri}');
    debugPrint('REQUEST METHOD: ${response.requestOptions.method}');

    if (body['success'] != true) {

      throw Exception(body['message']?.toString() ?? 'Failed to fetch report');
    }

    final List<dynamic> list = body['data'] ?? [];
    return list
        .map(
          (e) =>
              PrintingIssueReportModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  static String _date(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // OPTIONAL GETX ERROR
  // ==========================================================

  static void showError(Object e) {
    Get.snackbar(
      'Error',
      e.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}

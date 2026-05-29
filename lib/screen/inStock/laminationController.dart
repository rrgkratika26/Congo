// import 'package:flutter/foundation.dart';
// import '../../services/getSupervisors/getSupervisors.dart';
//
//
// class LaminationController {
//   final _service = InStockService();
//
//   String? selectedOperator;
//   String? selectedSupervisor;
//   String? selectedLocation;
//
//   List<String> operators = [];
//   List<String> supervisors = [];
//   List<String> locations = [];
//
//   Future<void> loadInitialData() async {
//     try {
//       operators = await _service.getLaminationOperators();
//       supervisors = await _service.getLaminationSupervisors();
//       locations = await _service.getLaminationLocations();
//     } catch (e) {
//       debugPrint('Lamination load error: $e');
//     }
//   }
//
//   bool isFormInvalid() {
//     return selectedOperator == null ||
//         selectedSupervisor == null ||
//         selectedLocation == null;
//   }
// }
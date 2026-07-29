// import 'package:flutter/cupertino.dart';
//
// import '../../../services/getSupervisors/getSupervisors.dart';
//
//
// class Laminationcontroller {
//   final InStockService _service = InStockService();
//
//   // ---------------- STATE ----------------
//   String? selectedOperator;
//   String? selectedSupervisor;
//   String? selectedLocation;
//
//   // ✅ DYNAMIC ROLL ENTRY
//   String? selectedRollEntry;
//
//   List<String> operators = [];
//   List<String> supervisors = [];
//   List<String> locations = [];
//   List<String> rollEntries = []; // or fetch from API
//
//   bool isLoading = false;
//
//   // ---------------- LOAD DATA ----------------
//   Future<void> loadInitialData() async {
//     isLoading = true;
//
//     try {
//       operators = await _service.getLaminationOperators();
//       supervisors = await _service.getLaminationSupervisors();
//       locations = await _service.getLaminationLocations();
//
//       selectedOperator = operators.isNotEmpty ? operators.first : null;
//       selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
//       selectedLocation = locations.isNotEmpty ? locations.first : null;
//       selectedRollEntry = rollEntries.isNotEmpty ? rollEntries.first : null;
//     } catch (e) {
//       debugPrint('Load initial data error: $e');
//     } finally {
//       isLoading = false;
//     }
//   }
//
//   // ---------------- VALIDATION ----------------
//   bool isFormValid() {
//     return selectedOperator != null &&
//         selectedSupervisor != null &&
//         selectedLocation != null &&
//         selectedRollEntry != null &&
//         selectedOperator!.isNotEmpty &&
//         selectedSupervisor!.isNotEmpty &&
//         selectedLocation!.isNotEmpty &&
//         selectedRollEntry!.isNotEmpty;
//   }
//   bool isFormInvalid() {
//     return selectedOperator == null ||
//         selectedSupervisor == null ||
//         selectedLocation == null;
//   }
// }




import 'package:flutter/material.dart';
import '../../../services/getSupervisors/getSupervisors.dart';

class Laminationcontroller extends ChangeNotifier {
  final InStockService _service = InStockService();

  // ---------------- STATE ----------------
  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;
  String? selectedRollEntry;

  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];
  List<String> rollEntries = [];

  bool isLoading = false;

  // ---------------- LOAD DATA ----------------
  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners(); // 🔥 refresh UI (loading start)

    try {
      operators = await _service.getLaminationOperators();
      supervisors = await _service.getLaminationSupervisors();
      locations = await _service.getLaminationLocations();

      selectedOperator = operators.isNotEmpty ? operators.first : null;
      selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
      selectedLocation = locations.isNotEmpty ? locations.first : null;

      // ❌ Don't set rollEntry here if empty
      selectedRollEntry = rollEntries.isNotEmpty ? rollEntries.first : null;

    } catch (e) {
      debugPrint('Load initial data error: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // 🔥 refresh UI (data loaded)
    }
  }

  // ---------------- UPDATE ROLL ENTRY ----------------
  void addRollEntry(String value) {
    if (!rollEntries.contains(value)) {
      rollEntries.add(value);
      selectedRollEntry = value;
      notifyListeners(); // 🔥 refresh UI after scan
    }
  }

  // ---------------- VALIDATION ----------------
  bool isFormValid() {
    return selectedOperator != null &&
        selectedSupervisor != null &&
        selectedLocation != null &&
        selectedRollEntry != null &&
        selectedOperator!.isNotEmpty &&
        selectedSupervisor!.isNotEmpty &&
        selectedLocation!.isNotEmpty &&
        selectedRollEntry!.isNotEmpty;
  }

  bool isFormInvalid() {
    return selectedOperator == null ||
        selectedSupervisor == null ||
        selectedLocation == null;
  }
}
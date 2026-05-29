import 'package:flutter/cupertino.dart';
import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';

class JBl_laminationController {
  final JblApiService _service = JblApiService(); // ✅ CHANGED

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

    try {
      // ✅ JBL APIs use karo
      operators = await _service.getLaminationOperators();
      supervisors = await _service.getLaminationSupervisors();
      // locations = await _service.getjblLocations();

      // agar roll entry API hai to use karo
      // rollEntries = await _service.getRollEntries();

      // ✅ DEFAULT SELECT
      selectedOperator = operators.isNotEmpty ? operators.first : null;
      selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
      // selectedLocation = locations.isNotEmpty ? locations.first : null;

      // fallback agar rollEntries empty ho
      selectedRollEntry = rollEntries.isNotEmpty
          ? rollEntries.first
          : 'LAMINATION';

    } catch (e) {
      debugPrint('❌ Load initial data error: $e');
    } finally {
      isLoading = false;
    }
  }

  // ---------------- VALIDATION ----------------
  bool isFormValid() {
    return selectedOperator != null && selectedSupervisor != null;
  }

  bool isFormInvalid() {
    return selectedOperator == null ||
        selectedSupervisor == null ||
        selectedLocation == null;
  }
}
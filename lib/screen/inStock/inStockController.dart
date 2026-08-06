import 'package:flutter/cupertino.dart';

import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/sharedpreference/shared_preference.dart';

class InStockController {
  final InStockService _service = InStockService();
  final JblApiService _jblService = JblApiService();

  // ---------------- STATE ----------------
  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;

  // ✅ DYNAMIC ROLL ENTRY
  String? selectedRollEntry;

  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];
  List<String> jbloperators = [];
  List<String> jblsupervisors = [];
  // List<String> jbl_locations = [];
  List<String> rollEntries = []; // or fetch from API

  bool isLoading = false;

  // ---------------- LOAD DATA ----------------
  Future<void> loadInitialData() async {
    isLoading = true;

    try {
      operators = await _service.getOperators();
      supervisors = await _service.getSupervisors();
      locations = await _service.getLocations();

      selectedOperator = operators.isNotEmpty ? operators.first : null;
      selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
      selectedLocation = locations.isNotEmpty ? locations.first : null;
      selectedRollEntry = rollEntries.isNotEmpty ? rollEntries.first : null;
    } catch (e) {
      debugPrint('Load initial data error: $e');
    } finally {
      isLoading = false;
    }
  }

  // ---------------- VALIDATION ----------------
  bool isFormValid() {
    return selectedOperator != null &&
        selectedSupervisor != null &&
        selectedLocation != null &&

        selectedOperator!.isNotEmpty &&
        selectedSupervisor!.isNotEmpty &&
        selectedLocation!.isNotEmpty;
  }
  //
  // Future<void> loadWebInitialData() async {
  //   final unit = await AppSession.getUnit();
  //   // other dropdown APIs if any
  //
  //   locations = await JblApiService.fetchWebbingLocations(plant: $unit);
  //   debugPrint("Locations: $locations");
  //
  // }

  // get_jblRmdOperators

  Future<void> load_JBl_InitialData() async {
    isLoading = true;

    try {
      jbloperators = await _jblService.get_jblRmdOperators();
      jblsupervisors = await _jblService.get_jblRmdSupervisors();

      // ✅ FIX: jbloperators aur jblsupervisors se set karo
      selectedOperator = jbloperators.isNotEmpty ? jbloperators.first : null;
      selectedSupervisor = jblsupervisors.isNotEmpty
          ? jblsupervisors.first
          : null;
    } catch (e) {
      debugPrint('Load initial data error: $e');
    } finally {
      isLoading = false;
    }
  }
}

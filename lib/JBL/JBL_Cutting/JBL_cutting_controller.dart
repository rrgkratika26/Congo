import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';

class JblCuttingController {
  final JblApiService _service = JblApiService();

  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;
  String? selectedRollEntry;

  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];
  List<String> rollEntries = ['JBL_CUTTING'];

  bool isLoading = false;

  // ---------- LOAD ----------
  Future<void> loadInitialData() async {
    isLoading = true;
    try {
      operators = await _service.getJblCuttingOperators();
      supervisors = await _service.getJblCuttingSupervisors();


      selectedOperator = operators.isNotEmpty ? operators.first : null;
      selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
      // selectedLocation = locations.isNotEmpty ? locations.first : null;
      selectedRollEntry = rollEntries.first;
    } catch (e) {
      print("JBL Cutting Load Error: $e");
    } finally {
      isLoading = false;
    }
  }

  // ---------- VALIDATION ----------
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

  bool isFormInvalid() => !isFormValid();
}
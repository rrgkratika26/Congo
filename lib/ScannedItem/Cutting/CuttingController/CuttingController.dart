
import '../../../services/getSupervisors/getSupervisors.dart';

class CuttingController {
  final InStockService _service = InStockService();

  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;
  String? selectedRollEntry; // ✅ ADDED

  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];
  List<String> rollEntries = ['CUTTING']; // optional

  bool isLoading = false;

  // ---------- LOAD ----------
  Future<void> loadInitialData() async {
    isLoading = true;
    try {
      operators = await _service.getCuttingOperators();
      supervisors = await _service.getCuttingSupervisors();
      locations = await _service.getCuttingLocations();

      selectedOperator = operators.isNotEmpty ? operators.first : null;
      selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
      selectedLocation = locations.isNotEmpty ? locations.first : null;
      selectedRollEntry = rollEntries.first;
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
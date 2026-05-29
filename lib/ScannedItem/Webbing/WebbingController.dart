import '../../services/getSupervisors/getSupervisors.dart';

class InStockWebController {
  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];

  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;

  Future<void> loadLookupData() async {
    final data = await InStockService.fetchWebbingOutLookup();

    if (data != null) {
      operators = data.operators;
      supervisors = data.supervisors;
      locations = data.locations;

      print("OUT OPERATORS: $operators");
      print("OUT SUPERVISORS: $supervisors");
      print("OUT LOCATIONS: $locations");
    }
  }
  Future<void> loadWebInitialData() async {
    final data = await InStockService.webbFetchDropdowns();

    if (data != null) {
      operators = data.operators;
      supervisors = data.supervisors;
      locations = data.locations;

      print("OPERATORS: $operators");
      print("SUPERVISORS: $supervisors");
      print("LOCATIONS: $locations");
    }
  }

  bool isFormValid() {
    return selectedOperator != null &&
        selectedSupervisor != null &&
        selectedLocation != null;
  }
}

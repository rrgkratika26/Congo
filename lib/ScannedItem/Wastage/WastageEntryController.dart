import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'WastageController.dart';



class WastageEntryController extends GetxController {
  // ----------------------------------------------------------
  // BASIC INFORMATION
  // ----------------------------------------------------------

  final String department;

  WastageEntryController({
    required this.department,
  });

  final isLoading = false.obs;

  final srNo = 1.obs;
  final date = DateTime.now().obs;

  // ----------------------------------------------------------
  // DROPDOWN LISTS
  // ----------------------------------------------------------

  final partyList = <String>[].obs;
  final poList = <String>[].obs;
  final articleList = <String>[].obs;
  final supervisorList = <String>[].obs;
  final wastageTypeList = <String>[].obs;
  final operatorList = <String>[].obs;
  final shiftList = <String>[].obs;
  final loomNoList = <String>[].obs;

  // ----------------------------------------------------------
  // SELECTED VALUES
  // ----------------------------------------------------------

  final selectedParty = Rxn<String>();
  final selectedPo = Rxn<String>();
  final selectedArticle = Rxn<String>();
  final selectedSupervisor = Rxn<String>();
  final selectedWastageType = Rxn<String>();
  final selectedOperator = Rxn<String>();
  final selectedShift = Rxn<String>();
  final selectedLoomNo = Rxn<String>();

  // ----------------------------------------------------------
  // TEXT FIELDS
  // ----------------------------------------------------------

  final weightCtrlText = ''.obs;
  final depositCtrlText = ''.obs;
  final remarkCtrlText = ''.obs;

  // ----------------------------------------------------------
  // ENTRIES
  // ----------------------------------------------------------

  final entries = <WastageEntryModel>[].obs;

  final selectedEntryId = RxnInt();

  // ----------------------------------------------------------
  // TOTALS
  // ----------------------------------------------------------

  double get totalWeight {
    return entries.fold(
      0.0,
          (sum, item) => sum + item.weight,
    );
  }

  double get totalDeposit {
    return entries.fold(
      0.0,
          (sum, item) => sum + item.depositQty,
    );
  }

  // ----------------------------------------------------------
  // SHOW LOOM NUMBER
  // ----------------------------------------------------------

  bool get showLoomNo {
    return department.toUpperCase() == 'LOOM' ||
        department.toUpperCase() == 'WEAVING';
  }

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    loadAll();
  }

  // ----------------------------------------------------------
  // LOAD ALL
  // ----------------------------------------------------------

  Future<void> loadAll() async {
    try {
      isLoading.value = true;

      await loadDropdowns();

      await loadEntries();

      calculateSrNo();
    } catch (e) {
      debugPrint('Wastage load error: $e');

      Get.snackbar(
        'Error',
        'Unable to load wastage data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // LOAD DROPDOWNS
  // ----------------------------------------------------------

  Future<void> loadDropdowns() async {
    // --------------------------------------------------------
    // TEMPORARY DATA
    //
    // Replace these with your API calls.
    // --------------------------------------------------------

    partyList.assignAll([
      'Party A',
      'Party B',
      'Party C',
      'Party D',
    ]);

    poList.assignAll([
      'PO-1001',
      'PO-1002',
      'PO-1003',
    ]);

    articleList.assignAll([
      'ARTICLE-001',
      'ARTICLE-002',
      'ARTICLE-003',
    ]);

    supervisorList.assignAll([
      'Supervisor 1',
      'Supervisor 2',
      'Supervisor 3',
    ]);

    wastageTypeList.assignAll([
      'Cutting Wastage',
      'Production Wastage',
      'Process Wastage',
      'Other',
    ]);

    operatorList.assignAll([
      'Operator 1',
      'Operator 2',
      'Operator 3',
    ]);

    shiftList.assignAll([
      'A',
      'B',
      'C',
    ]);

    loomNoList.assignAll([
      'Loom-01',
      'Loom-02',
      'Loom-03',
      'Loom-04',
      'Loom-05',
    ]);
  }

  // ----------------------------------------------------------
  // LOAD ENTRIES
  // ----------------------------------------------------------

  Future<void> loadEntries() async {
    // --------------------------------------------------------
    // TEMPORARY LOCAL DATA
    //
    // Replace with API response.
    // --------------------------------------------------------

    entries.assignAll([
      WastageEntryModel(
        id: 1,
        code: 1001,
        partyName: 'Party A',
        po: 'PO-1001',
        articleNo: 'ARTICLE-001',
        supervisor: 'Supervisor 1',
        wastageType: 'Cutting Wastage',
        operator: 'Operator 1',
        weight: 12.50,
        depositQty: 5.00,
        shift: 'A',
        loomNo: showLoomNo ? 'Loom-01' : null,
        remark: 'Test entry',
        date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        status: 'Saved',
      ),
    ]);
  }

  // ----------------------------------------------------------
  // NEW ENTRY
  // ----------------------------------------------------------

  void newEntry() {
    clearForm();

    selectedEntryId.value = null;

    srNo.value = entries.isEmpty ? 1 : entries.length + 1;

    date.value = DateTime.now();
  }

  // ----------------------------------------------------------
  // SAVE ENTRY
  // ----------------------------------------------------------

  Future<void> saveEntry() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      final weight =
          double.tryParse(weightCtrlText.value.trim()) ?? 0.0;

      final deposit =
          double.tryParse(depositCtrlText.value.trim()) ?? 0.0;

      // ------------------------------------------------------
      // UPDATE EXISTING ENTRY
      // ------------------------------------------------------

      if (selectedEntryId.value != null) {
        final index = entries.indexWhere(
              (e) => e.id == selectedEntryId.value,
        );

        if (index != -1) {
          final old = entries[index];

          entries[index] = old.copyWith(
            partyName: selectedParty.value,
            po: selectedPo.value,
            articleNo: selectedArticle.value,
            supervisor: selectedSupervisor.value,
            wastageType: selectedWastageType.value,
            operator: selectedOperator.value,
            weight: weight,
            depositQty: deposit,
            shift: selectedShift.value,
            loomNo: selectedLoomNo.value,
            remark: remarkCtrlText.value,
            status: 'Updated',
          );

          entries.refresh();

          Get.snackbar(
            'Success',
            'Wastage entry updated successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      // ------------------------------------------------------
      // NEW ENTRY
      // ------------------------------------------------------

      else {
        final nextId = entries.isEmpty
            ? 1
            : entries.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

        final nextCode = entries.isEmpty
            ? 1001
            : entries.map((e) => e.code).reduce((a, b) => a > b ? a : b) + 1;

        final newItem = WastageEntryModel(
          id: nextId,
          code: nextCode,
          partyName: selectedParty.value,
          po: selectedPo.value,
          articleNo: selectedArticle.value,
          supervisor: selectedSupervisor.value,
          wastageType: selectedWastageType.value,
          operator: selectedOperator.value,
          weight: weight,
          depositQty: deposit,
          shift: selectedShift.value,
          loomNo: selectedLoomNo.value,
          remark: remarkCtrlText.value,
          date: DateFormat('dd-MMM-yyyy').format(date.value),
          status: 'Saved',
        );

        entries.add(newItem);

        srNo.value = entries.length;

        Get.snackbar(
          'Success',
          'Wastage entry saved successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      calculateSrNo();

      clearForm();
    } catch (e) {
      debugPrint('Save wastage error: $e');

      Get.snackbar(
        'Error',
        'Unable to save wastage entry',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // DELETE ENTRY
  // ----------------------------------------------------------

  Future<void> deleteEntry() async {
    if (selectedEntryId.value == null) {
      Get.snackbar(
        'Delete',
        'Please select an entry first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final id = selectedEntryId.value!;

    final index = entries.indexWhere(
          (e) => e.id == id,
    );

    if (index == -1) {
      return;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this wastage entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    try {
      isLoading.value = true;

      // ------------------------------------------------------
      // CALL DELETE API HERE
      // ------------------------------------------------------

      entries.removeAt(index);

      selectedEntryId.value = null;

      clearForm();

      calculateSrNo();

      Get.snackbar(
        'Deleted',
        'Wastage entry deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Delete wastage error: $e');

      Get.snackbar(
        'Error',
        'Unable to delete wastage entry',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // LOAD ENTRY INTO FORM
  // ----------------------------------------------------------

  void loadIntoForm(WastageEntryModel e) {
    selectedEntryId.value = e.id;

    selectedParty.value = e.partyName;
    selectedPo.value = e.po;
    selectedArticle.value = e.articleNo;
    selectedSupervisor.value = e.supervisor;
    selectedWastageType.value = e.wastageType;
    selectedOperator.value = e.operator;

    weightCtrlText.value = e.weight.toString();
    depositCtrlText.value = e.depositQty.toString();

    selectedShift.value = e.shift;
    selectedLoomNo.value = e.loomNo;

    remarkCtrlText.value = e.remark ?? '';

    srNo.value = e.code;
  }

  // ----------------------------------------------------------
  // CLEAR FORM
  // ----------------------------------------------------------

  void clearForm() {
    selectedEntryId.value = null;

    selectedParty.value = null;
    selectedPo.value = null;
    selectedArticle.value = null;
    selectedSupervisor.value = null;
    selectedWastageType.value = null;
    selectedOperator.value = null;
    selectedShift.value = null;
    selectedLoomNo.value = null;

    weightCtrlText.value = '';
    depositCtrlText.value = '';
    remarkCtrlText.value = '';
  }

  // ----------------------------------------------------------
  // VALIDATION
  // ----------------------------------------------------------

  bool _validateForm() {
    if (selectedParty.value == null ||
        selectedParty.value!.trim().isEmpty) {
      _showValidation('Please select Party Name');
      return false;
    }

    if (selectedPo.value == null ||
        selectedPo.value!.trim().isEmpty) {
      _showValidation('Please select PO');
      return false;
    }

    if (selectedArticle.value == null ||
        selectedArticle.value!.trim().isEmpty) {
      _showValidation('Please select Article No');
      return false;
    }

    if (selectedSupervisor.value == null ||
        selectedSupervisor.value!.trim().isEmpty) {
      _showValidation('Please select Supervisor');
      return false;
    }

    if (selectedWastageType.value == null ||
        selectedWastageType.value!.trim().isEmpty) {
      _showValidation('Please select Wastage Type');
      return false;
    }

    if (selectedOperator.value == null ||
        selectedOperator.value!.trim().isEmpty) {
      _showValidation('Please select Operator');
      return false;
    }

    if (weightCtrlText.value.trim().isEmpty) {
      _showValidation('Please enter Weight');
      return false;
    }

    final weight =
    double.tryParse(weightCtrlText.value.trim());

    if (weight == null || weight <= 0) {
      _showValidation('Please enter valid Weight');
      return false;
    }

    if (depositCtrlText.value.trim().isEmpty) {
      _showValidation('Please enter Deposit Qty');
      return false;
    }

    final deposit =
    double.tryParse(depositCtrlText.value.trim());

    if (deposit == null || deposit < 0) {
      _showValidation('Please enter valid Deposit Qty');
      return false;
    }

    if (selectedShift.value == null ||
        selectedShift.value!.trim().isEmpty) {
      _showValidation('Please select Shift');
      return false;
    }

    if (showLoomNo &&
        (selectedLoomNo.value == null ||
            selectedLoomNo.value!.trim().isEmpty)) {
      _showValidation('Please select Loom No');
      return false;
    }

    return true;
  }

  void _showValidation(String message) {
    Get.snackbar(
      'Validation',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ----------------------------------------------------------
  // SR NO
  // ----------------------------------------------------------

  void calculateSrNo() {
    srNo.value = entries.length + 1;
  }
}
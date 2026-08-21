
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Color/Colorclass.dart';
import '../RecentEntryScreen.dart';


// ─── Data Model ──────────────────────────────────────────────────────────────

class EntryRecord {
  final int id;
  final String operator;
  final String party;
  final String recipe;
  final double gross;
  final bool isActive;

  const EntryRecord({
    required this.id,
    required this.operator,
    required this.party,
    required this.recipe,
    required this.gross,
    this.isActive = false,
  });
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class ManualTapeLineEntryScreen extends StatefulWidget {


  const ManualTapeLineEntryScreen({
    super.key,

  });

  @override
  State<ManualTapeLineEntryScreen> createState() => _ManualTapeLineEntryScreenState();
}

class _ManualTapeLineEntryScreenState extends State<ManualTapeLineEntryScreen> {
  final _widthController = TextEditingController();
  final _ppLotController = TextEditingController();
  final _dnrController = TextEditingController();
  final _grossController = TextEditingController();
  final _tareController = TextEditingController();
  final _netController = TextEditingController();
  final _batchController = TextEditingController();
  final _partyController = TextEditingController();
  final _bomController = TextEditingController();
  final _poController = TextEditingController();
  final _articleController = TextEditingController();
  final TextEditingController _operatorController = TextEditingController();
  // final _workOrderController = TextEditingController();
  final _remarkController = TextEditingController();
  final TextEditingController _generatedCodeController =
  TextEditingController();
  bool isPoLoading = false;
  bool isArticleLoading = false;
  String? _generatedBatch;
  String? _generatedCode;
  List<String> partyList = [];
  List<String> operatorList = [];
  String? srNo;
  List<String> recipeList = [];
  List<String> poList = [];
  List<String> articleList = [];
  bool isLoading = true;
  String? _selectedParty;
  String _getNumericDnr() {
    return _dnrController.text.replaceAll(RegExp(r'[^0-9]'), '');
  }
  String? _selectedRecipe;
  String? _selectedPO;
  String? _selectedArticle;
  String _selectedOperator = '';
  String _selectedPlant = 'TAPE PLANT-1';

  String _selectedShift = 'A';

  final InStockService api = InStockService();

  String _generateBatchNumber() {
    final party = _partyController.text.trim();
    final po = _poController.text.trim();
    final shift = _selectedShift.isNotEmpty ? _selectedShift : '';

    final now = DateTime.now();

    final date = now.day.toString();
    final month = now.month.toString().padLeft(2, '0');

    String partyCode = '';
    if (party.length >= 3) {
      partyCode = party.substring(0, 3).toUpperCase();
    } else {
      partyCode = party.toUpperCase();
    }

    return "$partyCode$po$date$month${shift}TP";
  }

  String _generateFinalCode() {
    final dnr = _dnrController.text.trim();
    final recipe = _selectedRecipe ?? '';
    final width = _widthController.text.trim();

    return "${dnr}DNR/$recipe/${width}MM";
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();

  }

  @override
  void dispose() {
    _widthController.dispose();
    _ppLotController.dispose();
    _dnrController.dispose();
    _grossController.dispose();
    _tareController.dispose();
    _netController.dispose();
    _batchController.dispose();
    _partyController.dispose();
    _bomController.dispose();
    _poController.dispose();
    _articleController.dispose();
    _generatedCodeController.dispose(); // ✅ ADD THIS
    _operatorController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _recalcNet() {
    final gross = double.tryParse(_grossController.text) ?? 0;
    final tare = double.tryParse(_tareController.text) ?? 0;
    setState(() {
      _netController.text = (gross - tare).toStringAsFixed(2);
    });
  }

  Future<void> _loadPoNumbers(String customerName) async {
    try {
      setState(() {
        isPoLoading = true;
        poList = [];
        _selectedPO = null;
        articleList = [];
        _selectedArticle = null;
      });

      final data = await api.getPoNumbers(customerName);

      setState(() {
        poList = List<String>.from(data);
        if (poList.isNotEmpty) {
          _selectedPO = poList.first;
          _loadArticleNumbers(customerName, _selectedPO!);
        }
        isPoLoading = false;
      });
    } catch (e) {
      debugPrint("PO API Error: $e");
      setState(() => isPoLoading = false);
    }
  }

  Future<void> _loadArticleNumbers(String customerName, String poNum) async {
    try {
      setState(() {
        isArticleLoading = true;
        articleList = [];
        _selectedArticle = null;
      });

      final data = await api.getArticleNumbers(customerName, poNum);

      setState(() {
        articleList = List<String>.from(data);
        if (articleList.isNotEmpty) {
          _selectedArticle = articleList.first;
        }
        isArticleLoading = false;
      });
    } catch (e) {
      debugPrint("Article API Error: $e");
      setState(() => isArticleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Text(
              'Manual Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: C.bg,
              ),
            ),
          ],
        ),
        actions: [
          // Date chip
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: C.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(fontSize: 13, color: C.primaryDark),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: C.bg, height: 0.5),
        ),
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SR No. ${srNo ?? '---'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: C.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),

            const SizedBox(height: 12),
            _buildOperatorCard(),
            const SizedBox(height: 12),
            _buildProductionCard(),
            const SizedBox(height: 16),
            // _buildGenerateButton(),
            // const SizedBox(height: 10),
            _buildActionRow(),
            const SizedBox(height: 20),
            _buildRecentEntries(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Section Card ─────────────────────────────────────────────────────────

  Widget _sectionCard({required String label, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: C.textHead,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ─── Field Helpers ────────────────────────────────────────────────────────
  Widget _dropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: C.primaryDark)),

        DropdownButtonFormField<String>(
          initialValue: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          decoration: const InputDecoration(),
          style: const TextStyle(fontSize: 15, color: C.textHigh),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        String placeholder = '',
        bool readOnly = false,
      }) {
    final isDnr = label == 'DNR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: C.primaryDark,
          ),
        ),

        TextField(
          controller: controller,
          readOnly: readOnly,

          // DNR will use numeric keyboard
          keyboardType: isDnr
              ? TextInputType.number
              : keyboardType,

          // Only numbers allowed for DNR
          inputFormatters: isDnr
              ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ]
              : null,

          style: const TextStyle(fontSize: 15),

          decoration: InputDecoration(
            hintText: placeholder,

            // Optional error-style validation if empty
            errorText: isDnr && controller.text.isEmpty
                ? null
                : null,
          ),

          onChanged: (!readOnly &&
              (label == 'Gross Weight (kg)' ||
                  label == 'Tare Weight (kg)'))
              ? (_) => _recalcNet()
              : null,
        ),
      ],
    );
  }

  // ─── Cards ────────────────────────────────────────────────────────────────

  Widget _buildOperatorCard() {
    return _sectionCard(
      label: 'Operator & Plant',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  "Party Name",
                  _partyController,
                  placeholder: "Enter Party Name",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  "BOM No",
                  _bomController,
                  placeholder: "Enter BOM No",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _textField(
                  "PO No",
                  _poController,
                  placeholder: "Enter PO No",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  "Article No",
                  _articleController,
                  placeholder: "Enter Article No",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:_operatorDropdown(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  'Tape Plant',
                  _selectedPlant,
                  ['TAPE PLANT-1', 'TAPE PLANT-2'],
                      (v) => setState(() => _selectedPlant = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductionCard() {
    return _sectionCard(
      label: 'Production Details',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  'Recipe Type',
                  _selectedRecipe,
                  recipeList.isEmpty ? ['Loading...'] : recipeList,
                      (v) => setState(() => _selectedRecipe = v!),
                ),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  'Width (mm)',
                  _widthController,
                  keyboardType: TextInputType.number,
                  placeholder: 'e.g. 2050',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  'PP Lot No',
                  _ppLotController,
                  placeholder: 'Enter PP Lot No',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  'DNR',
                  _dnrController,
                  placeholder: 'Enter DNR',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Gross Weight (kg)',
                  _grossController,
                  keyboardType: TextInputType.number,
                  placeholder: '0.00',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  'Tare Weight (kg)',
                  _tareController,
                  keyboardType: TextInputType.number,
                  placeholder: '0.00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Net Weight (kg)',
                  _netController,
                  keyboardType: TextInputType.number,
                  placeholder: 'Auto-calculated',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown('Shift', _selectedShift, [
                  'A',
                  'B',
                ], (v) => setState(() => _selectedShift = v!)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                    'Batch No',
                    _batchController,
                    placeholder: '',
                    keyboardType: TextInputType.none,
                    readOnly: true
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate Code',
                      style: TextStyle(fontSize: 13, color: C.primaryDark),
                    ),

                    TextField(
                      controller: _generatedCodeController,
                      readOnly: true, // ✅ important
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Auto-generated',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remark',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _remarkController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Optional note...'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Buttons ──────────────────────────────────────────────────────────────
  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _generatedBatch = _generateBatchNumber();
                _generatedCode = _generateFinalCode();

                _batchController.text = _generatedBatch!;
                _generatedCodeController.text = _generatedCode ?? '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Generate Code',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                // ─────────────────────────────────────
                // DNR VALIDATION
                // ─────────────────────────────────────
                final dnr = _dnrController.text.trim();

                if (dnr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter DNR"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Make sure DNR contains ONLY numbers
                if (!RegExp(r'^[0-9]+$').hasMatch(dnr)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("DNR must contain numbers only"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final now = DateTime.now();

                final time =
                    "${now.hour}:${now.minute.toString().padLeft(2, '0')}:00";

                final batch = _generateBatchNumber();

                // Generate code using numeric DNR
                final code = "${dnr}DNR/"
                    "${_selectedRecipe ?? ''}/"
                    "${_widthController.text.trim()}MM";

                _batchController.text = batch;
                _generatedCodeController.text = code;

                final body = {
                  "srNo": srNo,
                  "operator": _selectedOperator,
                  "tapePlant": _selectedPlant,
                  "partyName": _partyController.text.trim(),
                  "mPurchaseOrderNo": _poController.text.trim(),
                  "articleNo": _articleController.text.trim(),
                  "bom": _bomController.text.trim(),
                  "date": now.toString().split(' ')[0],
                  "time": time,
                  "recipeType": _selectedRecipe,

                  // Numeric DNR only
                  "dnr": dnr,

                  "widthMM": _widthController.text,
                  "grossWeight": _grossController.text,
                  "tareWeight": _tareController.text,
                  "netWeight": _netController.text,
                  "shift": _selectedShift,
                  "batchNo": batch,
                  "generateCode": code,
                  "ppLotNo": _ppLotController.text,
                  "remark": _remarkController.text,
                };

                final res = await api.saveTapeLineEntry(body);

                print(res);

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentEntriesScreen(),
                  ),
                      (route) => false,
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8F5E9),
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentEntriesScreen(),
                  ),
                );

              },
              child: const Text("View All Entries",style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w500,color: C.primary),),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadDropdownData() async {
    try {
      final data = await InStockService().fetchDropdownData();

      print("API RESPONSE: $data");

      setState(() {
        partyList = List<String>.from(data['customerNames'] ?? []);
        recipeList = List<String>.from(data['recipeTypes'] ?? []);
        srNo = data['id']?.toString();
        // ✅ FIX SR NO
        srNo = data['id']?.toString();

        // ❌ NOT AVAILABLE IN API → fallback

        operatorList = List<String>.from(data['operators'] ?? []);

        if (operatorList.isNotEmpty) {
          _selectedOperator = operatorList.first;
        }
        if (partyList.isNotEmpty) _selectedParty = partyList.first;
        if (recipeList.isNotEmpty) _selectedRecipe = recipeList.first;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("API Error: $e");
      setState(() => isLoading = false);
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${now.day.toString().padLeft(2, '0')}-${months[now.month - 1]}-${now.year}";
  }

  Widget _operatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operator",
          style: TextStyle(
            fontSize: 13,
            color: C.primaryDark,
          ),
        ),
        const SizedBox(height: 6),

        DropdownMenu<String>(
          controller: _operatorController,
          width: double.infinity,
          enableFilter: true,
          enableSearch: true,
          requestFocusOnTap: true,
          hintText: "Select Operator",

          dropdownMenuEntries: operatorList
              .map<DropdownMenuEntry<String>>(
                (e) => DropdownMenuEntry(
              value: e,
              label: e,
            ),
          )
              .toList(),

          onSelected: (value) {
            if (value != null) {
              setState(() {
                _selectedOperator = value;
                _operatorController.text = value;
              });
            }
          },
        ),
      ],
    );
  }
}

// Widget _readOnlyField(String label, String value, {IconData? icon}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: C.primaryDark,
//         ),
//       ),
//
//       const SizedBox(height: 6),
//
//       TextFormField(
//         initialValue: value,
//         readOnly: true,
//         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//         decoration: InputDecoration(
//           prefixIcon: icon == null ? null : Icon(icon, size: 20),
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//         ),
//       ),
//     ],
//   );
// }

import 'package:IMS/AdminDashBoard/NewAdminDashboard.dart';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';

import '../../AdminDashBoard/DashBoard.dart';
import '../../AdminDashBoard/ListMenuItems/dashBoardNewUi.dart';
import '../../Color/Colorclass.dart';
import 'RecentEntryScreen.dart';

class TapeLineApp extends StatelessWidget {
  const TapeLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Tape Line Entry',
      // debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
      //   fontFamily: 'SF Pro Display',
      // ),
      home: const TapeLineEntryScreen(),
    );
  }
}

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

class TapeLineEntryScreen extends StatefulWidget {
  const TapeLineEntryScreen({super.key});

  @override
  State<TapeLineEntryScreen> createState() => _TapeLineEntryScreenState();
}

class _TapeLineEntryScreenState extends State<TapeLineEntryScreen> {
  final _widthController = TextEditingController();
  final _ppLotController = TextEditingController();
  final _dnrController = TextEditingController();
  final _grossController = TextEditingController();
  final _tareController = TextEditingController();
  final _netController = TextEditingController();
  final _batchController = TextEditingController();
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
  String? _selectedRecipe;
  String? _selectedPO;
  String? _selectedArticle;
  String _selectedOperator = 'ADARSH';
  String _selectedPlant = 'TAPE PLANT-1';

  String _selectedShift = 'A';

  final InStockService api = InStockService();

  final List<EntryRecord> _records = const [
    EntryRecord(
      id: 1386,
      operator: 'RAMBABU',
      party: 'Palmetto',
      recipe: 'LEMON YLW',
      gross: 580,
    ),
  ];

  String _generateBatchNumber() {
    final party = _selectedParty ?? '';
    final po = _selectedPO ?? '';
    final shift = _selectedShift.isNotEmpty ? _selectedShift : '';

    final now = DateTime.now();
    final time = "${now.hour}:${now.minute.toString().padLeft(2, '0')}:00";
    // final date = now.day.toString().padLeft(2, '0');
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
    _generatedCodeController.dispose(); // ✅ ADD THIS


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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NewAdminDashboard()),
            );
          },
        ),
        title: Row(
          children: [
            const Text(
              'Tape Line Entry',
              style: TextStyle(
                fontSize: 15,
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
                  style: const TextStyle(fontSize: 11, color: C.primary),
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
          ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
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
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 8),
                  const SizedBox(height: 12),
                  _buildOperatorCard(),
                  const SizedBox(height: 12),
                  _buildProductionCard(),
                  const SizedBox(height: 16),
                  _buildGenerateButton(),
                  const SizedBox(height: 10),
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
              color: Color(0xFFBDBDBD),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          decoration: const InputDecoration(),
          style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(hintText: placeholder),
          onChanged:
              (label == 'Gross Weight (kg)' || label == 'Tare Weight (kg)')
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
                // child: _dropdown('Operator', _selectedOperator,
                //     ['ADARSH', 'RAMBABU'],
                //         (v) => setState(() => _selectedOperator = v!)),
                child: _dropdown(
                  'Operator',
                  _selectedOperator,
                  operatorList.isEmpty ? ['Loading...'] : operatorList,
                  (v) {
                    setState(() => _selectedOperator = v!);
                  },
                ),
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
          const SizedBox(height: 12),
          _dropdown(
            'Party Name',
            _selectedParty,
            partyList.isEmpty ? ['Loading...'] : partyList,
            (v) {
              setState(() => _selectedParty = v);
              if (v != null) {
                _loadPoNumbers(v);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  'Purchase Order No',
                  _selectedPO,
                  isPoLoading ? ['Loading...'] : poList,
                  (v) {
                    setState(() => _selectedPO = v);
                    if (v != null && _selectedParty != null) {
                      _loadArticleNumbers(_selectedParty!, v);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  'Article No',
                  _selectedArticle,
                  isArticleLoading ? ['Loading...'] : articleList,
                  (v) => setState(() => _selectedArticle = v),
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
                      style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _generatedCodeController,
                      readOnly: true, // ✅ important
                      style: const TextStyle(fontSize: 13),
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

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
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
          backgroundColor: const Color(0xFF212121),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Generate Code',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '+ New Entry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                final now = DateTime.now();

                final time =
                    "${now.hour}:${now.minute.toString().padLeft(2, '0')}:00";

                final batch = _generateBatchNumber();
                final code = _generateFinalCode();

                _batchController.text = batch;
                _generatedCodeController.text = code;

                final body = {
                  "srNo": srNo ?? "",
                  "operator": _selectedOperator,
                  "tapePlant": _selectedPlant,
                  "partyName": _selectedParty ?? "",
                  "mPurchaseOrderNo": _selectedPO ?? "",
                  "articleNo": _selectedArticle ?? "",
                  "date": now.toString().split(' ')[0],
                  "time": time, // ✅ now valid
                  "recipeType": _selectedRecipe ?? "",
                  "dnr": _dnrController.text,
                  "widthMM": _widthController.text,
                  "grossWeight": _grossController.text,
                  "tareWeight": _tareController.text,
                  "netWeight": _netController.text,
                  "remark": _remarkController.text,
                  "generateCode": code,
                  "shift": _selectedShift,
                  "batchNo": batch,
                  "ppLotNo": _ppLotController.text,
                };

                final res = await api.saveTapeLineEntry(body);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? "Saved successfully"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8F5E9),
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
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

  // ─── Recent Entries Table ─────────────────────────────────────────────────

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RecentEntriesScreen(),
              ),
            );
          },
          child: const Text("View All"),
        )
      ],
    ),
    ]
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
}

// ─── Table Helper Widgets ─────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _ColHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final EntryRecord record;
  const _EntryRow({required this.record});

  Color get _recipeColor {
    switch (record.recipe) {
      case 'BLUE ID':
        return const Color(0xFF1A73E8);
      case 'SKU BLUE':
        return const Color(0xFF2E7D32);
      case 'LEMON YLW':
        return const Color(0xFFF57F17);
      default:
        return const Color(0xFF757575);
    }
  }

  Color get _recipeBg {
    switch (record.recipe) {
      case 'BLUE ID':
        return const Color(0xFFE8F0FE);
      case 'SKU BLUE':
        return const Color(0xFFE8F5E9);
      case 'LEMON YLW':
        return const Color(0xFFFFF8E1);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: record.isActive
          ? const Color(0xFFE8F0FE).withOpacity(0.4)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${record.id}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: record.isActive ? FontWeight.w600 : FontWeight.w400,
                color: record.isActive
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFF212121),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record.operator,
              style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record.party,
              style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _recipeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                record.recipe,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _recipeColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              record.gross.toStringAsFixed(0),
              style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }
}

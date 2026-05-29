// import 'package:flutter/material.dart';
// import 'package:IMS/services/getSupervisors/getSupervisors.dart';
//
// import '../../Color/Colorclass.dart';
//
// class TapeLineApp extends StatelessWidget {
//   const TapeLineApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const TapeLineEntryScreen(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────
//
// class TapeLineEntryScreen extends StatefulWidget {
//   const TapeLineEntryScreen({super.key});
//
//   @override
//   State<TapeLineEntryScreen> createState() =>
//       _TapeLineEntryScreenState();
// }
//
// class _TapeLineEntryScreenState extends State<TapeLineEntryScreen> {
//   final InStockService api = InStockService();
//
//   // Controllers
//   final _grossController = TextEditingController();
//   final _tareController = TextEditingController();
//   final _netController = TextEditingController();
//
//   // Dropdown Lists
//   List<String> partyList = [];
//   List<String> recipeList = [];
//   List<String> poList = [];
//   List<String> articleList = [];
//
//   // Selected Values
//   String? _selectedParty;
//   String? _selectedRecipe;
//   String? _selectedPO;
//   String? _selectedArticle;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDropdownData();
//   }
//
//   // ───────────────── API CALLS ─────────────────
//
//   Future<void> fetchDropdownData() async {
//     try {
//       final data = await api.getDropdownData();
//
//       setState(() {
//
//         partyList = List<String>.from(data['partyNames'] ?? []);
//         recipeList = List<String>.from(data['recipeTypes'] ?? []);
//
//         if (partyList.isNotEmpty) {
//           _selectedParty = partyList.first;
//           fetchPoNumbers(_selectedParty!);
//         }
//
//         if (recipeList.isNotEmpty) {
//           _selectedRecipe = recipeList.first;
//         }
//       });
//     } catch (e) {
//       print("Dropdown Error: $e");
//     }
//   }
//
//   Future<void> fetchPoNumbers(String party) async {
//     try {
//       final data = await api.getPoNumbers(party);
//
//       setState(() {
//         poList = List<String>.from(data);
//
//         if (poList.isNotEmpty) {
//           _selectedPO = poList.first;
//           fetchArticles(party, _selectedPO!);
//         } else {
//           _selectedPO = null;
//           articleList = [];
//         }
//       });
//     } catch (e) {
//       print("PO Error: $e");
//     }
//   }
//
//   Future<void> fetchArticles(String party, String po) async {
//     try {
//       final data = await api.getArticleNumbers(party, po);
//
//       setState(() {
//         // articleList = data;
//         articleList = List<String>.from(data);
//
//         if (articleList.isNotEmpty) {
//           _selectedArticle = articleList.first;
//         } else {
//           _selectedArticle = null;
//         }
//       });
//     } catch (e) {
//       print("Article Error: $e");
//     }
//   }
//
//   // ───────────────── LOGIC ─────────────────
//
//   void _recalcNet() {
//     final g = double.tryParse(_grossController.text) ?? 0;
//     final t = double.tryParse(_tareController.text) ?? 0;
//
//     setState(() {
//       _netController.text = (g - t).toStringAsFixed(2);
//     });
//   }
//
//   // ───────────────── UI ─────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.bg,
//       appBar: AppBar(
//         backgroundColor: C.primaryBlue,
//         title: const Text("Tape Line Entry"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // PARTY
//             _dropdown(
//               "Party Name",
//               _selectedParty,
//               partyList,
//                   (v) {
//                 setState(() => _selectedParty = v);
//                 fetchPoNumbers(v!);
//               },
//             ),
//
//             const SizedBox(height: 12),
//
//             // PO
//             _dropdown(
//               "PO Number",
//               _selectedPO,
//               poList,
//                   (v) {
//                 setState(() => _selectedPO = v);
//                 fetchArticles(_selectedParty!, v!);
//               },
//             ),
//
//             const SizedBox(height: 12),
//
//             // ARTICLE
//             _dropdown(
//               "Article Number",
//               _selectedArticle,
//               articleList,
//                   (v) => setState(() => _selectedArticle = v),
//             ),
//
//             const SizedBox(height: 12),
//
//             // RECIPE
//             _dropdown(
//               "Recipe",
//               _selectedRecipe,
//               recipeList,
//                   (v) => setState(() => _selectedRecipe = v),
//             ),
//
//             const SizedBox(height: 20),
//
//             // GROSS
//             _textField("Gross", _grossController),
//
//             const SizedBox(height: 12),
//
//             // TARE
//             _textField("Tare", _tareController),
//
//             const SizedBox(height: 12),
//
//             // NET
//             _textField("Net", _netController, enabled: false),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ───────────────── WIDGETS ─────────────────
//
//   Widget _dropdown(
//       String label,
//       String? value,
//       List<String> items,
//       Function(String?) onChanged,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: items.contains(value) ? value : null,
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: onChanged,
//           decoration: const InputDecoration(border: OutlineInputBorder()),
//         ),
//       ],
//     );
//   }
//
//   Widget _textField(
//       String label,
//       TextEditingController controller, {
//         bool enabled = true,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 4),
//         TextField(
//           controller: controller,
//           enabled: enabled,
//           keyboardType: TextInputType.number,
//           onChanged: (_) => _recalcNet(),
//           decoration: const InputDecoration(border: OutlineInputBorder()),
//         ),
//       ],
//     );
//   }
// }
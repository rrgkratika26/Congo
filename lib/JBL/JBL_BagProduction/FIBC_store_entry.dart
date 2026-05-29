import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import 'FibcComponentScreen.dart';
import 'StoeIssueModleClass.dart';

// ─── Screen ──────────────────────────────────────────────────────────────────
class StoreEntryListScreen extends StatefulWidget {
  const StoreEntryListScreen({super.key});

  @override
  State<StoreEntryListScreen> createState() => _StoreEntryListScreenState();
}

class _StoreEntryListScreenState extends State<StoreEntryListScreen> {
  final _searchCtrl = TextEditingController();
  List<StoreIsssueModleClass> _entries = [];
  int? _selectedIndex;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await JblApiService.getFibcStoreEntries();
      setState(() {
        _entries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<StoreIsssueModleClass> get _filtered {
    if (_searchQuery.isEmpty) return _entries;
    final q = _searchQuery.toLowerCase();
    return _entries
        .where(
          (e) =>
              e.woNumber.toLowerCase().contains(q) ||
              e.customerName.toLowerCase().contains(q) ||
              e.type.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Column(
        children: [
          _Header(
            totalCount: _entries.length,
            isLoading: _isLoading,
            onRefresh: _load,
          ),
          _SearchBar(
            controller: _searchCtrl,
            query: _searchQuery,
            onChanged: (v) => setState(() => _searchQuery = v),
            onClear: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: C.appBar3, strokeWidth: 2.5),
            SizedBox(height: 14),
            Text(
              'Fetching records…',
              style: TextStyle(fontSize: 13, color: C.textMid),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 38,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Could not load data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: C.textMid),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try again'),
                style: TextButton.styleFrom(foregroundColor: C.primary),
              ),
            ],
          ),
        ),
      );
    }

    final list = _filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: C.textLow),
            const SizedBox(height: 10),
            const Text(
              'No records found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: C.textMid,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),

          /// ✅ TABLE SCROLL
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 720, // 👈 total table width
              child: Column(
                children: [
                  _TableHeader(),

                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) => _EntryRow(
                        entry: list[i],
                        index: i,
                        isSelected: _selectedIndex == i,
                        onTap: () async {
                          setState(() => _selectedIndex = i);

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FibcComponentScreen(
                                woNumber: list[i].woNumber.trim(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int totalCount;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _Header({
    required this.totalCount,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F1565C0),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIBC Store Entry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isLoading ? 'Loading…' : '$totalCount entries',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: C.textHigh),
        decoration: InputDecoration(
          hintText: 'Search WO, customer or type…',
          hintStyle: const TextStyle(fontSize: 13, color: C.textLow),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: C.textMid,
            size: 19,
          ),
          suffixIcon: query.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close_rounded,
                    color: C.textMid,
                    size: 17,
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF4F7FC),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

// ─── Table Header ─────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5FB),
        border: Border(bottom: BorderSide(color: C.borderLight)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 110, child: Text("WO Number")),
          SizedBox(width: 200, child: Text("Customer")),
          SizedBox(
            width: 130,
            child: Text("Date", textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 120,
            child: Text("Type", textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 80,
            child: Text("Qty", textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ─── Entry Row ────────────────────────────────────────────────────────────────
class _EntryRow extends StatelessWidget {
  final StoreIsssueModleClass entry;
  final int index;
  final bool isSelected;

  final VoidCallback onTap;

  const _EntryRow({
    required this.entry,
    required this.index,

    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors
                    .greenAccent
                    .shade100 // 👈 Selected row color
              : (isEven ? Colors.white : const Color(0xFFF8FAFF)),
          border: const Border(bottom: BorderSide(color: C.borderLight)),
        ),
        child:Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(entry.woNumber,
                  overflow: TextOverflow.ellipsis),
            ),

            SizedBox(
              width: 200,
              child: Text(
                entry.customerName.isEmpty ? "-" : entry.customerName,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(
              width: 130,
              child: Text(
                entry.date.isEmpty ? "-" : entry.date.split("T")[0],
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              width: 120,
              child: Text(
                entry.type,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              width: 80,
              child: Text(
                "${entry.quantity}",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        )
      ),
    );
  }
}

// ─── Detail Sheet ─────────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final StoreIsssueModleClass entry;
  const _DetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: C.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon + WO row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.woNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: C.primary,
                      ),
                    ),
                    const Text(
                      'Work Order',
                      style: TextStyle(fontSize: 11, color: C.textMid),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.quantity} PCS',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: C.borderLight),
          const SizedBox(height: 16),

          _row(
            'Customer',
            entry.customerName.isEmpty ? '—' : entry.customerName,
          ),
          _row('Date', entry.date.split("T")[0]),

          _row('Type', entry.type),
          _row('Quantity', '${entry.quantity} PCS'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: C.textMid,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text('  :  ', style: TextStyle(color: C.textLow, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: C.textHigh,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../Color/Colorclass.dart';
import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../app_colors.dart';
import 'BailingFormScreen.dart';
import 'modleclass/modelClass.dart';

class JblBailingEntry extends StatefulWidget {
  final String screenType;
  const JblBailingEntry({super.key, required this.screenType});

  @override
  State<JblBailingEntry> createState() => _JblBailingEntryState();
}

class _JblBailingEntryState extends State<JblBailingEntry> {
  List<BailingEntry> _entries = [];
  final service = JblApiService();
  bool _isLoading = true;
  String _rawResponse = ""; // 👈 Added for debugging
  String _errorMessage = "";
  TextEditingController _searchController = TextEditingController();
  List<BailingEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final token = await AppSession.getToken();

      print("🔐 TOKEN: $token");

      final response = await http.get(
        Uri.parse('${JblApiService.baseUrlJBL}/BaleDepartment/entry-report'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 STATUS CODE: ${response.statusCode}");
      print("📦 RAW RESPONSE: ${response.body}");

      _rawResponse = response.body; // store raw response

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        print("✅ DECODED: $decoded");

        if (decoded is List) {
          final list = decoded.map((e) => BailingEntry.fromJson(e)).toList();

          setState(() {
            _entries = list;
            _filteredEntries = list; // 👈 important
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Response is not a List";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Error ${response.statusCode}\n${response.body}";
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error ${response.statusCode}")));
      }
    } catch (e) {
      print("🔥 EXCEPTION: $e");

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exception occurred")));
    }
  }

  void _filterEntries(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      _filteredEntries = _entries.where((entry) {
        return entry.partyName.toLowerCase().contains(lowerQuery) ||
            entry.bomNo.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEBF5FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFDDEEFA),
          foregroundColor: const Color(0xFF1565C0),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          title: const Text(
            'Bailing Entries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: Color(0xFF1565C0),
              ),
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchEntries();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: C.appBar3,),
              )
            : _errorMessage.isNotEmpty
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
            : _entries.isEmpty
            ? _EmptyState(onRetry: _fetchEntries)
            : Column(
                children: [
                  // 🔍 Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterEntries,
                      decoration: InputDecoration(
                        hintText: "Search by Party Name or BOM No",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterEntries('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEDBF5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEDBF5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 📋 List
                  Expanded(
                    child: _filteredEntries.isEmpty
                        ? const Center(child: Text("No matching results"))
                        : _EntryList(
                            entries: _filteredEntries,
                            onTap: (i) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BailingFormScreen(
                                  entry: _filteredEntries[i],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────
class _EntryList extends StatelessWidget {
  final List<BailingEntry> entries;
  final ValueChanged<int> onTap;

  const _EntryList({required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            onTap: () => onTap(index),
            title: Text(
              e.partyName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BOM No: ${e.bomNo}"),
                Text("Article: ${e.articleNo}"),
                Text("Packets: ${e.totalPacket}"),
                Text("PCS: ${e.totalPcs}"),
                Text("Weight: ${e.totalWt} kg"),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Entry Card ────────────────────────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final BailingEntry entry;
  final int index;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBEDBF5), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90CAF9).withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Index badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFD6ECFA),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.partyName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3050),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.articleNo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B97B5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _Tag(entry.bomNo),
                      const SizedBox(width: 6),
                      _Tag('${entry.totalPacket} pkts'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Weight + PCS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalWt.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.totalPcs.toStringAsFixed(0)} pcs',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B97B5),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFBEDBF5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD6ECFA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }
}

// ── Summary Chip ──────────────────────────────────────────────────────────────
class _SumChip extends StatelessWidget {
  final String label, value;
  const _SumChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFC8E2F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4A7FA8),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFD6ECFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 34,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No entries found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3050),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap below to try again',
            style: TextStyle(fontSize: 12, color: Color(0xFF7B97B5)),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF1976D2)),
          ),
        ],
      ),
    );
  }
}

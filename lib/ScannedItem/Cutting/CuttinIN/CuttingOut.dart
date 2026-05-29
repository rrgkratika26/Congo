import 'package:flutter/material.dart';

class CuttingOutScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const CuttingOutScreen({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<CuttingOutScreen> createState() => _CuttingOutScreenState();
}

class _CuttingOutScreenState extends State<CuttingOutScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> reportData = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  @override
  void didUpdateWidget(CuttingOutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _loadReportData();
    }
  }

  Future<void> _loadReportData() async {
    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    setState(() {
      reportData = [
        {
          'id': '001',
          'operator': 'John Doe',
          'supervisor': 'Jane Smith',
          'quantity': 150,
          'date': '28-01-2026',
          'time': '10:30 AM',
        },
        {
          'id': '002',
          'operator': 'Mike Johnson',
          'supervisor': 'Jane Smith',
          'quantity': 200,
          'date': '28-01-2026',
          'time': '11:45 AM',
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
        ),
      )
          : reportData.isEmpty
          ? _buildEmptyState(isTablet, isDesktop)
          : _buildReportList(isTablet, isDesktop),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: isDesktop ? 80 : (isTablet ? 70 : 60),
              color: const Color(0xFF66BB6A),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
          Text(
            'No Reports Available',
            style: TextStyle(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
          Text(
            'Reports will appear here once items are scanned',
            style: TextStyle(
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(bool isTablet, bool isDesktop) {
    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      itemCount: reportData.length,
      itemBuilder: (context, index) {
        final item = reportData[index];
        return _buildReportCard(item, isTablet, isDesktop);
      },
    );
  }

  Widget _buildReportCard(
      Map<String, dynamic> item,
      bool isTablet,
      bool isDesktop,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : (isTablet ? 14 : 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show details
          },
          borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 14 : (isTablet ? 12 : 10)),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(isDesktop ? 14 : 12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF66BB6A).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: isDesktop ? 28 : (isTablet ? 24 : 22),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${item['id']}',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            '${item['date']} • ${item['time']}',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : (isTablet ? 14 : 12),
                        vertical: isDesktop ? 10 : (isTablet ? 9 : 8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item['quantity']} items',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF66BB6A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
                Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.person_rounded,
                          label: 'Operator',
                          value: item['operator'],
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.supervisor_account_rounded,
                          label: 'Supervisor',
                          value: item['supervisor'],
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isDesktop ? 20 : (isTablet ? 18 : 16),
          color: const Color(0xFF66BB6A),
        ),
        SizedBox(width: isTablet ? 10 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
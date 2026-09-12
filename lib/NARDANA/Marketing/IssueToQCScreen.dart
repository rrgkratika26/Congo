import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';

class IssueToQualityScreen extends StatefulWidget {
  const IssueToQualityScreen({super.key});

  @override
  State<IssueToQualityScreen> createState() => _IssueToQualityScreenState();
}

class _IssueToQualityScreenState extends State<IssueToQualityScreen> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final ScrollController _horizontalController = ScrollController();

  final ScrollController _verticalController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  // ==========================================================
  // DATA
  // ==========================================================

  List<Map<String, dynamic>> reports = [];

  List<Map<String, dynamic>> filteredReports = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  int page = 1;

  int totalRecords = 0;

  static const int pageSize = 50;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    loadData();

    _verticalController.addListener(_scrollListener);
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SCROLL LISTENER
  // ==========================================================

  void _scrollListener() {
    if (!_verticalController.hasClients) {
      return;
    }

    if (_verticalController.position.pixels >=
            _verticalController.position.maxScrollExtent - 250 &&
        !isLoadingMore &&
        hasMore) {
      loadMore();
    }
  }

  // ==========================================================
  // LOAD FIRST PAGE
  // ==========================================================

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        page = 1;
        hasMore = true;
      });

      final result = await NaradanaApiService().fetchIssueToQuality(
        pageNumber: page,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        reports = List<Map<String, dynamic>>.from(result);

        filteredReports = List<Map<String, dynamic>>.from(result);

        totalRecords = reports.length;

        isLoading = false;

        hasMore = result.length >= pageSize;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showError('Unable to load Issue To Quality data.');

      debugPrint('IssueToQuality load error: $e');
    }
  }

  // ==========================================================
  // LOAD MORE
  // ==========================================================

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) {
      return;
    }

    try {
      setState(() {
        isLoadingMore = true;
      });

      final nextPage = page + 1;

      final result = await NaradanaApiService().fetchIssueToQuality(
        pageNumber: nextPage,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        page = nextPage;

        reports.addAll(List<Map<String, dynamic>>.from(result));

        totalRecords = reports.length;

        hasMore = result.length >= pageSize;

        isLoadingMore = false;

        _applyFilterWithoutSetState();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });

      debugPrint('IssueToQuality load more error: $e');
    }
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  void _filter() {
    _applyFilterWithoutSetState();

    setState(() {});
  }

  void _applyFilterWithoutSetState() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      filteredReports = List<Map<String, dynamic>>.from(reports);

      return;
    }

    filteredReports = reports.where((item) {
      final wo = _value(item, 'wO_NO');

      final woSeries = _value(item, 'wO_NO_SERIES');

      final customer = _value(item, 'customeR_NAME');

      final bagRef = _value(item, 'baG_REF');

      final inquiry = _value(item, 'inquirY_NO');

      final bagType = _value(item, 'baG_TYPE');

      return wo.contains(query) ||
          woSeries.contains(query) ||
          customer.contains(query) ||
          bagRef.contains(query) ||
          inquiry.contains(query) ||
          bagType.contains(query);
    }).toList();
  }

  // ==========================================================
  // SAFE VALUE
  // ==========================================================

  String _value(Map<String, dynamic> item, String key) {
    return item[key]?.toString().trim().toLowerCase() ?? '';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,

      appBar: _buildAppBar(),

      body: Column(
        children: [
          // ====================================================
          // SEARCH / FILTER BAR
          // ====================================================
          _buildTopBar(),

          // ====================================================
          // TABLE
          // ====================================================
          Expanded(child: _buildTableArea()),
        ],
      ),
    );
  }

  // ==========================================================
  // APP BAR
  // ==========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: C.appBar1,

      elevation: 0,

      iconTheme: const IconThemeData(color: Colors.white),

      titleSpacing: 16,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Issue To Quality',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),



          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              '$totalRecords records',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          tooltip: 'Refresh',

          onPressed: isLoading ? null : loadData,

          icon: const Icon(Icons.refresh_rounded),
        ),

        const SizedBox(width: 2),
      ],
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),

      color: C.bg,

      child: Row(
        children: [

          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(10),

                border: Border.all(color: const Color(0xFFE1E4E8)),
              ),

              child: TextField(
                controller: _searchController,

                onChanged: (_) => _filter(),

                decoration: const InputDecoration(
                  hintText: 'Search WO, Customer, Inquiry, Bag Ref...',

                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),

                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Color(0xFF737983),
                  ),

                  border: InputBorder.none,

                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(9),

              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.table_rows_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),

                const SizedBox(width: 7),

                Text(
                  '${filteredReports.length} rows',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTableArea() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports.isEmpty) {
      return _emptyState(
        icon: Icons.inventory_2_outlined,

        title: 'No records found',

        subtitle: 'There are no Issue To Quality records available.',
      );
    }

    if (filteredReports.isEmpty) {
      return _emptyState(
        icon: Icons.search_off_rounded,

        title: 'No matching records',

        subtitle: 'Try searching with another WO, customer or inquiry number.',
      );
    }


    return Scrollbar(
      controller: _horizontalController,

      thumbVisibility: true,

      notificationPredicate: (notification) => notification.depth == 0,

      child: SingleChildScrollView(
        controller: _horizontalController,

        scrollDirection: Axis.horizontal,

        child: SizedBox(
          width: 980,

          child: Column(
            children: [

              _buildTableHeader(),

              Expanded(
                child: Scrollbar(
                  controller: _verticalController,

                  thumbVisibility: true,

                  child: ListView.builder(
                    controller: _verticalController,

                    itemCount: filteredReports.length + (isLoadingMore ? 1 : 0),

                    itemBuilder: (context, index) {
                      if (index == filteredReports.length) {
                        return _loadingMoreRow();
                      }

                      return _buildTableRow(filteredReports[index], index);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 52,

      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),

        border: Border(
          top: BorderSide(color: Colors.grey.shade300),

          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      child: Row(
        children: [
          _headerCell('S.No', 55),

          _headerCell('WO NO.', 70),

          _headerCell('WO SR.', 70),

          _headerCell('PARTY NAME', 100),

          _headerCell('BAG REF.', 120),

          _headerCell('INQUIRY NO.', 130),

          _headerCell('BAG TYPE', 100),

          _headerCell('STATUS', 120),
        ],
      ),
    );
  }


  Widget _headerCell(String text, double width) {
    return Container(
      width: width,

      height: double.infinity,

      alignment: Alignment.centerLeft,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: .8),
        ),
      ),

      child: Text(
        text,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: C.primary,
          letterSpacing: .2,
        ),
      ),
    );
  }


  Widget _buildTableRow(Map<String, dynamic> item, int index) {
    final status = item['status']?.toString().trim().toUpperCase() ?? '';

    final isQuality = status == 'QUALITY';

    final isActive = item['active']?.toString().toLowerCase() == 'true';

    final backgroundColor = isQuality
        ? const Color(0xFFFFF1EC)
        : index.isEven
        ? Colors.white
        : const Color(0xFFFAFBFC);

    return Container(
      height: 54,

      decoration: BoxDecoration(
        color: backgroundColor,

        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: .8),
        ),
      ),

      child: Row(
        children: [

          _dataCell(
            width: 55,

            child: Center(
              child: isActive
                  ? Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF2E7D32),
                      ),
                    )
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF737983),
                      ),
                    ),
            ),
          ),

          _dataCell(width: 70, child: _primaryText(item['wO_NO'])),

          _dataCell(width: 70, child: _centerText(item['wO_NO_SERIES'])),

          _dataCell(width: 100, child: _primaryText(item['customeR_NAME'])),

          _dataCell(width: 120, child: _centerText(item['baG_REF'])),

          _dataCell(width: 130, child: _centerText(item['inquirY_NO'])),

          _dataCell(width: 100, child: _centerText(item['baG_TYPE'])),

          _dataCell(width: 120, child: _statusBadge(status)),
        ],
      ),
    );
  }


  Widget _dataCell({required double width, required Widget child}) {
    return Container(
      width: width,

      height: double.infinity,

      alignment: Alignment.centerLeft,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: .8),
        ),
      ),

      child: child,
    );
  }


  Widget _primaryText(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return Text(
      text.isEmpty ? '-' : text,

      maxLines: 1,

      overflow: TextOverflow.ellipsis,

      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF30343B),
      ),
    );
  }


  Widget _centerText(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return Align(
      alignment: Alignment.center,

      child: Text(
        text.isEmpty ? '-' : text,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        textAlign: TextAlign.center,

        style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
      ),
    );
  }


  Widget _statusBadge(String status) {
    if (status.isEmpty) {
      return const Center(
        child: Text(
          '-',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      );
    }

    final bool quality = status == 'QUALITY';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

        decoration: BoxDecoration(
          color: quality ? const Color(0xFFFFE4DA) : const Color(0xFFEAF2FF),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 6,
              height: 6,

              decoration: BoxDecoration(
                color: quality
                    ? const Color(0xFFE4572E)
                    : const Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              status,

              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: quality
                    ? const Color(0xFFC2411D)
                    : const Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _loadingMoreRow() {
    return Container(
      height: 70,

      alignment: Alignment.center,

      child: const Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            width: 18,
            height: 18,

            child: CircularProgressIndicator(strokeWidth: 2),
          ),

          SizedBox(width: 10),

          Text(
            'Loading more records...',
            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }


  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F6),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, size: 32, color: const Color(0xFF7B8491)),
            ),

            const SizedBox(height: 16),

            Text(
              title,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF30343B),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12, color: Color(0xFF7A808A)),
            ),
          ],
        ),
      ),
    );
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        behavior: SnackBarBehavior.floating,

        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }
}

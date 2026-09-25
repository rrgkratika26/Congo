import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/statusTrackerServices.dart';
import 'StatusTrackerModel.dart';

class OrderLifecycleScreen extends StatefulWidget {
  final OrderStatusItem order;

  const OrderLifecycleScreen({super.key, required this.order});

  @override
  State<OrderLifecycleScreen> createState() => _OrderLifecycleScreenState();
}

class _OrderLifecycleScreenState extends State<OrderLifecycleScreen> {
  List<LifecycleStage> _stages = [];
  TrackingHeader? _header;
  String _currentStage = '';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  // ==========================================================
  // LOAD TRACKING
  // ==========================================================

  Future<void> _loadTracking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await StatusTrackerService.trackOrder(
        widget.order.generatedInquiry,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _header = result.data?.header;
          _currentStage = result.data!.currentStage;
          _stages = result.data!.timeline;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message.isNotEmpty
              ? result.message
              : 'Unable to track order';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load tracking data';
      });
    }
  }

  int get _completedCount => _stages.where((s) => s.completed).length;

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg ?? const Color(0xFFF5F6F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: C.primary ?? Colors.indigo,
        title: Text(
          'Tracking - ${widget.order.generatedInquiry}',
          style: TextStyle(color: C.bg),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTracking,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadTracking,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTracking,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderInfo(),
          const SizedBox(height: 16),
          _buildTimeline(),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER INFO
  // ==========================================================

  Widget _buildHeaderInfo() {
    final header = _header;
    if (header == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Divider(),
            _detailRow('Customer', header.customerName),
            _detailRow('Inquiry No', header.generatedInquiry),
            _detailRow('Article', header.articleNo),
            _detailRow('Quantity', header.quantity),
            _detailRow('Type', header.typee),
            _detailRow('Bag Size', header.sizeDisplay),
            _detailRow('Inquiry Date', header.inquiryDate),
            if (_currentStage.isNotEmpty)
              _detailRow('Current Stage', _currentStage),
            _detailRow(
              'Progress',
              '$_completedCount / ${_stages.length} stages',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TIMELINE (simple list, no external package)
  // ==========================================================

  Widget _buildTimeline() {
    if (_stages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text('No tracking stages available'),
        ),
      );
    }

    return Card(
      color: C.bg,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Department Tracking',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Divider(),
            ...List.generate(_stages.length, (index) {
              final stage = _stages[index];
              final isLast = index == _stages.length - 1;
              return _buildStageRow(stage, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStageRow(LifecycleStage stage, bool isLast) {
    final completed = stage.completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dot + line
          Column(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? Colors.green : Colors.grey,
                size: 20,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: completed ? Colors.green : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name.isEmpty ? 'Unknown' : stage.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: completed ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStageDisplayText(stage),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: completed
                          ? Colors.green.shade700
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // status badge
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: completed ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              completed ? 'DONE' : 'PENDING',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: completed ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STAGE DISPLAY TEXT
  // ==========================================================

  String _getStageDisplayText(LifecycleStage stage) {
    if (stage.details != null && stage.details!.displayValue.isNotEmpty) {
      return stage.details!.displayValue;
    }

    if (stage.completed && stage.date != null && stage.date!.isNotEmpty) {
      return _formatDateString(stage.date!);
    }

    if (stage.completed) return 'Completed';

    return 'Pending';
  }

  String _formatDateString(String value) {
    try {
      final date = DateTime.parse(value).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatefulWidget {
  final DateTime initialFromDate;
  final DateTime initialToDate;
  final Function(DateTime from, DateTime to) onDateChanged;

  const DateRangeFilter({
    Key? key,
    required this.initialFromDate,
    required this.initialToDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.light(primary: Color(0xFF42A5F6)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });

      widget.onDateChanged(_fromDate, _toDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF42A5F6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'From Date',
                  date: _fromDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: 'To Date',
                  date: _toDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF42A5F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF42A5F6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF42A5F6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

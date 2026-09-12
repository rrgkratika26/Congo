import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'WastageController.dart';
import 'WastageEntryController.dart';


class WastageEntryScreen extends StatelessWidget {
  const WastageEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String department =
        Get.arguments?['department'] as String? ?? 'UNKNOWN';
    final c = Get.find<WastageEntryController>(tag: department);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('WASTAGE · ${department.toUpperCase()}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        )),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: c.loadAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerBar(c),
              const SizedBox(height: 16),
              _formCard(c),
              const SizedBox(height: 16),
              _actionButtons(c),
              const SizedBox(height: 20),
              _totalsCard(c),
              const SizedBox(height: 12),
              Text('Entries',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...c.entries.map((e) => _entryTile(c, e)),
              if (c.entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No entries yet',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _headerBar(WastageEntryController c) {
    return Obx(() => Card(
      elevation: 0,
      color: const Color(0xFFE9EDF3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _labelValue('SR. NO.', c.srNo.value.toString()),
            _labelValue(
                'DATE', DateFormat('dd-MMM-yyyy').format(c.date.value)),
          ],
        ),
      ),
    ));
  }

  Widget _labelValue(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
      Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _formCard(WastageEntryController c) {
    return Obx(() => Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown('Party Name', c.partyList, c.selectedParty),
            _dropdown('PO', c.poList, c.selectedPo),
            _dropdown('Article No', c.articleList, c.selectedArticle),
            _dropdown('Supervisor Name', c.supervisorList, c.selectedSupervisor),
            _dropdown('Wastage Type', c.wastageTypeList, c.selectedWastageType),
            _dropdown('Operator', c.operatorList, c.selectedOperator),
            _textField('Weight (Kg)', c.weightCtrlText,
                keyboardType: TextInputType.number),
            _textField('Deposit Qty', c.depositCtrlText,
                keyboardType: TextInputType.number),
            _dropdown('Shift', c.shiftList, c.selectedShift),
            if (c.showLoomNo)
              _dropdown('Loom No', c.loomNoList, c.selectedLoomNo),
            _textField('Remark', c.remarkCtrlText, maxLines: 2),
          ],
        ),
      ),
    ));
  }

  Widget _dropdown(String label, List<String> items, Rxn<String> selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selected.value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: (v) => selected.value = v,
      ),
    );
  }

  Widget _textField(String label, RxString bind,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: bind.value,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (v) => bind.value = v,
      ),
    );
  }

  Widget _actionButtons(WastageEntryController c) {
    Widget btn(String label, IconData icon, VoidCallback onTap, Color color) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 16, color: color),
            label: Text(label, style: TextStyle(color: color, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      );
    }

    return Wrap(
      children: [
        Row(children: [
          btn('New', Icons.add, c.newEntry, const Color(0xFF287DB3)),
          btn('Save', Icons.save, c.saveEntry, const Color(0xFF0D9488)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          btn('Delete', Icons.delete_outline, c.deleteEntry, Colors.red),
          btn('Clear', Icons.clear, c.clearForm, Colors.grey.shade700),
        ]),
      ],
    );
  }

  Widget _totalsCard(WastageEntryController c) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEE7D00),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _totalItem('Total Weight', c.totalWeight),
          Container(width: 1, height: 32, color: Colors.white54),
          _totalItem('Total Deposit', c.totalDeposit),
        ],
      ),
    ));
  }

  Widget _totalItem(String label, double value) => Column(
    children: [
      Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
      Text(value.toStringAsFixed(2),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
    ],
  );

  Widget _entryTile(WastageEntryController c, WastageEntryModel e) {
    return Obx(() {
      final selected = c.selectedEntryId.value == e.id;
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selected ? const Color(0xFF287DB3) : const Color(0xFFE5E7EB),
              width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => c.loadIntoForm(e),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF287DB3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${e.supervisor ?? '-'} · ${e.date}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${e.weight} kg',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(e.status,
                        style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
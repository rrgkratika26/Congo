import 'package:flutter/material.dart';

class LaminationOutScreen extends StatelessWidget {
  const LaminationOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Row(
          children: [
            const _SideBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : constraints.maxWidth > 800
                        ? 2
                        : 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        const SizedBox(height: 16),

                        /// Responsive Sections
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _sectionCard(
                              width: _getWidth(constraints, crossAxisCount),
                              title: "Material & Fabric",
                              children: _materialFields(),
                            ),
                            _sectionCard(
                              width: _getWidth(constraints, crossAxisCount),
                              title: "Lamination Details",
                              children: _laminationFields(),
                            ),
                            _sectionCard(
                              width: _getWidth(constraints, crossAxisCount),
                              title: "Order Details",
                              children: _orderFields(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _remarkBox(),
                        const SizedBox(height: 20),
                        _bottomBar(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getWidth(BoxConstraints constraints, int count) {
    return (constraints.maxWidth - (16 * (count - 1))) / count;
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "LAMINATION OUT",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _dateField(),
            const SizedBox(width: 10),
            _timeField(),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print),
              label: const Text("Print Barcode"),
            ),
          ],
        )
      ],
    );
  }

  Widget _dateField() {
    return SizedBox(
      width: 150,
      child: TextField(
        decoration: InputDecoration(
          labelText: "Date",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _timeField() {
    return SizedBox(
      width: 120,
      child: TextField(
        decoration: InputDecoration(
          labelText: "Time",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required double width,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 8),
          ...children
        ],
      ),
    );
  }

  /// ================= FIELDS =================

  List<Widget> _materialFields() => [
    _field("Party Name"),
    _field("Article No"),
    _field("Required Qty (Kg)"),
    _field("Loom No"),
    _field("Machine Type"),
    _field("Fabric Type"),
    _field("Color (Warp/Weft)"),
    _field("Fabric GSM"),
    _field("Gross Weight"),
    _field("Tare Weight"),
    _field("Avg Weight"),
  ];

  List<Widget> _laminationFields() => [
    _field("PO No"),
    _field("BOM"),
    _field("Required Qty (Mtr)"),
    _field("Loom Type"),
    _field("Operator Name"),
    _field("Fabric Width"),
    _field("Lamination Type"),
    _field("Cut Type"),
    _field("Roll Length"),
    _field("Roll Weight"),
  ];

  List<Widget> _orderFields() => [
    _field("O No"),
    _field("Week No"),
    _field("Order Type"),
    _field("Mesh"),
    _field("Computer Operator"),
    _field("Batch No"),
  ];

  Widget _field(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _remarkBox() {
    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Remark",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _bottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              labelText: "Roll No",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text("Generate Code"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Finish"),
            ),
          ],
        )
      ],
    );
  }
}

/// ================= SIDEBAR =================

class _SideBar extends StatelessWidget {
  const _SideBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        children: [
          _icon(Icons.add, "New"),
          _icon(Icons.save, "Save"),
          _icon(Icons.delete, "Delete"),
          _icon(Icons.edit, "Update"),
          _icon(Icons.clear, "Clear"),
          _icon(Icons.exit_to_app, "Exit"),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 28),
          Text(label, style: const TextStyle(fontSize: 10))
        ],
      ),
    );
  }
}
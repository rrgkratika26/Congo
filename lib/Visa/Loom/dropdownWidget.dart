import 'package:flutter/material.dart';

import 'modelClass/LoomMasterModel.dart';

Widget buildDropdown({
  required String label,
  required List<LoomMasterModel> list,
  required String? value,
  required Function(String?) onChanged,
  required bool isLoading,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 6),

      isLoading
          ? CircularProgressIndicator()
          : DropdownButtonFormField<String>(
        value: value,
        hint: Text("Select $label"),
        items: list.map((e) {
          return DropdownMenuItem(
            value: e.name,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    ],
  );
}
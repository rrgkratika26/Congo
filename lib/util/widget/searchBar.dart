import 'package:flutter/material.dart';

class InlineSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const InlineSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 3, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),

          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: TextStyle(color: Colors.grey.shade500),

            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 20,
            ),

            // ✅ Clear button
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                controller.clear();
                onChanged("");
              },
            )
                : null,

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
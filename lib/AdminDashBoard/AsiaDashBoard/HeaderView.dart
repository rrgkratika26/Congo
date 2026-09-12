import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Color/Colorclass.dart';
import '../DepartmentDashboard.dart';

class Header extends StatelessWidget {
  final DashboardController ctrl;
  final bool isMobile;
  const Header({required this.ctrl, required this.isMobile, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // extra breakpoint for very small phones
    final isSmall = screenWidth < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 28,
        vertical: isMobile ? 12 : 18,
      ),
      decoration: const BoxDecoration(
        color: C.appBar1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipOval(
            child: Container(
              width: isSmall ? 36 : 45,
              height: isSmall ? 36 : 45,
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: C.bg,
                size: isSmall ? 24 : 32,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Middle title — flexible + fitted so it never overflows
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                        () => ctrl.unit.value.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        ctrl.unit.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: C.bg,
                          fontSize: isMobile ? 18 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'ERP',
                    maxLines: 1,
                    style: TextStyle(
                      color: C.warning,
                      fontSize: isMobile ? 18 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Logout Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: isSmall ? 32 : 40,
              minHeight: isSmall ? 32 : 40,
            ),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: C.textHigh),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: C.danger),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ctrl.logout();
              }
            },
            icon: Icon(
              Icons.logout_rounded,
              color: C.bg,
              size: isSmall ? 20 : 25,
            ),
          ),
        ],
      ),
    );
  }
}
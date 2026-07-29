import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';

class NavItemData {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavItemData({required this.icon, this.activeIcon, required this.label});
}

/// Floating pill-style bottom nav, gold accent (`NavColors`), matches the
/// existing PhonePe-style / flat-card design language.
///
/// Usage:
///   Scaffold(
///     body: ...,
///     bottomNavigationBar: DashboardBottomNav(
///       currentIndex: _index,
///       onTap: (i) => setState(() => _index = i),
///       items: const [
///         NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: "Dashboard"),
///         NavItemData(icon: Icons.insert_chart_outlined_rounded, activeIcon: Icons.insert_chart_rounded, label: "Reports"),
///         NavItemData(icon: Icons.apps_outlined, activeIcon: Icons.apps_rounded, label: "Departments"),
///         NavItemData(icon: Icons.more_horiz_rounded, label: "More"),
///       ],
///     ),
///   )
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Swap this for your actual NavColors.gold token if it differs.
    const gold = Color(0xFFD9B554);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < items.length; i++)
              _NavButton(
                data: items[i],
                selected: i == currentIndex,
                accent: gold,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItemData data;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _NavButton({
    required this.data,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? (data.activeIcon ?? data.icon) : data.icon,
              color: selected ? accent : (C.textLow ?? Colors.black45),
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  data.label,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              )
                  : const SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
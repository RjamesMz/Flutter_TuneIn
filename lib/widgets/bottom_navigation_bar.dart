import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// ─── Bottom Navigation Bar (StatelessWidget) ─────────────────────────────────
// Receives the current active tab index and an onTap callback.
// MainScreen controls the selected tab via IndexedStack.

class BottomNavBar extends StatelessWidget {
  final int currentIndex; // 0=Home, 1=Search, 2=Playlist, 3=Profile
  final void Function(int) onTap; // called when a tab is tapped

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home,             label: 'Home',       index: 0, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.search,           label: 'Search',     index: 1, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.headphones,       label: 'Playlist',   index: 2, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person,           label: 'Profile',    index: 3, currentIndex: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? kSurfaceContainerHighest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? kOnSurface : kOnSurfaceVariant, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? kOnSurface : kOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

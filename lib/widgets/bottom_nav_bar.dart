import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// ─── Bottom Navigation Bar (StatelessWidget) ─────────────────────────────────
// Receives the current active tab index, draws 4 nav items.
// Tapping an item uses named routing to navigate.

class BottomNavBar extends StatelessWidget {
  final int currentIndex; // 0=Home, 1=Library, 2=Playlists, 3=Profile

  const BottomNavBar({super.key, required this.currentIndex});

  // Maps tab index → named route string
  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; 
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/library');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/playlists');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

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
            _NavItem(icon: Icons.home,          label: 'Home',      index: 0, currentIndex: currentIndex, onTap: (i) => _onTap(context, i)),
            _NavItem(icon: Icons.library_music, label: 'Library',   index: 1, currentIndex: currentIndex, onTap: (i) => _onTap(context, i)),
            _NavItem(icon: Icons.queue_music,   label: 'Playlists', index: 2, currentIndex: currentIndex, onTap: (i) => _onTap(context, i)),
            _NavItem(icon: Icons.person,        label: 'Profile',   index: 3, currentIndex: currentIndex, onTap: (i) => _onTap(context, i)),
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

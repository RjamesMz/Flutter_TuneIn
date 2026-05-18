/// File: lib/widgets/bottom_navigation_bar.dart
/// Role: Premium bottom navigation bar component that tracks and signals index selections
/// for active home, search, playlist, or settings pages.

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Interactive navigation bar displaying tab buttons with colored highlight overlays.
class BottomNavBar extends StatelessWidget {
  /// The active highlighted tab index (0=Home, 1=Search, 2=Playlist, 3=Settings).
  final int currentIndex;

  /// Trigger callback fired when a navigation item gets selected.
  final void Function(int) onTap;

  /// Constructs a [BottomNavBar] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [currentIndex] The current active selected tab index.
  /// [onTap] Pressed callback mapping selected index.
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  /// Builds the safe-area nav rows containing individual nav items.
  ///
  /// [context] The building context.
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
            _NavItem(icon: Icons.settings,           label: 'Settings',    index: 3, currentIndex: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

/// Helper individual item tile rendering vector icons and highlighted text indicators.
class _NavItem extends StatelessWidget {
  /// Visual leading icon.
  final IconData icon;

  /// Display name label.
  final String label;

  /// Unique item identifier index.
  final int index;

  /// Active highlighted index.
  final void Function(int) onTap;

  /// Tap callback handler.
  final int currentIndex;

  /// Constructs a [_NavItem] instance.
  ///
  /// [key] An optional key.
  /// [icon] Tab icon.
  /// [label] Text indicator name.
  /// [index] Unique index.
  /// [currentIndex] Global active index.
  /// [onTap] Press callback.
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
      // Triggers index callbacks to sync current page views dynamically.
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

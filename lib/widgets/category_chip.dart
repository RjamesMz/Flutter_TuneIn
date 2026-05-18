/// File: lib/widgets/category_chip.dart
/// Role: Premium pill chip component that displays song genres or category labels with selected color transitions.

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Renders a single category pill button inside the horizontally scrollable deck.
class CategoryChip extends StatelessWidget {
  /// The descriptive name string printed on the chip.
  final String label;

  /// Check showing if this genre card is active.
  final bool isSelected;

  /// Tap callback triggered on selection.
  final VoidCallback onTap;

  /// Constructs a [CategoryChip] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [label] Targeted category name string.
  /// [isSelected] Active highlighted state.
  /// [onTap] Select action callback.
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  /// Builds the animated colored category chip container.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return GestureDetector(
      // Triggers selection callback to load targeted category listings.
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? kOnPrimary : kOnSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

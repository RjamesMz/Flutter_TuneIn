/// File: lib/core/responsive_helper.dart
/// Role: Provides helper widgets to achieve adaptive layout constraint scaling
/// on wider monitors, laptops, and web viewports, avoiding awkward component stretching.

import 'package:flutter/material.dart';

/// Responsive wrapper that constrains content width on web platforms.
///
/// This prevents the stretched appearance on large screens by limiting
/// the maximum width and centering the content.
class ResponsiveWrapper extends StatelessWidget {
  /// The child widget to be scaled and constrained.
  final Widget child;
  
  /// Maximum width for the content on large screens (web, desktop).
  /// Defaults to 1000 pixels.
  final double maxWidth;

  /// Constructs a [ResponsiveWrapper] widget.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [child] The primary widget to display within constraints.
  /// [maxWidth] The maximum width bound enforced on widescreen viewports.
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1000,
  });

  @override
  /// Builds the adaptive/responsive constraints layout around the child widget.
  ///
  /// [context] The building context containing media query dimension updates.
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // We bypass the bounding container on smaller mobile viewports to ensure
    // we make full use of the compact edge-to-edge screen real estate.
    if (screenWidth < 800) {
      return child;
    }

    // Creates a stylized pink border container to frame the screen mock layout on large viewports.
    final bordered = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );

    // Binds the bordered layout into a centered box to prevent landscape UI stretching.
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: bordered,
      ),
    );
  }
}

/// Constrain the width of a single widget for responsive design.
///
/// Use this for wrapping specific widgets that need width constraints.
class WidthConstrainer extends StatelessWidget {
  /// The target widget to enclose.
  final Widget child;

  /// The maximum width constraint allowed.
  final double maxWidth;

  /// Constructs a [WidthConstrainer] widget.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [child] The target widget to enclose.
  /// [maxWidth] The maximum width constraint allowed.
  const WidthConstrainer({
    super.key,
    required this.child,
    this.maxWidth = 1000,
  });

  @override
  /// Enforces a maximum width bound centered in the canvas.
  ///
  /// [context] The build context for widget assembly.
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Center(
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Responsive wrapper that constrains content width on web platforms.
/// This prevents the stretched appearance on large screens by limiting
/// the maximum width and centering the content.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  
  /// Maximum width for the content on large screens (web, desktop)
  /// Defaults to 1000 pixels
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1000,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // On mobile, don't apply the pink border — return the raw child for full-width.
    if (screenWidth < 800) {
      return child;
    }

    // Wrap content in a pink border container for visual styling on larger screens.
    final bordered = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );

    // On larger screens, constrain and center the bordered content
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: bordered,
      ),
    );
  }
}

/// Constrain the width of a single widget for responsive design.
/// Use this for wrapping specific widgets that need width constraints.
class WidthConstrainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WidthConstrainer({
    super.key,
    required this.child,
    this.maxWidth = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Center(
        child: child,
      ),
    );
  }
}

/// File: lib/widgets/primary_button.dart
/// Role: Reusable premium primary CTA button component styled with custom brand gradient colors,
/// optional leading icons, action states, and custom circular loading indicator overlays.

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Renders a full-width call-to-action button decorated with smooth drop-shadows.
class PrimaryButton extends StatelessWidget {
  /// Button display name string printed in bold.
  final String label;

  /// Press callback method. If null, the button is rendered in a disabled grey state.
  final VoidCallback? onPressed;

  /// Flag indicating if the button is locked in an active async processing state.
  final bool isLoading;

  /// Optional leading vector icon decorator.
  final IconData? icon;

  /// Constructs a [PrimaryButton] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [label] Title text string.
  /// [onPressed] Tap callback.
  /// [isLoading] Loading state status.
  /// [icon] Optional leading icon.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  /// Builds the gradient container representing the brand CTA visual.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Formulates flat solid disabled colors when no press actions are configured.
          gradient: onPressed != null
              ? kSoulGradient
              : const LinearGradient(
                  colors: [Color(0xFFCBCBCB), Color(0xFFBBBBBB)],
                ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: kOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kOnPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

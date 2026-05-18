/// File: lib/widgets/settings_button.dart
/// Role: Reusable premium Settings List Tile component showcasing leading icons,
/// text titles, and navigating chevron decorators for the options lists.

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Styled individual settings options row wrapper widget.
class SettingsTile extends StatelessWidget {
  /// Visual leading category icon.
  final IconData icon;

  /// Custom setting display title string.
  final String label;

  /// Optional action trigger callback.
  final VoidCallback? onTap;

  /// Constructs a [SettingsTile] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [icon] Leading options category icon.
  /// [label] Setting title label.
  /// [onTap] Optional pressed callback.
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  /// Builds the decorated tile container.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      // Formulates list rows with premium subtle background containers.
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: kPrimary, size: 22),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: kOnSurfaceVariant),
        onTap: onTap ?? () {},
      ),
    );
  }
}

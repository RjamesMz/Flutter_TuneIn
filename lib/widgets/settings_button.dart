import 'package:flutter/material.dart';

import '../core/app_colors.dart';

// ─── Settings Tile ────────────────────────────────────────────────────────────
/// A reusable styled list tile for settings-style navigation rows.
/// Shows a leading [icon], a [label], and a trailing chevron.
/// Tap behaviour is provided via the optional [onTap] callback.
class SettingsTile extends StatelessWidget {
  final IconData      icon;
  final String        label;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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

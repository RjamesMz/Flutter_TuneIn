/// File: lib/screens/user_screen/settings_screen.dart
/// Role: Tab view representing user dashboard configurations. Displays profile details,
/// active library statistics (liked counts, playlist amounts), routes to FAQ lists, and logout triggers.

// ignore_for_file: use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:tunely/widgets/settings_button.dart';
import 'package:tunely/widgets/primary_button.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/responsive_helper.dart';
import 'personal_info_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'dart:io';

/// Screen widget displaying the user settings dashboard panel.
class SettingsScreen extends StatelessWidget {
  /// Constructs a [SettingsScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const SettingsScreen({super.key});

  @override
  /// Builds the settings view layout including stats summaries.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: ResponsiveWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryContainer, width: 3),
                    ),
                    child: ClipOval(
                      child: (user?.avatarUrl ?? '').isNotEmpty
                          ? (user!.avatarUrl.startsWith('http')
                                ? Image.network(
                                    user.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatarPlaceholder(),
                                  )
                                : Image.file(
                                    File(user.avatarUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatarPlaceholder(),
                                  ))
                          : _avatarPlaceholder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                (user?.username != null && user!.username!.isNotEmpty)
                    ? '@${user.username}'
                    : user?.name ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 8),

              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Playlists',
                          value: userProvider.playlists.keys.length.toString(),
                        ),
                        _VerticalDivider(),
                        _StatItem(
                          label: 'Liked',
                          value: userProvider.likedSongIds.length.toString(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              SettingsTile(
                icon: Icons.badge_outlined,
                label: AppStrings.personalInfo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalInfoScreen(user: user),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy',
                onTap: () => Navigator.pushNamed(context, '/privacy'),
              ),
              SettingsTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () => Navigator.pushNamed(context, '/help_support'),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Logout',
                icon: Icons.logout,
                onPressed: () async {
                  // Resets authorization tokens and clears the active screen routes before returning to login.
                  await context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

Widget _avatarPlaceholder() => Container(
  color: kSurfaceContainerHighest,
  child: const Icon(Icons.person, color: kPrimary, size: 40),
);

// HELPER WIDGETS

/// Helper layout class displaying statistics counts.
class _StatItem extends StatelessWidget {
  /// Header category label.
  final String label;

  /// Amount statistics to show.
  final String value;

  /// Constructs a [_StatItem] instance.
  ///
  /// [key] An optional key.
  /// [label] Title description.
  /// [value] Calculated statistic amount.
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kOnSurfaceVariant),
        ),
      ],
    );
  }
}

/// Decorative vertical line layout widget.
class _VerticalDivider extends StatelessWidget {
  /// Constructs a [_VerticalDivider] instance.
  ///
  /// [key] An optional key.
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: kOutlineVariant);
  }
}

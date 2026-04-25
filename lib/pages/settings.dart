import 'package:flutter/material.dart';
import 'package:tunely/widgets/settings_button.dart';
import 'package:tunely/widgets/primary_button.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';


// PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ──────────────────────────────────────────────────────────
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
                  child: Container(
                    color: kSurfaceContainerHighest,
                    child: const Icon(Icons.person, color: kPrimary, size: 48),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: kSoulGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Name ────────────────────────────────────────────────────────────
          const Text(
            'Renan James',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kOnSurface,
            ),
          ),
          const Text(
            'renanjames@gmail.com',
            style: TextStyle(fontSize: 13, color: kOnSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // ── Plan Badge ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: kSoulGradient,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Stats Row ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Playlists', value: '12'),
                _VerticalDivider(),
                _StatItem(label: 'Following', value: '48'),
                _VerticalDivider(),
                _StatItem(label: 'Liked', value: '128'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Settings Tiles ──────────────────────────────────────────────────
           SettingsTile(
            icon: Icons.badge_outlined,
            label: AppStrings.personalInfo,
            onTap: () => Navigator.pushNamed(context, '/personal_info'),
          ),
          SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications'),
          SettingsTile(icon: Icons.download_outlined,      label: 'Downloads'),
          SettingsTile(icon: Icons.privacy_tip_outlined,   label: 'Privacy'),
          SettingsTile(icon: Icons.headphones_outlined,    label: 'Audio Quality'),
          SettingsTile(icon: Icons.help_outline,           label: 'Help & Support'),
          const SizedBox(height: 28),

          // ── Logout Button ───────────────────────────────────────────────────
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
              context, 
              '/login',
              (route)=> false,
              
              );
            },
          ),
        ],
      ),
    );
  }
}

// HELPER WIDGETS

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
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
        Text(label, style: const TextStyle(fontSize: 12, color: kOnSurfaceVariant)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: kOutlineVariant);
  }
}



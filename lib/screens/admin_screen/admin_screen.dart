/// File: lib/screens/admin_screen/admin_screen.dart
/// Role: Renders the central administrative control dashboard screen.
/// Offers navigation buttons to manage songs, upload new tracks, and log out.

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_song_screen.dart';
import 'manage_songs_screen.dart';
import '../../core/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Screen widget displaying the primary dashboard options for administrator users.
class AdminScreen extends StatelessWidget {
  /// Constructs an [AdminScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const AdminScreen({super.key});

  @override
  /// Builds the layout grid of control option cards.
  ///
  /// [context] The widget build context.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: kSoulGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/logo/TuneIn_Logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  'TuneIn',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kOnPrimary.withValues(alpha: 0.7),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Admin Dashboard',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kOnPrimary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AdminCard(
                        icon: Icons.cloud_upload_rounded,
                        title: 'Upload New Song',
                        subtitle:
                            'Add music, cover art, and metadata to the library.',
                        color: kPrimary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UploadSongScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AdminCard(
                        icon: Icons.library_music_rounded,
                        title: 'Manage Songs',
                        subtitle: 'View and remove songs from the library.',
                        color: Colors.pinkAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageSongsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AdminCard(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your admin account.',
                        color: kTertiary,
                        onTap: () async {
                          await context.read<AuthProvider>().logout();

                          // Restores the navigation context and clears page routes completely to block unauthorized browser back-clicks.
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom dashboard option card representation.
class _AdminCard extends StatelessWidget {
  /// The leading visual icon mapping to the administrative control action.
  final IconData icon;

  /// The primary header text.
  final String title;

  /// Detailed descriptive caption of the option.
  final String subtitle;

  /// Primary theme accent color.
  final Color color;

  /// Action listener called when the card is pressed.
  final VoidCallback onTap;

  /// Constructs an [_AdminCard] instance.
  ///
  /// [icon] The leading icon.
  /// [title] The main title.
  /// [subtitle] Detailed descriptive text.
  /// [color] Visual accent color.
  /// [onTap] Callback triggered on tap.
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  /// Renders the card row contents decorated with visual shadows.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOutlineVariant),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: kOnPrimary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kOnSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      color: kOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: kOnSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

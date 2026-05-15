import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../core/responsive_helper.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kOnPrimary,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kSoulGradient),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: kOnPrimary),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header: Icon & Welcome ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Image.asset(
                  'assets/image/logo/TuneIn_Logo.png',
                  height: 56,
                  width: 56,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'How can we help you today?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kOnSurface,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 24),

              // ── Search Bar ────────────────────────────────────────────────
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for articles, topics, or FAQs',
                  hintStyle: GoogleFonts.beVietnamPro(
                    color: kOnSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: kOnSurfaceVariant),
                  filled: true,
                  fillColor: kSurfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.beVietnamPro(
                  color: kOnSurface,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // ── Categories ────────────────────────────────────────────────
              _helpCategoryCard(
                icon: Icons.music_note_rounded,
                title: 'Audio & Playback',
                description: 'Fixes for buffering, low volume, or connection drops',
              ),
              _helpCategoryCard(
                icon: Icons.star_rounded,
                title: 'Premium Features',
                description: 'Information about subscriptions or ad-free listening',
              ),
              _helpCategoryCard(
                icon: Icons.devices_rounded,
                title: 'Device Compatibility',
                description: 'How to connect the app to Bluetooth speakers or car systems',
              ),
              _helpCategoryCard(
                icon: Icons.security_rounded,
                title: 'Account & Privacy',
                description: 'Update your password, email, or manage your data',
              ),
              const SizedBox(height: 32),

              // ── Contact Support Button ────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: kSoulGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final messengerUrl = Uri.parse('https://m.me/renanjames.miranda.1');
                      final facebookUrl = Uri.parse('https://www.facebook.com/renanjames.miranda.1');
                      
                      try {
                        // Try to open Messenger app first
                        if (await canLaunchUrl(messengerUrl)) {
                          await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
                        } else {
                          // Fall back to Facebook web URL if Messenger app isn't installed
                          await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        // If anything fails, try the web URL
                        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mail_outline_rounded, color: kOnPrimary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Contact Support',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kOnPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Available 24/7 via Email or Chat',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: kOnSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpCategoryCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kOutlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kPrimary, size: 24),
          ),
          const SizedBox(width: 16),

          // ── Title & Description ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: kOnSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Arrow ─────────────────────────────────────────────────────
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: kOnSurfaceVariant,
            size: 18,
          ),
        ],
      ),
    );
  }
}

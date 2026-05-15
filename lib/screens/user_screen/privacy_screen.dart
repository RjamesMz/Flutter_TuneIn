// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive_helper.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.65,
      letterSpacing: 0.1,
      color: kOnSurface.withValues(alpha: 0.96),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy',
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kSurface, kBackground],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: kSoulGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kOnPrimary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.privacy_tip_rounded, color: kOnPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TUNEIN',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: kOnPrimary.withValues(alpha: 0.72),
                                    letterSpacing: 3.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Privacy',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: kOnPrimary,
                                    letterSpacing: 0.15,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.10),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'A concise guide to how TuneIn handles your information',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    color: kOnPrimary.withValues(alpha: 0.86),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip('Effective date: May 15, 2026'),
                          _infoChip('Last updated: May 15, 2026'),
                          _infoChip('Academic use only'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  title: '1. Introduction',
                  icon: Icons.wb_sunny_outlined,
                  child: _paragraph(
                    context,
                    'TuneIn is a student project built for educational purposes only. It is not intended for commercial use and is not affiliated with any company or organization. This notice explains, in plain language, how we handle your information when you use the app.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '2. Information We Collect',
                  icon: Icons.badge_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paragraph(context, 'We collect the following information when you create an account or use the app:', style: textStyle),
                      const SizedBox(height: 10),
                      _bullet(context, 'Name', 'Used to personalize your experience'),
                      _bullet(context, 'Email Address', 'Used for account creation and login'),
                      _bullet(context, 'Notification Preferences', 'Used to send you relevant app notifications'),
                      const SizedBox(height: 8),
                      _paragraph(
                        context,
                        'We do not collect location data, payment information, or any other sensitive personal data.',
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: '3. How We Use Your Information',
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paragraph(context, 'Your information is used solely for the following purposes:', style: textStyle),
                      const SizedBox(height: 10),
                      _bullet(context, 'Create and manage your account'),
                      _bullet(context, 'Identify you within the app'),
                      _bullet(context, 'Send notifications based on your preferences'),
                      _bullet(context, 'Support academic evaluation and demonstration purposes'),
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: '4. Data Storage',
                  icon: Icons.cloud_outlined,
                  child: _paragraph(
                    context,
                    'All data collected is stored securely. As this is a student project, data may be stored on Firebase or similar third-party services used for educational purposes. We do not sell, trade, or share your data with any third parties for commercial purposes.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '5. Notifications',
                  icon: Icons.notifications_outlined,
                  child: _paragraph(
                    context,
                    'If you grant permission, TuneIn may send you push notifications. You can disable notifications at any time through your device settings.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '6. No Commercial Use',
                  icon: Icons.handshake_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paragraph(context, 'TuneIn is developed strictly as an academic/student project. It is not intended for:', style: textStyle),
                      const SizedBox(height: 10),
                      _bullet(context, 'Commercial distribution'),
                      _bullet(context, 'Monetization'),
                      _bullet(context, 'Public release beyond academic evaluation'),
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: '7. Copyright Disclaimer',
                  icon: Icons.copyright_outlined,
                  child: _paragraph(
                    context,
                    'TuneIn does not claim ownership over any third-party content, trademarks, or intellectual property. All music, media, or content referenced within the app belongs to their respective owners. TuneIn does not reproduce, distribute, or profit from any copyrighted material. This app is created for educational purposes only under the principles of fair use for academic work.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '8. Children\'s Privacy',
                  icon: Icons.child_care_outlined,
                  child: _paragraph(
                    context,
                    'TuneIn is not directed at children under the age of 13. We do not knowingly collect personal information from children.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '9. Your Rights',
                  icon: Icons.shield_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paragraph(context, 'You have the right to:', style: textStyle),
                      const SizedBox(height: 10),
                      _bullet(context, 'Request access to your personal data'),
                      _bullet(context, 'Request deletion of your account and data'),
                      _bullet(context, 'Opt out of notifications at any time'),
                      const SizedBox(height: 8),
                      _paragraph(context, 'To exercise any of these rights, contact the developer directly.', style: textStyle),
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: '10. Changes to This Notice',
                  icon: Icons.update_outlined,
                  child: _paragraph(
                    context,
                    'Since this is a student project, this Privacy Notice may be updated as the app evolves. Any changes will be reflected with an updated effective date.',
                    style: textStyle,
                  ),
                ),
                _sectionCard(
                  context,
                  title: '11. Contact',
                  icon: Icons.contact_mail_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paragraph(
                        context,
                        'This app was developed as a student project by:',
                        style: textStyle,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Renan James Z. Miranda\nAce S. Ogalesco\nJayvee E. Alapide\nJohn Llyod R. Ramigoso\nRosalio R. Oclo Jr',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                          color: kOnSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _paragraph(
                        context,
                        'Students — CatSu (Catanduanes State University)\nVirac, Catanduanes, Philippines',
                        style: textStyle,
                      ),
                      const SizedBox(height: 10),
                      _paragraph(
                        context,
                        'For any concerns regarding your data, please reach out to any of the developers directly.',
                        style: textStyle,
                      ),
                      const SizedBox(height: 10),
                      _paragraph(
                        context,
                        'This Privacy was created for academic purposes. TuneIn is a non-commercial student project.',
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kOutlineVariant.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: kOnSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kOnPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kOnPrimary.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kOnPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _paragraph(
    BuildContext context,
    String text, {
    TextStyle? style,
  }) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65),
    );
  }

  Widget _bullet(BuildContext context, String title, [String? detail]) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 7),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: kOnSurface,
                      ),
                  children: [
                    TextSpan(
                      text: detail == null ? title : '$title',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: kOnSurface),
                    ),
                    if (detail != null)
                      TextSpan(
                        text: ' — $detail',
                        style: TextStyle(color: kOnSurface.withValues(alpha: 0.9)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}


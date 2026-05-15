// ignore_for_file: unnecessary_const, unnecessary_underscores, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/responsive_helper.dart';
import '../../models/subscription_plan.dart';
import '../../models/user.dart';
import '../../widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';


class PersonalInfoScreen extends StatelessWidget {
  final User? user;
  const PersonalInfoScreen({super.key, this.user});
  
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser ?? user;
        final userPlanStr = currentUser?.plan ?? 'free';
        final userPlan = SubscriptionPlan.getPlanById(userPlanStr);
        final isPremium = userPlan.id != 'free';

        return Scaffold(
          backgroundColor: kBackground,
          body: ResponsiveWrapper(
            child: CustomScrollView(
        slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: kBackground,
                elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: kOnSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              AppStrings.personalInfo,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kOnSurface),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimary, kPrimaryContainer],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1200,
                            maxHeight: 1200,
                            imageQuality: 85,
                          );
                          if (picked == null) return;
                          final file = File(picked.path);
                          final success = await authProvider.updateAvatar(file);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? 'Profile picture updated' : 'Failed to update picture')),
                          );
                        },
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withAlpha(153), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(38),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _buildAvatarImage(currentUser?.avatarUrl),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                       Text(
                        currentUser?.name ?? 'Guest',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                          currentUser?.email ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(204)),
                      ),
                    ],
  
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  const _SectionHeader(title: 'Personal Information'),
                  const SizedBox(height: 12),
                   _InfoCard(
                    children: [
                       _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: currentUser?.name ?? '—',
                        onTap: () => _showEditDialog(
                          context,
                          'Full Name',
                          currentUser?.name,
                          (val) => authProvider.updateUserProfile(name: val),
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.alternate_email,
                        label: 'Username',
                        value: currentUser?.username != null
                            ? '@${currentUser!.username}'
                            : '—',
                        onTap: () => _showEditDialog(
                          context,
                          'Username',
                          currentUser?.username,
                          (val) => authProvider.updateUserProfile(username: val),
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: currentUser?.email ?? '—',
                        // Email is not editable
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: currentUser?.phone ?? '—',
                        isLast: true,
                        onTap: () => _showEditDialog(
                          context,
                          'Phone',
                          currentUser?.phone,
                          (val) => authProvider.updateUserProfile(phone: val),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile Details
                  const _SectionHeader(title: 'Profile Details'),
                  const SizedBox(height: 12),
                   _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Date of Birth',
                        value: _formatDob(currentUser?.dateOfBirth),
                        onTap: () => _pickDob(context, currentUser?.dateOfBirth, authProvider),
                      ),
                      _InfoRow(
                        icon: Icons.wc_outlined,
                        label: 'Gender',
                        value: currentUser?.gender ?? '—',
                        isLast: true,
                        onTap: () => _showGenderEditDialog(context, currentUser?.gender, authProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Subscription
                  const _SectionHeader(title: 'Subscription'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isPremium
                          ? kSoulGradient
                          : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isPremium ? kPrimary : Colors.grey).withAlpha(64),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isPremium ? Icons.workspace_premium : Icons.music_note,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userPlan.name} Plan',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPremium
                                    ? 'Enjoy unlimited music, offline playback & more'
                                    : 'Upgrade to unlock all features',
                                style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(217)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    children: [
                      _BenefitRow(icon: Icons.offline_pin_outlined,  label: 'Offline Playback',    enabled: isPremium),
                      _BenefitRow(icon: Icons.all_inclusive,          label: 'Unlimited Skips',     enabled: isPremium),
                      _BenefitRow(icon: Icons.high_quality_outlined,  label: 'High Quality Audio',  enabled: isPremium),
                      _BenefitRow(icon: Icons.block_outlined,         label: 'Ad-Free Experience',  enabled: isPremium, isLast: true),
                    ],
                  ),
                  if (!isPremium) ...[
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Upgrade to Premium',
                      onPressed: () {
                         Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/subscription',
                          (route)=> false,
                         );
                      },
                      icon: Icons.workspace_premium,
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: kSurfaceContainerHighest,
                            title: const Text('Cancel Subscription?', style: TextStyle(color: kOnSurface)),
                            content: const Text(
                              'Are you sure you want to cancel your premium subscription? You will lose access to offline playback and ad-free listening.',
                              style: TextStyle(color: kOnSurfaceVariant),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('No, keep it', style: TextStyle(color: kOnSurfaceVariant)),
                              ),
                              TextButton(
                                onPressed: () {
                                  authProvider.updatePlan('free');
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Subscription cancelled.')),
                                  );
                                },
                                child: const Text('Yes, cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
      },
    );
  }
  
  String _formatDob(String? iso) {
    if (iso == null) return '—';
    try {
      final parts = iso.split('-');
      if (parts.length != 3) return iso;
      final months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${parts[2]} ${months[int.parse(parts[1])]} ${parts[0]}';
    } catch (_) {
      return iso;
    }
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String? currentValue,
    Function(String) onSave, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kSurfaceContainerHighest,
          title: Text('Edit $title', style: const TextStyle(color: kOnSurface)),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(color: kOnSurface),
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $title',
              hintStyle: const TextStyle(color: kOnSurfaceVariant),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kOutlineVariant)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kPrimary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: kOnSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDob(BuildContext context, String? currentDob, AuthProvider authProvider) async {
    DateTime initialDate = DateTime(2000);
    if (currentDob != null) {
      try {
        initialDate = DateTime.parse(currentDob);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimary,
            onPrimary: Colors.white,
            surface: kSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final iso = picked.toIso8601String().split('T').first;
      authProvider.updateUserProfile(dateOfBirth: iso);
    }
  }

  void _showGenderEditDialog(BuildContext context, String? currentGender, AuthProvider authProvider) {
    String? selectedGender = currentGender;
    const genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
    if (selectedGender != null && !genders.contains(selectedGender)) {
      selectedGender = null;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kSurfaceContainerHighest,
              title: const Text('Edit Gender', style: const TextStyle(color: kOnSurface)),
              content: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGender,
                  hint: const Text('Gender (optional)', style: TextStyle(color: kOnSurfaceVariant, fontSize: 15)),
                  icon: const Icon(Icons.expand_more, color: kOnSurfaceVariant),
                  isExpanded: true,
                  dropdownColor: kSurface,
                  items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(color: kOnSurface)))).toList(),
                  onChanged: (val) {
                    setState(() => selectedGender = val);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: kOnSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () {
                    authProvider.updateUserProfile(gender: selectedGender);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(gradient: kSoulGradient, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kOnSurface)),
      ],
    );
  }
}
// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kSurfaceContainerLow, borderRadius: BorderRadius.circular(18)),
      child: Column(children: children),
    );
  }
}
// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: kPrimary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: kOnSurfaceVariant, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kOnSurface)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.edit, color: kOnSurfaceVariant, size: 16),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 50, endIndent: 16, color: kOutlineVariant),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isLast ? 18 : 0),
        child: content,
      );
    }
    return content;
  }
}
// ─── Benefit Row ──────────────────────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isLast;
  const _BenefitRow({required this.icon, required this.label, required this.enabled, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: enabled ? kPrimary : kOnSurfaceVariant, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: enabled ? kOnSurface : kOnSurfaceVariant),
                ),
              ),
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
                color: enabled ? kPrimary : kOnSurfaceVariant.withAlpha(128),
                size: 20,
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 50, endIndent: 16, color: kOutlineVariant),
      ],
    );
  }
}

Widget _avatarFallback() => Container(
  color: kSurfaceContainerHighest,
  child: const Icon(Icons.person, color: kPrimary, size: 40),
);

Widget _buildAvatarImage(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return _avatarFallback();

  if (avatarUrl.startsWith('http')) {
    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarFallback(),
    );
  }

  final file = File(avatarUrl);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarFallback(),
    );
  }

  return Image.asset(
    avatarUrl,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _avatarFallback(),
  );
}


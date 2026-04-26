import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../widgets/primary_button.dart';
class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});
  static const _name      = 'Aria Velvet';
  static const _username  = '@aria_velvet';
  static const _email     = 'aria@tunein.app';
  static const _phone     = '+1 234 567 8900';
  static const _dob       = '15 March 2000';
  static const _gender    = 'Female';
  static const _plan      = 'Premium'; // swap to 'Free' to test that state
  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDLQIKXOExnoKsmTGI9hX2tTvRmsoFlIN3Sr_kN6gQJOcYH5YJ7tsRjj7Qwc97fgrafvwEcXZDSmQkk_DorilQON2PfrMuLn5jGOaqAepLVE5s_CAAG6XjURvQQRx8WQtsGuDAmnmtVCE62_RNY5HG4MTjS3mePPCnk7DY0cxq8S4dxyMwByekQPNdOWSe278IcNeXjyikfdxY6Vj5j-u9Kk1eYHmTXAmRWvW6PwRfk2kyM3n4IwtCzjAA6BBuDshFbnIlRWQM9lFck';
  bool get _isPremium => _plan.toLowerCase() == 'premium';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
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
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kOnSurface),
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            _avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: kSurfaceContainerHighest,
                              child: const Icon(Icons.person, color: kPrimary, size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        _name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        _email,
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
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
                  const _InfoCard(
                    children: [
                      _InfoRow(icon: Icons.person_outline,    label: 'Full Name', value: _name),
                      _InfoRow(icon: Icons.alternate_email,   label: 'Username',  value: _username),
                      _InfoRow(icon: Icons.email_outlined,    label: 'Email',     value: _email),
                      _InfoRow(icon: Icons.phone_outlined,    label: 'Phone',     value: _phone, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile Details
                  const _SectionHeader(title: 'Profile Details'),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    children: [
                      _InfoRow(icon: Icons.calendar_month_outlined, label: 'Date of Birth', value: _dob),
                      _InfoRow(icon: Icons.wc_outlined,             label: 'Gender',        value: _gender, isLast: true),
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
                      gradient: _isPremium
                          ? kSoulGradient
                          : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (_isPremium ? kPrimary : Colors.grey).withOpacity(0.25),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _isPremium ? Icons.workspace_premium : Icons.music_note,
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
                                _isPremium ? 'Premium Plan' : 'Free Plan',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isPremium
                                    ? 'Enjoy unlimited music, offline playback & more'
                                    : 'Upgrade to unlock all features',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
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
                      _BenefitRow(icon: Icons.offline_pin_outlined,  label: 'Offline Playback',    enabled: _isPremium),
                      _BenefitRow(icon: Icons.all_inclusive,          label: 'Unlimited Skips',     enabled: _isPremium),
                      _BenefitRow(icon: Icons.high_quality_outlined,  label: 'High Quality Audio',  enabled: _isPremium),
                      _BenefitRow(icon: Icons.block_outlined,         label: 'Ad-Free Experience',  enabled: _isPremium, isLast: true),
                    ],
                  ),
                  if (!_isPremium) ...[
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Upgrade to Premium',
                      onPressed: () {},
                      icon: Icons.workspace_premium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Column(
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
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 50, endIndent: 16, color: kOutlineVariant),
      ],
    );
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
                color: enabled ? kPrimary : kOnSurfaceVariant.withOpacity(0.5),
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
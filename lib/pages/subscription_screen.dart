import 'package:flutter/material.dart';
import 'package:tunely/pages/checkout_screen.dart';

import '../core/app_colors.dart';

// ─── Subscription Screen ──────────────────────────────────────────────────────
/// Displays available subscription plans: Free, Plus, and Premium.

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 2;

  static const _plans = [_Plan.free, _Plan.monthly, _Plan.annual];

  void _selectPlan(int index) {
    if (index == _selectedPlan) return;
    setState(() => _selectedPlan = index);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: kBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: kOnSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Choose Your Plan',
              style: TextStyle(
                color: kOnSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),

          // ── Hero Header ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      gradient: kSoulGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Unlock the Full\nListening Experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kOnSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ad-free music, offline downloads,\nand crystal-clear audio — all in one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: kOnSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Plan Cards ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(
                    plan: _plans[i],
                    isSelected: _selectedPlan == i,
                    onTap: () => _selectPlan(i),
                  ),
                ),
                childCount: _plans.length,
              ),
            ),
          ),

          // ── CTA + Fine Print ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Column(
                children: [
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: plan == _Plan.free
                            ? LinearGradient(
                                colors: [kOutline, kOnSurfaceVariant],
                              )
                            : const LinearGradient(
                                colors: [kPrimary, kPrimaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: plan != _Plan.free
                            ? [
                                BoxShadow(
                                  color: kPrimary.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: () => _onTap(context, plan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          plan == _Plan.free
                              ? 'Continue with Free'
                              : 'Get ${plan.name} — ${plan.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Fine print
                  Text(
                    plan == _Plan.free
                        ? 'No payment required. Upgrade anytime.'
                        : 'Cancel anytime. Billed ${plan == _Plan.monthly ? "monthly" : "annually — save 30%"}.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TextLink('Terms of Service', onTap: () {}),
                      const Text(
                        '  ·  ',
                        style: TextStyle(
                          color: kOnSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      _TextLink('Privacy Policy', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, _Plan plan) {
    if (plan == _Plan.free) {
      // Free plan → go to the main screen, clearing the back stack
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } else {
      // Paid plan → go to checkout, passing the plan details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            planName: plan.name,
            planPrice: plan.price,
            planPeriod: plan.period,
          ),
        ),
      );
    }
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = plan == _Plan.annual;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? kSurfaceContainerLow : kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kPrimary : kOutlineVariant,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: BoxDecoration(
                gradient: isHighlighted
                    ? const LinearGradient(
                        colors: [kPrimary, kPrimaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.white.withOpacity(0.2)
                          : kSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      plan.icon,
                      color: isHighlighted ? Colors.white : kPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + tagline
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                plan.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isHighlighted
                                      ? Colors.white
                                      : kOnSurface,
                                ),
                              ),
                            ),
                            if (plan == _Plan.monthly) ...[
                              const SizedBox(width: 8),
                              _Badge(label: 'Most Popular', primary: true),
                            ],
                            if (plan == _Plan.annual) ...[
                              const SizedBox(width: 8),
                              _Badge(label: 'Best Value', primary: false),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.tagline,
                          style: TextStyle(
                            fontSize: 12,
                            color: isHighlighted
                                ? Colors.white.withOpacity(0.8)
                                : kOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isHighlighted ? Colors.white : kPrimary,
                        ),
                      ),
                      Text(
                        plan.period,
                        style: TextStyle(
                          fontSize: 11,
                          color: isHighlighted
                              ? Colors.white.withOpacity(0.75)
                              : kOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Feature List ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                children: plan.features
                    .map((f) => _FeatureRow(feature: f, included: f.included))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Row ──────────────────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final bool included;
  const _FeatureRow({required this.feature, required this.included});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: included
                  ? kPrimary.withOpacity(0.12)
                  : kOutlineVariant.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 13,
              color: included ? kPrimary : kOnSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            feature.label,
            style: TextStyle(
              fontSize: 13.5,
              color: included
                  ? kOnSurface
                  : kOnSurfaceVariant.withOpacity(0.55),
              fontWeight: included ? FontWeight.w500 : FontWeight.w400,
              decoration: included
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          if (feature.badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kSecondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                feature.badge!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Badge chip ───────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final bool primary;
  const _Badge({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: primary
            ? kSurfaceContainerHighest
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: primary ? kPrimary : Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Text link ────────────────────────────────────────────────────────────────
class _TextLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _TextLink(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: kPrimary,
          decoration: TextDecoration.underline,
          decorationColor: kPrimary,
        ),
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────
class _Feature {
  final String label;
  final bool included;
  final String? badge;
  const _Feature(this.label, {this.included = true, this.badge});
}

class _Plan {
  final String name;
  final String tagline;
  final String price;
  final String period;
  final IconData icon;
  final List<_Feature> features;

  const _Plan._({
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    required this.icon,
    required this.features,
  });

  static const free = _Plan._(
    name: 'Free',
    tagline: 'Start listening today',
    price: '\$0',
    period: 'forever',
    icon: Icons.music_note_rounded,
    features: [
      _Feature('Stream music online'),
      _Feature('Basic audio quality (128 kbps)'),
      _Feature('Create up to 3 playlists'),
      _Feature('Ad-free listening', included: false),
      _Feature('Offline downloads', included: false),
      _Feature('High-res audio (320 kbps)', included: false),
      _Feature('Lyrics view', included: false),
    ],
  );

  static const monthly = _Plan._(
    name: '1 Month Premium',
    tagline: 'Full access, no commitment',
    price: '\$7.99',
    period: '/ month',
    icon: Icons.star_rounded,
    features: [
      _Feature('Everything in Free'),
      _Feature('Ad-free listening'),
      _Feature('Unlimited playlists'),
      _Feature('High-quality audio (320 kbps)', badge: 'HD'),
      _Feature('Lyrics view'),
      _Feature('Offline downloads'),
      _Feature('Lossless / HiFi audio', included: false),
    ],
  );

  static const annual = _Plan._(
    name: '12 Months Premium',
    tagline: 'Best deal — save 30% vs monthly',
    price: '\$49.99',
    period: '/ year',
    icon: Icons.workspace_premium_rounded,
    features: [
      _Feature('Everything in 1 Month Premium'),
      _Feature('Lossless / HiFi audio', badge: 'LOSSLESS'),
      _Feature('Early access to new features'),
      _Feature('Priority customer support'),
      _Feature('Share with 1 family member'),
      _Feature('30% cheaper than monthly'),
    ],
  );
}

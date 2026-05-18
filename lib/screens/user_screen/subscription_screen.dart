/// File: lib/screens/user_screen/subscription_screen.dart
/// Role: Screen presenting three subscription plan tiers (Free, Plus, Premium).
/// Displays tier comparison grids, feature availability, and handles checkout/main navigation.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/screens/user_screen/checkout_screen.dart';

import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../models/subscription_plan.dart';
import '../../providers/auth_provider.dart';

/// Screen widget displaying the subscription tiers selection browse board.
class SubscriptionScreen extends StatefulWidget {
  /// Constructs a [SubscriptionScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

/// State controller managing plan selections and checkout routes in [SubscriptionScreen].
class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 2;

  static final _plans = SubscriptionPlan.availablePlans;

  /// Changes the active highlighted plan selection.
  ///
  /// [index] Target selection list index.
  void _selectPlan(int index) {
    if (index == _selectedPlan) return;
    setState(() => _selectedPlan = index);
  }

  @override
  /// Builds the subscription options card deck and CTA submit configurations.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];
    return Scaffold(
      backgroundColor: kBackground,
      body: ResponsiveWrapper(
        child: CustomScrollView(
          slivers: [
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
                          gradient: plan.id == 'free'
                              ? LinearGradient(
                                  colors: [kOutline, kOnSurfaceVariant],
                                )
                              : const LinearGradient(
                                  colors: [kPrimary, kPrimaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: plan.id != 'free'
                              ? [
                                  BoxShadow(
                                    color: kPrimary.withAlpha(89),
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
                            plan.id == 'free'
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
                      plan.id == 'free'
                          ? 'No payment required. Upgrade anytime.'
                          : 'Cancel anytime. Billed ${plan.id == 'premium' ? 'monthly' : 'annualy - save 30%'}.',
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
      ),
    );
  }

  /// Directs routes based on target premium or free options.
  ///
  /// [context] Route manager context.
  /// [plan] Subscription plan to proceed with.
  void _onTap(BuildContext context, SubscriptionPlan plan) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (plan.id == 'free') {
      // Free tier selections bypass online checkout gateways and transition instantly into primary tabs.
      authProvider.updatePlan(plan.id);
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            planId: plan.id,
            planName: plan.name,
            planPrice: plan.price,
            planPeriod: plan.period,
          ),
        ),
      );
    }
  }
}

/// Interactive individual plan card component detailing names, taglines, and prices.
class _PlanCard extends StatelessWidget {
  /// Detailed plan configurations model.
  final SubscriptionPlan plan;

  /// Selection flag.
  final bool isSelected;

  /// Trigger callback.
  final VoidCallback onTap;

  /// Constructs a [_PlanCard] instance.
  ///
  /// [key] An optional key.
  /// [plan] SubscriptionPlan representation parameters.
  /// [isSelected] Selection state.
  /// [onTap] Click handler.
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = plan.id == 'premium_annual';

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
                    color: kPrimary.withAlpha(38),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          ? Colors.white.withAlpha(51)
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
                            if (plan.id == 'monthly') ...[
                              const SizedBox(width: 8),
                              const _Badge(label: 'Most Popular', primary: true),
                            ],
                            if (plan.id == 'premium_annual') ...[
                              const SizedBox(width: 8),
                              const _Badge(label: 'Best Value', primary: false),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.tagline,
                          style: TextStyle(
                            fontSize: 12,
                            color: isHighlighted
                              ? Colors.white.withAlpha(204)
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
                              ? Colors.white.withAlpha(191)
                              : kOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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

/// Individual plan benefit checklist row indicating included properties.
class _FeatureRow extends StatelessWidget {
  /// Visual checkbox properties model.
  final PlanFeature feature;

  /// Checks if this item is included.
  final bool included;

  /// Constructs a [_FeatureRow] instance.
  ///
  /// [key] An optional key.
  /// [feature] PlanFeature configuration model.
  /// [included] Whether feature is active in target tier.
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
                  ? kPrimary.withAlpha(31)
                  : kOutlineVariant.withAlpha(102),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 13,
              color: included ? kPrimary : kOnSurfaceVariant.withAlpha(128),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            feature.label,
              style: TextStyle(
              fontSize: 13.5,
              color: included
                ? kOnSurface
                : kOnSurfaceVariant.withAlpha(140),
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

/// Decorative value highlight badge.
class _Badge extends StatelessWidget {
  /// Card description label.
  final String label;

  /// Selector distinguishing card color palettes.
  final bool primary;

  /// Constructs a [_Badge] instance.
  ///
  /// [key] An optional key.
  /// [label] Title description.
  /// [primary] Color palette selector.
  const _Badge({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: primary
            ? kSurfaceContainerHighest
            : Colors.white.withAlpha(64),
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

/// Tap-enabled underlined text links.
class _TextLink extends StatelessWidget {
  /// Linked label.
  final String text;

  /// Press callback.
  final VoidCallback onTap;

  /// Constructs a [_TextLink] instance.
  ///
  /// [key] An optional key.
  /// [text] Label string.
  /// [onTap] Pressed callback.
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

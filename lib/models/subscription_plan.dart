import 'package:flutter/material.dart';

class PlanFeature {
  final String label;
  final bool included;
  final String? badge;
  final IconData? icon;

  const PlanFeature(
    this.label, {
    this.included = true,
    this.badge,
    this.icon,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String tagline;
  final String price;
  final String period;
  final IconData icon;
  final List<PlanFeature> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    required this.icon,
    required this.features,
  });

  // Predefined plans
  static const free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
    tagline: 'Start listening today',
    price: '\$0',
    period: 'forever',
    icon: Icons.music_note_rounded,
    features: [
      PlanFeature('Stream music online', icon: Icons.wifi_tethering),
      PlanFeature('Basic audio quality (128 kbps)', icon: Icons.audiotrack),
      PlanFeature('Create up to 3 playlists', icon: Icons.queue_music),
      PlanFeature('Ad-free listening', included: false, icon: Icons.block_outlined),
      PlanFeature('Offline downloads', included: false, icon: Icons.offline_pin_outlined),
      PlanFeature('High-res audio (320 kbps)', included: false, icon: Icons.high_quality_outlined),
      PlanFeature('Lyrics view', included: false, icon: Icons.lyrics_outlined),
    ],
  );

  static const monthly = SubscriptionPlan(
    id: 'premium',
    name: '1 Month Premium',
    tagline: 'Full access, no commitment',
    price: '\$7.99',
    period: '/ month',
    icon: Icons.star_rounded,
    features: [
      PlanFeature('Everything in Free', icon: Icons.check_circle_outline),
      PlanFeature('Ad-free listening', icon: Icons.block_outlined),
      PlanFeature('Unlimited playlists', icon: Icons.queue_music),
      PlanFeature('High-quality audio (320 kbps)', badge: 'HD', icon: Icons.high_quality_outlined),
      PlanFeature('Lyrics view', icon: Icons.lyrics_outlined),
      PlanFeature('Offline downloads', icon: Icons.offline_pin_outlined),
      PlanFeature('Lossless / HiFi audio', included: false, icon: Icons.speaker),
    ],
  );

  static const annual = SubscriptionPlan(
    id: 'premium_annual',
    name: '12 Months Premium',
    tagline: 'Best deal — save 30% vs monthly',
    price: '\$49.99',
    period: '/ year',
    icon: Icons.workspace_premium_rounded,
    features: [
      PlanFeature('Everything in 1 Month Premium', icon: Icons.check_circle_outline),
      PlanFeature('Lossless / HiFi audio', badge: 'LOSSLESS', icon: Icons.speaker),
      PlanFeature('Early access to new features', icon: Icons.new_releases_outlined),
      PlanFeature('Priority customer support', icon: Icons.support_agent),
      PlanFeature('Share with 1 family member', icon: Icons.family_restroom),
      PlanFeature('30% cheaper than monthly', icon: Icons.savings_outlined),
    ],
  );

  static List<SubscriptionPlan> get availablePlans => [free, monthly, annual];

  static SubscriptionPlan getPlanById(String id) {
    return availablePlans.firstWhere(
      (p) => p.id.toLowerCase() == id.toLowerCase(),
      orElse: () => free,
    );
  }
}

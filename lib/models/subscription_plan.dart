/// File: lib/models/subscription_plan.dart
/// Role: Defines subscription plan tiers, features (PlanFeature), pricing model configurations,
/// and helper methods utilized throughout checkout and premium billing flows.

import 'package:flutter/material.dart';

/// A single plan feature entry used to describe what a subscription includes.
class PlanFeature {
  /// Short label for the feature.
  final String label;

  /// Whether the feature is included in the plan.
  final bool included;

  /// Optional small badge text (e.g. "HD", "LOSSLESS").
  final String? badge;

  /// Optional icon to show alongside the feature.
  final IconData? icon;

  /// Constructs a [PlanFeature] instance.
  ///
  /// [label] The feature description label.
  /// [included] Whether the feature is active or included in the respective tier.
  /// [badge] Optional pill badge tag (e.g. "LOSSLESS").
  /// [icon] Leading descriptive icon for the feature indicator list.
  const PlanFeature(this.label, {this.included = true, this.badge, this.icon});
}

/// Describes a subscription plan available in the app.
class SubscriptionPlan {
  /// Plan identifier (used in code and persistence).
  final String id;

  /// Human-friendly plan name.
  final String name;

  /// Short tagline shown under the name.
  final String tagline;

  /// Display price text.
  final String price;

  /// Billing period text.
  final String period;

  /// Icon used for visual badge styling.
  final IconData icon;

  /// List of features included or excluded in the plan.
  final List<PlanFeature> features;

  /// Constructs a [SubscriptionPlan] instance.
  ///
  /// [id] Plan identifier (used in code and database configurations).
  /// [name] Human-friendly plan name.
  /// [tagline] Short tagline shown under the name.
  /// [price] Display price text.
  /// [period] Billing period text.
  /// [icon] Icon used for visual badge styling.
  /// [features] List of features included or excluded in the plan.
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    required this.icon,
    required this.features,
  });

  /// Predefined free plan used by the app UI for demo purposes.
  static const free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
    tagline: 'Start listening today',
    price: '\₱0',
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

  /// Predefined monthly plan used by the app UI for demo purposes.
  static const monthly = SubscriptionPlan(
    id: 'premium',
    name: '1 Month Premium',
    tagline: 'Full access, no commitment',
    price: '\₱99 ',
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

  /// Predefined annual plan used by the app UI for demo purposes.
  static const annual = SubscriptionPlan(
    id: 'premium_annual',
    name: '12 Months Premium',
    tagline: 'Best deal — save 30% vs monthly',
    price: '\₱799',
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

  /// All available plans in display order.
  static List<SubscriptionPlan> get availablePlans => [free, monthly, annual];

  /// Returns a plan by its [id], falling back to `free` if unknown.
  ///
  /// [id] The string ID of the plan to find.
  static SubscriptionPlan getPlanById(String id) {
    return availablePlans.firstWhere(
      (p) => p.id.toLowerCase() == id.toLowerCase(),
      orElse: () => free,
    );
  }
}

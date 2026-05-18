/// File: lib/screens/user_screen/checkout_screen.dart
/// Role: Renders the subscription plan purchase checkout interface.
/// Simulates card payment confirmation, plan state updates, and main stack navigation resets.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/auth_provider.dart';

/// Screen widget providing the subscription checkout purchase form.
class CheckoutScreen extends StatelessWidget {
  /// The unique database identifier associated with the targeted subscription package.
  final String planId;

  /// The name of the premium tier selected.
  final String planName;

  /// The display price string.
  final String planPrice;

  /// The recurring payment billing interval.
  final String planPeriod;

  /// Constructs a [CheckoutScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [planId] Billing database plan ID identifier.
  /// [planName] Name string of the tier.
  /// [planPrice] Price tag string.
  /// [planPeriod] Recurring period string.
  const CheckoutScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
  });

  @override
  /// Builds the premium checkout purchase screen.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kOnSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Purchase',
          style: TextStyle(
            color: kOnSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kPrimaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withAlpha(77),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            planPrice,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              planPeriod,
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Payment Method',
                  style: TextStyle(
                    color: kOnSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kOutlineVariant, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card_rounded,
                          color: kPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add a payment method',
                          style: TextStyle(
                            color: kOnSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: kOnSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kPrimaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withAlpha(89),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        // NOTE: Since there is no active payment gateway in this application, clicking "Subscribe"
                        // directly triggers the authProvider to instantly change and persist the upgraded plan in the backend database.
                        authProvider.updatePlan(planId);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/main',
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Subscribe — $planPrice $planPeriod',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Cancel anytime. You won\'t be charged until you confirm.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

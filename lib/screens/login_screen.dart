/// File: lib/screens/login_screen.dart
/// Role: Renders the user login form layout. Manages form validation, input controllers
/// for credentials, and handles route redirection upon successful login transactions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/primary_button.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/responsive_helper.dart';
import '../providers/auth_provider.dart';

/// Screen widget providing the user credential login form interface.
class LoginScreen extends StatefulWidget {
  /// Constructs a [LoginScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State implementation of the login screen form controls and validations.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  /// Disposes text controllers to release keyboard channel references.
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Triggers credential validations and signals the AuthProvider to login.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    
    // Redirects administrative accounts to the administration dashboard, and standard accounts to home shell.
    if (success) {
      if (auth.currentUser?.isAdmin == true) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  /// Builds the scrollable login interface layout constrained by responsive bounds.
  ///
  /// [context] The building context containing active device media queries.
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  Center(
                    child: Image.asset(
                      'assets/image/logo/TuneIn_Logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),

                  Center(
                    child: Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      AppStrings.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kOnSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),

                  const Text(
                    AppStrings.welcomeBack,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.signInToContinue,
                    style: TextStyle(fontSize: 14, color: kOnSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => context.read<AuthProvider>().clearError(),
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: kOnSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    onChanged: (_) => context.read<AuthProvider>().clearError(),
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: kOnSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kOnSurfaceVariant,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (auth.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withAlpha(89)),
                      ),
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  PrimaryButton(
                    label: auth.isLoading ? 'Signing in...' : AppStrings.login,
                    onPressed: auth.isLoading ? null : _handleLogin,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.dontHaveAcc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/signup',
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

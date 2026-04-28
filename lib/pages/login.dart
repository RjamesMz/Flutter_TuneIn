import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/primary_button.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../providers/auth_provider.dart';

// ─── Login Prototype ──────────────────────────────────────────────────────────
/// Design-only version of the Login page.
/// No authentication logic, no provider — purely for UI prototyping.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool  _obscure    = true;


  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text.trim());

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                    'assets/image/logo/TuneIn_Logo.png',
                    width: 100,   // adjust to taste
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

              // ── Heading ───────────────────────────────────────────────────
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

              // ── Email Field ───────────────────────────────────────────────
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: kOnSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Password Field ────────────────────────────────────────────
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
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

              // ── Login Button ──────────────────────────────────────────────
              PrimaryButton(
                label: auth.isLoading ? 'Signing in...' : AppStrings.login,
                onPressed: auth.isLoading ? null : _handleLogin,
                icon: Icons.login,
              ),
              const SizedBox(height: 24),

              // ── Demo Hint ─────────────────────────────────────────────────
              Center(
                child: Text(
                  'Demo: any email & password will work',
                  style: TextStyle(
                    fontSize: 12,
                    color: kOnSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

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
                          context, '/signup'),
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
    );
  }
}


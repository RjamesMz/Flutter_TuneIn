import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool      _obscurePass    = true;
  bool      _obscureConfirm = true;
  String?   _selectedGender;
  DateTime? _selectedDob;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _dobDisplay() {
    if (_selectedDob == null) return null;
    final d = _selectedDob!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: kPrimary,
            onPrimary: Colors.white,
            surface: kSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select your date of birth.'),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    // TODO: connect to provider/backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ── Logo + title ────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: kSoulGradient,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: kPrimary.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )],
                          ),
                          child: const Icon(Icons.headphones, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(AppStrings.appName,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kPrimary)),
                        const SizedBox(height: 4),
                        const Text('Create your account',
                            style: TextStyle(fontSize: 14, color: kOnSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Personal Details ────────────────────────────────────
                  const _SectionLabel(label: 'Personal Details'),
                  const SizedBox(height: 12),

                  _field(controller: _nameCtrl, label: 'Full Name', icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null),
                  const SizedBox(height: 14),

                  _field(
                    controller: _usernameCtrl, label: 'Username', icon: Icons.alternate_email,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]'))],
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Choose a username' : null,
                  ),
                  const SizedBox(height: 14),

                  _field(
                    controller: _emailCtrl, label: 'Email Address', icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _field(
                    controller: _phoneCtrl, label: 'Phone Number (optional)', icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 24),

                  // ── Additional Info ─────────────────────────────────────
                  const _SectionLabel(label: 'Additional Info'),
                  const SizedBox(height: 12),

                  // DOB picker
                  GestureDetector(
                    onTap: _pickDob,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: kSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kOutlineVariant),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_month_outlined,
                            color: _selectedDob != null ? kPrimary : kOnSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dobDisplay() ?? 'Date of Birth',
                            style: TextStyle(
                                fontSize: 15,
                                color: _selectedDob != null ? kOnSurface : kOnSurfaceVariant),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kOnSurfaceVariant, size: 20),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gender dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kOutlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text('Gender (optional)',
                            style: TextStyle(color: kOnSurfaceVariant, fontSize: 15)),
                        icon: const Icon(Icons.expand_more, color: kOnSurfaceVariant),
                        isExpanded: true,
                        dropdownColor: kSurface,
                        borderRadius: BorderRadius.circular(14),
                        items: _genders
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Security ────────────────────────────────────────────
                  const _SectionLabel(label: 'Security'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: kOnSurfaceVariant),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kOnSurfaceVariant),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: kOnSurfaceVariant),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kOnSurfaceVariant),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm your password';
                      if (v != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Create Account button
                  PrimaryButton(
                    label: AppStrings.createAccount,
                    onPressed: _handleSignup,
                    icon: Icons.person_add_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Already have an account link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings.alreadyHaveAcc,
                            style: const TextStyle(fontSize: 13, color: kOnSurfaceVariant)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context,'/login'),
                          child: const Text('Log in',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kOnSurfaceVariant),
      ),
      validator: validator,
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            gradient: kSoulGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kOnSurfaceVariant,
              letterSpacing: 0.5,
            )),
      ],
    );
  }
}

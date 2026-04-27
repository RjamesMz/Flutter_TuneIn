import '../models/user.dart';

// ─── Auth Service ─────────────────────────────────────────────────────────────
/// Mock authentication service. No real backend — simulates network delay.
/// In a real app this would call Firebase Auth, REST API, etc.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Simulated user database
  static const _mockUser = User(
id :  'usr_123456',
name      : 'Renan James',
username  : 'James',
email     : 'renanjames@gmail.com',
phone     : '+63 91234 5678',
dateOfBirth : '2005-03-10',
gender     : 'Male',
plan      : 'Premium',
avatarUrl : 'assets/image/profilepic.jpg',
  );

  /// Simulates a login call. Any non-empty credentials succeed after 1.5 s.
  /// Throws [Exception] for empty credentials.
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }

    // Return the mock user (ignores actual email/password values)
    _currentUser = _mockUser;
    return _currentUser!;
  }

  /// Simulates a signup call. Builds a [User] from the provided form data.
  /// Any non-empty name + email + password will succeed after 1.5 s.
  Future<User> signup({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw Exception('Name, email and password are required.');
    }

    final createdUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      username: username.trim().isEmpty ? null : username.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      dateOfBirth: dateOfBirth,
      gender: gender,
      avatarUrl: _mockUser.avatarUrl, // reuse demo avatar
      plan: 'Free',
    );

    _currentUser = createdUser;
    return createdUser;
  }

  /// Simulates a logout call.
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  void updateCurrentUserPlan(String planId) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(plan: planId);
  }
}

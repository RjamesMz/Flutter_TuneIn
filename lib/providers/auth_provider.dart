import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── Auth Provider ────────────────────────────────────────────────────────────
/// Manages authentication state: current user, loading status, and errors.
//
class AuthProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  User?   _currentUser;
  bool    _isLoading   = false;
  String? _errorMessage;

 
  AuthProvider() {
    // Listen to AuthService changes (plan updates, etc)
    AuthService.instance.addListener(_onAuthServiceChanged);
  }

  void _onAuthServiceChanged() {
    _currentUser = AuthService.instance.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthServiceChanged);
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  User?   get currentUser   => _currentUser;
  bool    get isLoading     => _isLoading;
  bool    get isLoggedIn    => _currentUser != null;
  String? get errorMessage  => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Calls [AuthService.login] and updates state accordingly.
  Future<bool> login(String email, String password) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user     = await AuthService.instance.login(email, password);
      _currentUser   = user;
      _isLoading     = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage  = e.toString().replaceFirst('Exception: ', '');
      _isLoading     = false;
      notifyListeners();
      return false;
    }
  }

  /// Calls [AuthService.signup] and updates state accordingly.
  Future<bool> signup({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user   = await AuthService.instance.signup(
        name:        name,
        email:       email,
        username:    username,
        password:    password,
        phone:       phone,
        dateOfBirth: dateOfBirth,
        gender:      gender,
      );
      _currentUser = user;
      _isLoading   = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears the current user session.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.instance.logout();

    _currentUser  = null;
    _isLoading    = false;
    notifyListeners();
  }

  /// Clears any lingering error message (e.g. when user starts re-typing).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Updates the current user's subscription plan.
  void updatePlan(String planId) {
    AuthService.instance.updateCurrentUserPlan(planId);
    // _onAuthServiceChanged will be called automatically by AuthService.notifyListeners()
  }
}

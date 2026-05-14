import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../providers/player_provider.dart';

// ─── Auth Provider ────────────────────────────────────────────────────────────
/// Manages authentication state: current user, loading status, and errors.
//
class AuthProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  User?   _currentUser;
  bool    _isLoading   = false;
  String? _errorMessage;
  final PlayerProvider? _playerProvider;

 
  AuthProvider({PlayerProvider? playerProvider}) : _playerProvider = playerProvider {
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

  /// Checks if the user is already logged in from a previous session.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    await AuthService.instance.checkAuthStatus();
    
    _isLoading = false;
    notifyListeners();
  }

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

    await _playerProvider?.stop();
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

  /// Upload a new avatar image file and update the current user.
  Future<bool> updateAvatar(File imageFile) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final url = await AuthService.instance.updateAvatar(imageFile);
      _currentUser = _currentUser!.copyWith(avatarUrl: url);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates user profile details
  Future<bool> updateUserProfile({
    String? name,
    String? username,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.instance.updateUserProfile(
        name: name,
        username: username,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

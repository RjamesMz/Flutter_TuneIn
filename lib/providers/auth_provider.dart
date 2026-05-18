/// File: lib/providers/auth_provider.dart
/// Role: Manages authentication, profile edits, and subscription state updates.
/// Directs operations to [AuthService], updates local states reactively,
/// and signals UI listeners to rebuild.

import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../providers/player_provider.dart';

/// Manages authentication state: current user, loading status, and errors.
class AuthProvider extends ChangeNotifier {
  User?   _currentUser;
  bool    _isLoading   = false;
  String? _errorMessage;
  final PlayerProvider? _playerProvider;

  /// Constructs an [AuthProvider] instance.
  ///
  /// [playerProvider] State provider injected to control audio when user logs out.
  AuthProvider({PlayerProvider? playerProvider}) : _playerProvider = playerProvider {
    // Listens to global AuthService changes to automatically sync user instance states.
    AuthService.instance.addListener(_onAuthServiceChanged);
  }

  /// Synchronizes local user properties with current [AuthService] session states.
  void _onAuthServiceChanged() {
    _currentUser = AuthService.instance.currentUser;
    notifyListeners();
  }

  @override
  /// Clears active listeners on service disposal.
  void dispose() {
    AuthService.instance.removeListener(_onAuthServiceChanged);
    super.dispose();
  }

  /// Retrieves the currently authenticated [User] profile model.
  User?   get currentUser   => _currentUser;

  /// Returns true if an authentication or profile transaction is pending.
  bool    get isLoading     => _isLoading;

  /// Returns true if a user profile is actively authenticated.
  bool    get isLoggedIn    => _currentUser != null;

  /// Returns the current error string from failed authentication attempts.
  String? get errorMessage  => _errorMessage;

  /// Checks if the user is already logged in from a previous session.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    await AuthService.instance.checkAuthStatus();
    
    _isLoading = false;
    notifyListeners();
  }

  /// Calls [AuthService.login] and updates state accordingly.
  ///
  /// [email] Account identifier.
  /// [password] Account security password.
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
  ///
  /// [name] User display name.
  /// [email] Target email.
  /// [username] Selected unique identifier profile handle.
  /// [password] Account security password.
  /// [phone] Optional contact number.
  /// [dateOfBirth] Optional user birthday string.
  /// [gender] Optional user self-identified gender.
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

    // Halts active music tracks during logout sequence to prevent unauthorized background streaming.
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
  ///
  /// [planId] The target plan identifier.
  void updatePlan(String planId) {
    AuthService.instance.updateCurrentUserPlan(planId);
  }

  /// Upload a new avatar image file and update the current user.
  ///
  /// [imageFile] Target image file path reference to upload.
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

  /// Updates user profile details.
  ///
  /// [name] Updated display name.
  /// [username] Updated unique handle identifier.
  /// [phone] Updated contact phone number.
  /// [dateOfBirth] Updated birth date string.
  /// [gender] Updated gender label.
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

/// File: lib/services/auth_service.dart
/// Role: Interacts with Firebase Auth for authentication transactions,
/// and uses Cloud Firestore to store and query extended user profile documents.

// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:io';
import '../models/user.dart';
import 'supabase_service.dart';

/// Authentication service for signing in, signing up, and profile management.
class AuthService extends ChangeNotifier {
  AuthService._();

  /// Global singleton instance of [AuthService].
  static final AuthService instance = AuthService._();

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  /// Gets the currently authenticated user profile session.
  User? get currentUser => _currentUser;

  /// Translates raw Firebase authentication exceptions into human-friendly messages.
  String _authErrorMessage(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Wrong email or password. Try again.';
      case 'invalid-credential':
        return 'Wrong email or password. Try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  /// Checks if a Firebase user is already logged in, and if so, fetches their data.
  Future<void> checkAuthStatus() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        final data = doc.data() ?? {};
        
        // Maps the Firestore document attributes into our local immutable User model representation.
        _currentUser = User(
          id: firebaseUser.uid,
          name: data['name'] ?? firebaseUser.displayName ?? 'Unknown',
          email: firebaseUser.email ?? '',
          username: data['username'],
          phone: data['phone'],
          dateOfBirth: data['dateOfBirth'],
          gender: data['gender'],
          plan: data['plan'] ?? 'Free',
          isAdmin: data['isAdmin'] ?? false,
          avatarUrl: data['avatarUrl'] ?? '',
        );
        notifyListeners();
      } catch (e) {
        print('Error in auto-login: $e');
      }
    }
  }

  /// Logs in a user using Firebase Auth.
  ///
  /// [email] User account email.
  /// [password] User account password.
  Future<User> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final firebaseUser = credential.user!;
      
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      final data = doc.data() ?? {};
      
      final user = User(
        id: firebaseUser.uid,
        name: data['name'] ?? firebaseUser.displayName ?? 'Unknown',
        email: firebaseUser.email ?? '',
        username: data['username'],
        phone: data['phone'],
        dateOfBirth: data['dateOfBirth'],
        gender: data['gender'],
        plan: data['plan'] ?? 'Free',
        isAdmin: data['isAdmin'] ?? false,
        avatarUrl: data['avatarUrl'] ?? '',
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Registers a new user.
  ///
  /// [name] User full display name.
  /// [email] Unique target signup email address.
  /// [username] Selected custom profile handle.
  /// [password] Account password.
  /// [phone] Optional contact phone number.
  /// [dateOfBirth] Optional user birthday string.
  /// [gender] Optional self-identified user gender.
  Future<User> signup({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw Exception('Name, email and password are required.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;
      final avatarUrl = '';

      final createdUser = User(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        username: username.trim().isEmpty ? null : username.trim(),
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        dateOfBirth: dateOfBirth,
        gender: gender,
        avatarUrl: avatarUrl,
        plan: 'Free',
      );

      await firebaseUser.updateDisplayName(name.trim());
      
      // Persists extended user-specific properties to Firestore to bypass Firebase Auth storage limits.
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': createdUser.name,
        'email': createdUser.email,
        'username': createdUser.username,
        'phone': createdUser.phone,
        'dateOfBirth': createdUser.dateOfBirth,
        'gender': createdUser.gender,
        'plan': createdUser.plan,
        'isAdmin': createdUser.isAdmin,
        'avatarUrl': createdUser.avatarUrl,
      });

      _currentUser = createdUser;
      notifyListeners();
      return createdUser;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  /// Clears the active authentication session in Firebase Auth.
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Updates the current user's subscription plan.
  ///
  /// [planId] The ID of the plan to assign.
  void updateCurrentUserPlan(String planId) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(plan: planId);
    
    // Updates the plan status to keep billing records synced in the database.
    _firestore.collection('users').doc(_currentUser!.id).set(
      {'plan': planId},
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  /// Uploads [imageFile] to Supabase and updates the avatar URL in Firestore.
  ///
  /// [imageFile] Target local file reference of the avatar image to upload.
  Future<String> updateAvatar(File imageFile) async {
    if (_currentUser == null) throw Exception('Not authenticated');
    if (!await imageFile.exists()) throw Exception('Image file does not exist');

    final uid = _currentUser!.id;

    try {
      final publicUrl = await SupabaseService.instance.uploadAvatar(uid, imageFile);

      await _firestore.collection('users').doc(uid).set(
        {'avatarUrl': publicUrl},
        SetOptions(merge: true),
      );

      _currentUser = _currentUser!.copyWith(avatarUrl: publicUrl);
      notifyListeners();
      return publicUrl;
    } catch (e) {
      throw Exception('Avatar upload failed: $e');
    }
  }

  /// Updates user profile details in Firestore and local state.
  ///
  /// [name] Target updated display name.
  /// [username] Target updated unique profile handle.
  /// [phone] Target updated phone number.
  /// [dateOfBirth] Target updated birth date.
  /// [gender] Target updated gender classification.
  Future<void> updateUserProfile({
    String? name,
    String? username,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (_currentUser == null) return;
    
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (username != null) updates['username'] = username;
    if (phone != null) updates['phone'] = phone;
    if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
    if (gender != null) updates['gender'] = gender;

    if (updates.isEmpty) return;

    await _firestore.collection('users').doc(_currentUser!.id).update(updates);
    
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      username: username ?? _currentUser!.username,
      phone: phone ?? _currentUser!.phone,
      dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
      gender: gender ?? _currentUser!.gender,
    );
    notifyListeners();
  }
}

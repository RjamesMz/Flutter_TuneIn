import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:io';
import '../models/user.dart';
import 'supabase_service.dart';

// ─── Auth Service ─────────────────────────────────────────────────────────────
/// Mock authentication service. No real backend — simulates network delay.
/// In a real app this would call Firebase Auth, REST API, etc.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

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
        // Print or handle error quietly during auto-login
        print('Error in auto-login: $e');
      }
    }
  }

  /// Simulates a login call. Any non-empty credentials succeed after 1.5 s.
  /// Throws [Exception] for empty credentials.
  Future<User> login(String email, String password) async {
    // Validate email and password are not null or empty
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }

    try {
      // Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final firebaseUser = credential.user!;
      // Fetch the extra user data from Firestore
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      final data = doc.data() ?? {};
      
      // Return your local User model
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

  /// Simulates a logout call.
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUserPlan(String planId) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(plan: planId);
    _firestore.collection('users').doc(_currentUser!.id).set(
      {'plan': planId},
      SetOptions(merge: true),
    );
    notifyListeners();
  }


  
  /// Uploads [imageFile] to Supabase and updates the avatar URL in Firestore.
  Future<String> updateAvatar(File imageFile) async {
    if (_currentUser == null) throw Exception('Not authenticated');
    if (!await imageFile.exists()) throw Exception('Image file does not exist');

    final uid = _currentUser!.id;

    try {
      // 1. Upload to Supabase Storage
      final publicUrl = await SupabaseService.instance.uploadAvatar(uid, imageFile);

      // 2. Update Firestore with the new public URL
      await _firestore.collection('users').doc(uid).set(
        {'avatarUrl': publicUrl},
        SetOptions(merge: true),
      );

      // 3. Update local state
      _currentUser = _currentUser!.copyWith(avatarUrl: publicUrl);
      notifyListeners();
      return publicUrl;
    } catch (e) {
      throw Exception('Avatar upload failed: $e');
    }
  }

  /// Updates user profile details in Firestore and local state.
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


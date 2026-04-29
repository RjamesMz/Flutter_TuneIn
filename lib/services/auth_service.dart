import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

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

  /// Saves [imageFile] to local device storage.
  /// Returns the local file path on success.
  Future<String> updateAvatar(File imageFile) async {
    if (_currentUser == null) throw Exception('Not authenticated');
    if (!await imageFile.exists()) throw Exception('Image file does not exist');

    final uid = _currentUser!.id;

    try {
      // Get local documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/avatars');
      
      // Create avatars directory if it does not exist
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      // Save avatar locally
      final localPath = '${avatarDir.path}/$uid.jpg';
      await imageFile.copy(localPath);
      await FileImage(File(localPath)).evict();

      // Persist the avatar path to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_$uid', localPath);

      // Update local state
      _currentUser = _currentUser!.copyWith(avatarUrl: localPath);
      notifyListeners();
      return localPath;
    } catch (e) {
      throw Exception('Avatar save failed: $e');
    }
  }


  /// Simulates a login call. Any non-empty credentials succeed after 1.5 s.
  /// Throws [Exception] for empty credentials.
  Future<User> login(String email, String password) async {
    try {
      // Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;
      // Fetch the extra user data from Firestore
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      final data = doc.data() ?? {};
      
      // Load saved avatar path from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final savedAvatarUrl = prefs.getString('avatar_${firebaseUser.uid}') ?? '';
      
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
        avatarUrl: savedAvatarUrl.isNotEmpty ? savedAvatarUrl : (data['avatarUrl'] ?? ''),
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
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
        'avatarUrl': createdUser.avatarUrl,
      });
      
      // Initialize avatar path in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_${firebaseUser.uid}', '');

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
  
}


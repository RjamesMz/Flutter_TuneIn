import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
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
        avatarUrl: data['avatarUrl'] ?? '',
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed.');
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

      _currentUser = createdUser;
      notifyListeners();
      return createdUser;
    } on auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Signup failed.');
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


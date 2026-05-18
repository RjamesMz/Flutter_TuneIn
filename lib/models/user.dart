/// File: lib/models/user.dart
/// Role: Defines the User model representing a music listener or administrator.
/// Encompasses account settings, profile data, billing status, and local copy utility.

/// Represents a user of the application.
class User {
  /// Unique user id (maps to Firebase uid in this project).
  final String id;

  /// Full display name.
  final String name;

  /// Email address.
  final String email;

  /// Avatar image URL or local path.
  final String avatarUrl;

  /// Subscription plan identifier (e.g. "Free", "premium").
  final String plan; // e.g. "Premium", "Free"

  /// Whether the user has administrative privileges.
  final bool isAdmin;


  /// Optional username chosen during signup.
  final String? username;

  /// Optional phone number.
  final String? phone;

  /// Optional date of birth as an ISO date string `YYYY-MM-DD`.
  final String? dateOfBirth;

  /// Optional gender string.
  final String? gender;

  /// Creates a new [User].
  ///
  /// [id] Unique user ID mapping to the backend authentication system identifier.
  /// [name] The full display name of the user.
  /// [email] The associated email address.
  /// [avatarUrl] URL or local asset path representing the profile avatar.
  /// [plan] The active subscription level or billing tier.
  /// [isAdmin] Flag denoting administrative rights for library operations.
  /// [username] Optional handle identifier chosen on signup.
  /// [phone] Optional verified contact number.
  /// [dateOfBirth] Optional date of birth string formatted as YYYY-MM-DD.
  /// [gender] Optional self-identified gender field.
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.plan = 'Free',
    this.isAdmin = false,
    this.username,
    this.phone,
    this.dateOfBirth,
    this.gender,
  });

  /// Returns the user's first name (text before the first space).
  String get firstName => name.split(' ').first;

  /// Returns a copy of this user with the provided fields replaced.
  ///
  /// [id] Replacement unique user ID.
  /// [name] Replacement display name.
  /// [email] Replacement email address.
  /// [avatarUrl] Replacement avatar path or URL.
  /// [plan] Replacement subscription plan level.
  /// [isAdmin] Replacement admin privileges state.
  /// [username] Replacement handle identifier.
  /// [phone] Replacement contact phone number.
  /// [dateOfBirth] Replacement date of birth string.
  /// [gender] Replacement gender specification.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? plan,
    bool? isAdmin,
    String? username,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
      isAdmin: isAdmin ?? this.isAdmin,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}

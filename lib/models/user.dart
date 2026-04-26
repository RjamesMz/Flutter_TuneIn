// ─── User Model ───────────────────────────────────────────────────────────────

class User {
  final String  id;
  final String  name;
  final String  email;
  final String  avatarUrl;
  final String  plan;           // e.g. "Premium", "Free"

  // ── Signup fields (nullable — not collected during login flow) ─────────────
  final String? username;
  final String? phone;
  final String? dateOfBirth;    // stored as  date string "YYYY-MM-DD"
  final String? gender;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.plan         = 'Free',
    this.username,
    this.phone,
    this.dateOfBirth,
    this.gender,
  });

  /// Returns the user's first name only.
  String get firstName => name.split(' ').first;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? plan,
    String? username,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) {
    return User(
      id:          id          ?? this.id,
      name:        name        ?? this.name,
      email:       email       ?? this.email,
      avatarUrl:   avatarUrl   ?? this.avatarUrl,
      plan:        plan        ?? this.plan,
      username:    username    ?? this.username,
      phone:       phone       ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender:      gender      ?? this.gender,
    );
  }
}

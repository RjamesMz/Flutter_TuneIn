/// File: lib/core/app_strings.dart
/// Role: Manages global string constants, route definitions, and catalog categories
/// throughout the TuneIn application to avoid hardcoded strings.

/// Centralizes general localization string constants used in the user interface.
class AppStrings {
  /// Private constructor to prevent instantiation.
  AppStrings._();

  /// Application brand name.
  static const String appName = 'TuneIn';

  /// Brand tagline.
  static const String tagline = 'Tune into your world';

  /// Home screen label.
  static const String home = 'Home';

  /// Search screen label.
  static const String search = 'Search';

  /// Now playing header label.
  static const String nowPlaying = 'Now Playing';

  /// Profile screen label.
  static const String profile = 'Profile';

  /// Playlists screen label.
  static const String playlists = 'Playlists';

  /// Login button/header label.
  static const String login = 'Login';

  /// Logout button label.
  static const String logout = 'Logout';

  /// Email field label.
  static const String email = 'Email';

  /// Password field label.
  static const String password = 'Password';

  /// Welcome banner label.
  static const String welcomeBack = 'Welcome back 👋';

  /// Sign up button/header label.
  static const String signup = 'Sign Up';

  /// Create account header label.
  static const String createAccount = 'Create Account';

  /// Under-login banner label.
  static const String signInToContinue = 'Sign in to continue listening.';

  /// Personal information settings label.
  static const String personalInfo = 'Personal Info';

  /// Navigation prompt for existing users.
  static const String alreadyHaveAcc = 'Already have an account?';

  /// Navigation prompt for new users.
  static const String dontHaveAcc = "Don't have an account?";
}

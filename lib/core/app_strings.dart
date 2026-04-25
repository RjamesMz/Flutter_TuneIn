// ─── Route Names ──────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String login  = '/';
  static const String shell  = '/shell';
  static const String player = '/player';
}

// ─── App Strings ─────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName       = 'TuneIn';
  static const String tagline       = 'Tune into your world';
  static const String home          = 'Home';
  static const String search        = 'Search';
  static const String nowPlaying    = 'Now Playing';
  static const String profile       = 'Profile';
  static const String playlists     = 'Playlists';
  static const String login         = 'Login';
  static const String logout        = 'Logout';
  static const String email         = 'Email';
  static const String password      = 'Password';
  static const String welcomeBack   = 'Welcome back 👋';
  static const String signup           = 'Sign Up';
  static const String createAccount   = 'Create Account';
  static const String signInToContinue = 'Sign in to continue listening.';
  static const String personalInfo     = 'Personal Info';
  static const String alreadyHaveAcc  = 'Already have an account?';
  static const String dontHaveAcc     = "Don't have an account?";

}


// ─── Music Categories ────────────────────────────────────────────────────────
class MusicCategories {
  MusicCategories._();

  static const String all      = 'All';
  static const String trending = 'Trending';
  static const String loFi     = 'Lo-Fi';
  static const String indie    = 'Indie';
  static const String rnb      = 'R&B';
  static const String pop      = 'Pop';
  static const String jazz     = 'Jazz';

  static const List<String> all_categories = [
    all, trending, loFi, indie, rnb, pop, jazz
  ];
}

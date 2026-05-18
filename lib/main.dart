/// File: lib/main.dart
/// Role: Entry point for the TuneIn application. Initializes core Firebase and Supabase services,
/// configures global state providers (PlayerProvider, AuthProvider, MusicProvider), and defines
/// the application routing table.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/screens/user_screen/home_screen.dart';
import 'package:tunely/screens/login_screen.dart';
import 'package:tunely/screens/user_screen/personal_info_screen.dart';
import 'package:tunely/screens/user_screen/settings_screen.dart';
import 'package:tunely/screens/user_screen/search_screen.dart';
import 'package:tunely/screens/user_screen/playlist_screen.dart';
import 'package:tunely/screens/user_screen/main_screen.dart';
import 'package:tunely/screens/admin_screen/admin_screen.dart';
import 'package:tunely/screens/user_screen/signup_screen.dart';
import 'package:tunely/screens/user_screen/subscription_screen.dart';
import 'package:tunely/screens/user_screen/notifications_screen.dart';
import 'package:tunely/screens/user_screen/privacy_screen.dart';
import 'package:tunely/screens/user_screen/help_support_screen.dart';
import 'package:tunely/providers/auth_provider.dart';
import 'package:tunely/providers/music_provider.dart';
import 'package:tunely/providers/player_provider.dart';
import 'package:tunely/providers/admin_provider.dart';
import 'package:tunely/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

/// Entry point for the TuneIn app.
///
/// Initializes Firebase and Supabase SDKs before running the Flutter
/// application. This function deliberately performs asynchronous SDK
/// initialization synchronously at startup to ensure services are ready
/// before UI code accesses them.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // We initialize the third-party backend services before launching UI so that
  // user authorization and storage mechanisms are fully set up for the providers.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://rboolpverhezwondeezy.supabase.co',
    anonKey: 'sb_publishable_ICdCFa8qdB_4v5bPO5zrHQ_hSazvMD5',
  );

  runApp(const MyApp());
}

/// Root widget that wires up providers and routes for the app.
///
/// Provides global `ChangeNotifier` instances and registers named routes
/// used throughout the application.
class MyApp extends StatelessWidget {
  /// Constructs the root [MyApp] widget.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const MyApp({super.key});

  @override
  /// Builds the multi-provider and routing system for the application.
  ///
  /// [context] The location in the widget tree where this widget is built.
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            playerProvider: context.read<PlayerProvider>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => AdminProvider()),

        ChangeNotifierProvider(create: (_) => MusicProvider()),

        // UserProvider manages personal likes, playlists, downloads, and notices reactively
        ChangeNotifierProxyProvider2<AuthProvider, MusicProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, music, user) {
            user?.update(auth.currentUser?.id, music);
            return user!;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/admin': (context) => const AdminScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => const MainScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/playlist': (context) => const PlaylistScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/privacy': (context) => const PrivacyScreen(),
          '/help_support': (context) => const HelpSupportScreen(),
          '/personal_info': (context) => const PersonalInfoScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
        },
      ),
    );
  }
}

/// Small bootstrapping widget that checks authentication status and
/// redirects to the appropriate top-level route.
class AuthWrapper extends StatefulWidget {
  /// Constructs an [AuthWrapper] widget.
  ///
  /// [key] An optional key used for identifying the widget in the tree.
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

/// State implementation for the [AuthWrapper] bootstrapping flow.
class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Checks whether a user is already authenticated and redirects.
  ///
  /// Uses [AuthProvider.checkAuthStatus] and then routes to `/admin`,
  /// `/main`, or `/login` depending on the result.
  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();
    if (!mounted) return;

    // Checks user role and login status to enforce access controls early in the application lifecycle.
    if (auth.isLoggedIn) {
      if (auth.currentUser?.isAdmin == true) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  /// Builds the splash loader layout while authentication status is resolved.
  ///
  /// [context] The location in the widget tree where this widget is built.
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF141218), // kSurface color
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE28C9D),
        ), // kPrimary color
      ),
    );
  }
}

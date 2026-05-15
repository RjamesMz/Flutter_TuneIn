import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/screens/home_screen.dart';
import 'package:tunely/screens/login_screen.dart';
import 'package:tunely/screens/personal_info_screen.dart';
import 'package:tunely/screens/settings_screen.dart';
import 'package:tunely/screens/search_screen.dart';
import 'package:tunely/screens/playlist_screen.dart';
import 'package:tunely/screens/main_screen.dart';
import 'package:tunely/screens/admin_screen.dart';
import 'package:tunely/screens/signup_screen.dart';
import 'package:tunely/screens/subscription_screen.dart';
import 'package:tunely/screens/notifications_screen.dart';
import 'package:tunely/screens/privacy_screen.dart';
import 'package:tunely/screens/help_support_screen.dart';
import 'package:tunely/providers/auth_provider.dart';
import 'package:tunely/providers/music_provider.dart';
import 'package:tunely/providers/player_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://rboolpverhezwondeezy.supabase.co',
    anonKey: 'sb_publishable_ICdCFa8qdB_4v5bPO5zrHQ_hSazvMD5',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            playerProvider: context.read<PlayerProvider>(),
          ),
        ),

        ChangeNotifierProxyProvider<AuthProvider, MusicProvider>(
          create: (_) => MusicProvider(),
          update: (_, auth, music) {
            music?.updateUser(auth.currentUser?.id);
            return music!;
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();
    if (!mounted) return;

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

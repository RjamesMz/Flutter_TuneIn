import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/pages/home.dart';
import 'package:tunely/pages/login.dart';
import 'package:tunely/pages/personalinfopage.dart';
import 'package:tunely/pages/settings.dart';
import 'package:tunely/pages/search_screen.dart';
import 'package:tunely/pages/playlist_page.dart';
import 'package:tunely/pages/main_screen.dart';
import 'package:tunely/pages/admin_screen.dart';
import 'package:tunely/pages/signup_page.dart';
import 'package:tunely/pages/subscription_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => MusicProvider()),

        ChangeNotifierProvider(create: (_) => PlayerProvider()),
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
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => const MainScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/playlist': (context) => const PlaylistPage(),
          '/settings': (context) => const SettingsScreen(),
          '/personal_info': (context) => const PersonalInfoPage(),
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

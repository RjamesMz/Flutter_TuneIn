import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/pages/home.dart';
import 'package:tunely/pages/login.dart';
import 'package:tunely/pages/personalinfopage.dart';
import 'package:tunely/pages/settings.dart';
import 'package:tunely/pages/search_screen.dart';
import 'package:tunely/pages/playlist_page.dart';
import 'package:tunely/pages/main_screen.dart';
import 'package:tunely/pages/signup_page.dart';
import 'package:tunely/pages/subscription_screen.dart';
import 'package:tunely/providers/auth_provider.dart';
import 'package:tunely/providers/music_provider.dart';
import 'package:tunely/providers/player_provider.dart';

void main() {
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
        initialRoute: '/login',

        routes: {
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

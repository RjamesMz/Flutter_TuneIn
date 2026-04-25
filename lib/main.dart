import 'package:flutter/material.dart';
import 'package:tunely/pages/home.dart';
import 'package:tunely/pages/login.dart';
import 'package:tunely/pages/personalinfopage.dart';
import 'package:tunely/pages/settings.dart';
import 'package:tunely/pages/search_screen.dart';
import 'package:tunely/pages/playlist_page.dart';
import 'package:tunely/pages/main_screen.dart';
import 'package:tunely/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/playlist': (context) => const PlaylistPage(),
        '/settings': (context) => const SettingsScreen(),
        '/personal_info': (context) => const PersonalInfoPage(),
      },
      
    );
  }
}

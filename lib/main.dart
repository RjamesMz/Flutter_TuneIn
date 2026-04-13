import 'package:flutter/material.dart';
import 'package:tunely/mainpage.dart';
import 'package:tunely/pages/home.dart';
import 'package:tunely/pages/login.dart';
import 'package:tunely/pages/profile.dart';
import 'package:tunely/pages/searchpage.dart';
import 'package:tunely/pages/playlist_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',

      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchPage(),
        '/profile': (context) => const ProfilePage(username: ''),
        '/playlist': (context) => const PlaylistPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final username = settings.arguments is String
              ? settings.arguments as String
              : '';
          return MaterialPageRoute(
            builder: (context) => MainPage(username: username),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

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

  
  Widget build(BuildContext context) {
    return MaterialApp(
      
      initialRoute: '/',

      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => const MainPage(username: ''),
        '/home': (context) => const HomePage(username: '',),
        '/search': (context) => const SearchPage(),
        '/profile': (context) => const ProfilePage(username: ''),
        '/playlist': (context) => const PlaylistPage(),
      },
    );
  }
}

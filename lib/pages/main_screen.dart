import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../pages/search_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_navigation_bar.dart';

// ─── Main Shell ───────────────────────────────────────────────────────────────
/// The root scaffold after login. Houses the bottom navigation bar
/// and switches between Home, Search, Player, and Profile tabs.
/// The [MiniPlayer] floats above the nav bar whenever a song is loaded.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Hardcoded — flip to true if you want the MiniPlayer visible during design
  final bool hasActiveSong = false;

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ProfilePage(username: '',),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: IndexedStack(index: _currentIndex, children: _screens),
      // ── Bottom Area: MiniPlayer + NavBar ──────────────────────────────
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating mini player (only shown when something is playing)
          if (hasActiveSong && _currentIndex != 2)
           MiniPlayer(
                onTap: () => setState(() => _currentIndex = 2),
                title: 'Song Title',       // pass your current song's title
                artist: 'Artist Name',     // pass your current song's artist
                coverUrl: 'https://...',   // pass your current song's coverUrl
                isPlaying: true,           // pass your playing state
                hasNext: true,             // pass whether next exists
                onTogglePlay: () {},       // pass your toggle callback
                onNext: () {},             // pass your next callback
              ),

          // Navigation bar (standalone widget)
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        ],
      ),
    );
  }
}


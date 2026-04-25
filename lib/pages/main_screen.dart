import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../pages/home.dart';
import '../pages/playlist_page.dart';
import 'settings.dart';
import '../pages/search_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final bool hasActiveSong = true;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    PlaylistPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,

      // ── Only the nav bar here ─────────────────────────────────────────
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),

      // ── MiniPlayer floats above content using Stack ───────────────────
      body: Stack(
        children: [
          // Screens fill the full area
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          // MiniPlayer floats above content, above the nav bar
          if (hasActiveSong && _currentIndex != 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                title: 'Blinding Lights',
                artist: 'The Weeknd',
                coverUrl:
                    'https://i.scdn.co/image/ab67616d0000b273a048415db06a5b6fa7ec4e1a',
                isPlaying: true,
                hasNext: true,
                onTap: () {
                  // TODO: navigate to full player
                },
                onTogglePlay: () {
                  setState(() {}); // toggle play state
                },
                onNext: () {
                  // TODO: skip to next
                },
              ),
            ),
        ],
      ),
    );
  }
}

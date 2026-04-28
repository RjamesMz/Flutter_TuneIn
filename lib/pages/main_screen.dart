import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../pages/home.dart';
import '../pages/playlist_page.dart';
import '../pages/search_screen.dart';
import '../pages/now_playing_page.dart';
import 'settings.dart';
import 'package:provider/provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/player_provider.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    PlaylistPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final currentSong = player.currentSong;
    final hasActiveSong = currentSong != null;

    return Scaffold(
      backgroundColor: kBackground,

      // ── Bottom Navigation ─────────────────────────
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),

      // ── Body with MiniPlayer ──────────────────────
      body: Stack(
        children: [
          // Screens
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // MiniPlayer
          if (hasActiveSong && _currentIndex != 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                title: currentSong.title,
                artist: currentSong.artist,
                coverUrl: currentSong.coverUrl,
                isPlaying: player.isPlaying,
                hasNext: player.hasNext,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NowPlayingPage(),
                    ),
                  );
                },

                onTogglePlay: () {
                  player.togglePlayPause();
                },

                onNext: () {
                  player.next();
                },
              ),
            ),
        ],
      ),
    );
  }
}
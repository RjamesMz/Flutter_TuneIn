import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'home_screen.dart';
import 'playlist_screen.dart';
import 'search_screen.dart';
import 'now_playing_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../../core/responsive_helper.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/player_provider.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController = PageController(initialPage: _currentIndex);

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    PlaylistScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        onTap: (i) {
          setState(() => _currentIndex = i);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),

      // ── Body with MiniPlayer ──────────────────────
      body: ResponsiveWrapper(
        child: Stack(
          children: [
            // Screens
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
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
                      builder: (_) => const NowPlayingScreen(),
                    ),
                  );
                },

                onTogglePlay: () {
                  player.togglePlayPause();
                },

                onNext: () {
                  player.next();
                },

                onDismissed: () {
                  player.stop();
                },
              ),
            ),
        ],
      ),
      ),
    );
  }
}

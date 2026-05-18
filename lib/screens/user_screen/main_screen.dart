/// File: lib/screens/user_screen/main_screen.dart
/// Role: Core user interface scaffold. Hosts a page controller to transition between
/// Home, Search, Playlists, and Settings tabs while maintaining a global MiniPlayer overlay.

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

/// Screen widget hosting the primary client tab navigation container.
class MainScreen extends StatefulWidget {
  /// Constructs a [MainScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// State controller managing active tab selections, page views, and global mini-player widgets in [MainScreen].
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
  /// Disposes page controllers to release animation bindings.
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  /// Builds the primary client layout, overlaying the active tab screen and mini player.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final currentSong = player.currentSong;
    final hasActiveSong = currentSong != null;

    return Scaffold(
      backgroundColor: kBackground,

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
          // Avoids rendering the mini player overlay when the settings/profile tab (index 3) is active.
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

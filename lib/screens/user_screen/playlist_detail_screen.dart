/// File: lib/screens/user_screen/playlist_detail_screen.dart
/// Role: Screen displaying tracks inside a selected playlist. Offers offline downloads,
/// a search shortcut to add music, and support for swiping to remove songs.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/mini_player.dart';
import 'now_playing_screen.dart';
import 'search_screen.dart';
import '../../providers/auth_provider.dart';

/// Screen widget listing the detailed songs in a specific user playlist.
class PlaylistDetailScreen extends StatelessWidget {
  /// The active name header identifying the user's custom playlist.
  final String playlistName;

  /// Constructs a [PlaylistDetailScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [playlistName] Targeted playlist name string.
  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  /// Builds the detailed playlist screen with dismissible swipe remove lists.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final player = context.watch<PlayerProvider>();
    final auth = context.watch<AuthProvider>();
    
    final isPremium = auth.currentUser?.plan != 'free';
    final songs = playlistName == 'Liked Songs' 
        ? user.likedSongs 
        : user.getSongsInPlaylist(playlistName);
    final currentSong = player.currentSong;
    final hasActiveSong = currentSong != null;

    return Scaffold(
      backgroundColor: kSurface,

      appBar: AppBar(
        backgroundColor: kSurface.withAlpha(230),
        elevation: 0,
        title: Text(
          playlistName,
          style: const TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (isPremium && songs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_for_offline, color: kPrimary),
              tooltip: 'Download All',
              onPressed: () {
                // Iterates and invokes background offline SQLite music files download on all tracks in the playlist.
                for (var song in songs) {
                  if (!user.isDownloaded(song.id)) {
                    user.downloadSong(song);
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading playlist...')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.add, color: kPrimary),
            tooltip: 'Add Music',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          ResponsiveWrapper(
            child: songs.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/logs/nothing.png',
                        width: 180,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Songs Yet",
                        style: TextStyle(
                          color: kOnSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Add songs from the search or home screen",
                        style: TextStyle(
                          color: kOnSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, hasActiveSong ? 100 : 16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];

                    return Dismissible(
                      key: ValueKey(song.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(38),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (_) {
                        user.removeSongFromPlaylist(playlistName, song.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed "${song.title}" from $playlistName'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: SongTile(song: song, queue: songs),
                    );
                  },
                ),
            ),

          if (hasActiveSong)
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                ),
                onTogglePlay: () => player.togglePlayPause(),
                onNext: () => player.next(),
                onDismissed: () => player.stop(),
              ),
            ),
        ],
      ),
    );
  }
}

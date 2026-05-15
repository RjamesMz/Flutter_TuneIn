import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/responsive_helper.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import 'now_playing_screen.dart';
import 'search_screen.dart';
import '../providers/auth_provider.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final player = context.watch<PlayerProvider>();
    final auth = context.watch<AuthProvider>();
    
    final isPremium = auth.currentUser?.plan != 'free';
    final songs = playlistName == 'Liked Songs' 
        ? music.likedSongs 
        : music.getSongsInPlaylist(playlistName);
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
                for (var song in songs) {
                  if (!music.isDownloaded(song.id)) {
                    music.downloadSong(song);
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
          // ── Song List ────────────────────────────────────────────────────
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
                        music.removeSongFromPlaylist(playlistName, song.id);
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

          // ── Mini Player ──────────────────────────────────────────────────
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

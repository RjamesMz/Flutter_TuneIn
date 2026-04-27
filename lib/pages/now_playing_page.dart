import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/music_provider.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  void _openRecommendations(BuildContext context, List<Song> songs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 255, 167, 183),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 10),

                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kOnSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Recommended for Songs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.read<PlayerProvider>().play(song, queue: songs);
                        },
                        child: _songTile(
                          song.title,
                          song.artist,
                          coverUrl: song.coverUrl,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final music = context.watch<MusicProvider>();
    final current = player.currentSong;

    final recommended = music.allSongs.isNotEmpty
        ? music.allSongs.where((s) => s != current).toList()
        : player.queue.where((s) => s != current).toList();

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    current?.coverUrl ?? 'https://i.scdn.co/image/ab67616d0000b273a048415db06a5b6fa7ec4e1a',
                    height: 260,
                    width: 260,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current?.title ?? 'No song playing',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kOnSurface,
                            ),
                          ),
                          Text(
                            current?.artist ?? '',
                            style: const TextStyle(color: kOnSurfaceVariant),
                          ),
                        ],
                      ),
                      const Icon(Icons.favorite, color: kPrimary),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Slider(
                  value: (() {
                    if (current == null || player.position == Duration.zero) return 0.0;
                    final total = current.duration.inSeconds;
                    if (total == 0) return 0.0;
                    return (player.position.inSeconds / total).clamp(0.0, 1.0);
                  })(),
                  onChanged: (v) {
                    if (current == null) return;
                    final total = current.duration.inSeconds;
                    final sec = (v * total).round();
                    context.read<PlayerProvider>().updatePosition(Duration(seconds: sec));
                  },
                  activeColor: kPrimary,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(player.position == Duration.zero ? '0:00' : player.position.inMinutes.toString()+':'+(player.position.inSeconds%60).toString().padLeft(2,'0')),
                      Text(current?.formattedDuration ?? '0:00'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(player.isShuffled ? Icons.shuffle_on : Icons.shuffle),
                      onPressed: () => context.read<PlayerProvider>().toggleShuffle(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => context.read<PlayerProvider>().previous(),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kPrimary,
                      child: IconButton(
                        splashRadius: 28,
                        icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          if (player.currentSong == null) {
                            final songs = music.allSongs;
                            if (songs.isNotEmpty) {
                              context.read<PlayerProvider>().play(songs.first, queue: songs);
                            }
                            return;
                          }
                          context.read<PlayerProvider>().togglePlayPause();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => context.read<PlayerProvider>().next(),
                    ),
                    IconButton(
                      icon: Icon(player.isRepeating ? Icons.repeat_on : Icons.repeat),
                      onPressed: () => context.read<PlayerProvider>().toggleRepeat(),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),

          // ─── CLICKABLE RECOMMENDED BAR ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _openRecommendations(context, recommended),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kOnSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Recommended Songs",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _songTile(String title, String artist, {String? coverUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              coverUrl ?? "https://picsum.photos/seed/$title/200",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: kOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            artist,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

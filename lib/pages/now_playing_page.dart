import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  void _openRecommendations(BuildContext context) {
    final player = context.read<PlayerProvider>();
    final List<Song> queue = player.queue; // making the exact match

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
                  "Recommended Songs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final song = queue[index];

                      return GestureDetector(
                        onTap: () {
                          // showig the  exact method signature
                          player.play(song, queue: queue);
                          Navigator.pop(context);
                        },
                        child: _songTile(song),
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
    final song = player.currentSong;

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

                // showing the uses currentSong
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    song?.coverUrl ?? 'https://via.placeholder.com/150',
                    height: 260,
                    width: 260,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                // for the uses currentSong
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? "No song",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kOnSurface,
                            ),
                          ),
                          Text(
                            song?.artist ?? "Unknown artist",
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
                  value: 0.3,
                  onChanged: (v) {},
                  activeColor: kPrimary,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1:05"),
                      Text("3:20"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                //  to all the controls mapped to provider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      onPressed: player.toggleShuffle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: player.hasPrevious ? player.previous : null,
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kPrimary,
                      child: IconButton(
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: player.togglePlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: player.hasNext ? player.next : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat),
                      onPressed: player.toggleRepeat,
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _openRecommendations(context),
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

  // this accepts Song directly (matches your model)
  static Widget _songTile(Song song) {
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
              song.coverUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              song.title,
              style: const TextStyle(
                color: kOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            song.artist,
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
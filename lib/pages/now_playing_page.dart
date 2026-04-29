import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // bagong ADDED
import '../core/app_colors.dart';
import '../providers/player_provider.dart'; // to yung bagong ADDED

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  final List<Map<String, String>> songs = const [
    {"title": "Levitating", "artist": "Dua Lipa"},
    {"title": "Stay", "artist": "Kid LAROI"},
    {"title": "Good 4 U", "artist": "Olivia Rodrigo"},
    {"title": "Peaches", "artist": "Justin Bieber"},
  ];

  void _openRecommendations(BuildContext context) {
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

                      return _songTile(
                        song["title"]!,
                        song["artist"]!,
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
    //  to yung ga connect sa PROVIDER
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

                //  the dynamic COVER
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    song?.coverUrl ??
                        'https://via.placeholder.com/150',
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
                      //  the dynamic TITLE + ARTIST
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
                            style: const TextStyle(
                                color: kOnSurfaceVariant),
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1:05"),
                      Text("3:20"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.shuffle),
                    const Icon(Icons.skip_previous),

                    //  for the SYNC PLAY/PAUSE
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
                        onPressed: () {
                          player.togglePlayPause();
                        },
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        player.next();
                      },
                    ),

                    const Icon(Icons.repeat),
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
              onTap: () => _openRecommendations(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
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
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Recommended Songs",
                      style:
                          TextStyle(fontWeight: FontWeight.w600),
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

  static Widget _songTile(String title, String artist) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12, left: 16, right: 16),
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
              "https://picsum.photos/seed/$title/200",
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
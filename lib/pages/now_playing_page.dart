import 'package:flutter/material.dart';
import '../core/app_colors.dart';

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
                    'https://i.scdn.co/image/ab67616d0000b273a048415db06a5b6fa7ec4e1a',
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
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Blinding Lights",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kOnSurface,
                            ),
                          ),
                          Text(
                            "The Weeknd",
                            style: TextStyle(color: kOnSurfaceVariant),
                          ),
                        ],
                      ),
                      Icon(Icons.favorite, color: kPrimary),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.shuffle),
                    Icon(Icons.skip_previous),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kPrimary,
                      child: Icon(Icons.pause, color: Colors.white),
                    ),
                    Icon(Icons.skip_next),
                    Icon(Icons.repeat),
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


  static Widget _songTile(String title, String artist) {
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
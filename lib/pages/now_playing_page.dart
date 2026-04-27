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
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.6,
            builder: (context, controller) {
              return Container(
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
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kOnSurfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }

                    if (index == 1) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Recommended for you",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    final song = songs[index - 2];

                    return _songTile(
                      song["title"]!,
                      song["artist"]!,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _songTile(String title, String artist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
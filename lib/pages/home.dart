import 'package:flutter/material.dart';
import 'package:tunely/pages/personalinfopage.dart';
import '../core/app_colors.dart';
import '../widgets/category_chip.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All', 'Trending', 'Lo-Fi', 'Indie', 'R&B', 'Pop', 'Jazz'
  ];

  // Dummy song data
  final List<Map<String, String>> songs = [
    {'title': 'Blinding Lights',  'artist': 'The Weeknd',    'duration': '3:20', 'cover': 'https://picsum.photos/seed/song1/200'},
    {'title': 'Levitating',       'artist': 'Dua Lipa',      'duration': '3:23', 'cover': 'https://picsum.photos/seed/song2/200'},
    {'title': 'Stay',             'artist': 'Kid LAROI',      'duration': '2:21', 'cover': 'https://picsum.photos/seed/song3/200'},
    {'title': 'Good 4 U',         'artist': 'Olivia Rodrigo', 'duration': '2:58', 'cover': 'https://picsum.photos/seed/song4/200'},
    {'title': 'Peaches',          'artist': 'Justin Bieber',  'duration': '3:18', 'cover': 'https://picsum.photos/seed/song5/200'},
    {'title': 'Montero',          'artist': 'Lil Nas X',      'duration': '2:17', 'cover': 'https://picsum.photos/seed/song6/200'},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [

        // ── App Bar ────────────────────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          expandedHeight: 0,
          backgroundColor: kSurface.withOpacity(0.9),
          title: const Text(
            'TuneIn',
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInfoPage(),
                  ),
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: kSurfaceContainerHighest,
                child: const Icon(Icons.person, color: kPrimary, size: 18),
                ),
             ),
            ),
          ],
        ),

        // ── Featured Banner ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _FeaturedBanner(
            title: songs.first['title']!,
            artist: songs.first['artist']!,
            coverUrl: songs.first['cover']!,
          ),
        ),

        // ── Browse + Category Chips ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 0, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: cat,
                          isSelected: selectedCategory == cat,
                          onTap: () => setState(() => selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Song List ──────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(
                title:    songs[index]['title']!,
                artist:   songs[index]['artist']!,
                duration: songs[index]['duration']!,
                coverUrl: songs[index]['cover']!,
              ),
              childCount: songs.length,
            ),
          ),
        ),

      ],
    );
  }
}

// ── Featured Banner ────────────────────────────────────────────────────────────
class _FeaturedBanner extends StatelessWidget {
  final String title;
  final String artist;
  final String coverUrl;

  const _FeaturedBanner({
    required this.title,
    required this.artist,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover image
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: kSurfaceContainer),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        kOnSurface.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
                // Text
                Positioned(
                  bottom: 16, left: 16, right: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: kPrimaryContainer, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: kPrimaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        artist,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play button
                Positioned(
                  bottom: 16, right: 16,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

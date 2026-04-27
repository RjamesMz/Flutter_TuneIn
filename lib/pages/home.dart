import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/models/song.dart';
import 'package:tunely/pages/personalinfopage.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../widgets/category_chip.dart';
import '../widgets/song_tile.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../services/music_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void initState() {
    super.initState();
    // Kick off data load after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().fetchSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final categories = MusicCategories.all_categories;
    final selectedCategory = music.selectedCategory;

    return CustomScrollView(
      slivers: [
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
                  MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
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
            song: music.allSongs.isNotEmpty ? music.allSongs.first : null,
            allSongs: music.allSongs,
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
                          onTap: () =>
                              context.read<MusicProvider>().selectCategory(cat),
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
        if (music.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          )
        else if (music.filteredSongs.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_off,
                    size: 48,
                    color: kOnSurfaceVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No songs in this category',
                    style: TextStyle(color: kOnSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SongTile(
                  song: music.filteredSongs[index],
                  queue: music.filteredSongs,
                ),
                childCount: music.filteredSongs.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Featured Banner ────────────────────────────────────────────────────────────
class _FeaturedBanner extends StatelessWidget {
  final Song? song;
  final List<Song> allSongs;

  const _FeaturedBanner({this.song, required this.allSongs});

  @override
  Widget build(BuildContext context) {
    if (song == null) {
      return const SizedBox(height: 180);
    }
    final s = song!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => context.read<PlayerProvider>().play(s, queue: allSongs),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  s.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: kSurfaceContainer),
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
                // Content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: kPrimaryContainer,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          const Text(
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
                        s.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        s.artist,
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
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 26,
                    ),
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

/// File: lib/screens/user_screen/home_screen.dart
/// Role: Renders the primary user landing dashboard tab. Offers genre category chips,
/// a featured song banner, pull-to-refresh feeds, and standard catalog list views.

// ignore_for_file: unnecessary_underscores, annotate_overrides

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunely/models/song.dart';
import 'package:tunely/screens/user_screen/personal_info_screen.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/song_tile.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen widget displaying the home browse tab for regular users.
class HomeScreen extends StatefulWidget {
  /// Constructs a [HomeScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State controller for managing catalog loads and sliver scroll effects in [HomeScreen].
class _HomeScreenState extends State<HomeScreen> {
  /// Invokes initial song loading once the screen is fully constructed.
  void initState() {
    super.initState();
    
    // Triggers initial asynchronous song catalog fetching after the screen renders to ensure smooth animation frames.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().fetchSongs();
    });
  }

  @override
  /// Builds the scrollable browse layout with sliver components.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final categories = ['All', ...music.categoryNames];
    final selectedCategory = music.selectedCategory;

    return ResponsiveWrapper(
      child: RefreshIndicator(
        onRefresh: () => context.read<MusicProvider>().fetchSongs(forceRefresh: true),
        color: kPrimary,
        backgroundColor: kSurface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: false,
              snap: false,
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight: 110,
              collapsedHeight: kToolbarHeight,
              backgroundColor: kBackground,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final delta = 110 - kToolbarHeight;
                  final t = ((constraints.maxHeight - kToolbarHeight) / delta)
                      .clamp(0.0, 1.0);
                  final bgColor = Color.lerp(kPrimaryContainer, kBackground, t);

                  return DecoratedBox(
                    decoration: BoxDecoration(color: bgColor),
                  );
                },
              ),
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
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final user = auth.currentUser;
                      final hasAvatar = user != null && user.avatarUrl.isNotEmpty;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                        ),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: kSurfaceContainerHighest,
                          backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl) : null,
                          child: hasAvatar ? null : const Icon(Icons.person, color: kPrimary, size: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: _FeaturedBanner(
                song: music.allSongs.isNotEmpty ? music.allSongs.first : null,
                allSongs: music.allSongs,
              ),
            ),

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
                        color: kOnSurfaceVariant.withAlpha(102),
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
        ),
      ),
    );
  }
}

/// A banner widget showcasing a highlighted track on the user home view.
class _FeaturedBanner extends StatelessWidget {
  /// Highlighted song displayed on the banner.
  final Song? song;

  /// Full queue fallback sequence for playback context.
  final List<Song> allSongs;

  /// Constructs a [_FeaturedBanner] instance.
  ///
  /// [key] An optional key.
  /// [song] Highlighted song track.
  /// [allSongs] Complete catalog sequence list.
  const _FeaturedBanner({this.song, required this.allSongs});

  @override
  /// Renders the highlighted card stack containing metadata overlays.
  ///
  /// [context] The building context.
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
                        kOnSurface.withAlpha(191),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        s.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(191),
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

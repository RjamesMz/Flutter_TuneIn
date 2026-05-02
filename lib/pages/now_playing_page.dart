import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final ScrollController _controller = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _scrollOffset = _controller.offset;
      });
    });
  }

  double get _fade => (1 - (_scrollOffset / 250)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    final queue = player.queue;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
      
          SliverFillRemaining(
            hasScrollBody: true,
            child: Center(
              child: Opacity(
                opacity: _fade,
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - _fade)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
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

                      /// Song title
                      Text(
                        song?.title ?? "No song",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kOnSurface,
                        ),
                      ),

                      /// Artist
                      Text(
                        song?.artist ?? "Unknown artist",
                        style: const TextStyle(
                          color: kOnSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Progress bar
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          value: 0.3,
                          onChanged: (v) {},
                          activeColor: kPrimary,
                          inactiveColor:
                              kOnSurface.withOpacity(0.2),
                        ),
                      ),

                      /// Time labels
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text("00:11",
                                style: TextStyle(
                                    color: kOnSurfaceVariant)),
                            Text("03:43",
                                style: TextStyle(
                                    color: kOnSurfaceVariant)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                    
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shuffle),
                            color: kOnSurfaceVariant,
                            onPressed: player.toggleShuffle,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            color: kOnSurface,
                            onPressed: player.hasPrevious
                                ? player.previous
                                : null,
                          ),

                          /// Play button
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
                              onPressed:
                                  player.togglePlayPause,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            color: kOnSurface,
                            onPressed: player.hasNext
                                ? player.next
                                : null,
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.favorite_border),
                            color: kPrimary,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// spacing before recommendations
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),

         /// now scrool not drawer
          SliverOpacity(
            opacity: (_scrollOffset > 120) ? 1 : 0,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = queue[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSurfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child: Image.network(
                          s.coverUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        s.title,
                        style: const TextStyle(
                            color: kOnSurface),
                      ),
                      subtitle: Text(
                        s.artist,
                        style: const TextStyle(
                            color: kOnSurfaceVariant),
                      ),
                      onTap: () {
                        player.play(s, queue: queue);
                      },
                    ),
                  );
                },
                childCount: queue.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';

// ─── Song Tile ────────────────────────────────────────────────────────────────
/// A reusable list tile that displays a [Song].
/// Tapping it calls [PlayerProvider.play] with the full [queue].
class SongTile extends StatelessWidget {
  final Song       song;
  final List<Song> queue;          // sibling songs for next/prev
  final bool       showTrailingMenu;

  const SongTile({
    super.key,
    required this.song,
    required this.queue,
    this.showTrailingMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final player       = context.watch<PlayerProvider>();
    final isCurrentSong = player.currentSong == song;
    final isPlaying     = isCurrentSong && player.isPlaying;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentSong
            ? kSurfaceContainerHighest
            : kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentSong
            ? Border.all(color: kPrimary.withOpacity(0.25), width: 1.5)
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<PlayerProvider>().play(song, queue: queue),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // ── Cover Art ────────────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      song.coverUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: kSurfaceContainer,
                        child: const Icon(Icons.music_note, color: kPrimary),
                      ),
                    ),
                  ),
                  if (isCurrentSong)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPlaying ? Icons.volume_up : Icons.pause_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // ── Title + Artist ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isCurrentSong ? kPrimary : kOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Duration / Icon ───────────────────────────────────────────
              if (isCurrentSong)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.equalizer, color: kPrimary, size: 20),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    song.formattedDuration,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kOnSurfaceVariant,
                    ),
                  ),
                ),
              if (showTrailingMenu)
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.more_vert,
                    color: kOnSurfaceVariant,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

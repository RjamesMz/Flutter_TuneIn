/// File: lib/widgets/mini_player.dart
/// Role: Compact floating mini-player overlay bar. Renders dynamic track progress, title details,
/// and allows play/skip/dismiss controls aligned to the active player queue state.

// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Floating music player strip widget providing basic playback buttons and dismissible swipe controls.
class MiniPlayer extends StatelessWidget {
  /// Click event callback that transitions screen states to the expanded player views.
  final VoidCallback onTap;

  /// Active track title display label.
  final String title;

  /// Active track artist name display label.
  final String artist;

  /// URL pointing to the song cover art image.
  final String coverUrl;

  /// Flag indicating if the player is currently outputting audio.
  final bool isPlaying;

  /// Boolean indicating if the active queue has another track waiting.
  final bool hasNext;

  /// Toggles active playback between play and pause.
  final VoidCallback onTogglePlay;

  /// Action skipping forward to the next queued song.
  final VoidCallback onNext;

  /// Swipe gesture callback that terminates playback.
  final VoidCallback onDismissed;

  /// Constructs a [MiniPlayer] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [onTap] Navigation details press callback.
  /// [title] Current song title string.
  /// [artist] Current artist name string.
  /// [coverUrl] Artwork network image URL string.
  /// [isPlaying] Audio play state status.
  /// [hasNext] Next item queue availability indicator.
  /// [onTogglePlay] Play/pause toggle event.
  /// [onNext] Skip forward transition callback.
  /// [onDismissed] Swipe closing callback.
  const MiniPlayer({
    super.key,
    required this.onTap,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.isPlaying,
    required this.hasNext,
    required this.onTogglePlay,
    required this.onNext,
    required this.onDismissed,
  });

  @override
  /// Builds the swipable player overlay bar with curved corner profiles.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    return Dismissible(
      // Formulates a uniquely identifiable key using dynamic track and artist attributes.
      key: Key('mini_player_${title}_$artist'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kSurfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  coverUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: kSurfaceContainer,
                    child: const Icon(Icons.music_note, color: kPrimary, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kOnSurface,
                      ),
                    ),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: hasNext ? kPrimary : kOnSurfaceVariant.withValues(alpha: 0.4),
                  size: 22,
                ),
                onPressed: hasNext ? onNext : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onTogglePlay,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    gradient: kSoulGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

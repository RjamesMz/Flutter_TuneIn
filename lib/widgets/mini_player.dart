import 'package:flutter/material.dart';

import '../core/app_colors.dart';

// ─── Mini Player ──────────────────────────────────────────────────────────────
/// Floating bottom bar that shows the currently playing song.
/// Tapping it navigates to the full Player screen.
class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;
  final String      title;
  final String      artist;
  final String      coverUrl;
  final bool        isPlaying;
  final bool        hasNext;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;

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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kSurfaceContainerHighest.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Cover Art ──────────────────────────────────────────────────
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
            // ── Song Info ──────────────────────────────────────────────────
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
            // ── Controls ───────────────────────────────────────────────────
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: hasNext ? kPrimary : kOnSurfaceVariant.withOpacity(0.4),
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
    );
  }
}

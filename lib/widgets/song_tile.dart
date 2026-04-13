import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final String coverUrl;

  const SongTile({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Cover Art
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  coverUrl,
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

              const SizedBox(width: 14),

              // Title + Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artist,
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

              // Duration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kOnSurfaceVariant,
                  ),
                ),
              ),

              // More icon
              const Icon(Icons.more_vert, color: kOnSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

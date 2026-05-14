import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';

// ─── Song Tile ────────────────────────────────────────────────────────────────
/// A reusable list tile that displays a [Song].
/// Tapping it calls [PlayerProvider.play] with the full [queue].
class SongTile extends StatelessWidget {
  final Song       song;
  final List<Song> queue;          // sibling songs for next/prev
  final bool       showActions;

  const SongTile({
    super.key,
    required this.song,
    required this.queue,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final player       = context.watch<PlayerProvider>();
    final music        = context.watch<MusicProvider>();
    final isCurrentSong = player.currentSong == song;
    final isPlaying     = isCurrentSong && player.isPlaying;
    final isLiked       = music.isLiked(song.id);
    final auth          = context.watch<AuthProvider>();
    final isPremium     = auth.currentUser?.plan != 'free';
    final isDownloaded  = music.isDownloaded(song.id);

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
              // ── Duration / Equalizer ───────────────────────────────────────
              if (isCurrentSong)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.equalizer, color: kPrimary, size: 20),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    song.formattedDuration,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kOnSurfaceVariant,
                    ),
                  ),
                ),
              // ── Like Button ────────────────────────────────────────────────
              if (showActions)
                GestureDetector(
                  onTap: () => context.read<MusicProvider>().toggleLike(song.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isLiked),
                        color: isLiked ? kPrimary : kOnSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              // ── Add to Playlist Button ─────────────────────────────────────
              if (showActions)
                GestureDetector(
                  onTap: () => _showPlaylistSheet(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.playlist_add,
                      color: kOnSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
              // ── Download Button ────────────────────────────────────────────
              if (showActions && isPremium)
                GestureDetector(
                  onTap: () {
                    if (isDownloaded) {
                      music.removeDownload(song);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed download: ${song.title}')));
                    } else {
                      music.downloadSong(song);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading: ${song.title}')));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isDownloaded ? Icons.download_done : Icons.download_for_offline_outlined,
                      color: isDownloaded ? kPrimary : kOnSurfaceVariant,
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

  /// Shows a bottom sheet to pick or create a playlist.
  void _showPlaylistSheet(BuildContext context) {
    final music = context.read<MusicProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PlaylistBottomSheet(
        song: song,
        music: music,
      ),
    );
  }
}

// ─── Playlist Bottom Sheet ────────────────────────────────────────────────────
class _PlaylistBottomSheet extends StatefulWidget {
  final Song song;
  final MusicProvider music;

  const _PlaylistBottomSheet({required this.song, required this.music});

  @override
  State<_PlaylistBottomSheet> createState() => _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends State<_PlaylistBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final names = widget.music.playlistNames;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.playlist_add, color: kPrimary, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Add to playlist',
                  style: TextStyle(
                    color: kOnSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: kOnSurfaceVariant, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Create new playlist ────────────────────────────────────────
          GestureDetector(
            onTap: () => _showCreateDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: kSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: kPrimary, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Create new playlist',
                    style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Existing playlists ─────────────────────────────────────────
          if (names.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: names.length,
                itemBuilder: (_, i) {
                  final name = names[i];
                  final alreadyAdded = widget.music.isSongInPlaylist(name, widget.song.id);

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      alreadyAdded ? Icons.check_circle : Icons.music_note,
                      color: alreadyAdded ? kPrimary : kOnSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: alreadyAdded ? kPrimary : kOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: alreadyAdded
                        ? const Text('Added', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12))
                        : null,
                    onTap: alreadyAdded
                        ? null
                        : () {
                            widget.music.addSongToPlaylist(name, widget.song.id);
                            setState(() {});  // refresh checkmarks
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${widget.song.title}" to $name'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Create Playlist', style: TextStyle(color: kOnSurface)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                widget.music.createPlaylist(name);
                widget.music.addSongToPlaylist(name, widget.song.id);
                Navigator.pop(dialogCtx);  // close dialog
                Navigator.pop(context);    // close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Created "$name" and added "${widget.song.title}"'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }
}

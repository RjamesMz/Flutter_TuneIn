/// File: lib/widgets/song_tile.dart
/// Role: Interactive list tile showing track durations, names, cover arts, and active play indicators.
/// Supports liking, downloading, and adding songs to custom playlists via a Bottom Sheet overlay.

// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/song.dart';
import '../providers/user_provider.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';

/// Highly customizable track card component loaded inside catalog lists.
class SongTile extends StatelessWidget {
  /// Selected track model parameters.
  final Song       song;

  /// Complete queue list for active track context.
  final List<Song> queue;

  /// Check showing if likes, playlists, and downloads buttons should be displayed.
  final bool       showActions;

  /// Constructs a [SongTile] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  /// [song] Active Song model data.
  /// [queue] Complete sibling songs list.
  /// [showActions] Visual actions display indicator.
  const SongTile({
    super.key,
    required this.song,
    required this.queue,
    this.showActions = true,
  });

  @override
  /// Builds the animated song card tile layout.
  ///
  /// [context] The building context.
  Widget build(BuildContext context) {
    final player       = context.watch<PlayerProvider>();
    final user         = context.watch<UserProvider>();
    final isCurrentSong = player.currentSong == song;
    final isPlaying     = isCurrentSong && player.isPlaying;
    final isLiked       = user.isLiked(song.id);
    final auth          = context.watch<AuthProvider>();
    final isPremium     = auth.currentUser?.plan.toLowerCase() == 'premium' || auth.currentUser?.plan.toLowerCase() == 'annual';
    final isDownloaded  = user.isDownloaded(song.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentSong
            ? kSurfaceContainerHighest
            : kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentSong
          ? Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1.5)
          : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<PlayerProvider>().play(song, queue: queue),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
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
                          color: kPrimary.withValues(alpha: 0.4),
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
              if (showActions)
                GestureDetector(
                  onTap: () => context.read<UserProvider>().toggleLike(song.id),
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
              if (showActions && isPremium)
                GestureDetector(
                  onTap: () {
                    if (isDownloaded) {
                      user.removeDownload(song);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed download: ${song.title}')));
                    } else {
                      user.downloadSong(song);
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

  /// Opens the playlist sheet dialogue.
  void _showPlaylistSheet(BuildContext context) {
    final user = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PlaylistBottomSheet(
        song: song,
        user: user,
      ),
    );
  }
}

/// Modal panel sheet rendering checklists of custom playlists to append new songs.
class _PlaylistBottomSheet extends StatefulWidget {
  /// Target song to append.
  final Song song;

  /// Custom provider managing active user state library operations.
  final UserProvider user;

  /// Constructs a [_PlaylistBottomSheet] instance.
  ///
  /// [key] An optional key.
  /// [song] Selected Song instance.
  /// [user] Active UserProvider instance.
  const _PlaylistBottomSheet({required this.song, required this.user});

  @override
  State<_PlaylistBottomSheet> createState() => _PlaylistBottomSheetState();
}

/// State controller managing checkmarks list updates on [_PlaylistBottomSheet].
class _PlaylistBottomSheetState extends State<_PlaylistBottomSheet> {
  @override
  /// Builds the playlists selection list inside sheet frames.
  Widget build(BuildContext context) {
    final names = widget.user.playlists.keys.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          if (names.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: names.length,
                itemBuilder: (_, i) {
                  final name = names[i];
                  final alreadyAdded = widget.user.isSongInPlaylist(name, widget.song.id);

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
                            // Syncs checklist checks inside the active state view frame dynamically on new items selection.
                            widget.user.addSongToPlaylist(name, widget.song.id);
                            setState(() {});
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

  /// Opens the confirm dialogue inputting new playlist names.
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
                widget.user.createPlaylist(name);
                widget.user.addSongToPlaylist(name, widget.song.id);
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
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

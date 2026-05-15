import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/responsive_helper.dart';
import '../providers/music_provider.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _addPlaylist(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: const Text("Create Playlist", style: TextStyle(color: kOnSurface)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Playlist name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<MusicProvider>().createPlaylist(name);
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _deletePlaylist(BuildContext context, String name) {
    context.read<MusicProvider>().deletePlaylist(name);
  }

  void _openPlaylist(BuildContext context, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(playlistName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final playlists = music.playlistNames;

    return Scaffold(
      backgroundColor: kSurface,

      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Playlists",
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          // ── Add Playlist button in the app bar ───────────────────────
          GestureDetector(
            onTap: () => _addPlaylist(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: ResponsiveWrapper(
        child: playlists.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/logs/nothing.png',
                      width: 180,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                    "No Playlists Yet",
                    style: TextStyle(
                      color: kOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tap + New to create one",
                    style: TextStyle(
                      color: kOnSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final name = playlists[index];
                final songCount = music.playlists[name]?.length ?? 0;

                return GestureDetector(
                  onTap: () => _openPlaylist(context, name),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Playlist icon
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.queue_music, color: kPrimary, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: kOnSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$songCount song${songCount == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  color: kOnSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: kOnSurfaceVariant),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: kSurface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) {
                                return ListTile(
                                  leading: const Icon(Icons.delete, color: Colors.red),
                                  title: const Text("Delete Playlist"),
                                  onTap: () {
                                    _deletePlaylist(context, name);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
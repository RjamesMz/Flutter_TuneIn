import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'playlist_music.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}
class _PlaylistPageState extends State<PlaylistPage> {

  List<String> playlists = [];
  void addPlaylist() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: const Text(
            "Create Playlist",
            style: TextStyle(color: kOnSurface),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: kOnSurface),
            decoration: const InputDecoration(
              hintText: "Playlist name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    playlists.add(controller.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void deletePlaylist(int index) {
    setState(() {
      playlists.removeAt(index);
    });
  }

  void openPlaylist(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(playlistName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,

      appBar: AppBar(
        backgroundColor: kSurface.withOpacity(0.9),
        elevation: 0,
        title: const Text(
          "Playlists",
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: playlists.isEmpty
          ? const Center(
              child: Text(
                "No Playlists",
                style: TextStyle(
                  color: kOnSurface,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: playlists.length,
              itemBuilder: (context, index) {

                return GestureDetector(
                  onTap: () {
                    openPlaylist(playlists[index]);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: kSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://picsum.photos/seed/${playlists[index]}/200",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlists[index],
                                style: const TextStyle(
                                  color: kOnSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Playlist",
                                style: TextStyle(
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
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text("Delete Playlist"),
                                        onTap: () {
                                          deletePlaylist(index);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: addPlaylist,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

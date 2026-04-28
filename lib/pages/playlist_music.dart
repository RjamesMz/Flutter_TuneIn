import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// 🔥 SAME FAB POSITION CLASS (or import it if you separate files)
class TopRightFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width
        - scaffoldGeometry.floatingActionButtonSize.width
        - 16;

    final double fabY = scaffoldGeometry.minInsets.top + 16;

    return Offset(fabX, fabY);
  }
}

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;

  const PlaylistDetailPage({super.key, required this.playlistName});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<String> songs = [];

  void addSong() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: const Text("Add Song", style: TextStyle(color: kOnSurface)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Song title"),
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
                    songs.add(controller.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void deleteSong(int index) {
    setState(() {
      songs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,

      appBar: AppBar(
        backgroundColor: kSurface.withOpacity(0.9),
        elevation: 0,
        title: Text(
          widget.playlistName,
          style: const TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: songs.isEmpty
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
                    "No Songs Yet",
                    style: TextStyle(
                      color: kOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tap + to add music",
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
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return Container(
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
                          "https://picsum.photos/seed/${songs[index]}/200",
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          songs[index],
                          style: const TextStyle(
                            color: kOnSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: kOnSurfaceVariant),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: kSurface,
                            builder: (_) {
                              return ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text("Delete Song"),
                                onTap: () {
                                  deleteSong(index);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

      // 🔥 TOP RIGHT FAB
      floatingActionButtonLocation: TopRightFabLocation(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: addSong,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';
import 'now_playing_page.dart';

// 🔥 SAME FAB POSITION CLASS
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

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {

  // 🔥 PLAYLIST SONGS
  List<Map<String, String>> songs = [];

  // 🔥 AVAILABLE SONGS
  final List<Map<String, String>> allSongs = [
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'duration': '3:20',
    },
    {
      'title': 'Levitating',
      'artist': 'Dua Lipa',
      'duration': '3:23',
    },
    {
      'title': 'Stay',
      'artist': 'Kid LAROI',
      'duration': '2:21',
    },
    {
      'title': 'Good 4 U',
      'artist': 'Olivia Rodrigo',
      'duration': '2:58',
    },
    {
      'title': 'Peaches',
      'artist': 'Justin Bieber',
      'duration': '3:18',
    },
    {
      'title': 'Montero',
      'artist': 'Lil Nas X',
      'duration': '2:17',
    },
  ];

  // 🔥 ADD SONG
  void addSong() {
    TextEditingController searchController = TextEditingController();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            final results = allSongs.where((song) {
              return song['title']!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  song['artist']!
                      .toLowerCase()
                      .contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 TITLE
                    const Center(
                      child: Text(
                        "Add Music",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kOnSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 SEARCH
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setModalState(() {
                          query = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Songs, artists...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: kOnSurfaceVariant,
                        ),

                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchController.clear();

                                  setModalState(() {
                                    query = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 SONG RESULTS
                    Expanded(
                      child: results.isEmpty
                          ? const Center(
                              child: Text(
                                "No songs found",
                                style: TextStyle(
                                  color: kOnSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {

                                final song = results[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: kSurfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(

                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        "https://picsum.photos/seed/${song['title']}/200",
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    title: Text(
                                      song['title']!,
                                      style: const TextStyle(
                                        color: kOnSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    subtitle: Text(
                                      song['artist']!,
                                      style: const TextStyle(
                                        color: kOnSurfaceVariant,
                                      ),
                                    ),

                                    trailing: const Icon(
                                      Icons.add_circle,
                                      color: kPrimary,
                                    ),

                                    onTap: () {

                                      final alreadyExists = songs.any(
                                        (s) =>
                                            s['title'] == song['title'],
                                      );

                                      if (!alreadyExists) {
                                        setState(() {
                                          songs.add(song);
                                        });
                                      }

                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 DELETE SONG
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

          // 🔥 EMPTY STATE
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

          // 🔥 SONG LIST
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: songs.length,
              itemBuilder: (context, index) {

                final song = songs[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20),

                 onTap: () {

  final durationText = songs[index]['duration']!;
  final parts = durationText.split(':');

  final minutes = int.parse(parts[0]);
  final seconds = int.parse(parts[1]);

  final songData = Song(
    id: songs[index]['title']!,

    title: songs[index]['title']!,

    artist: songs[index]['artist']!,

    album: 'Unknown Album',

    category: 'Music',

    duration: Duration(
      minutes: minutes,
      seconds: seconds,
    ),

    coverUrl:
        "https://picsum.photos/seed/${songs[index]['title']}/200",
  );

  context.read<PlayerProvider>().play(
    songData,
    queue: [
      songData,
    ],
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NowPlayingPage(),
    ),
  );
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

                        // 🔥 COVER
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://picsum.photos/seed/${song['title']}/200",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 🔥 SONG INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                song['title']!,
                                style: const TextStyle(
                                  color: kOnSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                song['artist']!,
                                style: const TextStyle(
                                  color: kOnSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔥 DURATION
                        Text(
                          song['duration']!,
                          style: const TextStyle(
                            color: kOnSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 6),

                        // 🔥 MORE
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: kOnSurfaceVariant,
                          ),
                          onPressed: () {

                            showModalBottomSheet(
                              context: context,
                              backgroundColor: kSurface,
                              builder: (_) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),

                                  title: const Text(
                                    "Delete Song",
                                  ),

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
                  ),
                );
              },
            ),

      // 🔥 FAB
      floatingActionButtonLocation: TopRightFabLocation(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: addSong,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
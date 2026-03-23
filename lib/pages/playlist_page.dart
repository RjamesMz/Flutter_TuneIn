    import 'package:flutter/material.dart';
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
              title: const Text("Create Playlist"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Playlist name",
                ),
              ),
              actions: [

                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),



                TextButton(
                  onPressed: (){
                    if(controller.text.isNotEmpty){
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

        return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
      SafeArea(
      child:Container(
        width: double.infinity,
        height: double.infinity,
      
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB6467A),
              Color(0xFFC65482),
              Color(0xFFD6688E),
            ],
          ),
        ),

         child: Container(
          padding: const EdgeInsets.all(10),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Playlists",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            
            Expanded(
              child: playlists.isEmpty
                  ? const Center(
                      child: Text(
                        "No Playlists",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 68),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),

                          child: ListTile(
                            leading: const Icon(Icons.queue_music),
                            title: Text(playlists[index]),

                            onTap: (){
                              openPlaylist(playlists[index]);
                            },

                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: (){
                                deletePlaylist(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton(
          onPressed: addPlaylist,
          child: const Icon(Icons.add),
        ),
      ),
        ],
      ),
      );
    }
 }
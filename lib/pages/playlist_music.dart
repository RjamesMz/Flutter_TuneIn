      import 'package:flutter/material.dart';

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

                title: const Text("Add Song"),

                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Song title",
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
       
        

        floatingActionButton: FloatingActionButton(
          onPressed: addSong,
          child: const Icon(Icons.add),
        ),

        body:SafeArea(
         child: Container(
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
             Text(
              "Songs in ${widget.playlistName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),

            Expanded(
              child: songs.isEmpty
                  ? const Center(
                      child: Text(
                        "No songs in playlist",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                 : ListView.builder(
                  padding: const EdgeInsets.only(top: 100),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),

                      child: ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(songs[index]),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: (){
                            deleteSong(index);
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
       );
     }
   }
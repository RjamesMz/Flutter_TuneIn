import 'package:flutter/material.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
      child : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFC24C7A),
              Color(0xFFD96C8C),
              Color(0xFFF08F98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
           ),
         ),
      
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
            
              const Text(
                "Search",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),

              const SizedBox(height: 20),

               TextField(
                 decoration: InputDecoration(
                  hintText: "Search songs, artists...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

          const SizedBox(height: 20),

               SizedBox(
                height: 350,
                child: Container(
                   decoration: BoxDecoration(
                      color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                                  
                  child: ListView(
                    children: const [

                      ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Blinding Lights"),
                        subtitle: Text("The Weeknd"),
                        trailing: Icon(Icons.play_arrow),
                      ),

                      ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Shape of You"),
                        subtitle: Text("Ed Sheeran"),
                        trailing: Icon(Icons.play_arrow),
                      ),

                      ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Levitating"),
                        subtitle: Text("Dua Lipa"),
                        trailing: Icon(Icons.play_arrow),
                      ),

                      ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Stay"),
                        subtitle: Text("Justin Bieber"),
                        trailing: Icon(Icons.play_arrow),
                      ),

                        ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Stay"),
                        subtitle: Text("Justin Bieber1"),
                        trailing: Icon(Icons.play_arrow),
                      ),

                        ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text("Stay"),
                        subtitle: Text("Justin Bieber2"),
                        trailing: Icon(Icons.play_arrow),
                      ),
                      
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    ),
    );
  }
}
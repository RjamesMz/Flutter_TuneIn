import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 
            Row(
                children: [
                   Image.asset(
                    'assets/image/logo/TuneIn_Logo.png',
                    height: 60,
                  ),

                   Text(
                    "Welcome ${widget.username}!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            const Text(
              "Featured Playlist",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),

            const SizedBox(height: 10),

            
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.album, size: 40),
                title: const Text("Top Hits 2026"),
                subtitle: const Text("Best trending songs"),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {},
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Recommended Songs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),

            const SizedBox(height: 10),

            
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
                         trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add),
                                SizedBox(width: 10),
                                Icon(Icons.play_arrow),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
              )

          ],
        ),
      ),
      ),
    );
  }
}
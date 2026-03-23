import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePage();
    }

   class _ProfilePage extends State<ProfilePage>{
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFC85080),
              Color(0xFFE77994),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 20),

       
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color.fromARGB(255, 194, 189, 191),
                      child: Text(
                        "JA",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "jeybi@email.com",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child: ListView(
                    children: [

                      profileTile(Icons.settings, "Settings", () {}),

                      profileTile(Icons.support_agent, "Customer Service", () {}),

                      profileTile(Icons.privacy_tip, "Privacy Policy", () {}),

                      profileTile(Icons.help_outline, "Help Center", () {}),

                      const SizedBox(height: 50),

                      SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300, 
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Lgout",
                                  style: TextStyle(
                                  fontSize: 18,      
                                  fontWeight: FontWeight.bold, 
                                ),
                            ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),  
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),

      child: ListTile(
        leading: Icon(icon, color: color),

        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}
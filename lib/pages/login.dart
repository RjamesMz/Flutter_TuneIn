    import 'package:flutter/material.dart';
  import 'package:tunely/mainpage.dart';

  class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
  }

     class _LoginPageState extends State<LoginPage>{ 

      final TextEditingController usernameController = TextEditingController();
      final TextEditingController passwordController = TextEditingController();

      final String correctUsername = "admin";
      final String correctPassword = "1234";

       Widget build(BuildContext context) {
        return Scaffold(
        body: Container(
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
            padding: const EdgeInsets.all(50),
            child: Column(
            
              children: [

                Image.asset(
                  'assets/image/logo/TuneIn_Logo.png',
                  height: 120,
                ),


                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                
                    SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, 
                        ),
                        onPressed: () {

                                  String username = usernameController.text;
                                  String password = passwordController.text;

                                  if (username == correctUsername && password == correctPassword) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MainPage(username: username),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Invalid username or password"),
                                      ),
                                    );

                                  }
                                },
                                
                        child: const Text(
                          "Login",
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
        );
    }
  }
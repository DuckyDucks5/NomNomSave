import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool isLoading = false;
  String? errorMessage;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse('http://10.0.2.2:3000/login'); // Emulator
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    if (response.statusCode == 200) {

      final hasRoom = data['hasRoom'] as bool;
      final user = data['user'];
      if (user == null || user['UserID'] == null) {
        setState(() {
          errorMessage = "User ID not found in response.";
        });
        return;
      }

      final int userId = user['UserID'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('UserID', userId);

      if (!mounted) return;
      if(hasRoom) {
        log("User has a room: ${data['room']}");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        log("User does not have a room: ${data['room']}");
        Navigator.pushReplacementNamed(context, "/homeNull");
      }

    } else {
      setState(() {
        errorMessage = data['message'];
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        log("Google ID Token: $idToken");

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          log("Google login success: ${data['user']}");
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Google Sign-In failed.';
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to retrieve ID token.";
        });
      }
    } catch (e) {
      log("Google Sign-In error: $e");
      setState(() {
        errorMessage = "An error occurred during Google Sign-In.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                "LOGIN",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Please sign in to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              TextField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    const Text("Or"),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleGoogleSignIn,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/googlelogo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text("Continue with Google"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LOGIN →",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text(
                        "Don't have an account? Register here.",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

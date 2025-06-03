import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_se/view/homepage2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomDescController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  int? userID; // deklarasi global di _CreateRoomPageState
  String? token;

  @override
  void initState() {
    super.initState();
    loadUserID();
  }

  Future<void> loadUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('UserID');
    });

    if(userID == null) {
      setState(() {
        errorMessage = "User ID is null.";
      });
    }
  }

  Future<void> createRoom(String teamName, String teamDesc, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });

    final url = Uri.parse('https://nomnomsave-be-se-production.up.railway.app/create-room'); // Emulator

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({
          'teamName': teamName,
          'teamDesc': teamDesc,
          'userId': userID,
          'profileImageIndex': selectedImageIndex,
        }),
      );
      print("response status code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setInt('TeamID', data['teamId']);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Room Created'),
            content: Text('Room Code: ${data['roomCode']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        showError(error['error'] ?? 'Failed to create room.');
      }
    } catch (e) {
      showError('An error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  int selectedImageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 90,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Room',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.grey),
            const SizedBox(height: 5),
            Row(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePicturePickerPage(),
                          ),
                        );
                        if (result != null && result is int) {
                          setState(() {
                            selectedImageIndex = result;
                          });
                        }
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          image: DecorationImage(
                            image: AssetImage('assets/profileRoom/profile_$selectedImageIndex.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePicturePickerPage(),
                            ),
                          );
                          if (result != null && result is int) {
                            setState(() {
                              selectedImageIndex = result;
                            });
                          }
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.orange, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Room Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _roomNameController,
                        cursorColor: const Color.fromARGB(255, 43, 29, 9),
                        decoration: const InputDecoration(
                          hintText: 'Enter room name',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Room Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            TextField(
              controller: _roomDescController,
              cursorColor: Colors.orange,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Room Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'You can only create up to 7 rooms in your account',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.orange,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          final name = _roomNameController.text.trim();
                          final desc = _roomDescController.text.trim();
                          if (name.isEmpty || desc.isEmpty) {
                            showError('Please fill in all fields.');
                            return;
                          }
                          if (userID != null) {
                            createRoom(name, desc, userID!);
                          } else {
                            showError('User ID is null.');
                          }
                          // createRoom(name, desc, userID!); 
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage2()),
                        );
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Room', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProfilePicturePickerPage extends StatelessWidget {
  const ProfilePicturePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Profile Picture")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final imageIndex = index + 1;
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, imageIndex); // kembalikan nilai ke parent
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/profileRoom/profile_$imageIndex.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

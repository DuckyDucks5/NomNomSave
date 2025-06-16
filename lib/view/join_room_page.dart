import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_se/view/homepage2.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JoinRoomPage(),
  ));
}

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});
  

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController roomCodeController = TextEditingController();
  String? roomName;
  bool isLoading = false;
  String? errorMessage;

  Future<void> findRoom() async {
    final enteredCode = roomCodeController.text.trim();

    if (enteredCode.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a room code.';
        roomName = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      roomName = null;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse('http://10.0.2.2:3000/get-room-name/$enteredCode');
      
      final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          roomName = data['roomName'];
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Room not found.';
        });
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to connect: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> joinRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');


    if (userId == null) {
      return;
    }

    final roomCode = roomCodeController.text.trim();

    if (roomCode.isEmpty || roomName == null) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/join-room');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({
          'userId': userId,
          'roomCode': roomCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined room!')),
        );

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage2()),
        ); 
        
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to join room.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          'Join a Room',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Divider(color: Colors.grey),
                const SizedBox(height: 100),
                const Text(
                  'Room Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: roomCodeController,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter room code',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Find Room
                ElevatedButton(
                  onPressed: isLoading ? null : findRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Find Room'),
                ),

                const SizedBox(height: 16),

                if (roomName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Room Name:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          roomName!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),
                  ),

                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 160),
              ],
            ),
          ),

          // Tombol Join Room
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: ElevatedButton(
                onPressed: roomName != null
                    ? () {
                        joinRoom();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: roomName != null ? Colors.orange : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Join Room',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

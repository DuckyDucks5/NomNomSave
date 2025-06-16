import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePage extends StatefulWidget {
  final int teamId;
  final String? teamName;
  final int teamProfileIndex;
  final String? teamDescription;

  const UpdatePage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamProfileIndex,
    required this.teamDescription,
  });

  @override
  State<UpdatePage> createState() => UpdateRoomPage();
}

class UpdateRoomPage extends State<UpdatePage> {
  int? currentUserId;
  int? selectedImageIndex;
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String currentUser = 'You';
  static const orange = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    selectedImageIndex = widget.teamProfileIndex;
    _roomNameController.text = widget.teamName ?? '';
    _descriptionController.text = widget.teamDescription ?? '';
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('UserID');
    });
  }

  Future<void> _updateRoom() async {
  final teamName = _roomNameController.text;
  final teamDesc = _descriptionController.text; // Akses dari controller global
  final teamId = widget.teamId;
  final profileImageIndex = selectedImageIndex ?? 0;

  final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

  final url = Uri.parse('http://10.0.2.2:3000/update-room/$teamId'); // Ganti dengan URL backend kamu

  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
      },
    body: jsonEncode({
      'teamName': teamName, 
      'teamDesc': teamDesc,
      'profileImageIndex': profileImageIndex}),
  );

  
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room updated successfully!')),
    );
    Navigator.pushReplacementNamed(context, '/home'); // Kembali ke halaman sebelumnya
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update room: ${response.body}')),
    );
  }
}


  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          _buildRoomDescription(),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildActionButton("Update Room", orange, () {
                  _updateRoom();
                }),
              ),
            ],
          ),
          // const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Stack(
            clipBehavior: Clip.none, 
            children: [
              // Gambar profil dengan bingkai orange
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/profileRoom/profile_${selectedImageIndex ?? 0}.jpeg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              
              Positioned(
                bottom:
                    -5, // Geser ke bawah sedikit agar terlihat keluar dari frame
                right: -5, // Geser ke kanan sedikit agar ikonnya di pojok
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        // Ikon kamera dengan latar gradasi orange
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _pickProfileImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePicturePickerPage()),
    );
    if (result != null && result is int && mounted) {
      setState(() {
        selectedImageIndex = result;
      });
    }
  }

  Widget _buildRoomDescription() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Room Name",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: _roomNameController,
        decoration: InputDecoration(
          hintText: "Enter room name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      const SizedBox(height: 20),

      const Text(
        "Room Description",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Enter room description",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (value) {
          // Optional: update local variable if needed
        },
      ),
    ],
  );
}


  Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback onPressed,
  ) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
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
                  image: AssetImage(
                    'assets/profileRoom/profile_$imageIndex.jpeg',
                  ),
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

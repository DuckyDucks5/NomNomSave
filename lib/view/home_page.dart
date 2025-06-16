import 'package:flutter/material.dart';
import 'package:flutter_se/view/create_room_page.dart';
import 'package:flutter_se/view/join_room_page.dart';
// import 'package:flutter_se/view/view_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  int? userProfileIndex; 
  int? userId; 

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserId(); // Refresh data saat halaman muncul kembali
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('UserID');
      userProfileIndex = prefs.getInt('UserProfileIndex') ?? 1; 
    });
    print("User Profile Index room: $userProfileIndex");
  }

  Future<void> fetchLogOut() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null || token == null) return;

    final url = Uri.parse(
      'http://10.0.2.2:3000/logout',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      print("Logout successful: ${response.body}");
      await prefs.remove('UserID');
      await prefs.remove('token');
      await prefs.setBool('isLoggedIn', false);
      await prefs.clear();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else {
      print("Logout failed: ${response.body}");
      throw Exception('Failed to logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);
    const lightOrange = Color(0xFFFFC692);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black, size: 30),
              tooltip: 'Logout',
              onPressed: () async {
                try {
                  await fetchLogOut();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
                }
              },
            ),
          ],
        title: const Text(
          "Welcome New NomNomers!",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const ProfilePage(),
        //         ),
        //       );
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.only(right: 16.0),
        //       child: Container(
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           border: Border.all(color: Colors.orange, width: 2.0),
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.black.withOpacity(0.2),
        //               spreadRadius: 0.4,
        //               blurRadius: 2,
        //               offset: const Offset(0, 3),
        //             ),
        //           ],
        //         ),
        //         child: CircleAvatar(
        //           radius: 20,
        //           backgroundImage: AssetImage(
        //             'assets/profileUser/profile_$userProfileIndex.jpg',
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),

      body: const SharedPage(),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: orange,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: lightOrange,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            if (index == 0) {
              _loadUserId(); // Refresh data saat klik home di navbar
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          ],
        ),
      ),
    );
  }
}

class SharedPage extends StatelessWidget {
  const SharedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.grey, thickness: 0.5, height: 0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "To continue your experience with NomNomSave, please create or join a room to be able to add product",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateRoomPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Create a Room"),
                    ),
                    const SizedBox(width: 16),
                    const Text("or", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinRoomPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Join a Room"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

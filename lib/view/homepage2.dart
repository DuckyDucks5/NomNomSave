import 'package:flutter/material.dart';
import 'product_page.dart';
import 'calendar_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_room_page.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  int currentIndex = 0;
  List<dynamic> roomList = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final teamId = prefs.getString('teamId') ?? '';

    if (teamId.isEmpty) {
      print("No teamId found in SharedPreferences.");
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/view-room/$teamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        roomList = data;
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);
    const lightOrange = Color(0xFFFFC692);

    final pages = [
      DashboardPage(roomList: roomList, onReload: fetchRooms),
      const ProductPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
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
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<dynamic> roomList;
  final VoidCallback onReload;

  const DashboardPage({super.key, required this.roomList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "Welcome, NomNomers!",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "My Room",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: roomList.length + 1,
              itemBuilder: (context, index) {
                if (index < roomList.length) {
                  final room = roomList[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/profileRoom/profile_${room['image']}.jpeg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 70,
                          child: Text(
                            room['name'] ?? 'Room',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      // Add new room action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateRoomPage()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Icon(Icons.add, size: 30),
                          ),
                          const SizedBox(height: 4),
                          const Text("add new",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "Expires Soon!",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Save your product, don’t let them wasted!",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildProductSoonItem("#1", "Coklat Silverqueen", "Friday, 14 March 2025"),
          _buildProductSoonItem("#2", "Selai kacang ABC", "Tuesday, 18 March 2025"),
          _buildProductSoonItem("#3", "Blueband Bakery", "Sunday, 16 March 2025"),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "Recently Added Product",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Check the product that recently added by you or your team member",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("New",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: orange.withAlpha(20),
                      ),
                      onPressed: () {},
                      child: const Text("View Detail",
                          style: TextStyle(color: orange)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Sarden kaleng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                const Text("added by Auryn from OneTwo team",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProductSoonItem(String index, String name, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(index,
              style: const TextStyle(
                  color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("from nomnom’s team",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(date,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

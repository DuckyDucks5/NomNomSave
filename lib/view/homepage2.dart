import 'package:flutter/material.dart';
import 'package:flutter_se/view/view_room_page.dart';
import 'join_room_page.dart';
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
  List<dynamic> productSoonList = [];
  List<dynamic> recentlyAdded = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
    fetchProductSoon();
    fetchRecentlyAdded();
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');

    if (userId == null) {
      print('UserID not found in SharedPreferences');
      return;
    }

    print('UserID sekarang: $userId');
    final url = Uri.parse('http://10.0.2.2:3000/view-room/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        roomList = data;
      });
    } else {
      throw Exception('Failed to load rooms');
    }

    print('Room list adalah: $roomList');
  }

  Future<void> fetchProductSoon() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');

    final url = Uri.parse('http://10.0.2.2:3000/overview-product-home/$userId');
    final response = await http.get(url);
    print("response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        productSoonList = data;
      });
    } else {
      throw Exception('Failed to load products');
    }

    print("product soon list: $productSoonList");
  }

  Future<void> fetchRecentlyAdded() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');

    final url = Uri.parse(
      'http://10.0.2.2:3000/recently-added-product/$userId',
    );
    final response = await http.get(url);
    print("response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        recentlyAdded = data;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);
    const lightOrange = Color(0xFFFFC692);

    final pages = [
      DashboardPage(
        roomList: roomList,
        productSoonList: productSoonList,
        recentlyAdded: recentlyAdded,
        onReload: () {
          fetchRooms();
          fetchProductSoon();
          fetchRecentlyAdded();
        },
      ),
      const ProductPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: currentIndex, children: pages),
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

class DashboardPage extends StatelessWidget {
  final List<dynamic> roomList;
  final List<dynamic> productSoonList;
  final List<dynamic> recentlyAdded;
  final VoidCallback onReload;

  const DashboardPage({
    super.key,
    required this.roomList,
    required this.productSoonList,
    required this.onReload,
    required this.recentlyAdded,
  });

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

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewRoom(
                                teamId: room['TeamID'],
                                teamName: room['TeamName'],
                                teamProfileIndex: room['TeamProfileIndex'],
                                teamDescription: room['TeamDescription'],
                                teamCode: room['RoomCode'],
                              ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/profileRoom/profile_${room['TeamProfileIndex'] ?? 1}.jpeg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80,
                            child: Text(
                              room['TeamName'] ?? 'Room',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const CreateJoinRoomModal();
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Icon(Icons.add, size: 30),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "add new",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
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
          ...productSoonList.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            if (index < 1 || index > 3) return const SizedBox.shrink();

            final name = product['ProductName'] as String;
            final teamName = product['TeamName'] as String;
            final rawDate = product['FormattedExpiredDate'] as String;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orangeAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text("from $teamName's team"),
                        ],
                      ),
                      Text(
                        rawDate,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
          const SizedBox(height: 10),
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
          ...recentlyAdded.map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge "New" yang sudah di-center vertikal
                  SizedBox(
                    height: 48, // pastikan tingginya seragam dengan konten lain
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: orange),
                        ),
                        child: const Text(
                          "New",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Center content: Product name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['ProductName'] ?? 'Unknown Product',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "added by ${product['UserName']} from ${product['TeamName']} team",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // "View Detail" button
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: orange),
                      minimumSize: const Size(0, 24), // adjust height
                    ),
                    onPressed: () {
                      // Tambahkan logika jika diperlukan
                    },
                    child: Text(
                      "View Detail",
                      style: TextStyle(color: orange, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProductSoonItem(
    String index,
    String name,
    String date,
    String teamName,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            index,
            style: const TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "from ${teamName}'s team",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class CreateJoinRoomModal extends StatelessWidget {
  const CreateJoinRoomModal({super.key});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Container(
      padding: const EdgeInsets.all(24),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Select One",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.pop(context); // tutup modal
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRoomPage()),
              );
            },
            child: const Text(
              "Create New Room",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.pop(context); // tutup modal
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JoinRoomPage()),
              );
            },
            child: const Text(
              "Join a Room",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.orange,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.orange,
                  decorationThickness: 2.0, // Tebal underline
                  height: 2.5, // Menambahkan jarak antara teks dan underline
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
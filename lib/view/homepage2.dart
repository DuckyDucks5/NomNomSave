import 'package:flutter/material.dart';
import 'package:flutter_se/view/history_page.dart';
import 'package:flutter_se/view/view_product_page.dart';
import 'package:flutter_se/view/view_profile_page.dart';
import 'package:flutter_se/view/view_room_page.dart';
import 'join_room_page.dart';
import 'product_page.dart';
import 'calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_room_page.dart';

class HomePage2 extends StatefulWidget {
  final int initialIndex;
  final int? initialRoomId;

  const HomePage2({super.key, this.initialIndex = 0, this.initialRoomId});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  late int currentIndex;
  List<dynamic> roomList = [];
  List<dynamic> productSoonList = [];
  List<dynamic> recentlyAdded = [];
  int userProfileIndex = 1;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    fetchRooms();
    fetchUserProfile();
    fetchProductSoon();
    fetchRecentlyAdded();
    fetchCheckExpired();
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('UserID');

    if (userId == null) {
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/view-room/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        roomList = data;
      });
    } else {
      throw Exception('Failed to load rooms');
    }

    print("Room list: $roomList");
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null || token == null) return;

    final url = Uri.parse('http://10.0.2.2:3000/view-profile/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded is List ? decoded[0] : decoded;

      setState(() {
        userProfileIndex = data['UserProfileIndex'] ?? 1;
      });
    } else {
      throw Exception('Failed to load user profile');
    }

    print("User Profile Index home: $userProfileIndex");
  }

  Future<void> fetchProductSoon() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:3000/overview-product-home/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("status code product soon : ${response.statusCode}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        productSoonList = data;
      });
    } else {
      throw Exception('Failed to load products');
    }
    print("product Soon: $productSoonList");
  }

  Future<void> fetchRecentlyAdded() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    final url = Uri.parse(
      'http://10.0.2.2:3000/recently-added-product/$userId',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        recentlyAdded = data;
      });
    } else {
      throw Exception('Failed to load products');
    }

    print("recently added : $recentlyAdded");
  }

  Future<void> fetchCheckExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/mark-expired'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Expired products updated successfully.");
    } else {
      print("Failed to update expired products.");
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
        userProfileIndex: userProfileIndex,
      ),
      ProductPage(roomId: widget.initialRoomId ?? -1), // Pass initialRoomId
      const CalendarPage(),
      const HistoryPage(),
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
          currentIndex: currentIndex, // Add this line
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

              if (index == 0) {
                fetchRooms();
                fetchProductSoon();
                fetchRecentlyAdded();
              }
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
  final int userProfileIndex;

  const DashboardPage({
    super.key,
    required this.roomList,
    required this.productSoonList,
    required this.onReload,
    required this.recentlyAdded,
    required this.userProfileIndex,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome, NomNomers!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Ganti `ProfilePage()` dengan halaman tujuan kamu
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange, // Warna border
                      width: 2.0, // Ketebalan border
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Warna bayangan
                        spreadRadius: 0.4,
                        blurRadius: 2,
                        offset: Offset(0, 3), // Posisi bayangan
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      'assets/profileUser/profile_$userProfileIndex.jpg',
                    ),
                  ),
                ),
              ),
            ],
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
                      onReload();
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
                    onTap: () async {
                      await showModalBottomSheet(
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
                      onReload();
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
            "Expired Soon!",
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

            if (index >= 3) return const SizedBox.shrink();

            final name = product['ProductName'] as String;
            final teamName = product['TeamName'] as String;
            final rawDate = product['FormattedExpiredDate'] as String;
            final teamId = product['TeamTeamID'];
            final category = product['CategoryName'] as String;
            final categoryId = product['ProductCategoryId'];

            print("isi produk soon: $product");
            print("isi teamId: $teamId");
            print("isi category: $category");
            print("isi categoryId: $categoryId");

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ViewProductCategory(
                              category: category,
                              teamId: teamId,
                              categoryId: categoryId,
                            ),
                      ),
                    );
                  },
                  child: Container(
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
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
            print("isi produk : $product");
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
                      minimumSize: const Size(0, 24),
                    ),
                    onPressed: () {
                      // final homeState =
                      //     context.findAncestorStateOfType<_HomePage2State>();
                      // if (homeState != null) {
                      final roomId = product['TeamID'];
                      //   // int selectedRoomIndex = 10;

                      //   // if (roomId != null && roomId != -1) {
                      //   //   selectedRoomIndex = homeState.roomList.indexWhere(
                      //   //     (room) => room['TeamID'] == roomId,
                      //   //   );
                      //   //   selectedRoomIndex =
                      //   //       selectedRoomIndex == -1 ? 0 : selectedRoomIndex;
                      //   // }

                      //   // print(
                      //   //   "Selected Room Index ke product: $selectedRoomIndex",
                      //   // );
                      //   print("Room ID ke product: $roomId");
                      //   // Update pages with new ProductPage instance
                      //   final newPages = [
                      //     // ...existing DashboardPage...
                      //     ProductPage(roomId: roomId),
                      //     // ...existing other pages...
                      //   ];

                      //   homeState.setState(() {
                      //     homeState.currentIndex = 1;
                      //   });
                      // }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => HomePage2(
                                initialIndex:
                                    1, // Set initial index ke ProductPage
                                initialRoomId: roomId, // Pass roomId
                              ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text(
                      "View Detail",
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 140, 66, 1),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }), //.toList(),

          const SizedBox(height: 50),
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

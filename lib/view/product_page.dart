import 'package:flutter/material.dart';
import 'package:flutter_se/view/add_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'join_room_page.dart';
import 'view_room_page.dart';
import 'create_room_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> roomList = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');

    print('UserID dari SharedPreferences: $userId');
    if (userId == null) {
      print('UserID not found in SharedPrreferences');
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

  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: const Icon(Icons.addchart_rounded, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Text(
              "My Room",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomList.length + 1,
                itemBuilder: (context, index) {
                  print("Room list length product: ${roomList.length}");

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
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                CategoryCard(
                  imagePath: "assets/category/bread.png",
                  title: "Bakery & Bread",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/category/drinks.png",
                  title: "Beverages",
                  count: 2,
                ),
                CategoryCard(
                  imagePath: "assets/category/canned.png",
                  title: "Canned & Preserved Food",
                  count: 2,
                ),
                CategoryCard(
                  imagePath: "assets/category/dairy.png",
                  title: "Dairy & Eggs",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/category/frozen.png",
                  title: "Frozen Food",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/category/snack.png",
                  title: "Snacks & Sweets",
                  count: 5,
                ),
                CategoryCard(
                  imagePath: "assets/category/spices.png",
                  title: "Spices & Condiments",
                  count: 5,
                ),
                CategoryCard(
                  imagePath: "assets/category/other.png",
                  title: "Others",
                  count: 3,
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomItem(String imagePath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAddNewRoom() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, size: 30),
        ),
        const SizedBox(height: 4),
        const Text(
          "add new",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final int count;

  const CategoryCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF333333);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
          Text(
            "$count items",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
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

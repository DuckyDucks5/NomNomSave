import 'package:flutter/material.dart';
import 'package:flutter_se/view/add_product_page.dart';
import 'package:flutter_se/view/view_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'join_room_page.dart';
import 'create_room_page.dart';

class ProductPage extends StatefulWidget {
  // final int? selectedRoomIndex;
  final int? roomId;

  const ProductPage({super.key, this.roomId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> roomList = [];
  List<dynamic> categoryCounts = [];
  // hapus late int selectedRoomIndex;
  late int roomId;

  @override
  void initState() {
    super.initState();
    print("roomId di ProductPage: ${widget.roomId}");
    roomId = widget.roomId ?? -1;
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null) return;

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
        // Jika roomId belum diset (-1), gunakan TeamID dari room pertama
        if (roomId == -1 && data.isNotEmpty) {
          roomId = data[0]['TeamID'];
        }
        fetchProductCountForRoom(roomId);
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> fetchProductCountForRoom(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:3000/count-products/$teamId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        categoryCounts = data;
      });
    } else {
      throw Exception('Failed to load product counts');
    }
  }

  int getCountByCategory(String category) {
    for (var item in categoryCounts) {
      if (item is Map<String, dynamic>) {
        if (item['CategoryName'] == category) {
          return item['ProductCount'] as int;
        }
      }
    }
    return 0;
  }

  int getCategoryId(String category) {
    for (var item in categoryCounts) {
      if (item is Map<String, dynamic>) {
        if (item['CategoryName'] == category) {
          return item['CategoryID'] as int;
        }
      }
    }
    return 0;
  }

  Widget buildCategoryCard(String imagePath, String title) {
    final count = getCountByCategory(title);
    final categoryId = getCategoryId(title);

    return GestureDetector(
      onTap: () {
        if (roomId != -1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProductCategory(
                category: title,
                teamId: roomId,
                categoryId: categoryId,
              ),
            ),
          ).then((value) {
            if (value == 'refresh') {
              fetchProductCountForRoom(roomId);
            }
          });
        }
      },
      child: CategoryCard(imagePath: imagePath, title: title, count: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);
    // print("roomIndexdiProduct : $selectedRoomIndex");
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );

          if (result == 'goToProduct') {
            await fetchRooms();
          }
        },
        child: const Icon(Icons.addchart_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "My Room",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 105,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: roomList.length + 1,
                    itemBuilder: (context, index) {
                      if (index < roomList.length) {
                        final room = roomList[index];
                        final isSelected = room['TeamID'] == roomId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              roomId = room['TeamID'];
                            });
                            fetchProductCountForRoom(roomId);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 80,
                              child: Column(
                                children: [
                                  Container(
                                    decoration:
                                        isSelected
                                            ? BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            )
                                            : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/profileRoom/profile_${room['TeamProfileIndex'] ?? 1}.jpeg',
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    room['TeamName'] ?? 'Room',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.black : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      height: 2,
                                      color: Colors.grey.shade500,
                                      width: 40,
                                    ),
                                ],
                              ),
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
                  children: [
                    buildCategoryCard(
                      "assets/category/bread.png",
                      "Bakery & Bread",
                    ),
                    buildCategoryCard(
                      "assets/category/drinks.png",
                      "Beverages",
                    ),
                    buildCategoryCard(
                      "assets/category/canned.png",
                      "Canned & Preserved Food",
                    ),
                    buildCategoryCard(
                      "assets/category/dairy.png",
                      "Dairy & Eggs",
                    ),
                    buildCategoryCard(
                      "assets/category/frozen.png",
                      "Frozen Food",
                    ),
                    buildCategoryCard(
                      "assets/category/snack.png",
                      "Snack & Sweets",
                    ),
                    buildCategoryCard(
                      "assets/category/spices.png",
                      "Spice & Condiments",
                    ),
                    buildCategoryCard("assets/category/other.png", "Other"),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: title == "Canned & Preserved Food" ? 12.9 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text('$count items', style: TextStyle(color: Colors.grey.shade600)),
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

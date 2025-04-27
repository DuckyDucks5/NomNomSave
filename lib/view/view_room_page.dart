import 'package:flutter/material.dart';

void main() {
  runApp(const ViewRoom());
}

class ViewRoom extends StatelessWidget {
  const ViewRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RoomPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoomPage extends StatelessWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent, // makes it fully transparent
        elevation: 0, // removes shadow
        shadowColor: Colors.transparent, // extra safety
        surfaceTintColor: Colors.transparent, // for Material 3 themes
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Nomnom’s",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/room_icon.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Text("Member/s",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMemberCircle("You", orange),
                      _buildMemberCircle("A", orange),
                      _buildMemberCircle("S", orange),
                      _buildAddMemberCircle(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Room Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Remember to save your nonnoms!",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Product List",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(color: orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildProductTile(
                    name: "Sarden kaleng",
                    addedBy: "Auryn",
                    date: "10 December 2025",
                  ),
                  const SizedBox(height: 10),
                  _buildProductTile(
                    name: "Ramyeon Yummy",
                    addedBy: "You",
                    date: "6 February 2025",
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton("Update Room", orange),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton("Delete Room", Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMemberCircle(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  static Widget _buildAddMemberCircle() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: const Icon(Icons.add, color: Colors.grey),
        foregroundColor: Colors.grey,
      ),
    );
  }

  static Widget _buildProductTile({
    required String name,
    required String addedBy,
    required String date,
  }) {
    return Container(
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("added by $addedBy"),
            ],
          ),
          Text(
            "Expiration Date\n$date",
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text(label),
      ),
    );
  }
}

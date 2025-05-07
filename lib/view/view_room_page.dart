import 'package:flutter/material.dart';
import 'package:flutter_se/view/update_room_page.dart';

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

void _navigateToUpdateRoomPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const UpdatePage()),
  );
}

bool isExpanded = false;

List<Map<String, String>> members = [
  {"label": "You", "name": "Siapanamanydmnrumahny"},
  {"label": "A", "name": "Auryn"},
  {"label": "S", "name": "Selina"},
];

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool isExpanded = false;

  List<Map<String, String>> members = [
    {"label": "You", "name": "Siapanamanydmnrumahny"},
    {"label": "A", "name": "Auryn"},
    {"label": "S", "name": "Selina"},
    {"label": "D", "name": "Dontol"},
  ];

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isExpanded = !isExpanded),
                        child: Row(
                          children: [
                            const Text(
                              "Member/s",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    firstChild: Row(
                      children: [
                        for (var member in members)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFFF49A50),
                              radius: 20,
                              child: Text(
                                member["label"]!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            // Add member logic
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    secondChild: SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var member in members)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFF49A50),
                                      radius: 20,
                                      child: Text(
                                        member["label"]!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        member["name"]!,
                                        style: const TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                // Add new member logic
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Add New Member",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
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
                      Text("View All", style: TextStyle(color: orange)),
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
                        child: _buildActionButton(
                          "Update Room",
                          orange,
                          () => _navigateToUpdateRoomPage(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          "Delete Room",
                          Colors.red,
                          () => _showDeleteConfirmation(context),
                        ),
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

  static Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback onPress,
  ) {
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
        onPressed: onPress,
        child: Text(label),
      ),
    );
  }
}

void _showDeleteConfirmation(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure to delete this room?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "By deleting this room, all of your saved nomnoms will be deleted ",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Text(
              "permanently.",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle delete logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4A651),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Delete Room"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFFF4A651),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

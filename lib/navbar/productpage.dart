import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          // TODO: Add action
        },
        child: const Icon(Icons.addchart_rounded, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Text("My Room", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRoomItem("assets/room_icon.jpg", "nomnom’s"),
                const SizedBox(width: 12),
                _buildAddNewRoom(),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  imagePath: "assets/bread.png",
                  title: "Bakery & Bread",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/drinks.png",
                  title: "Beverages",
                  count: 2,
                ),
                CategoryCard(
                  imagePath: "assets/canned.png",
                  title: "Canned & Preserved Food",
                  count: 2,
                ),
                CategoryCard(
                  imagePath: "assets/dairy.png",
                  title: "Dairy & Eggs",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/frozen.png",
                  title: "Frozen Food",
                  count: 3,
                ),
                CategoryCard(
                  imagePath: "assets/snack.png",
                  title: "Snacks & Sweets",
                  count: 5,
                ),
                CategoryCard(
                  imagePath: "assets/spices.png",
                  title: "Spices & Condiments",
                  count: 5,
                ),
                CategoryCard(
                  imagePath: "assets/other.png",
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
          child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
        const Text("add new", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
              child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
          Text("$count items",
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

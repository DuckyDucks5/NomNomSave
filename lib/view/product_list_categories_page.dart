// main.dart
import 'package:flutter/material.dart';

void main() => runApp(CategoriesListPage());

class CategoriesListPage extends StatefulWidget {
  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    Center(child: Text('Home Page')),
    Center(child: Text('Categories List Page')),
    Center(child: Text('Calendar Page')),
    Center(child: Text('History Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Icon(Icons.playlist_add),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        ],
      ),
      body: _currentIndex == 1 ? _buildCategoriesBody() : _pages[_currentIndex],
    );
  }

  Widget _buildCategoriesBody() {
    final List<Map<String, String>> rooms = [
      {'name': "nomnom's", 'image': 'assets/pochacco.png'},
      {'name': "ai lop u", 'image': 'assets/ailopu.png'},
      {'name': "add new", 'image': ''},
    ];

    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Bakery & Bread',
        'items': 3,
        'image': 'assets/SE_ctg_Bread.png',
      },
      {'name': 'Beverages', 'items': 2, 'image': 'assets/SE_ctg_Drinks.png'},
      {
        'name': 'Canned & Preserved Food',
        'items': 2,
        'image': 'assets/SE_ctg_CannedFood.png',
      },
      {
        'name': 'Dairy & Eggs',
        'items': 3,
        'image': 'assets/SE_ctg_Dairy&Eggs.png',
      },
      {
        'name': 'Frozen Food',
        'items': 3,
        'image': 'assets/SE_ctg_FrozenFood.png',
      },
      {
        'name': 'Snacks & Sweets',
        'items': 5,
        'image': 'assets/SE_ctg_Snacks&Sweets.png',
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 100),
            const Text(
              'My Room',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                          image:
                              room['image'] != ''
                                  ? DecorationImage(
                                    image: AssetImage(room['image']!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            room['image'] == ''
                                ? const Center(child: Icon(Icons.add, size: 28))
                                : null,
                      ),
                      const SizedBox(height: 8),
                      Text(room['name']!, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(category['image']),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(
                      '${category['name']}\n${category['items']} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

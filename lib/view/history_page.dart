import 'package:flutter/material.dart';

class ProductHistoryPage extends StatelessWidget {
  final List<Map<String, String>> historyItems = [
    {
      'status': 'Expired',
      'product': 'Mini Banana Bread',
      'room': "NomNom’s",
      'date': '20 Mei 2025',
    },
    {
      'status': 'Expired',
      'product': 'Ultramilk Strawberry 9000mL',
      'room': "ai lop u",
      'date': '19 Mei 2025',
    },
    {
      'status': 'Consumed',
      'product': 'Selai Kacang ABC',
      'room': "NomNom’s",
      'date': '18 Mei 2025',
    },
    {
      'status': 'Consumed',
      'product': 'Sari roti roti sari roti',
      'room': "ai lop u",
      'date': '15 Mei 2025',
    },
    {
      'status': 'Expired',
      'product': 'Silverqueen Lalala',
      'room': "NomNom’s",
      'date': '11 Mei 2025',
    },
  ];

  Color _getStatusColor(String status) {
    return status == 'Expired' ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Product History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...historyItems.map((item) {
                final color = _getStatusColor(item['status']!);
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 100,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['status']!,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['product']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['room']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    item['date']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 100), // for bottom padding
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: 3,
          onTap: (index) {
            // Handle navigation
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

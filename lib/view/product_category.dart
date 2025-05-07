import 'package:flutter/material.dart';
import 'package:flutter_se/view/update_product_page.dart' as updatePage;
import 'package:flutter_se/model/bakery_items.dart';

void main() => runApp(const BakeryApp());

class BakeryApp extends StatelessWidget {
  const BakeryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BakeryScreen(), debugShowCheckedModeBanner: false);
  }
}

class BakeryScreen extends StatefulWidget {
  @override
  _BakeryScreenState createState() => _BakeryScreenState();
}

class _BakeryScreenState extends State<BakeryScreen> {
  final List<BakeryItem> _items = [
    BakeryItem(
      name: 'Sari Roti Roti Sari Roti',
      addedBy: 'Auryn',
      expirationDate: DateTime.now().add(const Duration(days: 12)),
    ),
    BakeryItem(
      name: 'Choco Cheese Bread',
      addedBy: 'Jessica',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
    ),
    BakeryItem(
      name: 'Selai Kacang ABC',
      addedBy: 'Jessica',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
    ),
    BakeryItem(
      name: 'Mini Banana Bread',
      addedBy: 'You',
      expirationDate: DateTime.now(),
    ),
  ];

  String _sortOption = 'Expiration (Soonest)';
  final List<String> sortOptions = [
    'Expiration (Soonest)',
    'Expiration (Latest)',
    'Name (A-Z)',
  ];

  List<BakeryItem> get sortedItems {
    final sorted = List<BakeryItem>.from(_items);
    switch (_sortOption) {
      case 'Expiration (Latest)':
        sorted.sort((a, b) => b.expirationDate.compareTo(a.expirationDate));
        break;
      case 'Name (A-Z)':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Expiration (Soonest)':
      default:
        sorted.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    }
    return sorted;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  void _showItemOptions(BuildContext context, BakeryItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => updatePage.UpdateByProduct(item: item),
                    ),
                  );
                },
                child: const Text('Update Product'),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle mark as consumed
                },
                child: const Text('Mark as Consumed'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle delete
                },
                child: const Text('Delete Product'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print("Back pressed");
          },
        ),
        title: const Text('Bakery & Bread'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Your Product',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (value) {
                    setState(() => _sortOption = value!);
                  },
                  items:
                      sortOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  final daysLeft = item.daysLeft;
                  final status =
                      daysLeft > 7
                          ? 'Fresh'
                          : daysLeft > 0
                          ? 'Exp. Soon'
                          : 'Expired';
                  final color =
                      daysLeft > 7
                          ? Colors.green
                          : daysLeft > 0
                          ? Colors.orange
                          : Colors.red;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => _showItemOptions(context, item),
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 5,
                        height: double.infinity,
                        color: color,
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('added by ${item.addedBy}'),
                          const SizedBox(height: 4),
                          Text(formatDate(item.expirationDate)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            daysLeft > 0
                                ? '$daysLeft Days Left'
                                : daysLeft == 0
                                ? 'Today'
                                : '${-daysLeft} Days Ago',
                            style: TextStyle(color: color),
                          ),
                          Text(
                            status,
                            style: TextStyle(color: color, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

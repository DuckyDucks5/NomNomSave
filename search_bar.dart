import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final String name;
  final String addedBy;
  final String status;
  final int daysLeft;

  Product(this.name, this.addedBy, this.status, this.daysLeft);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      home: CategoryListScreen(),
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  final List<String> categories = [
    'Bakery & Bread',
    'Beverages',
    'Canned & Preserved Food',
    'Dairy & Eggs',
    'Frozen Food',
    'Snacks & Sweets',
    'Spices & Condiments',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Categories')),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, __) => Divider(height: 0),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductListScreen(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  final String category;

  ProductListScreen({required this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> allProducts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    allProducts = getProducts(widget.category);
  }

  List<Product> getProducts(String category) {
    switch (category) {
      case 'Bakery & Bread':
        return [
          Product('Sari Roti Roti Sari Roti', 'Ayurn', 'Fresh', 12),
          Product('Choco Cheese Bread', 'Jessica', 'Exp. Soon', 3),
          Product('Selai Kacang ABC', 'Jessica', 'Exp. Soon', 3),
          Product('Mini Banana Bread', 'You', 'Expired', 0),
        ];
      case 'Beverages':
        return [
          Product('Coca Cola', 'Ayurn', 'Fresh', 12),
          Product('Fanta', 'Jessica', 'Exp. Soon', 3),
          Product('Susu UHT Full Cream', 'You', 'Expired', 0),
        ];
      case 'Canned & Preserved Food':
        return [
          Product('Sarden Kaleng', 'Ayurn', 'Fresh', 70),
          Product('Canned Corn', 'Jessica', 'Exp. Soon', 2),
          Product('Canned Soup', 'You', 'Expired', 0),
        ];
      case 'Dairy & Eggs':
        return [
          Product('Telur Ayam 10 Butir', 'Ayu', 'Fresh', 5),
          Product('Keju Cheddar', 'Dio', 'Exp. Soon', 2),
          Product('Yogurt Drink Strawberry', 'You', 'Expired', 0),
        ];
      case 'Frozen Food':
        return [
          Product('Nugget Ayam', 'Ayu', 'Fresh', 40),
          Product('Sosis Sapi Beku', 'Dio', 'Exp. Soon', 3),
          Product('Dimsum Udang', 'You', 'Expired', 0),
        ];
      case 'Snacks & Sweets':
        return [
          Product('Chitato Sapi Panggang', 'Ayu', 'Fresh', 10),
          Product('SilverQueen Almond', 'Dio', 'Exp. Soon', 5),
          Product('Gummy Bear', 'You', 'Expired', 0),
        ];
      case 'Spices & Condiments':
        return [
          Product('Kecap Manis ABC', 'Ayu', 'Fresh', 60),
          Product('Garam Dapur', 'Dio', 'Exp. Soon', 15),
          Product('Merica Bubuk', 'You', 'Expired', 0),
        ];
      case 'Others':
        return [
          Product('Tepung Terigu Segitiga Biru', 'Ayu', 'Fresh', 30),
          Product('Minyak Goreng', 'Dio', 'Exp. Soon', 4),
          Product('Air Mineral', 'You', 'Expired', 0),
        ];
      default:
        return [Product('Unknown Item', 'System', 'Fresh', 99)];
    }
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) return allProducts;
    return allProducts
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Fresh':
        return Colors.green;
      case 'Exp. Soon':
        return Colors.orange;
      case 'Expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      getStatusColor(product.status).value,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.daysLeft == 0
                        ? 'Today'
                        : '${product.daysLeft} Days Left',
                    style: TextStyle(
                      color: getStatusColor(product.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  product.status,
                  style: TextStyle(
                    color: getStatusColor(product.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text('added by ${product.addedBy}'),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '20 Mei 2025',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category), leading: BackButton()),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Your Product',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (_, index) {
                return buildProductCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
